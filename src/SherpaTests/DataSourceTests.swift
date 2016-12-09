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
    
    func testSectionAtIndex() {
        let document = Sherpa.Document(dictionary: DocumentTests.dictionary)
        let datasource = Sherpa.DataSource(document: document)
        
        XCTAssertNil(datasource.section(-1), "Nil should be returned when attempting to retrieve section with out-of-bounds index.")
        XCTAssertNil(datasource.section(100), "Nil should be returned when attempting to retrieve section with out-of-bounds index.")
        XCTAssertEqual(datasource.section(1)?.title, datasource.filteredSections[1].title, "Section retrieved by index should be the same as when accessing via filteredSections array.")
    }
    
    func testArticleAtIndexPath() {
        let document = Sherpa.Document(dictionary: DocumentTests.dictionary)
        let datasource = Sherpa.DataSource(document: document)
        
        let outOfBoundsIndexPath = NSIndexPath(forRow: 0, inSection: 100)
        XCTAssertNil(datasource.article(outOfBoundsIndexPath), "Nil should be returned when attempting to retrieve article with out-of-bounds index path.")
        
        let validIndexPath = NSIndexPath(forRow: 0, inSection: 1)
        XCTAssertEqual(datasource.article(validIndexPath)?.title, datasource.filteredSections[validIndexPath.section].articles[validIndexPath.row].title, "Article retrieved by index path should be the same as when accessing via filteredSections array.")
    }
    
    func testIndexPathForArticle() {
        let document = Sherpa.Document(dictionary: DocumentTests.dictionary)
        let datasource = Sherpa.DataSource(document: document)

        let articleFromDataSource = datasource.filteredSections[0].articles[1]
        XCTAssertEqual(datasource.indexPath(articleFromDataSource), NSIndexPath(forRow: 1, inSection: 0), "Index path for article retrieved from datasource should match indices used to access via filteredSections array.")

        let articleFromExternalSource = Sherpa.Article(dictionary: ArticleTests.dictionary)!
        XCTAssertNil(datasource.indexPath(articleFromExternalSource), "Nil should be returned when attempting to retrieve index path for article that doesn't exist in the data source.")
    }
    
    func testFilter() {
        let document = Sherpa.Document(dictionary: DocumentTests.dictionary)
        let datasource = Sherpa.DataSource(document: document)
        
        datasource.filter = { $0.buildMin >= 400 }
        
        XCTAssertEqual(datasource.filteredSections.count, 1, "Sections that do not contain articles matching the specified filter should be removed.")
        XCTAssertEqual(datasource.filteredSections[0].articles.count, 1, "Articles that don't match the specified filter should be removed.")
    }
    
    func testQuery() {
        let document = Sherpa.Document(dictionary: DocumentTests.dictionary)
        let datasource = Sherpa.DataSource(document: document)
        
        datasource.query = "biBE"
        
        XCTAssertEqual(datasource.filteredSections.count, 2, "Sections that do not contain articles matching the specified query should be removed.")
        XCTAssertEqual(datasource.filteredSections[0].articles.count, 1, "Articles that don't match the specified filter should be removed.")
        XCTAssertEqual(datasource.filteredSections[1].articles.count, 1, "Articles that don't match the specified filter should be removed.")
    }
    
    func testBuildNumber() {
        let document = Sherpa.Document(dictionary: DocumentTests.dictionary)
        let datasource = Sherpa.DataSource(document: document)
        
        datasource.buildNumber = 370
        
        XCTAssertEqual(datasource.filteredSections.count, 2, "Sections that do not contain articles matching the specified query should be removed.")
        XCTAssertEqual(datasource.filteredSections[0].articles.count, 1, "Articles that don't match the specified filter should be removed.")
        XCTAssertEqual(datasource.filteredSections[1].articles.count, 1, "Articles that don't match the specified filter should be removed.")
    }
    
    func testSectionTitle() {
        let document = Sherpa.Document(dictionary: DocumentTests.dictionary)
        let datasource = Sherpa.DataSource(document: document)
        
        datasource.sectionTitle = "Section Title"
        
        XCTAssertEqual(datasource.filteredSections.count, 1, "When a data source has a section title specified, it should only have a single section.")
        XCTAssertEqual(datasource.filteredSections[0].articles.count, 3, "When a data source has a section title specified, all articles should exist in a single section.")
    }
    
    func testTableViewDataSource() {
        let document = Sherpa.Document(dictionary: DocumentTests.dictionary)
        let datasource = Sherpa.DataSource(document: document)
        
        let tableView = UITableView()
        
        XCTAssertEqual(datasource.numberOfSectionsInTableView(tableView), document.sections.count + 1, "The number of table view sections should reflect the number of article sections, plus the feedback section.")
        XCTAssertEqual(datasource.tableView(tableView, numberOfRowsInSection: 0), document.sections[0].articles.count, "The number of table view rows for a section should reflect the number of articles in that section.")
        XCTAssertEqual(datasource.tableView(tableView, numberOfRowsInSection: document.sections.count), 2, "The number of table view rows for the feedback section should reflect the number of feedback options available.")
        XCTAssertEqual(datasource.tableView(tableView, titleForHeaderInSection: 0), document.sections[0].title, "The title for a section's header should match that section's `title` property.")
        XCTAssertEqual(datasource.tableView(tableView, titleForFooterInSection: 0), document.sections[0].detail, "The title for a section's footer should match that section's `detail` property.")
        XCTAssertEqual(datasource.tableView(tableView, titleForHeaderInSection: 1), document.sections[1].title, "The title for a section's header should match that section's `title` property.")
        XCTAssertEqual(datasource.tableView(tableView, titleForFooterInSection: 1), document.sections[1].detail, "The title for a section's footer should match that section's `detail` property.")
    }

}
