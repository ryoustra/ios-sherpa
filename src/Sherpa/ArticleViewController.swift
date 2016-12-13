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
	
	init(document: Document, article: Article) {
		self.article = article
		
		super.init(document: document)
		
		self.dataSource.sectionTitle = NSLocalizedString("Related", comment: "Title for table view section containing one or more related articles.")
		self.dataSource.filter = { (article: Article) -> Bool in return article.key != nil && self.article.relatedKeys.contains(article.key!)  }
		
		self.allowSearch = false
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: View life cycle
	
	internal let contentView: UIView! = UIView()
	
	internal let titleLabel: UILabel! = UILabel()
	
	internal let bodyView: UITextView! = UITextView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.title = nil
		
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
		
		self.titleLabel.text = self.article.title
		
		self.bodyView.backgroundColor = UIColor.clearColor()
		self.bodyView.editable = false
		self.bodyView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
		self.bodyView.textColor = self.dataSource.document.articleTextColor
		self.bodyView.tintColor = self.dataSource.document.tintColor
		self.bodyView.translatesAutoresizingMaskIntoConstraints = false
		self.bodyView.textContainer.lineFragmentPadding = 0
		self.bodyView.textContainerInset = UIEdgeInsetsZero
		self.contentView.addSubview(self.bodyView)
		
		self.bodyView.attributedText = self._applyAttributes(toString: self.article.body)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		self.navigationController?.setNavigationBarHidden(false, animated: false)
	}
	
	override func viewDidLayoutSubviews() {
		let header = self.contentView
		if header.superview == nil || CGRectGetWidth(header.frame) != CGRectGetWidth(header.superview!.frame) {
			let margins = self.tableView.layoutMargins
			let width = CGRectGetWidth(self.tableView.frame)
			
			let maxSize = CGSize(width: width - margins.left - margins.right, height: CGFloat.max)
			let titleSize = self.titleLabel.sizeThatFits(maxSize)
			let bodySize = self.bodyView.sizeThatFits(maxSize)
			
			self.titleLabel.frame = CGRect(x: margins.left, y: 30, width: maxSize.width, height: titleSize.height)
			self.bodyView.frame = CGRect(x: margins.left, y: CGRectGetMaxY(self.titleLabel.frame) + 15, width: maxSize.width, height: bodySize.height)
			header.frame = CGRect(x: 0, y: 0, width: width, height: CGRectGetMaxY(self.bodyView.frame))
			
			self.tableView.tableHeaderView = header
		}
	}
	
	@_semantics("optimize.sil.never")
	private func _applyAttributes(toString string: String?) -> NSAttributedString? {
		guard let string = string else {
			return nil
		}
		
		var mutable = string
		
		while let range = mutable.rangeOfString("\n") {
			mutable.replaceRange(range, with: "<br />")
		}
		
		guard let data = mutable.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false) else {
			return nil
		}
		
		do {
			let attributedText = try NSMutableAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
			
			attributedText.beginEditing()
			attributedText.enumerateAttributesInRange(NSMakeRange(0,attributedText.length), options: [], usingBlock: { attributes, range, stop in
				var mutable = attributes
				
				if let font = mutable[NSFontAttributeName] as? UIFont {
					let symbolicTraits = font.fontDescriptor().symbolicTraits
					let descriptor = self.bodyView.font!.fontDescriptor().fontDescriptorWithSymbolicTraits(symbolicTraits)
					
					if font.familyName == "Times New Roman" {
						mutable[NSFontAttributeName] = UIFont(descriptor: descriptor!, size: self.bodyView.font!.pointSize)
					}
						
					else {
						mutable[NSFontAttributeName] = font.fontWithSize(self.bodyView.font!.pointSize)
					}
				}
				
				
				if mutable[NSLinkAttributeName] != nil {
					mutable[NSForegroundColorAttributeName] = self.bodyView.tintColor
					mutable[NSStrokeColorAttributeName] = self.bodyView.tintColor
				}
					
				else {
					mutable[NSForegroundColorAttributeName] = self.bodyView.textColor
				}
				
				attributedText.setAttributes(mutable, range: range)
			})
			attributedText.endEditing()
			
			return attributedText
		}
			
		catch {
			return nil
		}
	}
	
}
