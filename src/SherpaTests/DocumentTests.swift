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
    
    static let dictionary = [
        "feedback_email": "JellyStyle Support <support@jellystyle.com>",
        "feedback_twitter": "jellybeansoup",
        "entries": [
            [
                "detail": "Text that appears in the footer for the section.",
                "articles": [
                    [
                        "title": "Article 1",
                        "body": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc lacinia, nibh in rutrum placerat, augue risus convallis enim, eget elementum metus odio ut arcu. Phasellus ultricies sollicitudin arcu, at lacinia sem convallis sit amet. Suspendisse ac mauris elementum, eleifend est in, placerat urna. Donec elementum dignissim elit sed tempor.",
                        "build_min": 360,
                    ],
                    [
                        "key": "invalid-article",
                    ],
                    [
                        "key": "article-key",
                        "title": "Article 2",
                        "body": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris at rhoncus erat, in bibendum lectus. Aliquam vel turpis nec justo volutpat rhoncus. Integer venenatis, lectus sed ultrices dictum, dolor nunc scelerisque arcu, et tincidunt justo elit eu nulla. Aenean erat ante, blandit vitae elit non, posuere eleifend mi.",
                        "build_min": 401,
                    ],
                ],
            ],
            [
                "title": "Empty Section",
                "articles": [],
            ],
            [
                "title": "Section Three",
                "articles": [
                    [
                        "key": "article-key",
                        "title": "Article 3",
                        "body": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla hendrerit tortor ac velit porta, at bibendum neque imperdiet. In bibendum urna nec nisl consequat, ac eleifend lacus vehicula. Nam laoreet risus a mollis ultrices. Proin at magna eget sem interdum porta id eget eros. Nam vitae molestie orci, at ornare mauris. In hac habitasse platea dictumst.",
                    ],
                ],
            ],
        ],
    ]

    func testKeys() {
        let fromDictionary = Sherpa.Document(dictionary: DocumentTests.dictionary)
        
        XCTAssertEqual(fromDictionary.feedbackEmail, DocumentTests.dictionary["feedback_email"], "Feedback email should reflect value of 'feedback_email' when initializing document from dictionary.")
        XCTAssertEqual(fromDictionary.feedbackTwitter, DocumentTests.dictionary["feedback_twitter"], "Feedback email should reflect value of 'feedback_twitter' when initializing document from dictionary.")

        var dictionaryWithoutFeedback = DocumentTests.dictionary
        dictionaryWithoutFeedback.removeValueForKey("feedback_email")
        dictionaryWithoutFeedback.removeValueForKey("feedback_twitter")
        let fromDictionaryWithoutFeedback = Sherpa.Document(dictionary: dictionaryWithoutFeedback)

        XCTAssertNil(fromDictionaryWithoutFeedback.feedbackEmail, "Feedback email should be nil when initializing document from dictionary without a 'feedback_email' value.")
        XCTAssertNil(fromDictionaryWithoutFeedback.feedbackTwitter, "Feedback twitter should be nil when initializing document from dictionary without a 'feedback_twitter' value.")
        
        let fromArray = Sherpa.Document(array: DocumentTests.dictionary["entries"] as! [[String: AnyObject]])
        
        XCTAssertNil(fromArray.feedbackEmail, "Feedback email should be nil when initializing document from array.")
        XCTAssertNil(fromArray.feedbackTwitter, "Feedback twitter should be nil when initializing document from array.")
    }
    
    func testSectionsFromDictionary() {
        let entries = DocumentTests.dictionary["entries"] as! [[String: AnyObject]]
        let document = Sherpa.Document(dictionary: DocumentTests.dictionary)

        XCTAssertEqual(document.sections.count, entries.count - 1, "Number of sections in the document should reflect the number found in the dictionary, minus any empty sections.")
        XCTAssertEqual(document.sections[0].title, entries[0]["title"] as? String, "Sections in the document should match those found in the dictionary, minus any empty sections.")
        XCTAssertEqual(document.sections[1].title, entries[2]["title"] as? String, "Sections in the document should match those found in the dictionary, minus any empty sections.")
    }
    
    func testSectionsFromArray() {
        let entries = DocumentTests.dictionary["entries"] as! [[String: AnyObject]]
        let document = Sherpa.Document(array: entries)
        
        XCTAssertEqual(document.sections.count, entries.count - 1, "Number of sections in the document should reflect the number found in the array, minus any empty sections.")
        XCTAssertEqual(document.sections[0].title, entries[0]["title"] as? String, "Sections in the document should match those found in the array, minus any empty sections.")
        XCTAssertEqual(document.sections[1].title, entries[2]["title"] as? String, "Sections in the document should match those found in the array, minus any empty sections.")
    }
    
    func testSectionAtIndex() {
        let document = Sherpa.Document(dictionary: DocumentTests.dictionary)
        
        XCTAssertNil(document.section(-1), "Nil should be returned when attempting to retrieve section with out-of-bounds index.")
        XCTAssertNil(document.section(100), "Nil should be returned when attempting to retrieve section with out-of-bounds index.")
        XCTAssertEqual(document.section(1)?.title, document.sections[1].title, "Section retrieved by index should be the same as when accessing via sections array.")
    }

    func testArticleWithKey() {
        let document = Sherpa.Document(dictionary: DocumentTests.dictionary)
        
        XCTAssertNil(document.article("invalid-key"), "Nil should be returned when attempting to retrieve article with a key that doesn't exist.")
        XCTAssertEqual(document.article("article-key")?.title, document.sections[0].articles[1].title, "Section retrieved by key should be the first matching when accessing via indices.")
    }

    func testDelegate() {
        let document = Sherpa.Document(dictionary: DocumentTests.dictionary)
        let delegate = DocumentTestDelegate()
        
        document.delegate = delegate
        
        let article = document.sections[0].articles[0]
        document.didSelect(article)
        XCTAssertNotNil(delegate.document, "")
        XCTAssertNotNil(delegate.article, "")
        XCTAssertNil(delegate.viewController, "")

        let viewController = UIViewController()
        document.shouldPresent(viewController)
        XCTAssertNotNil(delegate.document, "")
        XCTAssertNotNil(delegate.viewController, "")
        XCTAssertNil(delegate.article, "")
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
