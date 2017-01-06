//
// Copyright © 2017 Daniel Farrelly
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
	] as [String : Any]
	
	func testInit() {
		XCTAssertNotNil(Sherpa.Section(dictionary: SectionTests.dictionary), "Section should successfully initialize with valid dictionary.")
		
		var minimal = SectionTests.dictionary
		minimal.removeValue(forKey: "title")
		minimal.removeValue(forKey: "details")
		XCTAssertNotNil(Sherpa.Section(dictionary: minimal), "Section should successfully initialize with only articles.")
	}
	
	func testTitle() {
		var dictionary = SectionTests.dictionary
		
		dictionary["title"] = "Section Title"
		let validTitle = Sherpa.Section(dictionary: dictionary)
		XCTAssertNotNil(validTitle, "Section should successfully init from dictionary with a valid 'title' value.")
		if let section = validTitle {
			XCTAssertEqual(section.title, "Section Title", "Section title should match the 'title' value in the provided dictionary.")
		}
		
		dictionary["title"] = ""
		let emptyTitle = Sherpa.Section(dictionary: dictionary)
		XCTAssertNotNil(emptyTitle, "Section should successfully init from dictionary with an empty 'title' value.")
		if let section = emptyTitle {
			XCTAssertNil(section.title, "Section should translate an empty 'title' value to nil.")
		}
		
		dictionary["title"] = [23]
		let titleAsInvalidType = Sherpa.Section(dictionary: dictionary)
		XCTAssertNotNil(titleAsInvalidType, "Section should successfully init from dictionary with an invalid 'title' value.")
		if let section = titleAsInvalidType {
			XCTAssertNil(section.title, "Section should translate an invalid 'title' value to nil.")
		}
		
		dictionary.removeValue(forKey: "title")
		let missingTitle = Sherpa.Section(dictionary: dictionary)
		XCTAssertNotNil(missingTitle, "Section should successfully init from dictionary without a 'title' value.")
		if let section = missingTitle {
			XCTAssertNil(section.title, "Section title should match the 'title' value in the provided dictionary.")
		}
	}
	
	func testDetail() {
		var dictionary = SectionTests.dictionary
		
		dictionary["detail"] = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc lacinia, nibh in rutrum placerat, augue risus convallis enim, eget elementum metus odio ut arcu. Phasellus ultricies sollicitudin arcu, at lacinia sem convallis sit amet. Suspendisse ac mauris elementum, eleifend est in, placerat urna. Donec elementum dignissim elit sed tempor."
		let validDetail = Sherpa.Section(dictionary: dictionary)
		XCTAssertNotNil(validDetail, "Section should successfully init from dictionary with a valid 'detail' value.")
		if let section = validDetail {
			XCTAssertEqual(section.detail, dictionary["detail"] as! String, "Section detail should match the 'detail' value in the provided dictionary.")
		}
		
		dictionary["detail"] = ""
		let emptyDetail = Sherpa.Section(dictionary: dictionary)
		XCTAssertNotNil(emptyDetail, "Section should successfully init from dictionary with an empty 'detail' value.")
		if let section = emptyDetail {
			XCTAssertNil(section.detail, "Section should translate an empty 'detail' value to nil.")
		}
		
		dictionary["detail"] = [23]
		let detailAsInvalidType = Sherpa.Section(dictionary: dictionary)
		XCTAssertNotNil(detailAsInvalidType, "Section should successfully init from dictionary with an invalid 'detail' value.")
		if let section = detailAsInvalidType {
			XCTAssertNil(section.detail, "Section should translate an invalid 'detail' value to nil.")
		}
		
		dictionary.removeValue(forKey: "detail")
		let missingDetail = Sherpa.Section(dictionary: dictionary)
		XCTAssertNotNil(missingDetail, "Section should successfully init from dictionary without a 'detail' value.")
		if let section = missingDetail {
			XCTAssertNil(section.detail, "Section detail should match the 'detail' value in the provided dictionary.")
		}
	}
	
	func testSectionByFilteringArticles() {
		if let section = Sherpa.Section(dictionary: SectionTests.dictionary) {
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
	}
	
	func testSectionMatchingQuery() {
		if let section = Sherpa.Section(dictionary: SectionTests.dictionary) {
			let empty = section.section("")
			XCTAssertNotNil(empty, "An empty query should always return a section.")
			
			if let empty = empty {
				XCTAssertEqual(empty.title, section.title, "An empty query should always return section with same title.")
				XCTAssertEqual(empty.detail, section.detail, "An empty query should always return section with same detail text.")
				XCTAssertEqual(empty.articles.count, section.articles.count, "An empty query should always return all articles.")
				XCTAssertEqual(empty.articles[0].title, section.articles[0].title, "An empty query should always return section containing the same articles.")
				XCTAssertEqual(empty.articles[1].title, section.articles[1].title, "An empty query should always return section containing the same articles.")
			}
			
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
	
}
