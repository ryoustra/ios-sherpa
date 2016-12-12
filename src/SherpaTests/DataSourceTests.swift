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

class DataSourceTests: XCTestCase {

	var document: Sherpa.Document!
		
	var dataSource: Sherpa.DataSource!

	var tableView: UITableView!

	override func setUp() {
		super.setUp()
		
		let bundle = NSBundle(forClass: DataSourceTests.self)

		let url = NSBundle(forClass: DataSourceTests.self).URLForResource("dictionary", withExtension: "json")!
		self.document = Sherpa.Document(fileAtURL: url)

		self.tableView = UITableView(frame: CGRect.zero, style: .Plain)
		self.tableView.dataSource = self.dataSource

		self.dataSource = Sherpa.DataSource(tableView: self.tableView, document: self.document, bundle: bundle)
	}

	func testSectionAtIndex() {
        XCTAssertNil(dataSource.section(-1), "Nil should be returned when attempting to retrieve section with out-of-bounds index.")
        XCTAssertNil(dataSource.section(100), "Nil should be returned when attempting to retrieve section with out-of-bounds index.")
        XCTAssertEqual(dataSource.section(1)?.title, dataSource.filteredSections[1].title, "Section retrieved by index should be the same as when accessing via filteredSections array.")
    }
    
    func testArticleAtIndexPath() {
        let outOfBoundsIndexPath = NSIndexPath(forRow: 0, inSection: 100)
        XCTAssertNil(dataSource.article(outOfBoundsIndexPath), "Nil should be returned when attempting to retrieve article with out-of-bounds index path.")
        
        let validIndexPath = NSIndexPath(forRow: 0, inSection: 1)
        XCTAssertEqual(dataSource.article(validIndexPath)?.title, dataSource.filteredSections[validIndexPath.section].articles[validIndexPath.row].title, "Article retrieved by index path should be the same as when accessing via filteredSections array.")
    }
    
    func testIndexPathForArticle() {
        let articleFromDataSource = dataSource.filteredSections[0].articles[1]
        XCTAssertEqual(dataSource.indexPath(articleFromDataSource), NSIndexPath(forRow: 1, inSection: 0), "Index path for article retrieved from dataSource should match indices used to access via filteredSections array.")

        let articleFromExternalSource = Sherpa.Article(dictionary: ArticleTests.dictionary)!
        XCTAssertNil(dataSource.indexPath(articleFromExternalSource), "Nil should be returned when attempting to retrieve index path for article that doesn't exist in the data source.")
    }
    
    func testFilter() {
		let testCases: [(filter: ((Article) -> Bool)?, expectedNumberOfRows: [Int])] = [
			(nil, self.document.sections.map { $0.articles.count }),
			({ $0.buildMin >= 400 }, [1])
		]

		for (filter, expectedNumberOfRows) in testCases {
			dataSource.sectionTitle = nil
			dataSource.filter = filter
			
			XCTAssertEqual(self.dataSource.numberOfSectionsInTableView(self.tableView), expectedNumberOfRows.count + 1, "Sections without articles matching the filter should not be visible (the Feedback section should always match).")
			for (i, count) in (expectedNumberOfRows + [2]).enumerate() {
				XCTAssertEqual(self.dataSource.tableView(self.tableView, numberOfRowsInSection: i), count, "Articles that don't match the specified filter should not be visible.")
			}
			XCTAssertEqual(self.dataSource.tableView(self.tableView, numberOfRowsInSection: expectedNumberOfRows.count), 2, "The feedback section should always contain rows for each of the available feedback options.")
			XCTAssertEqual(self.dataSource.tableView(self.tableView, numberOfRowsInSection: expectedNumberOfRows.count * 10), 0, "Out-of-bounds sections should always have zero rows.")
			
			dataSource.sectionTitle = "Example Section Title"
			XCTAssertEqual(self.dataSource.numberOfSectionsInTableView(self.tableView), 1, "If a section title is specified, there should only be one section (with the feedback section removed).")
			XCTAssertEqual(self.dataSource.tableView(self.tableView, numberOfRowsInSection: 0), expectedNumberOfRows.reduce(0, combine: +), "All articles matching the specified query should be visible in the combined section.")
			XCTAssertEqual(self.dataSource.tableView(self.tableView, numberOfRowsInSection: expectedNumberOfRows.count * 10), 0, "Out-of-bounds sections should always have zero rows.")
		}
    }
    
