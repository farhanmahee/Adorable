import Foundation
import Dispatch
import ExpoModulesCore
import EXManifests
import Expo
import React
import ReactAppDependencyProvider

/**
 * AppLoader that creates a separate React Native instance for external apps
 * Using ExpoReactNativeFactory for cleaner implementation
 */
public class AppLoader: NSObject {
  
  // MARK: - Properties
  
  private weak var originalRootViewController: UIViewController?
  private var externalAppWindow: UIWindow?
  private var externalAppFactory: ExpoReactNativeFactory?
  private var externalAppDelegate: ExternalAppDelegate?
  private var externalAppViewController: UIViewController?
  
  // MARK: - Initialization
  
  public override init() {
    super.init()
  }
  
  // MARK: - Public Methods
  
  public func closeApp(promise: Promise) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        promise.reject("NO_INSTANCE", "AppLoader instance not available")
        return
      }
      
      // Dismiss the modal if it exists
      if let modalVC = self.externalAppViewController {
        print("🔴 Dismissing external app modal")
        modalVC.dismiss(animated: true) {
          // Clean up after dismissal
          self.cleanupExternalApp()
          promise.resolve(["success": true, "closed": true])
        }
      } else {
        // No modal to dismiss
        self.cleanupExternalApp()
        promise.resolve(["success": true, "closed": false, "message": "No modal to close"])
      }
    }
  }
  
  @objc private func closeButtonTapped() {
    // Dismiss the modal when close button is tapped
    if let modalVC = self.externalAppViewController {
      print("🔴 Dismissing external app modal via close button")
      modalVC.dismiss(animated: true) {
        // Clean up after dismissal
        self.cleanupExternalApp()
      }
    }
  }
  
  private func cleanupExternalApp() {
    // Clean up external app factory
    if let factory = self.externalAppFactory {
      print("🔴 Cleaning up external app")
      // Invalidate the bridge if it exists
      if let bridge = factory.value(forKey: "bridge") as? NSObject {
        _ = bridge.perform(NSSelectorFromString("invalidate"))
      }
      self.externalAppFactory = nil
    }
    
    // Clean up delegate
    self.externalAppDelegate = nil
    
    // Clean up external window
    self.externalAppWindow?.isHidden = true
    self.externalAppWindow = nil
    
    // Clean up modal reference
    self.externalAppViewController = nil
  }
  
  public func loadAndShowApp(
    manifest: Manifest,
    promise: Promise
  ) {
    print("⚡️ loadAndShowApp called at: \(Date())")
    
    let bundleUrlString = manifest.bundleUrl()
    
    guard let bundleUrl = URL(string: bundleUrlString) else {
      promise.reject("INVALID_URL", "Invalid bundle URL from manifest: \(bundleUrlString)")
      return
    }
    
    print("🟢 Loading app from: \(bundleUrl.absoluteString)")
    
    DispatchQueue.main.async {
      // Get the current root view controller
      guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
        promise.reject("NO_ROOT_VC", "Could not access root view controller")
        return
      }
      
      // Store the original root view controller if not already stored
      if self.originalRootViewController == nil {
        self.originalRootViewController = rootViewController
      }
      
      
      // Create delegate for external app
      let delegate = ExternalAppDelegate(bundleURL: bundleUrl)
      delegate.dependencyProvider = RCTAppDependencyProvider()
      self.externalAppDelegate = delegate
      
      // Create factory for external app
      let factory = ExpoReactNativeFactory(delegate: delegate)
      self.externalAppFactory = factory
      
      // Get the module name from manifest
      let moduleName = manifest.slug() ?? "main"
      print("📦 Creating React Native instance for module: \(moduleName)")
      
      // Create a new window for the React Native instance
      let modalWindow = UIWindow(frame: UIScreen.main.bounds)
      modalWindow.windowLevel = UIWindow.Level.normal
      self.externalAppWindow = modalWindow
      
      // IMPORTANT: Make the window key and visible temporarily to ensure React Native starts
      print("🔑 Making external window key and visible for React Native initialization")
      modalWindow.makeKeyAndVisible()
      
      // Start React Native with the external app in the modal window
      factory.startReactNative(
        withModuleName: moduleName,
        in: modalWindow,
        launchOptions: nil
      )
      
      // Give React Native a moment to initialize
      // DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        // Get the root view controller from the modal window
        guard let externalRootVC = modalWindow.rootViewController else {
          print("⚠️ No root view controller created by factory")
          promise.reject("NO_EXTERNAL_VC", "Failed to create external app view controller")
          return
        }
        
        print("📱 React Native initialized, transferring to modal")
      
      // Create a modal view controller wrapper
      let modalViewController = UIViewController()
      modalViewController.modalPresentationStyle = .fullScreen
      modalViewController.modalTransitionStyle = .coverVertical
      
      // Instead of adding the view controller as a child, just take its view
      // This avoids the UIViewControllerHierarchyInconsistency error
      let externalView = externalRootVC.view!
      modalViewController.view.addSubview(externalView)
      externalView.frame = modalViewController.view.bounds
      externalView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      
      
      // Store reference to the modal
      self.externalAppViewController = modalViewController
      
      // Present the modal
      rootViewController.present(modalViewController, animated: true) {
        print("✅ External app presented in modal!")
      }
      
      print("✅ External app loaded successfully!")
      
      promise.resolve([
        "success": true,
        "bundleUrl": bundleUrlString,
        "name": manifest.name() as Any,
        "slug": manifest.slug() as Any
      ])
    }
  }
  
  // MARK: - Private Helpers
  
  private func hexStringToUIColor(hex: String?) -> UIColor? {
    guard let hex = hex else { return nil }
    
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

// MARK: - External App Delegate

class ExternalAppDelegate: ExpoReactNativeFactoryDelegate {
  private let externalBundleURL: URL
  
  init(bundleURL: URL) {
    self.externalBundleURL = bundleURL
    super.init()
  }
  
  override func sourceURL(for bridge: RCTBridge) -> URL? {
    print("🔗 Providing bundle URL for external app: \(externalBundleURL.absoluteString)")
    return externalBundleURL
  }
  
  override func bundleURL() -> URL? {
    return externalBundleURL
  }
}

