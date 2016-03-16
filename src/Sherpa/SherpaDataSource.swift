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

internal protocol DocumentDelegate {

	func document(document: Document, didSelectArticle article: Article)

}

internal class Document {

	internal var delegate: DocumentDelegate?

	// MARK: Customising appearance

	internal var tintColor: UIColor! = UINavigationBar.appearance().tintColor

	internal var articleBackgroundColor: UIColor! = UIColor.whiteColor()

	internal var articleTextColor: UIColor! = UIColor.darkTextColor()

	// MARK: Instance life cycle
	
	private let fileURL: NSURL

	private var sections: [Section] = []

	internal init( fileAtURL fileURL: NSURL ) {
		self.fileURL = fileURL
		self._loadFromFile()
	}

	// MARK: Retrieving content

	internal func section(index: Int) -> Section? {
		if index < 0 || index >= self.sections.count { return nil }

		return self.sections[index]
	}

	internal func article(key: String) -> Article? {
		return self.sections.flatMap({ $0.articles }).filter({ key == $0.key }).first
	}

	internal func dataSource() -> DataSource! {
		return DataSource(document: self)
	}

	// MARK: Utilities

	private func _didSelect(article: Article) {
		if let delegate = self.delegate {
			delegate.document(self, didSelectArticle: article)
		}
	}

	private func _loadFromFile() {
		do {
			guard let data = NSData(contentsOfURL: self.fileURL) else {
				return
			}

			let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))

			guard let array = json as? [[String:AnyObject]] else {
				return
			}

			sections = array.map({ Section(dictionary: $0) }).flatMap({ $0 }) ?? []
		}
		catch {
			return
		}
	}

}

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

		self.document._didSelect(article)
	}

	func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		if cell.accessoryType != .None {
			cell.textLabel!.textColor = self.document.tintColor
		}
	}
	
}

internal struct Section {

	let title: String?

	let detail: String?

	let articles: [Article]!

	private init(dictionary: [String: AnyObject]) {
		self.title = dictionary["title"] as? String
		self.detail = dictionary["detail"] as? String
		self.articles = (dictionary["articles"] as? [[String: AnyObject]])?.map({ Article(dictionary: $0) }).flatMap({ $0 }) ?? []
	}

	private init(title: String?, detail: String?, articles: [Article]!) {
		self.title = title
		self.detail = detail
		self.articles = articles
	}

	private func section(@noescape filter: (Article) -> Bool) -> Section? {
		let articles = self.articles.filter(filter)

		if articles.count == 0 { return nil }

		return Section(title: self.title, detail: self.detail, articles: articles)
	}

	private func section(query: String) -> Section? {
		return self.section({ return $0.matches(query) })
	}

}

internal struct Article {

	let key: String?

	let title: String!

	let body: String!

	let buildMin: Int!

	let buildMax: Int!

	let relatedKeys: [String]!

	private init?(dictionary: [String: AnyObject]) {
		self.key = dictionary["key"] as? String
		self.title = dictionary["title"] as? String ?? ""
		self.body = dictionary["body"] as? String ?? ""
		self.buildMin = dictionary["build_min"] as? Int ?? 0
		self.buildMax = dictionary["build_max"] as? Int ?? Int.max
		self.relatedKeys = dictionary["related_articles"] as? [String] ?? []

		// Require both a title and a body
		if title.isEmpty || body.isEmpty {
			return nil
		}

		// Compare to the build number
		if let build = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as? String where Int(build) < buildMin && Int(build) > buildMax {
			return nil
		}
	}

	private func matches(query: String) -> Bool {
		if query.isEmpty {
			return true
		}

		let lowercaseQuery = query.lowercaseString

		if self.title.lowercaseString.rangeOfString(lowercaseQuery) != nil {
			return true
		}

		else if self.body.lowercaseString.rangeOfString(lowercaseQuery) != nil {
			return true
		}

		return false
	}

}
