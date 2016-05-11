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
import MessageUI
import Social
import SafariServices

internal class DataSource: NSObject, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {

	// MARK: Instance life cycle

	internal var document: Document!

	internal init(document: Document!) {
		self.document = document
		super.init()
		self.applyFilter()
	}

	private var sections: [Section]! {
		get { return self.document.sections }
	}

	// MARK: Altering the visible data

	internal var sectionTitle: String? {
		didSet{ self.applyFilter() }
	}

	internal var query: String? {
		didSet{ self.applyFilter() }
	}

	internal var filter: ((Article) -> Bool)? {
		didSet{ self.applyFilter() }
	}

	private var filteredSections: [Section] = []

	private func applyFilter() {
		var sections = self.sections

		if let query = self.query {
			sections = sections.map({ $0.section(query) }).flatMap({ $0 })
		}

		if let filter = self.filter {
			sections = sections.map({ $0.section(filter) }).flatMap({ $0 })
		}

		if let sectionTitle = self.sectionTitle {
			let articles = sections.flatMap({ $0.articles }).flatMap({ $0 })
			let title: String? = articles.count > 0 ? sectionTitle : nil
			sections = [ Section(title: title, detail: nil, articles: articles) ]
		}

		self.filteredSections = sections
	}

	// MARK: Accessing data

	internal func section(index: Int) -> Section? {
		if index < 0 || index >= self.filteredSections.count { return nil }

		return self.filteredSections[index]
	}

	internal func article(indexPath: NSIndexPath) -> Article? {
		guard let section = self.section(indexPath.section) else { return nil }

		if indexPath.row < 0 || indexPath.row >= section.articles.count { return nil }

		return section.articles[indexPath.row]
	}

	internal func indexPath(article: Article) -> NSIndexPath? {
		for (x, s) in self.filteredSections.enumerate() {
			for (y, a) in s.articles.enumerate() {
				if a.key == article.key && a.title == article.title && a.body == article.body {
					return NSIndexPath(forRow: y, inSection: x)
				}
			}
		}

		return nil
	}

	// MARK: Feedback

	private var allowFeedback: Bool {
		get{ return self.sectionTitle == nil && self.feedbackKeys.count > 0 }
	}

	private var indexOfFeedbackSection: Int? {
		get{ return self.allowFeedback ? self.filteredSections.count : nil }
	}

	private var feedbackKeys: [String] = []

	private func generateFeedbackSection() {
		var feedbackKeys: [String] = []

		if self.document.feedbackEmail != nil {
			feedbackKeys.append("__email")
		}

		if self.document.feedbackTwitter != nil {
			feedbackKeys.append("__twitter")
		}

		self.feedbackKeys = feedbackKeys
	}

	// MARK: Table view data source

	@objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		self.generateFeedbackSection()

		if self.allowFeedback {
			return self.filteredSections.count + 1
		}

