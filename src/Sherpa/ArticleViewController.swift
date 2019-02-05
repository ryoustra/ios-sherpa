//
// Copyright © 2019 Daniel Farrelly
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// *	Redistributions of source code must retain the above copyright notice, this list
//		of conditions and the following disclaimer.
// *	Redistributions in binary form must reproduce the above copyright notice, this
//		list of conditions and the following disclaimer in the documentation and/or
//		other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
// OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import UIKit
import SafariServices

internal class ArticleViewController: ListViewController {
	
	// MARK: Instance life cycle
	
	internal let article: Article!
	
	init(document: Document, article: Article) {
		self.article = article
		
		super.init(document: document)
		
		dataSource.sectionTitle = NSLocalizedString("Related", comment: "Title for table view section containing one or more related articles.")
		dataSource.filter = { (article: Article) -> Bool in return article.key != nil && self.article.relatedKeys.contains(article.key!)  }
		
		allowSearch = false

		bodyView.delegate = self
		bodyView.loadHTMLString(prepareHTML, baseURL: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: View life cycle
	
	internal let contentView: UIView = UIView()

	internal let bodyView: UIWebView = UIWebView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.title = nil
		
		contentView.preservesSuperviewLayoutMargins = true

		bodyView.backgroundColor = UIColor.clear
		bodyView.scrollView.isScrollEnabled = false
		bodyView.isOpaque = false
		contentView.addSubview(bodyView)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.setNavigationBarHidden(false, animated: false)
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		if contentView.superview == nil || contentView.frame.width != contentView.superview!.frame.width {
			layoutHeaderView()
		}
	}

	private func layoutHeaderView() {
		let margins = tableView.layoutMargins
		let width = tableView.frame.width

		let maxSize = CGSize(width: width - margins.left - margins.right, height: CGFloat.greatestFiniteMagnitude)
		let bodySize = bodyView.scrollView.contentSize

		bodyView.frame = CGRect(x: margins.left, y: 30, width: maxSize.width, height: bodySize.height)
		contentView.frame = CGRect(x: 0, y: 0, width: width, height: bodyView.frame.maxY)

		tableView.tableHeaderView = contentView
	}

	fileprivate var prepareHTML: String {
		let font = UIFont.preferredFont(forTextStyle: .body)
		let color = self.css(for: dataSource.document.articleTextColor)
		let weight = font.fontDescriptor.symbolicTraits.contains(.traitBold) ? "bold" : "normal"

		var css = """
		body {margin: 0;font-family: -apple-system,system-ui,sans-serif;font-size: \(font.pointSize)px;line-height: 1.4;color: \(color);font-weight: \(weight);}
		img {max-width: 100%; opacity: 1;transition: opacity 0.3s;}
		img[data-src] {opacity: 0;}
		h1, h2, h3, h4, h5, h6 {font-weight: 500;line-height: 1.2;}
		h1 {font-size: 1.6em;}
		h2 {font-size: 1.4em;}
		h3 {font-size: 1.2em;}
		h4 {font-size: 1.0em;}
		h5 {font-size: 0.8em;}
		h6 {font-size: 0.6em;}
		"""

		if let tintColor = dataSource.document.tintColor ?? view.tintColor {
			css += " a {color: \(self.css(for: tintColor));}"
		}

		if let articleCSS = dataSource.document.articleCSS {
			css += " \(articleCSS)"
		}

		var string = article.body

		var searchRange = Range(uncheckedBounds: (lower: string.startIndex, upper: string.endIndex))
		while let range = string.range(of: "(<img[^>]*)( src=\")", options: .regularExpression, range: searchRange) {
			string = string.replacingOccurrences(of: "src=\"", with: "data-src=\"", options: [], range: range)

			searchRange = Range(uncheckedBounds: (lower: range.lowerBound, upper: string.endIndex))
		}

		return """
		<html>
			<head>
				<meta charset="utf-8">
				<style type="text/css">\(css)</style>
				<style type="text/css">body {background-color: transparent !important;}</style>
			</head>
			<body><h1>\(article.title)</h1>\n\(paragraphs(for: string))</body>
			<script type="text/javascript">
				[].forEach.call(document.querySelectorAll('img[data-src]'), function(img) {
					img.setAttribute('src', img.getAttribute('data-src'));
					img.onload = function() {
						img.removeAttribute('data-src');
					};
				});
			</script>
		</html>
		"""
	}

	fileprivate func css(for color: UIColor) -> String {
		var red: CGFloat = 0
		var green: CGFloat = 0
		var blue: CGFloat = 0
		var alpha: CGFloat = 0

		color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

		return "rgba(\(Int(red * 255)), \(Int(green * 255)), \(Int(blue * 255)), \(alpha))"
	}

	fileprivate func paragraphs(for string: String) -> String {
		var string = string.trimmingCharacters(in: .whitespacesAndNewlines)

		guard string.range(of: "<(p|br)[/\\s>]", options: .regularExpression) == nil else {
			return string
		}

		while let range = string.range(of: "\n") {
			string.replaceSubrange(range, with: "<br/>")
		}

		return string
	}

}

extension ArticleViewController: UIWebViewDelegate {

	func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
		guard let url = request.url, navigationType != .other else {
			return true
		}

		guard #available(iOSApplicationExtension 11.0, *) else {
			let selector = sel_registerName("openURL:")
			var responder = self as UIResponder?
			while let r = responder, !r.responds(to: selector) {
				responder = r.next
			}
			_ = responder?.perform(selector, with: url)

			return false
		}

		let configuration = SFSafariViewController.Configuration()
		let viewController = SFSafariViewController(url: url, configuration: configuration)

		self.present(viewController, animated: true, completion: nil)

		return false
	}

	func webViewDidStartLoad(_ webView: UIWebView) {
		continuouslyUpdateHeight(for: webView)
	}

	func webViewDidFinishLoad(_ webView: UIWebView) {
		updateHeight(for: webView)
	}

	private func continuouslyUpdateHeight(for webView: UIWebView) {
		updateHeight(for: webView)

		guard webView.isLoading else {
			return
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
			self?.continuouslyUpdateHeight(for: webView)
		}
	}

	private func updateHeight(for webView: UIWebView) {
		guard let string = webView.stringByEvaluatingJavaScript(from: "document.body.scrollHeight"), let integer = Int(string) else {
			return
		}

		webView.frame.size.height = CGFloat(integer)
		layoutHeaderView()
	}

}
