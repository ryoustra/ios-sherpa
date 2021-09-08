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

import UIKit

open class SherpaViewController: UIViewController, UINavigationControllerDelegate, ListViewControllerDelegate {
	
	// MARK: Deep-linking
	
	/// Key matching an article to be displayed.
	open var articleKey: String? = nil

	/// Determine if an article matching the given key is available.
	/// - Parameter key: String matching an article within the document.
	/// - Returns: Flag indicating that an article matching the given `key` exists.
	open func contains(articleForKey key: String) -> Bool {
		return self.document.article(key) != nil
	}
	
	/// Have an article matching the given key pushed into the navigation hierarchy, if possible.
	/// - Parameters:
	///   - key: String matching an article within the document.
	///   - animated: Flag indicating whether the view controller transition should be animated.
	open func open(articleForKey key: String, animated: Bool) {
		guard let article = self.document.article(key) else {
			return
		}

		self.listViewController.selectRowForArticle(article)
		
		let articleViewController = ArticleViewController(document: self.document, article: article)
		articleViewController.delegate = self

		self.sherpa_navigationController.pushViewController(articleViewController, animated: animated)
	}

	/// Opens a screen for composing an email to the address from the document at the given `fileURL`.
	/// - Parameters:
	///   - fileURL: The file URL for the document to retrieve the Twitter account details from.
	///   - presentingViewController: The view controller to present from.
	///   - animated: Flag indicating whether the view controller transition should be animated.
	public static func openEmail(from fileURL: URL, presentingFrom presentingViewController: UIViewController, animated: Bool) {
		let document = Document(fileAtURL: fileURL)

		guard let feedback = document.feedback.first(where: { $0 is FeedbackEmail }), let viewController = feedback.viewController else {
			return
		}

		presentingViewController.present(viewController, animated: animated, completion: nil)
	}

	/// Opens the Twitter handle from the document at the given `fileURL`.
	/// - Parameters:
	///   - fileURL: The file URL for the document to retrieve the Twitter account details from.
	///   - presentingViewController: The view controller to present from.
	///   - animated: Flag indicating whether the view controller transition should be animated.
	public static func openTwitter(from fileURL: URL, presentingFrom presentingViewController: UIViewController, animated: Bool) {
		let document = Document(fileAtURL: fileURL)

		guard let feedback = document.feedback.first(where: { $0 is FeedbackTwitter }), let viewController = feedback.viewController else {
			return
		}

		presentingViewController.present(viewController, animated: animated, completion: nil)
	}

	// MARK: Allowing feedback
	
	/// Email address for receiving feedback.
	@available(*, deprecated)
	open var feedbackEmail: String? {
		get { return self.document.feedback.compactMap { $0 as? FeedbackEmail }.first?.fullString }
		set(feedbackEmail) {
			var feedback = self.document.feedback.filter{ !($0 is FeedbackEmail) }
			
			if let emailString = feedbackEmail, let twitter = FeedbackEmail(string: emailString) {
				feedback.append(twitter)
			}

			self.document.feedback = feedback
		}
	}
	
	/// Twitter account handle for receiving feedback.
	@available(*, deprecated)
	open var feedbackTwitter: String? {
		get { return self.document.feedback.compactMap { $0 as? FeedbackTwitter }.first?.handle }
		set(feedbackTwitter) {
			var feedback = self.document.feedback.filter{ !($0 is FeedbackTwitter) }
			
			if let twitterString = feedbackTwitter, let twitter = FeedbackTwitter(string: twitterString) {
				feedback.append(twitter)
			}
			
			self.document.feedback = feedback
		}
	}
	
	// MARK: Customising appearance
	
	/// Tint color used for indicating links.
	open var tintColor: UIColor! {
		get { return self.document.tintColor }
		set(tintColor) { self.document.tintColor = tintColor }
	}
	
	/// Background color for article pages.
	open var articleBackgroundColor: UIColor! {
		get { return self.document.articleBackgroundColor }
		set(articleBackgroundColor) { self.document.articleBackgroundColor = articleBackgroundColor }
	}

	/// Text color for article pages.
	open var articleTextColor: UIColor! {
		get { return self.document.articleTextColor }
		set(articleTextColor) { self.document.articleTextColor = articleTextColor }
	}

	/// Text color for article pages.
	open var articleCSS: String? {
		get { return self.document.articleCSS }
		set(articleCSS) { self.document.articleCSS = articleCSS }
	}

	/// Register the class used to display article rows in the table view.
	/// - Parameter cellClass: The cell class to use for displaying article rows.
	@objc(registerTableViewCellClassForArticleRows:)
	open func registerTableViewCellClass(forArticleRows cellClass: UITableViewCell.Type) {
		self.document.articleCellClass = cellClass
	}
	
