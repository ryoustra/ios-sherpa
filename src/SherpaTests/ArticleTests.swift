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

class ArticleTests: XCTestCase {
    
    static let dictionary = [
        "key": "example-key",
        "title": "Test Article",
        "body": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc lacinia, nibh in rutrum placerat, augue risus convallis enim, eget elementum metus odio ut arcu. Phasellus ultricies sollicitudin arcu, at lacinia sem convallis sit amet. Suspendisse ac mauris elementum, eleifend est in, placerat urna. Donec elementum dignissim elit sed tempor.",
        "build_min": 365,
        "build_max": 867,
        "related_articles": ["missing-article"]
    ]

    func testInit() {
        XCTAssertNotNil(Sherpa.Article(dictionary: ArticleTests.dictionary), "Article should successfully initialize with valid dictionary.")
        
        var minimal = ArticleTests.dictionary
        minimal.removeValueForKey("key")
        minimal.removeValueForKey("build_min")
        minimal.removeValueForKey("build_max")
        minimal.removeValueForKey("related_articles")
        XCTAssertNotNil(Sherpa.Article(dictionary: minimal), "Article should successfully initialize with title and body.")
	}
	
	func testKey() {
		var dictionary = ArticleTests.dictionary
		
		dictionary["key"] = "valid key"
		let validKey = Sherpa.Article(dictionary: dictionary)
		XCTAssertNotNil(validKey, "Article should successfully init from dictionary with a valid 'key' value.")
		if let article = validKey {
			XCTAssertEqual(article.key, dictionary["key"], "Article key should match the 'key' value in the provided dictionary.")
		}
		
		dictionary["key"] = ""
		let emptyKey = Sherpa.Article(dictionary: dictionary)
		XCTAssertNotNil(emptyKey, "Article should successfully init from dictionary with an empty 'key' value.")
		if let article = emptyKey {
			XCTAssertNil(article.key, "Article should translate an empty 'key' value to nil.")
		}
		
		dictionary["key"] = [23]
		let buildAsInvalidType = Sherpa.Article(dictionary: dictionary)
		XCTAssertNotNil(buildAsInvalidType, "Article should successfully init from dictionary with an invalid 'key' value.")
		if let article = buildAsInvalidType {
			XCTAssertNil(article.key, "Article should translate an invalid 'key' value to nil.")
		}
		
		dictionary.removeValueForKey("key")
		let missingKey = Sherpa.Article(dictionary: dictionary)
		XCTAssertNotNil(missingKey, "Article should successfully init from dictionary without a 'key' value.")
		if let article = missingKey {
			XCTAssertNil(article.key, "Minimum build should match the 'build_min' value in the provided dictionary.")
		}
	}
	
	func testTitle() {
		var dictionary = ArticleTests.dictionary

		let article = Sherpa.Article(dictionary: dictionary)
		XCTAssertNotNil(article, "Article should successfully init from dictionary with valid 'title' and 'body' values.")
		if let article = article {
			XCTAssertEqual(article.title, dictionary["title"], "Article title should match the 'title' value in the provided dictionary.")
		}
		
		dictionary["title"] = ""
		XCTAssertNil(Sherpa.Article(dictionary: dictionary), "Article should not initialize with an empty 'title' value.")
		
		dictionary["title"] = [23]
		XCTAssertNil(Sherpa.Article(dictionary: dictionary), "Article should not initialize with an invalid 'title' value.")
		
        dictionary.removeValueForKey("title")
        XCTAssertNil(Sherpa.Article(dictionary: dictionary), "Article should not initialize without a 'title' value.")
	}
	
	func testBody() {
        var dictionary = ArticleTests.dictionary

		let article = Sherpa.Article(dictionary: dictionary)
		XCTAssertNotNil(article, "Article should successfully init from dictionary with valid 'title' and 'body' values.")
		if let article = article {
			XCTAssertEqual(article.body, dictionary["body"], "Article body should match the 'body' value in the provided dictionary.")
		}

		dictionary["body"] = ""
        XCTAssertNil(Sherpa.Article(dictionary: dictionary), "Article should not initialize with an empty 'body' value.")

		dictionary["body"] = [23]
		XCTAssertNil(Sherpa.Article(dictionary: dictionary), "Article should not initialize with an invalid 'body' value.")
		
        dictionary.removeValueForKey("body")
        XCTAssertNil(Sherpa.Article(dictionary: dictionary), "Article should not initialize without a 'body' value.")
    }
	
