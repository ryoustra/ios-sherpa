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

public class SherpaViewController: UIViewController, UINavigationControllerDelegate {

	// MARK: Customising appearance

	//! Tint color used for indicating links.
	public var tintColor: UIColor! = UINavigationBar.appearance().tintColor

	//! Background color for article pages.
	public var articleBackgroundColor: UIColor! = UIColor.whiteColor()

	//! Text color for article pages.
	public var articleTextColor: UIColor! = UIColor.darkTextColor()
	
	// MARK: Instance life cycle

	private let _listViewController: ListViewController

	private var _navigationController: UINavigationController?

	public init( fileAtURL fileURL: NSURL ) {
		_listViewController = ListViewController(fileAtURL: fileURL)
		super.init(nibName: nil, bundle: nil)
	}

	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: View controller

	public override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		self._listViewController.tintColor = self.tintColor
		self._listViewController.articleBackgroundColor = self.articleBackgroundColor
		self._listViewController.articleTextColor = self.articleTextColor

		if self.isBeingPresented() {
			let navigationController = UINavigationController(rootViewController: self._listViewController)
			self._navigationController = navigationController

			navigationController.delegate = self
			navigationController.view.frame = CGRect(origin: CGPointZero, size: self.view.frame.size)
			navigationController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
			navigationController.view.preservesSuperviewLayoutMargins = true

			self.addChildViewController(navigationController)
			self.view.addSubview(navigationController.view)
		}

		else {
			self._listViewController.view.frame = CGRect(origin: CGPointZero, size: self.view.frame.size)
			self._listViewController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
			self._listViewController.view.preservesSuperviewLayoutMargins = true

			self.addChildViewController(self._listViewController)
			self.view.addSubview(self._listViewController.view)
		}
	}

	public override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)

		let activeViewController = self.sherpa_activeViewController()

		activeViewController.view.removeFromSuperview()
		activeViewController.removeFromParentViewController()

		self._navigationController = nil
	}

	public override var navigationItem: UINavigationItem {
		get {
			return self._listViewController.navigationItem
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

	// MARK: Utilities

	private func sherpa_activeViewController() -> UIViewController {
		return self._navigationController ?? self._listViewController
	}

	public func sherpa_dismiss() {
		self.dismissViewControllerAnimated(true, completion: nil)
	}

}
