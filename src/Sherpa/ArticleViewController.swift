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

internal class ArticleViewController: ListViewController {

	// MARK: Instance life cycle

	internal let article: Article!

	init(dataSource: DataSource!, article: Article!) {
		self.article = article
		super.init(dataSource: dataSource)
		self.allowSearch = false
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: View life cycle

	internal let contentView: UIView! = UIView()

	internal let titleLabel: UILabel! = UILabel()

	internal let bodyLabel: UILabel! = UILabel()
	
	override func viewDidLoad() {
		super.viewDidLoad()

		self.navigationItem.title = nil

		self.dataSource.sectionTitle = NSLocalizedString("Related", comment: "Title for table view section containing one or more related articles.")
		self.dataSource.filter = { (article: Article) -> Bool in return article.key != nil && self.article.relatedKeys.contains(article.key!)  }

		self.contentView.preservesSuperviewLayoutMargins = true
		self.contentView.translatesAutoresizingMaskIntoConstraints = false

		if #available(iOSApplicationExtension 9.0, *) {
			self.titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle2)
		} else {
			self.titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
		}
		self.titleLabel.textColor = self.dataSource.document.articleTextColor
		self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
		self.titleLabel.numberOfLines = 0
		self.contentView.addSubview(self.titleLabel)

		if let title = self.article.title {
			self.titleLabel.text = title
		}

		self.bodyLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
		self.bodyLabel.textColor = self.dataSource.document.articleTextColor
		self.bodyLabel.translatesAutoresizingMaskIntoConstraints = false
		self.bodyLabel.numberOfLines = 0
		self.contentView.addSubview(self.bodyLabel)

		if var body = self.article.body {
			while let range = body.rangeOfString("\n") {
				body.replaceRange(range, with: "<br />")
			}

			if let data = body.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false) {
				do {
					let attributedText = try NSMutableAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
					attributedText.enumerateAttributesInRange(NSMakeRange(0,attributedText.length), options: [], usingBlock: { attributes, range, stop in
						var mutable = attributes
						let symbolicTraits = (mutable[NSFontAttributeName] as! UIFont).fontDescriptor().symbolicTraits
						let descriptor = self.bodyLabel.font.fontDescriptor().fontDescriptorWithSymbolicTraits(symbolicTraits)
						mutable[NSFontAttributeName] = UIFont(descriptor: descriptor, size: self.bodyLabel.font.pointSize)
						mutable[NSForegroundColorAttributeName] = self.bodyLabel.textColor
						attributedText.setAttributes(mutable, range: range)
					})
					self.bodyLabel.attributedText = attributedText
				}
				catch {}
			}
		}
	}

	override func viewDidLayoutSubviews() {
		let header = self.contentView
		if header.superview == nil || CGRectGetWidth(header.frame) != CGRectGetWidth(header.superview!.frame) {
			let margins = self.tableView.layoutMargins
			let width = CGRectGetWidth(self.tableView.frame)

			let maxSize = CGSize(width: width - margins.left - margins.right, height: CGFloat.max)
			let titleSize = self.titleLabel.sizeThatFits(maxSize)
			let bodySize = self.bodyLabel.sizeThatFits(maxSize)

			self.titleLabel.frame = CGRect(x: margins.left, y: 30, width: maxSize.width, height: titleSize.height)
			self.bodyLabel.frame = CGRect(x: margins.left, y: CGRectGetMaxY(self.titleLabel.frame) + 15, width: maxSize.width, height: bodySize.height)
			header.frame = CGRect(x: 0, y: 0, width: width, height: CGRectGetMaxY(self.bodyLabel.frame))

			self.tableView.tableHeaderView = header
		}
	}

}
