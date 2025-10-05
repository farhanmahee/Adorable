import ExpoModulesCore
import UIKit

class ReactBundleView: ExpoView {
  private var bundleViewController: ReactBundleViewController?
  private var currentURL: URL?

  let onLoad = EventDispatcher()

  required init(appContext: AppContext? = nil) {
    super.init(appContext: appContext)
    clipsToBounds = true
    backgroundColor = .systemBackground
    NSLog("[ReactBundleView] init")
  }

  func loadBundle(url: URL) {
    NSLog("[ReactBundleView] loadBundle called with URL: \(url)")

    // Don't reload if URL hasn't changed
    if currentURL == url, bundleViewController != nil {
      NSLog("[ReactBundleView] URL unchanged, skipping reload")
      return
    }

    currentURL = url

    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }

      // Remove existing view controller if present
      if let existingVC = self.bundleViewController {
        NSLog("[ReactBundleView] Removing existing VC")
        existingVC.willMove(toParent: nil)
        existingVC.view.removeFromSuperview()
        existingVC.removeFromParent()
      }

      // Create new bundle view controller
      NSLog("[ReactBundleView] Creating ReactBundleViewController")
      let viewController = ReactBundleViewController(bundleURL: url)
      self.bundleViewController = viewController

      // Find the parent view controller
      guard let parentVC = self.reactViewController() else {
        NSLog("[ReactBundleView] ERROR: No parent view controller found")
        return
      }

      NSLog("[ReactBundleView] Found parent VC: \(parentVC)")

      // Add as child view controller
      parentVC.addChild(viewController)
      viewController.view.translatesAutoresizingMaskIntoConstraints = false
      self.addSubview(viewController.view)

      NSLayoutConstraint.activate([
        viewController.view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
        viewController.view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        viewController.view.topAnchor.constraint(equalTo: self.topAnchor),
        viewController.view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      ])

      viewController.didMove(toParent: parentVC)
      NSLog("[ReactBundleView] VC added to hierarchy")

      // Listen for content loaded notification
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(self.onContentDidAppear(_:)),
        name: NSNotification.Name("RCTContentDidAppearNotification"),
        object: nil
      )
    }
  }

  @objc private func onContentDidAppear(_ notification: Notification) {
    if let url = currentURL {
      onLoad([
        "url": url.absoluteString
      ])
    }
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}
