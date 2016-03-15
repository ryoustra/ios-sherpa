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

internal class SherpaDataSource: NSObject, UITableViewDataSource {

	private let _fileURL: NSURL

	internal init( fileAtURL fileURL: NSURL ) {
		_fileURL = fileURL

		super.init()

		self._loadFromFile()
	}

	// MARK: Retrieving content

	internal func section(index: Int) -> Section? {
		if index < 0 || index >= self.sections.count { return nil }

		return self.sections[index]
	}

	internal func article(indexPath: NSIndexPath) -> Article? {
		let articles: [Article]
		if let filtered = self.articles {
			articles = indexPath.section == 0 ? filtered : []
		}

		else {
			articles = self.section(indexPath.section)?.articles ?? []
		}

		if indexPath.row < 0 || indexPath.row >= articles.count { return nil }

		return articles[indexPath.row]
	}

	internal func article(key: String) -> Article? {
		return self.sections.flatMap({ $0.articles }).filter({ key == $0.key }).first
	}

	// MARK: Table view data source

	private var articles: [Article]?

	internal var sections: [Section] = []

	private var filteredSections: [Section] = []

	internal var query: String? {
		didSet {
			if let query = self.query {
				self.filter = { (article: Article) in return article.matches(query) }
			}
			else {
				self.filter = nil
			}
		}
	}

	internal var filter: ((Article) -> Bool)?

	internal var flattenSections: Bool = false

	@objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if self.flattenSections, let filter = self.filter {
			let articles = self.sections.flatMap({ $0.articles }).filter(filter)
			self.filteredSections = [ Section(title: nil, detail: nil, articles: articles) ]
		}
		else if let filter = self.filter {
			self.filteredSections = self.sections.map({ $0.section(filter) }).flatMap({ $0 })
		}
		else {
			self.filteredSections = self.sections
		}

		return self.filteredSections.count
	}

	@objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "_SherpaCell")

		return self.filteredSections[section].articles.count ?? 0
	}

	@objc func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return self.filteredSections[section].title
	}

	@objc func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return self.filteredSections[section].detail
	}

	@objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("_SherpaCell", forIndexPath: indexPath)

		let article = self.filteredSections[indexPath.section].articles[indexPath.row]

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

			cell.textLabel?.attributedText = attributedTitle
		}

		return cell
	}

	// MARK: Utilities

	private func _loadFromFile() {
		do {
			guard let data = NSData(contentsOfURL: _fileURL) else {
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

internal struct Section {

	let title: String?

	let detail: String?

	let articles: [Article]!

	init(dictionary: [String: AnyObject]) {
		self.title = dictionary["title"] as? String
		self.detail = dictionary["detail"] as? String
		self.articles = (dictionary["articles"] as? [[String: AnyObject]])?.map({ Article(dictionary: $0) }).flatMap({ $0 }) ?? []
	}

	private init(title: String?, detail: String?, articles: [Article]!) {
		self.title = title
		self.detail = detail
		self.articles = articles
	}

	func section(@noescape filter: (Article) -> Bool) -> Section? {
		let articles = self.articles.filter(filter)

		if articles.count == 0 { return nil }

		return Section(title: self.title, detail: self.detail, articles: articles)
	}

}

internal struct Article {

	let key: String?

	let title: String!

	let body: String!

	let buildMin: Int!

	let buildMax: Int!

	init?(dictionary: [String: AnyObject]) {
		key = dictionary["key"] as? String
		title = dictionary["title"] as? String ?? ""
		body = dictionary["body"] as? String ?? ""
		buildMin = dictionary["build_min"] as? Int ?? 0
		buildMax = dictionary["build_max"] as? Int ?? Int.max

		// Require both a title and a body
		if title.isEmpty || body.isEmpty {
			return nil
		}

		// Compare to the build number
		if let build = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as? String where Int(build) < buildMin && Int(build) > buildMax {
			return nil
		}
	}

	func matches(query: String) -> Bool {
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
