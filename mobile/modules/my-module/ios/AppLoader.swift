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
      
      // Clean up external app factory
      if let factory = self.externalAppFactory {
        print("🔴 Closing external app")
        // Invalidate the bridge if it exists
        if let bridge = factory.value(forKey: "bridge") as? NSObject {
          _ = bridge.perform(NSSelectorFromString("invalidate"))
        }
        self.externalAppFactory = nil
      }
      
      // Clean up delegate
      self.externalAppDelegate = nil
      
      // Restore the original root view controller
      if let window = UIApplication.shared.delegate?.window as? UIWindow,
         let originalVC = self.originalRootViewController {
        print("🔴 Restoring original app view")
        window.rootViewController = originalVC
        window.makeKeyAndVisible()
        
        // Clean up external window
        self.externalAppWindow?.isHidden = true
        self.externalAppWindow = nil
        
        promise.resolve(["success": true, "closed": true])
      } else {
        promise.reject("NO_ORIGINAL", "No original view to restore")
      }
    }
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
      // Get the main window
      guard let mainWindow = UIApplication.shared.delegate?.window as? UIWindow else {
        promise.reject("NO_WINDOW", "Could not access application window")
        return
      }
      
      // Store the original root view controller if not already stored
      if self.originalRootViewController == nil {
        self.originalRootViewController = mainWindow.rootViewController
      }
      
      // Clean up any existing external app
      if let existingFactory = self.externalAppFactory {
        print("🔄 Cleaning up existing external app...")
        if let bridge = existingFactory.value(forKey: "bridge") as? NSObject {
          _ = bridge.perform(NSSelectorFromString("invalidate"))
        }
        self.externalAppFactory = nil
        self.externalAppDelegate = nil
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
      
      // Create a new window for the external app (or reuse main window)
      let window = self.externalAppWindow ?? mainWindow
      self.externalAppWindow = window
      
      // Start React Native with the external app
      factory.startReactNative(
        withModuleName: moduleName,
        in: window,
        launchOptions: nil
      )
      
      // Apply background color if specified
      if let bgColorHex = manifest.iosOrRootBackgroundColor() {
        window.backgroundColor = self.hexStringToUIColor(hex: bgColorHex)
      }
      
      // Make sure the window is visible
      window.makeKeyAndVisible()
      
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

