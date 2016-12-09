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
        
        var emptyTitle = ArticleTests.dictionary
        emptyTitle["title"] = ""
        XCTAssertNil(Sherpa.Article(dictionary: emptyTitle), "Article should not initialize with empty title value.")
        
        var missingTitle = ArticleTests.dictionary
        missingTitle.removeValueForKey("title")
        XCTAssertNil(Sherpa.Article(dictionary: missingTitle), "Article should not initialize with missing title value.")
        
        var emptyBody = ArticleTests.dictionary
        emptyBody["body"] = ""
        XCTAssertNil(Sherpa.Article(dictionary: emptyBody), "Article should not initialize with empty body value.")

        var missingBody = ArticleTests.dictionary
        missingBody.removeValueForKey("body")
        XCTAssertNil(Sherpa.Article(dictionary: missingBody), "Article should not initialize with missing body value.")
    }
    
    func testKeys() {
        guard let article = Sherpa.Article(dictionary: ArticleTests.dictionary) else {
            return
        }
        
        XCTAssertEqual(article.key, ArticleTests.dictionary["key"], "Article key should match the 'key' value in the provided dictionary.")
        XCTAssertEqual(article.title, ArticleTests.dictionary["title"], "Article title should match the 'title' value in the provided dictionary.")
        XCTAssertEqual(article.body, ArticleTests.dictionary["body"], "Article body should match the 'body' value in the provided dictionary.")
        XCTAssertEqual(article.relatedKeys, ArticleTests.dictionary["related_articles"], "Related article keys should match the 'related_articles' value in the provided dictionary.")
    }
    
    func testBuildMin() {
        var dictionary = ArticleTests.dictionary
        
        dictionary["build_min"] = 42
        let buildAsInt = Sherpa.Article(dictionary: dictionary)!
        XCTAssertEqual(buildAsInt.buildMin, 42, "Minimum build should match the 'build_min' value in the provided dictionary.")

        dictionary["build_min"] = "88"
        let buildAsString = Sherpa.Article(dictionary: dictionary)!
        XCTAssertEqual(buildAsString.buildMin, 88, "Minimum build should match the 'build_min' value in the provided dictionary.")
        
        dictionary["build_min"] = ""
        let buildAsEmptyString = Sherpa.Article(dictionary: dictionary)!
        XCTAssertLessThan(buildAsEmptyString.buildMin, 1, "An empty 'build_min' string should result in a build number matching any integer greater than zero.")
        
        dictionary["build_min"] = "invalid build number"
        let buildAsInvalidString = Sherpa.Article(dictionary: dictionary)!
        XCTAssertLessThan(buildAsInvalidString.buildMin, 1, "An invalid 'build_min' string should result in a build number matching any integer greater than zero.")
        
        dictionary.removeValueForKey("build_min")
        let buildAsDefault = Sherpa.Article(dictionary: dictionary)!
        XCTAssertLessThan(buildAsDefault.buildMin, 1, "A missing 'build_min' value should result in a build number matching any integer greater than zero.")
    }
    
    func testBuildMax() {
        var dictionary = ArticleTests.dictionary
        
        dictionary["build_max"] = 42
        let buildAsInt = Sherpa.Article(dictionary: dictionary)!
        XCTAssertEqual(buildAsInt.buildMax, 42, "Minimum build should match the 'build_max' value in the provided dictionary.")
        
        dictionary["build_max"] = "88"
        let buildAsString = Sherpa.Article(dictionary: dictionary)!
        XCTAssertEqual(buildAsString.buildMax, 88, "Minimum build should match the 'build_max' value in the provided dictionary.")
        
        dictionary["build_max"] = ""
        let buildAsEmptyString = Sherpa.Article(dictionary: dictionary)!
        XCTAssertGreaterThan(buildAsEmptyString.buildMax, Int.max - 1, "An empty 'build_max' string should result in a build number matching any integer less than Int.max.")
        
        dictionary["build_max"] = "invalid build number"
        let buildAsInvalidString = Sherpa.Article(dictionary: dictionary)!
        XCTAssertGreaterThan(buildAsInvalidString.buildMax, Int.max - 1, "An invalid 'build_max' string should result in a build number matching any integer less than Int.max.")

        dictionary.removeValueForKey("build_max")
        let buildAsDefault = Sherpa.Article(dictionary: dictionary)!
        XCTAssertGreaterThan(buildAsDefault.buildMax, Int.max - 1, "A missing 'build_max' value should result in a build number matching any integer less than Int.max.")
    }
    
    func testMatchesQuery() {
        guard let article = Sherpa.Article(dictionary: ArticleTests.dictionary) else {
            return
        }
        
        XCTAssertTrue(article.matches(""), "Article should always match an empty query.")
        XCTAssertTrue(article.matches("Est"), "Article should match query when (case-insensitively) found in both title and body.")
        XCTAssertTrue(article.matches("artic"), "Article should match query when (case-insensitively) found only in title.")
        XCTAssertTrue(article.matches("PENDI"), "Article should match query when (case-insensitively) found only in body.")
        XCTAssertFalse(article.matches("Example"), "Article should NOT match query when not (case-insensitively) found in the title or body.")
    }
    
    func testMatchesBuildNumber() {
        guard let article = Sherpa.Article(dictionary: ArticleTests.dictionary) else {
            return
        }

        XCTAssertTrue(article.matches(500), "Article should match build number (500) that is greater than its buildMin (\(article.buildMin)) and less than its buildMax (\(article.buildMax)).")
        XCTAssertFalse(article.matches(200), "Article should not match build number (200) that is less than its buildMin (\(article.buildMin)).")
        XCTAssertFalse(article.matches(900), "Article should not match build number (900) that is greater than its buildMax (\(article.buildMax)).")
    }
    
}
