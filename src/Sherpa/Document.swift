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

	func document(document: Document, didSelectViewController viewController: UIViewController)

}

internal class Document {

	internal var delegate: DocumentDelegate?

	// MARK: Customising appearance

	internal var tintColor: UIColor! = UINavigationBar.appearance().tintColor

	internal var articleBackgroundColor: UIColor! = UIColor.whiteColor()

	internal var articleTextColor: UIColor! = UIColor.darkTextColor()

	internal var articleCellClass = UITableViewCell.self

	internal var feedbackCellClass = UITableViewCell.self

	// MARK: Feedback points.

	internal var feedbackEmail: String? = nil

	internal var feedbackTwitter: String? = nil
	
	// MARK: Instance life cycle

	internal let fileURL: NSURL

	internal var sections: [Section] = []

	internal init(fileAtURL fileURL: NSURL) {
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

	internal func didSelect(article: Article) {
		if let delegate = self.delegate {
			delegate.document(self, didSelectArticle: article)
		}
	}

	internal func shouldPresent(viewController: UIViewController) {
		if let delegate = self.delegate {
			delegate.document(self, didSelectViewController: viewController)
		}
	}

	private func _loadFromFile() {
		do {
			guard let data = NSData(contentsOfURL: self.fileURL) else {
				return
			}

			let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))

			if let dictionary = json as? [String:AnyObject] {
				feedbackEmail = dictionary["feedback_email"] as? String
				feedbackTwitter = dictionary["feedback_twitter"] as? String

				let entries = dictionary["entries"] as? [[String:AnyObject]] ?? []
				sections = entries.map({ Section(dictionary: $0) }).flatMap({ $0 }) ?? []
			}

			else if let array = json as? [[String:AnyObject]] {
				sections = array.map({ Section(dictionary: $0) }).flatMap({ $0 }) ?? []
			}
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

	private init(dictionary: [String: AnyObject]) {
		self.title = dictionary["title"] as? String
		self.detail = dictionary["detail"] as? String
		self.articles = (dictionary["articles"] as? [[String: AnyObject]])?.map({ Article(dictionary: $0) }).flatMap({ $0 }) ?? []
	}

	internal init(title: String?, detail: String?, articles: [Article]!) {
		self.title = title
		self.detail = detail
		self.articles = articles
	}

	internal func section(@noescape filter: (Article) -> Bool) -> Section? {
		let articles = self.articles.filter(filter)

		if articles.count == 0 { return nil }

		return Section(title: self.title, detail: self.detail, articles: articles)
	}

	internal func section(query: String) -> Section? {
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

	internal func matches(query: String) -> Bool {
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

