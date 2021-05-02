//
// Copyright © 2021 Daniel Farrelly
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

class ListViewControllerTests: XCTestCase {
	
	var document: Sherpa.Document!
	
	var listViewController: Sherpa.ListViewController!
	
	override func setUp() {
		super.setUp()
		
		let url = Bundle(for: DataSourceTests.self).url(forResource: "dictionary", withExtension: "json")!
		self.document = Sherpa.Document(fileAtURL: url)

		self.listViewController = Sherpa.ListViewController(document: self.document)
	}
	
	// MARK: Delegate tests
	
	fileprivate class ListViewControllerTestDelegate: ListViewControllerDelegate {
		
		var listViewController: Sherpa.ListViewController?
		
		var article: Sherpa.Article?
		
		var feedback: Sherpa.Feedback?
		
		var count: Int = 0
		
		fileprivate func listViewController(_ listViewController: Sherpa.ListViewController, didSelectArticle article: Sherpa.Article) {
			self.listViewController = listViewController
			self.article = article
			self.count += 1
		}
		
		fileprivate func listViewController(_ listViewController: Sherpa.ListViewController, didSelectFeedback feedback: Sherpa.Feedback) {
			self.listViewController = listViewController
			self.feedback = feedback
			self.count += 1
		}
		
		fileprivate func reset() {
			self.listViewController = nil
			self.article = nil
			self.feedback = nil
			self.count = 0
		}
		
	}
	
	func testDelegate() {
		let delegate = ListViewControllerTestDelegate()
		
		let listViewController = Sherpa.ListViewController(document: self.document)
		listViewController.delegate = delegate

		// Articles
		
		for (x, section) in self.document.sections.enumerated() {
			for (y, _) in section.articles.enumerated() {
				let indexPath = IndexPath(row: y, section: x)
				listViewController.tableView(self.listViewController.tableView, didSelectRowAt: indexPath)
				
				XCTAssertEqual(delegate.listViewController, listViewController, "Data source provided to delegate should match the calling data source.")
				XCTAssertNotNil(delegate.article, "Article provided to delegate should match the article for the selected row.")
				XCTAssertNil(delegate.feedback, "Feedback type should not be present after selecting an article row.")
				XCTAssertEqual(delegate.count, 1, "Delegate methods should only be called one time when row is selected.")
				
				delegate.reset()
			}
		}
		
		// Feedback
		
		for i in 0..<2 {
			let indexPath = IndexPath(row: i, section: self.document.sections.count)
			listViewController.tableView(self.listViewController.tableView, didSelectRowAt: indexPath)
			
			XCTAssertEqual(delegate.listViewController, listViewController, "Data source provided to delegate should match the calling data source.")
			XCTAssertNotNil(delegate.feedback, "Feedback type provided to delegate should match the option for the selected row.")
			XCTAssertNil(delegate.article, "Article should not be present after selecting a feedback row.")
			XCTAssertEqual(delegate.count, 1, "Delegate methods should only be called one time when row is selected.")
			
			delegate.reset()
		}
		
		// Out-of-bounds
		
		let outOfBoundsIndexPaths = [
			IndexPath(row: 100, section: self.document.sections.startIndex), // Article section
			IndexPath(row: 100, section: self.document.sections.endIndex), // Feedback section
			IndexPath(row: 100, section: 100) // Out-of-bounds section
		]
		
		for indexPath in outOfBoundsIndexPaths {
			listViewController.tableView(self.listViewController.tableView, didSelectRowAt: indexPath)
			
			XCTAssertNil(delegate.listViewController, "Delegate should never be called for an out-of-bounds index path.")
			XCTAssertNil(delegate.article, "Delegate should never be called for an out-of-bounds index path.")
			XCTAssertNil(delegate.feedback, "Delegate should never be called for an out-of-bounds index path.")
			XCTAssertEqual(delegate.count, 0, "Delegate should never be called for an out-of-bounds index path.")
			
			delegate.reset()
		}
	}
	
}
