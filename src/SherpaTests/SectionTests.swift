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

class SectionTests: XCTestCase {
    
    static let dictionary = [
        "title": "Section Title",
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
                "title": "Article 2",
                "body": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris at rhoncus erat, in bibendum lectus. Aliquam vel turpis nec justo volutpat rhoncus. Integer venenatis, lectus sed ultrices dictum, dolor nunc scelerisque arcu, et tincidunt justo elit eu nulla. Aenean erat ante, blandit vitae elit non, posuere eleifend mi.",
                "build_min": 401,
            ]
        ]
    ]
    
    func testKeys() {
        let section = Sherpa.Section(dictionary: SectionTests.dictionary)
        
        XCTAssertEqual(section.title, SectionTests.dictionary["title"], "Section title should match the 'title' value in the provided dictionary.")
        XCTAssertEqual(section.detail, SectionTests.dictionary["detail"], "Section detail text should match the 'detail' value in the provided dictionary.")
        XCTAssertEqual(section.articles.count, 2, "Article count should match the number of articles in the provided dictionary, minus any invalid articles.")
        
        let articles = SectionTests.dictionary["articles"] as! [[String: AnyObject]]
        XCTAssertEqual(section.articles[0].title, articles[0]["title"] as? String, "Articles should match those in the provided dictionary, minus any invalid articles.")
        XCTAssertEqual(section.articles[1].title, articles[2]["title"] as? String, "Articles should match those in the provided dictionary, minus any invalid articles.")
    }
    
    func testSectionByFilteringArticles() {
        let section = Sherpa.Section(dictionary: SectionTests.dictionary)
        
        let nonMatching = section.section { return $0.key == "example-key" }
        XCTAssertNil(nonMatching, "Filter that do not match at least one article should return nil.")
        
        let matching = section.section { $0.buildMin >= 400 }
        XCTAssertNotNil(matching, "Filter that matches at least one article should not return nil.")

        if let matching = matching {
            XCTAssertEqual(matching.title, section.title, "Filter that matches at least one article should return section with same title.")
            XCTAssertEqual(matching.detail, section.detail, "Filter that matches at least one article should return section with same detail text.")
            XCTAssertEqual(matching.articles.count, 1, "Filter that matches at least one article should only contain filtered articles.")
            XCTAssertEqual(matching.articles[0].title, section.articles[1].title, "Filter that matches at least one article should only contain filtered articles.")
        }
    }
    
    func testSectionMatchingQuery() {
        let section = Sherpa.Section(dictionary: SectionTests.dictionary)
        
        let nonMatching = section.section("example")
        XCTAssertNil(nonMatching, "Filter that do not (case-insensitively) match at least one article should return nil.")
        
        let matching = section.section("Element")
        XCTAssertNotNil(matching, "Filter that (case-insensitively) matches at least one article should not return nil.")
        
        if let matching = matching {
            XCTAssertEqual(matching.title, section.title, "Filter that matches at least one article should return section with same title.")
            XCTAssertEqual(matching.detail, section.detail, "Filter that matches at least one article should return section with same detail text.")
            XCTAssertEqual(matching.articles.count, 1, "Filter that matches at least one article should only contain filtered articles.")
            XCTAssertEqual(matching.articles[0].title, section.articles[0].title, "Filter that matches at least one article should only contain filtered articles.")
        }
    }
    
}