		return self.filteredSections.count
	}

	@objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == self.indexOfFeedbackSection {
			return self.feedbackKeys.count
		}

		return self.section(section)?.articles.count ?? 0
	}

	@objc func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == self.indexOfFeedbackSection {
			return "Feedback"
		}

		return self.section(section)?.title
	}

	@objc func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		if section == self.indexOfFeedbackSection {
			return nil
		}

		return self.section(section)?.detail
	}

	@objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell: UITableViewCell

		if indexPath.section == self.indexOfFeedbackSection {
			let reuseIdentifier = "_SherpaFeedbackCell";
			cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) ?? self.document.feedbackCellClass.init(style: .Value1, reuseIdentifier: reuseIdentifier)

			let key = self.feedbackKeys[indexPath.row]
			if key == "__email" {
				var email = self.document.feedbackEmail!

				do {
					let regex = try NSRegularExpression(pattern: "<([^>]+)>", options: [])
					if let match = regex.firstMatchInString(email, options: [], range: NSMakeRange(0,email.characters.count)) {
						email = (email as NSString).substringWithRange(match.rangeAtIndex(1))
					}
				}
				catch {}

				cell.textLabel!.text = NSLocalizedString("Email", comment: "Label for email feedback button.")
				cell.detailTextLabel!.text = email

				if MFMailComposeViewController.canSendMail() {
					if self.document.feedbackCellClass === UITableViewCell.self {
						cell.textLabel!.textColor = self.document.tintColor
					}
				}
				else {
					cell.selectionStyle = .None
				}
			}

			else if key == "__twitter" {
				cell.textLabel!.text = NSLocalizedString("Twitter", comment: "Label for Twitter feedback button.")
				cell.detailTextLabel!.text = "@\(self.document.feedbackTwitter!)".stringByReplacingOccurrencesOfString("@@", withString: "@")

				if #available(iOSApplicationExtension 9.0, *) {
					if self.document.feedbackCellClass === UITableViewCell.self {
						cell.textLabel!.textColor = self.document.tintColor
					}
				}
				else {
					cell.selectionStyle = .None
				}
			}
		}

		else {
			let reuseIdentifier = "_SherpaArticleCell";
			cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) ?? self.document.articleCellClass.init(style: .Default, reuseIdentifier: reuseIdentifier)

			guard let article = self.article(indexPath) else { return cell }

			cell.accessoryType = .DisclosureIndicator
			cell.textLabel!.text = article.title
			cell.textLabel!.numberOfLines = 0

			if self.document.articleCellClass === UITableViewCell.self {
				if #available(iOSApplicationExtension 9.0, *) {
					cell.textLabel!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCallout)
				} else {
					cell.textLabel!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
				}
				cell.textLabel!.textColor = self.document.tintColor
			}

			if let query = self.query {
				let attributedTitle = cell.textLabel?.attributedText as! NSMutableAttributedString

				let bold = cell.textLabel!.font.fontDescriptor().fontDescriptorWithSymbolicTraits(.TraitBold)

				var i = 0
				while true {
					let searchRange = NSMakeRange(i, article.title.characters.count-i)
					let range = (article.title as NSString).rangeOfString(query, options: .CaseInsensitiveSearch, range: searchRange, locale: NSLocale.currentLocale())

					if range.location == NSNotFound { break }

					attributedTitle.addAttribute(NSFontAttributeName, value: UIFont(descriptor: bold, size: 0.0), range: range)

					i = range.location + range.length
				}

				cell.textLabel!.attributedText = attributedTitle
			}
		}

		return cell
	}

	// MARK: Table view delegate

	func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 44
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if indexPath.section == self.indexOfFeedbackSection {
			let key = self.feedbackKeys[indexPath.row]

			if key == "__email" && MFMailComposeViewController.canSendMail() {
				let bundle = NSBundle.mainBundle()
				let name = bundle.objectForInfoDictionaryKey("CFBundleDisplayName") ?? bundle.objectForInfoDictionaryKey("CFBundleName") ?? ""
				let version = bundle.objectForInfoDictionaryKey("CFBundleShortVersionString") ?? ""
				let build = bundle.objectForInfoDictionaryKey("CFBundleVersion") ?? ""
				let subject = "Feedback for \(name!) v\(version!) (\(build!))"

				let viewController = MFMailComposeViewController()
				viewController.mailComposeDelegate = self
				viewController.setToRecipients([self.document.feedbackEmail!])
				viewController.setSubject(subject)
				self.document.shouldPresent(viewController)
			}

			else if key == "__twitter" {
				let handle = self.document.feedbackTwitter!.stringByReplacingOccurrencesOfString("@", withString: "")

				if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
					let viewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
					viewController.setInitialText("@\(handle) ")
					self.document.shouldPresent(viewController)
				}

				else if let url = NSURL(string: "https://twitter.com/\(handle)") {
					if #available(iOSApplicationExtension 9.0, *) {
						let viewController = SFSafariViewController(URL: url)
						self.document.shouldPresent(viewController)
					}
				}
			}
		}

		else if let article = self.article(indexPath) {
			self.document.didSelect(article)
		}
	}

	// MARK: Mail compose controller delegate

	func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
		controller.dismissViewControllerAnimated(true, completion: nil)
	}

}