	func testBuildMin() {
		var dictionary = ArticleTests.dictionary
		
		dictionary["build_min"] = 42
		let buildAsInt = Sherpa.Article(dictionary: dictionary)
		XCTAssertNotNil(buildAsInt, "Article should successfully init from dictionary with a integer 'build_min' value.")
		if let article = buildAsInt {
			XCTAssertEqual(article.buildMin, 42, "Minimum build should match the 'build_min' value in the provided dictionary.")
		}
		
		dictionary["build_min"] = "88"
		let buildAsString = Sherpa.Article(dictionary: dictionary)
		XCTAssertNotNil(buildAsString, "Article should successfully init from dictionary with a string 'build_min' value.")
		if let article = buildAsString {
			XCTAssertEqual(article.buildMin, 88, "Minimum build should match the 'build_min' value in the provided dictionary.")
		}

		dictionary["build_min"] = ""
		let buildAsEmptyString = Sherpa.Article(dictionary: dictionary)
		XCTAssertNotNil(buildAsEmptyString, "Article should successfully init from dictionary with a string 'build_min' value.")
		if let article = buildAsEmptyString {
			XCTAssertLessThanOrEqual(article.buildMin, 1, "An empty 'build_min' string should result in a build number matching any integer greater than zero.")
		}
		
		dictionary["build_min"] = "invalid build number"
		let buildAsInvalidString = Sherpa.Article(dictionary: dictionary)
		XCTAssertNotNil(buildAsInvalidString, "Article should successfully init from dictionary with a string 'build_min' value.")
		if let article = buildAsInvalidString {
			XCTAssertLessThanOrEqual(article.buildMin, 1, "An invalid 'build_min' string should result in a build number matching any integer greater than zero.")
		}
		
		dictionary["build_min"] = [23]
		let buildAsInvalidType = Sherpa.Article(dictionary: dictionary)
		XCTAssertNotNil(buildAsInvalidType, "Article should successfully init from dictionary with an invalid 'build_min' value.")
		if let article = buildAsInvalidType {
			XCTAssertLessThanOrEqual(article.buildMin, 1, "An invalid 'build_min' value should result in a build number matching any integer greater than zero.")
		}
		
		dictionary.removeValueForKey("build_min")
		let missingBuild = Sherpa.Article(dictionary: dictionary)
		XCTAssertNotNil(missingBuild, "Article should successfully init from dictionary without a 'build_min' value.")
		if let article = missingBuild {
			XCTAssertLessThanOrEqual(article.buildMin, 1, "A missing 'build_min' value should result in a build number matching any integer greater than zero.")
		}
	}
	
	func testBuildMax() {
		var dictionary = ArticleTests.dictionary
		
		dictionary["build_max"] = 42
		let buildAsInt = Sherpa.Article(dictionary: dictionary)
		XCTAssertNotNil(buildAsInt, "Article should successfully init from dictionary with a integer 'build_max' value.")
		if let article = buildAsInt {
			XCTAssertEqual(article.buildMax, 42, "Minimum build should match the 'build_max' value in the provided dictionary.")
		}

		dictionary["build_max"] = "88"
		let buildAsString = Sherpa.Article(dictionary: dictionary)
		XCTAssertNotNil(buildAsString, "Article should successfully init from dictionary with a string 'build_max' value.")
		if let article = buildAsString {
			XCTAssertEqual(article.buildMax, 88, "Minimum build should match the 'build_max' value in the provided dictionary.")
		}

		dictionary["build_max"] = ""
		let buildAsEmptyString = Sherpa.Article(dictionary: dictionary)
		XCTAssertNotNil(buildAsEmptyString, "Article should successfully init from dictionary with a string 'build_max' value.")
		if let article = buildAsEmptyString {
			XCTAssertGreaterThanOrEqual(article.buildMax, Int.max, "An empty 'build_max' string should result in a build number matching any integer less than Int.max.")
		}
		
		dictionary["build_max"] = "invalid build number"
		let buildAsInvalidString = Sherpa.Article(dictionary: dictionary)
		XCTAssertNotNil(buildAsInvalidString, "Article should successfully init from dictionary with a string 'build_max' value.")
		if let article = buildAsInvalidString {
			XCTAssertGreaterThanOrEqual(article.buildMax, Int.max, "An invalid 'build_max' string should result in a build number matching any integer less than Int.max.")
		}
		
		dictionary["build_max"] = [23]
		let buildAsInvalidType = Sherpa.Article(dictionary: dictionary)
		XCTAssertNotNil(buildAsInvalidType, "Article should successfully init from dictionary with an invalid 'build_max' value.")
		if let article = buildAsInvalidType {
			XCTAssertGreaterThanOrEqual(article.buildMax, Int.max, "An invalid 'build_max' value should result in a build number matching any integer less than Int.max.")
		}
		
		dictionary.removeValueForKey("build_max")
		let missingBuild = Sherpa.Article(dictionary: dictionary)
		XCTAssertNotNil(missingBuild, "Article should successfully init from dictionary without a 'build_max' value.")
		if let article = missingBuild {
			XCTAssertGreaterThanOrEqual(article.buildMax, Int.max, "A missing 'build_max' value should result in a build number matching any integer less than Int.max.")
		}
	}
	
