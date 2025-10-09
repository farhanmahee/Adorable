import UIKit
import SwiftUI
import React
import React_RCTAppDelegate
import ReactAppDependencyProvider
@_spi(DevLauncher) import ExpoLinking

// Notification name exposed by our Obj-C swizzle to receive progress updates.
private let kBundleLoadingProgressNotification = Notification.Name("BundleLoadingProgressNotification")

// Link to the C function without a bridging header (framework targets can’t use them).
@_silgen_name("RCTDevLoadingViewSetEnabled")
func RCTDevLoadingViewSetEnabled(_ enabled: Bool)

class ReactBundleViewController: UIViewController {
  var reactNativeFactory: RCTReactNativeFactory?
  var reactNativeFactoryDelegate: RCTReactNativeFactoryDelegate?
  private let bundleURL: URL

  // UI overlay hosting controller
  private var loadingHost: UIHostingController<BundleLoadingView>?
  private var currentProgress: Double? {
    didSet { updateLoadingOverlay() }
  }

  init(bundleURL: URL) {
    self.bundleURL = bundleURL
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    NSLog("[BLV] viewDidLoad")

    // Disable React Native Dev Loading View progress overlay for this controller
    RCTDevLoadingViewSetEnabled(false)

    // Clear the initial URL so embedded apps don't receive outer app's URL
    ExpoLinkingRegistry.shared.initialURL = nil
    NSLog("[BLV] Cleared ExpoLinkingRegistry initial URL")

    // Observe content appearance to hide overlay as soon as the first RN content renders.
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(onContentDidAppear(_:)),
                                           name: NSNotification.Name("RCTContentDidAppearNotification"),
                                           object: nil)
    // Also hide overlay if bundle load fails.
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(onJSDidFailToLoad(_:)),
                                           name: NSNotification.Name("RCTJavaScriptDidFailToLoadNotification"),
                                           object: nil)

    // Observe our custom progress notifications to update percent.
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(onBundleProgress(_:)),
                                           name: kBundleLoadingProgressNotification,
                                           object: nil)

    reactNativeFactoryDelegate = ReactBundleDelegate(bundleURL: bundleURL)
    reactNativeFactoryDelegate!.dependencyProvider = RCTAppDependencyProvider()
    reactNativeFactory = RCTReactNativeFactory(delegate: reactNativeFactoryDelegate!)

    // Wrap RN root view in a container so our overlay reliably stays above it.
    let container = UIView()
    container.translatesAutoresizingMaskIntoConstraints = false
    container.backgroundColor = .systemBackground
    self.view = container

    let rnRoot = reactNativeFactory!.rootViewFactory.view(withModuleName: "main")
    rnRoot.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(rnRoot)
    NSLayoutConstraint.activate([
      rnRoot.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      rnRoot.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      rnRoot.topAnchor.constraint(equalTo: container.topAnchor),
      rnRoot.bottomAnchor.constraint(equalTo: container.bottomAnchor),
    ])

    // Show the overlay immediately; it will switch to determinate when we get progress and hide on completion.
    DispatchQueue.main.async { [weak self] in
      NSLog("[BLV] show overlay (initial)")
      self?.showLoadingOverlay(initialProgress: nil)
    }
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    // If the overlay exists, ensure it stays on top of the RN root view.
    if let host = loadingHost {
      view.bringSubviewToFront(host.view)
      host.view.layer.zPosition = 9999
    }
  }

  // MARK: - Loading overlay management

  private func showLoadingOverlay(initialProgress: Double? = nil) {
    DispatchQueue.main.async {
      if let host = self.loadingHost {
        NSLog("[BLV] overlay exists -> bring to front")
        self.view.bringSubviewToFront(host.view)
        host.view.layer.zPosition = 9999
        return
      }
      NSLog("[BLV] create overlay")
      self.currentProgress = initialProgress
      let host = UIHostingController(rootView: BundleLoadingView(progress: self.currentProgress))
      host.view.backgroundColor = .clear
      host.view.isOpaque = false
      host.view.isUserInteractionEnabled = false
      self.addChild(host)
      host.view.translatesAutoresizingMaskIntoConstraints = false
      self.view.addSubview(host.view)
      NSLayoutConstraint.activate([
        host.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
        host.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        host.view.topAnchor.constraint(equalTo: self.view.topAnchor),
        host.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      ])
      host.didMove(toParent: self)
      // Ensure overlay is on top
      self.view.bringSubviewToFront(host.view)
      host.view.layer.zPosition = 9999
      self.loadingHost = host
      self.view.setNeedsLayout()
      self.view.layoutIfNeeded()
    }
  }

  private func updateLoadingOverlay() {
    DispatchQueue.main.async {
      guard let host = self.loadingHost else { return }
      NSLog("[BLV] update overlay progress = %@", self.currentProgress as NSNumber? ?? 0)
      host.rootView = BundleLoadingView(progress: self.currentProgress)
    }
  }

  private func hideLoadingOverlay() {
    DispatchQueue.main.async {
      guard let host = self.loadingHost else { return }
      host.willMove(toParent: nil)
      host.view.removeFromSuperview()
      host.removeFromParent()
      self.loadingHost = nil
    }
  }

  // MARK: - Bridge notifications

  @objc private func onJSWillStartLoading() {
    NSLog("[BLV] JS will start loading")
    // Ensure overlay is visible; it will transition to determinate when we get progress updates.
    showLoadingOverlay(initialProgress: nil)
  }

  @objc private func onJSDidLoad() {
    NSLog("[BLV] JS did load")
    hideLoadingOverlay()
  }

  @objc private func onContentDidAppear(_ note: Notification) {
    NSLog("[BLV] content did appear")
    hideLoadingOverlay()
  }

  @objc private func onBundleProgress(_ note: Notification) {
    if loadingHost == nil {
      NSLog("[BLV] progress received - creating overlay")
      showLoadingOverlay(initialProgress: nil)
    }
    guard let userInfo = note.userInfo else { return }
    let done = (userInfo["doneBytes"] as? NSNumber)?.doubleValue ?? 0
    let total = (userInfo["totalBytes"] as? NSNumber)?.doubleValue ?? 0
    NSLog("[BLV] progress: done=%.0f total=%.0f", done, total)
    if total > 0 {
      currentProgress = min(max(done / total, 0.0), 1.0)
      if done >= total {
        NSLog("[BLV] progress complete -> hide overlay")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
          self.hideLoadingOverlay()
        }
      }
    } else {
      currentProgress = nil
    }
  }

  @objc private func onJSDidFailToLoad(_ note: Notification) {
    hideLoadingOverlay()
  }
}

class ReactBundleDelegate: RCTDefaultReactNativeFactoryDelegate {
  private let customBundleURL: URL

  init(bundleURL: URL) {
    self.customBundleURL = bundleURL
    super.init()
  }

  override func sourceURL(for bridge: RCTBridge) -> URL? {
    return customBundleURL
  }

  override func bundleURL() -> URL? {
    return customBundleURL
  }
}