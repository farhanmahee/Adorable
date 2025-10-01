import UIKit
import React
import React_RCTAppDelegate
import ReactAppDependencyProvider

class ReactBundleViewController: UIViewController {
  var reactNativeFactory: RCTReactNativeFactory?
  var reactNativeFactoryDelegate: RCTReactNativeFactoryDelegate?
  private let bundleURL: URL

  init(bundleURL: URL) {
    self.bundleURL = bundleURL
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    reactNativeFactoryDelegate = ReactBundleDelegate(bundleURL: bundleURL)
    reactNativeFactoryDelegate!.dependencyProvider = RCTAppDependencyProvider()
    reactNativeFactory = RCTReactNativeFactory(delegate: reactNativeFactoryDelegate!)
    view = reactNativeFactory!.rootViewFactory.view(withModuleName: "HelloWorld")
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
