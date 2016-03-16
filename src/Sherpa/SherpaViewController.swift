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

	// MARK: Customising appearance

	//! Tint color used for indicating links.
	public var tintColor: UIColor! {
		get { return self._document.tintColor }
		set(tintColor) { self._document.tintColor = tintColor }
	}

	//! Background color for article pages.
	public var articleBackgroundColor: UIColor! {
		get { return self._document.articleBackgroundColor }
		set(articleBackgroundColor) { self._document.articleBackgroundColor = articleBackgroundColor }
	}

	//! Text color for article pages.
	public var articleTextColor: UIColor! {
		get { return self._document.articleTextColor }
		set(articleTextColor) { self._document.articleTextColor = articleTextColor }
	}

	// MARK: Deep-linking

	/// Key matching an article to be displayed.
	public var articleKey: String? = nil

	// MARK: Instance life cycle

	private let _document: Document

	private let _listViewController: ListViewController

	private var _articleViewController: ArticleViewController?

	private var _navigationController: UINavigationController?

	public init( fileAtURL fileURL: NSURL ) {
		let document = Document(fileAtURL: fileURL)

		_document = document
		_listViewController = ListViewController(dataSource: document.dataSource())

		super.init(nibName: nil, bundle: nil)

		document.delegate = self
	}

	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: View controller

	public override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		if self.isBeingPresented() {
			let navigationController = UINavigationController()
			self._navigationController = navigationController

			self.addChildViewController(navigationController)
			self.view.addSubview(navigationController.view)

			navigationController.delegate = self
			navigationController.view.frame = CGRect(origin: CGPointZero, size: self.view.frame.size)
			navigationController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
			navigationController.view.preservesSuperviewLayoutMargins = true
			navigationController.setViewControllers([self._listViewController], animated: false)

			if let key = articleKey, let article = self._document.article(key) {
				self._listViewController.selectRowForArticle(article)

				let dataSource = self._document.dataSource()
				let articleViewController = ArticleViewController(dataSource:dataSource, article: article)
				navigationController.pushViewController(articleViewController, animated: false)
			}
		}

		else if let key = articleKey, let article = self._document.article(key) {
			let dataSource = self._document.dataSource()
			let articleViewController = ArticleViewController(dataSource:dataSource, article: article)
			self._articleViewController = articleViewController

			self.addChildViewController(articleViewController)
			self.view.addSubview(articleViewController.view)

			articleViewController.view.frame = CGRect(origin: CGPointZero, size: self.view.frame.size)
			articleViewController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
			articleViewController.view.preservesSuperviewLayoutMargins = true
		}

		else {
			self.addChildViewController(self._listViewController)
			self.view.addSubview(self._listViewController.view)

			self._listViewController.view.frame = CGRect(origin: CGPointZero, size: self.view.frame.size)
			self._listViewController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
			self._listViewController.view.preservesSuperviewLayoutMargins = true
		}
	}

	public override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)

		let activeViewController = self.sherpa_activeViewController()

		activeViewController.view.removeFromSuperview()
		activeViewController.removeFromParentViewController()

		self._articleViewController = nil
		self._navigationController = nil
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
			viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "sherpa_dismiss")
		}
	}

	// MARK: Document controller delegate

	internal func document(document: Document, didSelectArticle article: Article) {
		let dataSource = self._document.dataSource()
		let articleViewController = ArticleViewController(dataSource:dataSource, article: article)
		let navigationController = self._navigationController ?? self.navigationController
		navigationController!.pushViewController(articleViewController, animated: true)
	}

	// MARK: Utilities

	private func sherpa_activeViewController() -> UIViewController {
		if let viewController = self._navigationController {
			return viewController
		}
		else if let viewController = self._articleViewController {
			return viewController
		}
		return self._listViewController
	}

	public func sherpa_dismiss() {
		self.dismissViewControllerAnimated(true, completion: nil)
	}

}
