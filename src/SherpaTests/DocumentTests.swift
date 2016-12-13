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

import XCTest
@testable import Sherpa

class DocumentTests: XCTestCase {
	
	static let dictionary: [String:AnyObject] = {
		let url = NSBundle(forClass: DocumentTests.self).URLForResource("dictionary", withExtension: "json")!
		let data = NSData(contentsOfURL: url)!
		return try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as! [String:AnyObject]
	}()
	
	static let array: [[String:AnyObject]] = {
		let url = NSBundle(forClass: DocumentTests.self).URLForResource("array", withExtension: "json")!
		let data = NSData(contentsOfURL: url)!
		return try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as! [[String:AnyObject]]
	}()
	
	func testFeedbackEmail() {
		var dictionary = DocumentTests.dictionary
		
		dictionary["feedback_email"] = "support@jellystyle.com"
		let validEmail = Sherpa.Document(dictionary: dictionary)
		XCTAssertEqual(validEmail.feedbackEmail, dictionary["feedback_email"] as? String, "Feedback email should match the 'feedback_email' value in the provided dictionary.")
		
		dictionary["feedback_email"] = "JellyStyle Support <support@jellystyle.com>"
		let validEmailWithName = Sherpa.Document(dictionary: dictionary)
		XCTAssertEqual(validEmailWithName.feedbackEmail, dictionary["feedback_email"] as? String, "Feedback email should match the 'feedback_email' value in the provided dictionary.")
		
		dictionary["feedback_email"] = "JellyStyle Support"
		let emailAsInvalidString = Sherpa.Document(dictionary: dictionary)
		XCTAssertNil(emailAsInvalidString.feedbackEmail, "Document should translate an invalid 'feedback_email' string to nil.")
		
		dictionary["feedback_email"] = ""
		let emptyEmail = Sherpa.Document(dictionary: dictionary)
		XCTAssertNil(emptyEmail.feedbackEmail, "Document should translate an empty 'feedback_email' value to nil.")
		
		dictionary["feedback_email"] = [23]
		let emailAsInvalidType = Sherpa.Document(dictionary: dictionary)
		XCTAssertNil(emailAsInvalidType.feedbackEmail, "Document should translate an invalid 'title' value to nil.")
		
		dictionary.removeValueForKey("feedback_email")
		let missingEmail = Sherpa.Document(dictionary: dictionary)
		XCTAssertNil(missingEmail.feedbackEmail, "Feedback email should match the 'feedback_email' value in the provided dictionary.")
	}
	
	func testFeedbackTwitter() {
		var dictionary = DocumentTests.dictionary
		
		dictionary["feedback_twitter"] = "jellybeansoup"
		let validTwitter = Sherpa.Document(dictionary: dictionary)
		XCTAssertEqual(validTwitter.feedbackTwitter, dictionary["feedback_twitter"] as? String, "Feedback Twitter account should match the 'feedback_twitter' value in the provided dictionary.")
		
		dictionary["feedback_twitter"] = "@jellybeansoup"
		let validTwitterWithAt = Sherpa.Document(dictionary: dictionary)
		XCTAssertEqual(validTwitterWithAt.feedbackTwitter, "jellybeansoup", "Feedback Twitter account should match the 'feedback_twitter' value in the provided dictionary.")
		
		dictionary["feedback_twitter"] = "＠jellybeansoup"
		let validTwitterWithAlternateAt = Sherpa.Document(dictionary: dictionary)
		XCTAssertEqual(validTwitterWithAlternateAt.feedbackTwitter, "jellybeansoup", "Feedback Twitter account should match the 'feedback_twitter' value in the provided dictionary.")
		
		dictionary["feedback_twitter"] = "Daniel Farrelly"
		let twitterAsInvalidString = Sherpa.Document(dictionary: dictionary)
		XCTAssertNil(twitterAsInvalidString.feedbackTwitter, "Document should translate an invalid 'feedback_twitter' string to nil.")
		
		dictionary["feedback_twitter"] = ""
		let emptyTwitter = Sherpa.Document(dictionary: dictionary)
		XCTAssertNil(emptyTwitter.feedbackTwitter, "Document should translate an empty 'feedback_twitter' value to nil.")
		
		dictionary["feedback_twitter"] = [23]
		let twitterAsInvalidType = Sherpa.Document(dictionary: dictionary)
		XCTAssertNil(twitterAsInvalidType.feedbackTwitter, "Document should translate an invalid 'feedback_twitter' value to nil.")
		
		dictionary.removeValueForKey("feedback_twitter")
		let missingTwitter = Sherpa.Document(dictionary: dictionary)
		XCTAssertNil(missingTwitter.feedbackTwitter, "Feedback Twitter account should match the 'feedback_twitter' value in the provided dictionary.")
	}
	
	func testSectionsFromFiles() {
		let bundle = NSBundle(forClass: DocumentTests.self)
		
		let fileURLs: [(url: NSURL, shouldBeValid: Bool)] = [
			(bundle.URLForResource("dictionary", withExtension: "json")!, true),
			(bundle.URLForResource("array", withExtension: "json")!, true),
			(bundle.URLForResource("invalid", withExtension: "json")!, false),
			(bundle.resourceURL!.URLByAppendingPathComponent("missing.json")!, false),
			]
		
		for (url, shouldBeValid) in fileURLs {
			let entries = DocumentTests.dictionary["entries"] as! [[String: AnyObject]]
			let document = Sherpa.Document(fileAtURL: url)
			
			if shouldBeValid {
				XCTAssertEqual(document.sections.count, entries.count - 1, "Number of sections in the document should reflect the number found in the file, minus any empty sections.")
				XCTAssertEqual(document.sections[0].title, entries[0]["title"] as? String, "Sections in the document should match those found in the file, minus any empty sections.")
				XCTAssertEqual(document.sections[1].title, entries[2]["title"] as? String, "Sections in the document should match those found in the file, minus any empty sections.")
			}
			else {
				XCTAssertEqual(document.sections.count, 0, "\(url); Number of sections in the document should be zero if the JSON file does not match the required structure.")
			}
		}
	}
	
