//
// Copyright © 2016 Daniel Farrelly
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

internal class ArticleViewController: UIViewController {

	let _article: Article!

	init( article: Article! ) {
		_article = article

		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Appearance

	internal var tintColor: UIColor! = UINavigationBar.appearance().tintColor

	internal var textColor: UIColor! = UIColor.darkTextColor()

	internal var backgroundColor: UIColor! = UIColor.whiteColor()

	// MARK: View life cycle

	internal let contentView: UIView! = UIView()

	internal let titleLabel: UILabel! = UILabel()

	internal let bodyLabel: UILabel! = UILabel()
	
	override func viewDidLoad() {
		super.viewDidLoad()

		self.view.backgroundColor = self.backgroundColor

		let scrollView = UIScrollView()
		scrollView.preservesSuperviewLayoutMargins = true
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(scrollView)

		self.contentView.preservesSuperviewLayoutMargins = true
		self.contentView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(self.contentView)

		self.titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle2)
		self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
		self.titleLabel.textColor = self.textColor
		self.titleLabel.numberOfLines = 0
		self.contentView.addSubview(self.titleLabel)

		self.bodyLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
		self.bodyLabel.translatesAutoresizingMaskIntoConstraints = false
		self.bodyLabel.textColor = self.textColor
		self.bodyLabel.numberOfLines = 0
		self.contentView.addSubview(self.bodyLabel)

		let views = [ "scroll": scrollView, "content": self.contentView, "title": self.titleLabel, "body": self.bodyLabel ]

		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(0)-[scroll]-(0)-|", options: [], metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(0)-[scroll]-(0)-|", options: [], metrics: nil, views: views))
		scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(0)-[content(==scroll)]-(0)-|", options: [], metrics: nil, views: views))
		scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(0)-[content]-(0)-|", options: [], metrics: nil, views: views))
		self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[title]-|", options: [], metrics: nil, views: views))
		self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[body]-|", options: [], metrics: nil, views: views))
		self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(20)-[title]-(30)-[body]-(20)-|", options: [], metrics: nil, views: views))

		if let title = self._article.title {
			self.titleLabel.text = title
		}

		if let body = self._article.body {
			self.bodyLabel.text = body

			var mutableBody = body

			while let range = mutableBody.rangeOfString("\n") {
				mutableBody.replaceRange(range, with: "<br />")
			}

			let fontFamily = self.bodyLabel.font.fontName
			let fontSize = Int(self.bodyLabel.font.pointSize)
			var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
			self.bodyLabel.textColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
			mutableBody = "<div style=\"font-family: '\(fontFamily)'; font-size: \(fontSize)px; color: rgb(\(Int(red*255)),\(Int(green*255)),\(Int(blue*255)))\">\(mutableBody)</div>"

			if let data = mutableBody.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true) {
				do {
					self.bodyLabel.attributedText = try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
				}
				catch {}
			}
		}
	}
	
}
