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

public class SherpaViewController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating {

	// MARK: Appearance

	private let _dataSource: SherpaDataSource

	private let _articleKey: String?

	public init( fileAtURL fileURL: NSURL ) {
		_dataSource = SherpaDataSource(fileAtURL: fileURL)
		_articleKey = nil

		super.init(style: .Grouped)
	}
	
	public init( fileAtURL fileURL: NSURL, articleKey: String ) {
		_dataSource = SherpaDataSource(fileAtURL: fileURL)
		_articleKey = articleKey

		super.init(style: .Grouped)
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Appearance

	//! Tint color used for indicating links.
	public var tintColor: UIColor! = UINavigationBar.appearance().tintColor

	//! Background color for article pages.
	public var articleBackgroundColor: UIColor! = UIColor.whiteColor()

	//! Text color for article pages.
	public var articleTextColor: UIColor! = UIColor.darkTextColor()

	// MARK: View life cycle

	private let searchController = UISearchController(searchResultsController: nil)

	override public func viewDidLoad() {
		super.viewDidLoad()

		self.navigationItem.title = "User Guide"

		self.tableView.dataSource = self._dataSource

		self.searchController.delegate = self
		self.searchController.searchResultsUpdater = self
		if #available(iOSApplicationExtension 9.1, *) {
			self.searchController.obscuresBackgroundDuringPresentation = false
		} else {
			self.searchController.dimsBackgroundDuringPresentation = false
		}
		self.tableView.tableHeaderView = self.searchController.searchBar

		self.definesPresentationContext = true;
	}

	public override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		if let key = self._articleKey, let article = self._dataSource.article(key) {
			let viewController = self._viewController(article)
			self.navigationController?.pushViewController(viewController, animated: false)
		}
	}

	// MARK: Table view delegate

	override public func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 44
	}

	override public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		guard let article = self._dataSource.article(indexPath) else {
			return
		}

		let viewController = self._viewController(article)
		self.navigationController?.pushViewController(viewController, animated: true)
	}

	override public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		if cell.accessoryType != .None {
			cell.textLabel?.textColor = self.tintColor
		}
	}
	
	// MARK: Search results updating

	public func updateSearchResultsForSearchController(searchController: UISearchController) {
		if searchController.active, let query = searchController.searchBar.text where query.characters.count > 0 {
			self._dataSource.query = query
		}
		else {
			self._dataSource.query = nil
		}
		self.tableView.reloadData()
	}

	// MARK: Utilities

	private func _viewController(article: Article) -> ArticleViewController {
		let viewController = ArticleViewController(article: article)
		viewController.tintColor = self.tintColor
		viewController.backgroundColor = self.articleBackgroundColor
		viewController.textColor = self.articleTextColor
		return viewController
	}

}