	func testRelatedArticles() {
		var dictionary = ArticleTests.dictionary
		
		dictionary["related_articles"] = ["valid key"]
		let relatedAsStringArray = Sherpa.Article(dictionary: dictionary)
		XCTAssertNotNil(relatedAsStringArray, "Article should successfully init from dictionary when 'related_articles' is a string array.")
		if let article = relatedAsStringArray {
			XCTAssertEqual(article.relatedKeys, ["valid key"], "Related keys should be an array matching the 'related_articles' value in the provided dictionary.")
		}
		
		dictionary["related_articles"] = []
		let relatedAsEmptyArray = Sherpa.Article(dictionary: dictionary)
		XCTAssertNotNil(relatedAsEmptyArray, "Article should successfully init from dictionary when 'related_articles' is an empty array.")
		if let article = relatedAsEmptyArray {
			XCTAssertEqual(article.relatedKeys, [], "Related keys should be an array matching the 'related_articles' value in the provided dictionary.")
		}
		
		dictionary["related_articles"] = "valid key"
		let relatedAsString = Sherpa.Article(dictionary: dictionary)
		XCTAssertNotNil(relatedAsString, "Article should successfully init from dictionary when 'related_articles' is a string.")
		if let article = relatedAsString {
			XCTAssertEqual(article.relatedKeys, ["valid key"], "Related keys should be an array containing the 'related_articles' string from the provided dictionary.")
		}
		
		dictionary["related_articles"] = ""
		let relatedAsEmptyString = Sherpa.Article(dictionary: dictionary)
		XCTAssertNotNil(relatedAsEmptyString, "Article should successfully init from dictionary when 'related_articles' is an empty string.")
		if let article = relatedAsEmptyString {
			XCTAssertEqual(article.relatedKeys, [], "Related keys should be an empty array if the 'related_articles' value in the provided dictionary is an empty string.")
		}
		
		dictionary["related_articles"] = [23]
		let relatedAsInvalidType = Sherpa.Article(dictionary: dictionary)
		XCTAssertNotNil(relatedAsInvalidType, "Article should successfully init from dictionary when 'related_articles' is an invalid type.")
		if let article = relatedAsInvalidType {
			XCTAssertEqual(article.relatedKeys, [], "Related keys should be an empty array if the 'related_articles' value in the provided dictionary is invalid.")
		}

		dictionary.removeValueForKey("related_articles")
		let missingRelated = Sherpa.Article(dictionary: dictionary)
		XCTAssertNotNil(missingRelated, "Article should successfully init from dictionary when 'related_articles' is missing.")
		if let article = missingRelated {
			XCTAssertEqual(article.relatedKeys, [], "Related keys should be an empty array if the 'related_articles' value in the provided dictionary is missing.")
		}
	}
	
    func testMatchesQuery() {
        if let article = Sherpa.Article(dictionary: ArticleTests.dictionary) {
			XCTAssertTrue(article.matches(""), "Article should always match an empty query.")
			XCTAssertTrue(article.matches("Est"), "Article should match query when (case-insensitively) found in both title and body.")
			XCTAssertTrue(article.matches("artic"), "Article should match query when (case-insensitively) found only in title.")
			XCTAssertTrue(article.matches("PENDI"), "Article should match query when (case-insensitively) found only in body.")
			XCTAssertFalse(article.matches("Example"), "Article should NOT match query when not (case-insensitively) found in the title or body.")
        }
    }
    
    func testMatchesBuildNumber() {
        if let article = Sherpa.Article(dictionary: ArticleTests.dictionary) {
			XCTAssertTrue(article.matches(article.buildMin), "Article should match build number that is equal to its buildMin (\(article.buildMin)).")
			XCTAssertTrue(article.matches(article.buildMin), "Article should match build number that is equal to its buildMax (\(article.buildMax)).")
			XCTAssertTrue(article.matches(500), "Article should match build number (500) that is greater than its buildMin (\(article.buildMin)) and less than its buildMax (\(article.buildMax)).")
			XCTAssertFalse(article.matches(200), "Article should not match build number (200) that is less than its buildMin (\(article.buildMin)).")
			XCTAssertFalse(article.matches(900), "Article should not match build number (900) that is greater than its buildMax (\(article.buildMax)).")
        }
    }
    
}