    func testQuery() {
		let testCases: [(query: String?, expectedNumberOfRows: [Int])] = [
			(nil, self.document.sections.map { $0.articles.count }),
			("biBE", [1, 1])
		]
		
		for (query, expectedNumberOfRows) in testCases {
			dataSource.sectionTitle = nil
			dataSource.query = query
			
			XCTAssertEqual(self.dataSource.numberOfSectionsInTableView(self.tableView), expectedNumberOfRows.count + 1, "Sections without articles matching the query should not be visible (the Feedback section should always match).")
			for (i, count) in (expectedNumberOfRows + [2]).enumerate() {
				XCTAssertEqual(self.dataSource.tableView(self.tableView, numberOfRowsInSection: i), count, "Articles that don't match the specified query should not be visible.")
			}
			XCTAssertEqual(self.dataSource.tableView(self.tableView, numberOfRowsInSection: expectedNumberOfRows.count), 2, "The feedback section should always contain rows for each of the available feedback options.")
			XCTAssertEqual(self.dataSource.tableView(self.tableView, numberOfRowsInSection: expectedNumberOfRows.count * 10), 0, "Out-of-bounds sections should always have zero rows.")
			
			dataSource.sectionTitle = "Example Section Title"
			XCTAssertEqual(self.dataSource.numberOfSectionsInTableView(self.tableView), 1, "If a section title is specified, there should only be one section (with the feedback section removed).")
			XCTAssertEqual(self.dataSource.tableView(self.tableView, numberOfRowsInSection: 0), expectedNumberOfRows.reduce(0, combine: +), "All articles matching the specified query should be visible in the combined section.")
			XCTAssertEqual(self.dataSource.tableView(self.tableView, numberOfRowsInSection: expectedNumberOfRows.count * 10), 0, "Out-of-bounds sections should always have zero rows.")
		}
    }
    
    func testBuildNumber() {
		let testCases: [(buildNumber: Int?, expectedNumberOfRows: [Int])] = [
			(nil, self.document.sections.map { $0.articles.count }),
			(370, [1, 1])
		]
		
		for (buildNumber, expectedNumberOfRows) in testCases {
			dataSource.sectionTitle = nil
			dataSource.buildNumber = buildNumber
			
			XCTAssertEqual(self.dataSource.numberOfSectionsInTableView(self.tableView), expectedNumberOfRows.count + 1, "Sections without articles matching the build number should not be visible (the Feedback section should always match).")
			for (i, count) in (expectedNumberOfRows + [2]).enumerate() {
				XCTAssertEqual(self.dataSource.tableView(self.tableView, numberOfRowsInSection: i), count, "Articles that don't match the specified build number should not be visible.")
			}
			XCTAssertEqual(self.dataSource.tableView(self.tableView, numberOfRowsInSection: expectedNumberOfRows.count), 2, "The feedback section should always contain rows for each of the available feedback options.")
			XCTAssertEqual(self.dataSource.tableView(self.tableView, numberOfRowsInSection: expectedNumberOfRows.count * 10), 0, "Out-of-bounds sections should always have zero rows.")
			
			dataSource.sectionTitle = "Example Section Title"
			XCTAssertEqual(self.dataSource.numberOfSectionsInTableView(self.tableView), 1, "If a section title is specified, there should only be one section (with the feedback section removed).")
			XCTAssertEqual(self.dataSource.tableView(self.tableView, numberOfRowsInSection: 0), expectedNumberOfRows.reduce(0, combine: +), "All articles matching the specified build number should be visible in the combined section.")
			XCTAssertEqual(self.dataSource.tableView(self.tableView, numberOfRowsInSection: expectedNumberOfRows.count * 10), 0, "Out-of-bounds sections should always have zero rows.")
		}
    }

	func testTableViewDataSource() {
        let tableView = UITableView()
        
        XCTAssertEqual(dataSource.numberOfSectionsInTableView(tableView), document.sections.count + 1, "The number of table view sections should reflect the number of article sections, plus the feedback section.")

		for (i, section) in document.sections.enumerate() {
			XCTAssertEqual(dataSource.tableView(tableView, numberOfRowsInSection: i), section.articles.count, "The number of table view rows for a section should reflect the number of articles in that section.")
			XCTAssertEqual(dataSource.tableView(tableView, titleForHeaderInSection: i), section.title, "The title for a section's header should match that section's `title` property.")
			XCTAssertEqual(dataSource.tableView(tableView, titleForFooterInSection: i), section.detail, "The title for a section's footer should match that section's `detail` property.")
		}

		let feedbackIndex = document.sections.count
		XCTAssertEqual(dataSource.tableView(tableView, numberOfRowsInSection: feedbackIndex), 2, "The feedback section should always contain rows for each of the available feedback options.")
        XCTAssertEqual(dataSource.tableView(tableView, titleForHeaderInSection: feedbackIndex), "Feedback", "The title for a the feedback section should always bee \"Feedback\".")
        XCTAssertNil(dataSource.tableView(tableView, titleForFooterInSection: feedbackIndex), "The detail text for the feeback section should always be nil.")
    }

}
