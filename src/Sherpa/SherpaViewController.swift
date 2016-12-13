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

public class SherpaViewController: UIViewController, UINavigationControllerDelegate, DocumentDelegate {
	
	// MARK: Deep-linking
	
	//! Key matching an article to be displayed.
	public var articleKey: String? = nil
	
	// MARK: Allowing feedback
	
	//! Email address for receiving feedback.
	public var feedbackEmail: String? {
		get { return self.document.feedbackEmail }
		set(feedbackEmail) { self.document.feedbackEmail = feedbackEmail }
	}
	
	//! Twitter account handle for receiving feedback.
	public var feedbackTwitter: String? {
		get { return self.document.feedbackTwitter }
		set(feedbackTwitter) { self.document.feedbackTwitter = feedbackTwitter }
	}
	
	// MARK: Customising appearance
	
	//! Tint color used for indicating links.
	public var tintColor: UIColor! {
		get { return self.document.tintColor }
		set(tintColor) { self.document.tintColor = tintColor }
	}
	
	//! Background color for article pages.
	public var articleBackgroundColor: UIColor! {
		get { return self.document.articleBackgroundColor }
		set(articleBackgroundColor) { self.document.articleBackgroundColor = articleBackgroundColor }
	}
	
	//! Text color for article pages.
	public var articleTextColor: UIColor! {
		get { return self.document.articleTextColor }
		set(articleTextColor) { self.document.articleTextColor = articleTextColor }
	}
	
	//! Register the class used to display article rows in the table view.
	@objc(registerTableViewCellClassForArticleRows:)
	public func registerTableViewCellClass(forArticleRows cellClass: UITableViewCell.Type) {
		self.document.articleCellClass = cellClass
	}
	
	//! Register the class used to display feedback rows in the table view.
	@objc(registerTableViewCellClassForFeedbackRows:)
	public func registerTableViewCellClass(forFeedbackRows cellClass: UITableViewCell.Type) {
		self.document.feedbackCellClass = cellClass
	}
	
	// MARK: Instance life cycle
	
	//! The Sherpa document.
	private let document: Document
	
	/// Creates a `SherpaViewController` instance for the file at the given file URL.
	/// @param fileURL The local URL for the underlying JSON document containing the content.
	public init(fileAtURL fileURL: NSURL) {
		let document = Document(fileAtURL: fileURL)
		
		self.document = document
		self.listViewController = ListViewController(document: document)
		
		super.init(nibName: nil, bundle: nil)
		
		document.delegate = self
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: View controller
	
	//! View controller for displaying the list of available articles.
	private let listViewController: ListViewController
	
	//! View controller for displaying a deep-linked article.
	private var articleViewController: ArticleViewController?
	
	//! Embedded navigation controller for modal presentation.
	private var embeddedNavigationController: UINavigationController?
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		// Presenting modally, sans-UINavigationController
		if self.navigationController == nil {
			let navigationController = UINavigationController()
			self.embeddedNavigationController = navigationController
			
			self.addChildViewController(navigationController)
			self.view.addSubview(navigationController.view)
			
			navigationController.delegate = self
			navigationController.view.frame = CGRect(origin: CGPointZero, size: self.view.frame.size)
			navigationController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
			navigationController.view.preservesSuperviewLayoutMargins = true
			navigationController.setViewControllers([self.listViewController], animated: false)
			
			if let key = articleKey, let article = self.document.article(key) {
				self.listViewController.selectRowForArticle(article)
				
				let articleViewController = ArticleViewController(document: self.document, article: article)
				navigationController.pushViewController(articleViewController, animated: false)
			}
		}
			
			// Pushing a deep-linked article into a navigation stack
		else if let key = articleKey, let article = self.document.article(key) {
			let articleViewController = ArticleViewController(document: self.document, article: article)
			self.articleViewController = articleViewController
			
			self.addChildViewController(articleViewController)
			self.view.addSubview(articleViewController.view)
			
			articleViewController.view.frame = CGRect(origin: CGPointZero, size: self.view.frame.size)
			articleViewController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
			articleViewController.view.preservesSuperviewLayoutMargins = true
		}
			
			// Pushing into a navigation stack
		else {
			self.addChildViewController(self.listViewController)
			self.view.addSubview(self.listViewController.view)
			
			self.listViewController.view.frame = CGRect(origin: CGPointZero, size: self.view.frame.size)
			self.listViewController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
			self.listViewController.view.preservesSuperviewLayoutMargins = true
		}
	}
	
	public override var navigationItem: UINavigationItem {
		get {
			return self.sherpa_activeViewController().navigationItem
		}
	}
	
	public override func childViewControllerForStatusBarHidden() -> UIViewController? {
		return self.sherpa_activeViewController()
	}
	
	public override func childViewControllerForStatusBarStyle() -> UIViewController? {
		return self.sherpa_activeViewController()
	}
	
	// MARK: Navigation controller delegate
	
	public func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
		if viewController.navigationItem.rightBarButtonItem == nil {
			viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(SherpaViewController.sherpa_dismiss))
		}
	}
	
	// MARK: Document controller delegate
	
	internal func document(document: Document, didSelectArticle article: Article) {
		let articleViewController = ArticleViewController(document: self.document, article: article)
		let navigationController = self.embeddedNavigationController ?? self.navigationController
		navigationController!.pushViewController(articleViewController, animated: true)
	}
	
	internal func document(document: Document, didSelectViewController viewController: UIViewController) {
		let navigationController = self.embeddedNavigationController ?? self.navigationController
		navigationController!.presentViewController(viewController, animated: true, completion: nil)
	}
	
	// MARK: Utilities
	
	private func sherpa_activeViewController() -> UIViewController {
		if let viewController = self.embeddedNavigationController {
			return viewController
		}
		else if let viewController = self.articleViewController {
			return viewController
		}
		return self.listViewController
	}
	
	public func sherpa_dismiss() {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
}