	/// Register the class used to display feedback rows in the table view.
	/// - Parameter cellClass: The cell class to use for displaying feedback rows.
	@objc(registerTableViewCellClassForFeedbackRows:)
	open func registerTableViewCellClass(forFeedbackRows cellClass: UITableViewCell.Type) {
		self.document.feedbackCellClass = cellClass
	}
	
    open var allowSearch: Bool {
        get { return self.document.allowSearch }
        set(allowSearch) { self.document.allowSearch = allowSearch }
    }
	// MARK: Instance life cycle
	
	/// The Sherpa document.
	fileprivate let document: Document
	
	/// Creates a `SherpaViewController` instance for the file at the given file URL.
	/// - Parameter fileURL The local URL for the underlying JSON document containing the content.
	public init(fileAtURL fileURL: URL) {
		let document = Document(fileAtURL: fileURL)
		
		self.document = document
		self.listViewController = ListViewController(document: document)
		
		super.init(nibName: nil, bundle: nil)

		self.listViewController.delegate = self
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: View controller
	
	/// View controller for displaying the list of available articles.
	fileprivate let listViewController: ListViewController
	
	/// View controller for displaying a deep-linked article.
	fileprivate var articleViewController: ArticleViewController?
	
	/// Embedded navigation controller for modal presentation.
	fileprivate var embeddedNavigationController: UINavigationController?
	
	open override func viewDidLoad() {
		super.viewDidLoad()
		
		// Presenting modally, sans-UINavigationController
		if self.navigationController == nil {
			let navigationController = UINavigationController()
			self.embeddedNavigationController = navigationController
			
			self.addChild(navigationController)
			self.view.addSubview(navigationController.view)
			
			navigationController.delegate = self
			navigationController.view.frame = CGRect(origin: CGPoint.zero, size: self.view.frame.size)
			navigationController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			navigationController.view.preservesSuperviewLayoutMargins = true
			navigationController.setViewControllers([self.listViewController], animated: false)
			
			if let key = articleKey, let article = self.document.article(key) {
				self.listViewController.selectRowForArticle(article)
				
				let articleViewController = ArticleViewController(document: self.document, article: article)
				articleViewController.delegate = self
				navigationController.pushViewController(articleViewController, animated: false)
			}
		}
			
		// Pushing a deep-linked article into a navigation stack
		else if let key = articleKey, let article = self.document.article(key) {
			let articleViewController = ArticleViewController(document: self.document, article: article)
			articleViewController.delegate = self
			self.articleViewController = articleViewController
			
			self.addChild(articleViewController)
			self.view.addSubview(articleViewController.view)
			
			articleViewController.view.frame = CGRect(origin: CGPoint.zero, size: self.view.frame.size)
			articleViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			articleViewController.view.preservesSuperviewLayoutMargins = true
		}
			
		// Pushing into a navigation stack
		else {
			self.addChild(self.listViewController)
			self.view.addSubview(self.listViewController.view)
			
			self.listViewController.view.frame = CGRect(origin: CGPoint.zero, size: self.view.frame.size)
			self.listViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			self.listViewController.view.preservesSuperviewLayoutMargins = true
		}
	}
	
	open override var navigationItem: UINavigationItem {
		get {
			return self.sherpa_activeViewController.navigationItem
		}
	}
	
	open override var childForStatusBarHidden : UIViewController? {
		return self.sherpa_activeViewController
	}
	
	open override var childForStatusBarStyle : UIViewController? {
		return self.sherpa_activeViewController
	}
	
	// MARK: Navigation controller delegate
	
	open func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		if viewController.navigationItem.rightBarButtonItem == nil {
			viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(SherpaViewController.sherpa_dismiss))
		}
	}
	
	// MARK: Data source delegate
	
	func listViewController(_ listViewController: ListViewController, didSelectArticle article: Article) {
		let articleViewController = ArticleViewController(document: self.document, article: article)
		articleViewController.delegate = self
		
		self.sherpa_navigationController.pushViewController(articleViewController, animated: true)
	}
	
	func listViewController(_ listViewController: ListViewController, didSelectFeedback feedback: Feedback) {
		guard let viewController = feedback.viewController else {
			return
		}

		self.sherpa_navigationController.present(viewController, animated: true, completion: nil)
	}

	// MARK: Utilities
	
	fileprivate var sherpa_activeViewController: UIViewController {
		if let viewController = self.embeddedNavigationController {
			return viewController
		}
		else if let viewController = self.articleViewController {
			return viewController
		}
		return self.listViewController
	}
	
	fileprivate var sherpa_navigationController: UINavigationController {
		return self.embeddedNavigationController ?? self.navigationController!
	}
	
	@objc open func sherpa_dismiss() {
		self.dismiss(animated: true, completion: nil)
	}
	
}
