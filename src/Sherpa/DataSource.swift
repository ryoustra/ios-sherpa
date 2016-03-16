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

internal class DataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

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

	// MARK: Table view data source

	@objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return self.filteredSections.count
	}

	@objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "_SherpaCell")

		return self.section(section)?.articles.count ?? 0
	}

	@objc func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return self.section(section)?.title
	}

	@objc func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return self.section(section)?.detail
	}

	@objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("_SherpaCell", forIndexPath: indexPath)

		guard let article = self.article(indexPath) else { return cell }

		cell.accessoryType = .DisclosureIndicator
		cell.textLabel!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCallout)
		cell.textLabel!.numberOfLines = 0
		cell.textLabel!.text = article.title

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

		return cell
	}

	// MARK: Table view delegate

	func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 44
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		guard let article = self.article(indexPath) else {
			return
		}

		self.document.didSelect(article)
	}

	func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		if cell.accessoryType != .None {
			cell.textLabel!.textColor = self.document.tintColor
		}
	}

}
