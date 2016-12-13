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

internal protocol ListViewControllerDelegate: class {
	
	func listViewController(listViewController: ListViewController, didSelectArticle article: Article)
	
	func listViewController(listViewController: ListViewController, didSelectFeedback feedbackType: DataSource.FeedbackType)
	
}

internal class ListViewController: UIViewController, UITableViewDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
	
	internal weak var delegate: ListViewControllerDelegate?
	
	internal var allowSearch: Bool = true
	
	// MARK: Instance life cycle
	
	internal private(set) var dataSource: DataSource!
	
	internal init(document: Document) {
		super.init(nibName: nil, bundle: nil)
		
		self.dataSource = DataSource(tableView: self.tableView, document: document)
		
		self.tableView.dataSource = self.dataSource
		self.tableView.delegate = self
		self.tableView.reloadData()
	}
	
	internal required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit{
		self.searchController?.view.removeFromSuperview()
	}
	
	// MARK: View life cycle
	
	private var searchController: UISearchController?
	
	internal let tableView = UITableView(frame: CGRectZero, style: .Grouped)
	
	override func loadView() {
		self.view = self.tableView
	}
	
	override internal func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.title = NSLocalizedString("User Guide", comment: "Title for view controller listing user guide articles.")
		
		if self.allowSearch {
			let searchController = UISearchController(searchResultsController: nil)
			if #available(iOS 9.1, *) {
				searchController.obscuresBackgroundDuringPresentation = false
			} else {
				searchController.dimsBackgroundDuringPresentation = false
			}
			searchController.delegate = self
			searchController.searchResultsUpdater = self
			searchController.searchBar.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 44.0)
			searchController.searchBar.tintColor = self.dataSource.document.tintColor
			searchController.searchBar.autoresizingMask = [.FlexibleWidth]
			self.searchController = searchController
			
			// Sticking the searchBar inside a wrapper stops the tableview trying to be clever with the content size.
			let headerView = UIView(frame: searchController.searchBar.frame)
			headerView.autoresizingMask = [.FlexibleWidth]
			headerView.addSubview(searchController.searchBar)
			self.tableView.tableHeaderView = headerView
			
			self.definesPresentationContext = true;
		}
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		if let indexPath = self.tableView.indexPathForSelectedRow {
			self.tableView.deselectRowAtIndexPath(indexPath, animated: animated)
		}
		
		if let searchController = self.searchController where searchController.active {
			self.navigationController?.setNavigationBarHidden(true, animated: false)
		}
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onKeyboard(_:)), name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onKeyboard(_:)), name: UIKeyboardWillHideNotification, object: nil)
	}
	
	@objc private func onKeyboard(notification: NSNotification) {
		UIView.beginAnimations(nil, context: nil)
		
		if let rawValue = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey]?.integerValue, let curve = UIViewAnimationCurve(rawValue: rawValue) {
			UIView.setAnimationCurve(curve)
		}
		
		if let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
			UIView.setAnimationDuration(duration)
		}
		
		let keyboardOrigin = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.origin.y ?? 0
		
		let contentInset = self.tableView.contentInset
		let bottomInset = max(self.bottomLayoutGuide.length, self.tableView.frame.size.height - keyboardOrigin)
		
		self.tableView.contentInset = UIEdgeInsets(top: contentInset.top, left: contentInset.left, bottom: bottomInset, right: contentInset.right)
		
		UIView.commitAnimations()
	}
	
	// MARK: Search results updating
	
	internal func updateSearchResultsForSearchController(searchController: UISearchController) {
		if !self.allowSearch { return }
		
		if searchController.active, let query = searchController.searchBar.text where query.characters.count > 0 {
			self.dataSource.query = query
		}
		else {
			self.dataSource.query = nil
		}
		
		self.tableView.reloadData()
	}

	// MARK: Table view delegate
	
	func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 44
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if let key = self.dataSource.feedback(indexPath) {
			self.delegate?.listViewController(self, didSelectFeedback: key)
		}
			
		else if let article = self.dataSource.article(indexPath) {
			self.delegate?.listViewController(self, didSelectArticle: article)
		}
	}

	// MARK: Utilities
	
	internal func selectRowForArticle(article: Article) {
		if let indexPath = self.dataSource.indexPath(article) {
			self.tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .Middle)
		}
	}
	
}