	func testSectionsFromDictionary() {
		var dictionary = DocumentTests.dictionary
		var entries = DocumentTests.array
		
		dictionary["entries"] = entries
		let validEntries = Sherpa.Document(dictionary: dictionary)
		XCTAssertEqual(validEntries.sections.count, entries.count - 1, "Number of sections in the document should reflect the number found in the dictionary, minus any empty sections.")
		XCTAssertEqual(validEntries.sections[0].title, entries[0]["title"] as? String, "Sections in the document should match those found in the dictionary, minus any empty sections.")
		XCTAssertEqual(validEntries.sections[1].title, entries[2]["title"] as? String, "Sections in the document should match those found in the dictionary, minus any empty sections.")
		
		dictionary["entries"] = []
		let entriesAsEmptyArray = Sherpa.Document(dictionary: dictionary)
		XCTAssertEqual(entriesAsEmptyArray.sections.count, 0, "Number of sections in the document should reflect the number found in the dictionary, minus any empty sections.")
		
		dictionary["entries"] = ArticleTests.dictionary
		let entriesAsArticleDictionary = Sherpa.Document(dictionary: dictionary)
		XCTAssertEqual(entriesAsArticleDictionary.sections.count, 0, "Number of sections in the document should be zero if the JSON file does not match the required structure.")
		
		dictionary["entries"] = [23]
		let entriesAsInvalidType = Sherpa.Document(dictionary: dictionary)
		XCTAssertEqual(entriesAsInvalidType.sections.count, 0, "Number of sections in the document should be zero if the JSON file does not match the required structure.")
		
		dictionary.removeValueForKey("entries")
		let missingEntries = Sherpa.Document(dictionary: dictionary)
		XCTAssertEqual(missingEntries.sections.count, 0, "Number of sections in the document should be zero if the JSON file does not match the required structure.")
	}
	
	func testSectionsFromArray() {
		let document = Sherpa.Document(array: DocumentTests.array)
		let entries = DocumentTests.array
		
		XCTAssertEqual(document.sections.count, entries.count - 1, "Number of sections in the document should reflect the number found in the array, minus any empty sections.")
		XCTAssertEqual(document.sections[0].title, entries[0]["title"] as? String, "Sections in the document should match those found in the array, minus any empty sections.")
		XCTAssertEqual(document.sections[1].title, entries[2]["title"] as? String, "Sections in the document should match those found in the array, minus any empty sections.")
	}
	
	func testSectionAtIndex() {
		let document = Sherpa.Document(array: DocumentTests.array)
		
		XCTAssertNil(document.section(-1), "Nil should be returned when attempting to retrieve section with out-of-bounds index.")
		XCTAssertNil(document.section(100), "Nil should be returned when attempting to retrieve section with out-of-bounds index.")
		XCTAssertEqual(document.section(1)?.title, document.sections[1].title, "Section retrieved by index should be the same as when accessing via sections array.")
	}
	
	func testArticleWithKey() {
		let document = Sherpa.Document(array: DocumentTests.array)
		
		XCTAssertNil(document.article("invalid-key"), "Nil should be returned when attempting to retrieve article with a key that doesn't exist.")
		XCTAssertEqual(document.article("article-key")?.title, document.sections[0].articles[1].title, "Section retrieved by key should be the first matching when accessing via indices.")
	}
	
	func testDelegate() {
		let document = Sherpa.Document(array: DocumentTests.array)
		let delegate = DocumentTestDelegate()
		
		document.delegate = delegate
		
		let article = document.sections[0].articles[0]
		document.didSelect(article)
		XCTAssertNotNil(delegate.document, "Document provided to delegate should match the calling document.")
		XCTAssertNotNil(delegate.article, "Article provided to the delegate should match the one provided to `didSelect`.")
		XCTAssertNil(delegate.viewController, "View controller should not be present after call to `didSelect`.")
		
		let viewController = UIViewController()
		document.shouldPresent(viewController)
		XCTAssertNotNil(delegate.document, "Document provided to delegate should match the calling document.")
		XCTAssertNotNil(delegate.viewController, "View controller provided to the delegate should match the one provided to `shouldPresent`.")
		XCTAssertNil(delegate.article, "Article should not be present after call to `shouldPresent`.")
	}
	
	private class DocumentTestDelegate: DocumentDelegate {
		
		var document: Document? = nil
		
		var article: Article? = nil
		
		var viewController: UIViewController? = nil
		
		func document(document: Document, didSelectArticle article: Article) {
			self.reset()
			self.document = document
			self.article = article
		}
		
		func document(document: Document, didSelectViewController viewController: UIViewController) {
			self.reset()
			self.document = document
			self.viewController = viewController
		}
		
		func reset() {
			self.document = nil
			self.article = nil
			self.viewController = nil
		}
		
	}
	
}
