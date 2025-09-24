import Foundation
import ExpoModulesCore
import EXManifests
import React
import Expo

public class AppLoader {
  private var currentRootView: UIView?
  private var currentManifest: Manifest?
  
  public init() {}
  
  public func loadAndShowApp(
    manifest: Manifest,
    promise: Promise
  ) {
    let bundleUrlString = manifest.bundleUrl()
    
    guard let bundleUrl = URL(string: bundleUrlString) else {
      promise.reject("INVALID_URL", "Invalid bundle URL from manifest: \(bundleUrlString)")
      return
    }
    
    print("Loading app from bundle URL: \(bundleUrl)")
    
    // Get the app delegate without knowing its specific type
    guard let appDelegate = UIApplication.shared.delegate as? NSObject else {
      promise.reject("NO_APP_DELEGATE", "Could not get app delegate")
      return
    }
    
    // Use KVC to get the factory
    guard let factory = appDelegate.value(forKey: "reactNativeFactory") as? NSObject else {
      promise.reject("NO_FACTORY", "Could not get factory from app delegate")
      return
    }
    
    // Check if factory responds to recreateRootView selector
    let selector = NSSelectorFromString("recreateRootViewWithBundleURL:moduleName:initialProps:launchOptions:")
    guard factory.responds(to: selector) else {
      promise.reject("NO_METHOD", "Factory doesn't respond to recreateRootView")
      return
    }
    
    // Reset the factory to allow recreation
    if let rootViewFactory = factory.value(forKey: "rootViewFactory") as? NSObject {
      if RCTIsNewArchEnabled() {
        rootViewFactory.setValue(nil as Any?, forKey: "_reactHost")
      } else {
        rootViewFactory.setValue(nil, forKey: "bridge")
      }
    }
    factory.setValue(nil, forKey: "bridge")
    
    // Call recreateRootView using Objective-C runtime
    typealias RecreateRootViewFunc = @convention(c) (Any, Selector, URL?, String?, [AnyHashable: Any]?, [AnyHashable: Any]?) -> UIView
    let method = class_getInstanceMethod(type(of: factory), selector)!
    let implementation = method_getImplementation(method)
    let typedImplementation = unsafeBitCast(implementation, to: RecreateRootViewFunc.self)
    
    let rootView = typedImplementation(
      factory,
      selector,
      bundleUrl,
      "main",
      nil,
      nil
    )
    
    // Apply background color from manifest if available
    if let backgroundColor = manifest.iosOrRootBackgroundColor() {
      rootView.backgroundColor = self.hexStringToColor(backgroundColor)
    }
    
    self.currentRootView = rootView
    self.currentManifest = manifest
    
    // Get the key window
    var window: UIWindow?
    if #available(iOS 15.0, *) {
      window = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow }
    } else {
      window = UIApplication.shared.windows.first { $0.isKeyWindow }
    }
    
    guard let keyWindow = window else {
      promise.reject("NO_WINDOW", "Could not find key window")
      return
    }
    
    let hostVC = UIViewController()
    hostVC.view = rootView
    
    // Present full screen
    keyWindow.rootViewController?.present(hostVC, animated: true) {
      promise.resolve([
        "success": true,
        "bundleUrl": bundleUrlString,
        "name": manifest.name() as Any,
        "slug": manifest.slug() as Any
      ])
    }
  }
  
  // Helper function to convert hex color string to UIColor
  private func hexStringToColor(_ hex: String) -> UIColor {
    var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
    
    var rgb: UInt64 = 0
    Scanner(string: hexSanitized).scanHexInt64(&rgb)
    
    let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
    let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
    let blue = CGFloat(rgb & 0x0000FF) / 255.0
    
    return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
  }
}