import Foundation
import Dispatch
import ExpoModulesCore
import EXManifests

/**
 * AppLoader that creates a separate bridge for external apps
 * Maintains isolation between main app and loaded apps
 */
public class AppLoader: NSObject {
  
  private weak var originalRootViewController: UIViewController?
  private var appRootViewController: UIViewController?
  private var appBridge: AnyObject? // Will hold the separate RCTBridge for external app
  private var bundleURL: URL?
  
  public override init() {
    super.init()
  }
  
  public func closeApp(promise: Promise) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        promise.reject("NO_INSTANCE", "AppLoader instance not available")
        return
      }
      
      // Invalidate the external app bridge if it exists
      if let bridge = self.appBridge {
        print("🔴 Closing external app and invalidating bridge")
        _ = bridge.perform(NSSelectorFromString("invalidate"))
        self.appBridge = nil
      }
      
      // Restore the original root view controller
      if let window = UIApplication.shared.delegate?.window as? UIWindow,
         let originalVC = self.originalRootViewController {
        print("🔴 Restoring original app view")
        window.rootViewController = originalVC
        window.makeKeyAndVisible()
        self.appRootViewController = nil
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
    
    self.bundleURL = bundleUrl
    
    print("🟢 Loading app from: \(bundleUrl.absoluteString)")
    
    // Create work item for main thread execution
    let workItem = DispatchWorkItem {
      // Get the main window
      guard let window = UIApplication.shared.delegate?.window as? UIWindow else {
        promise.reject("NO_WINDOW", "Could not access application window")
        return
      }
      
      // Store the original root view controller if not already stored
      if self.originalRootViewController == nil {
        self.originalRootViewController = window.rootViewController
      }
      
      // Clean up existing external app bridge if any
      if let existingBridge = self.appBridge {
        print("🔄 Invalidating existing external app bridge...")
        _ = existingBridge.perform(NSSelectorFromString("invalidate"))
        self.appBridge = nil
      }
      
      // Create a new bridge for the external app
      print("🔨 Creating new bridge for external app...")
      
      // We need to create the bridge using runtime methods since we can't import React directly
      guard let bridgeClass = NSClassFromString("RCTBridge") else {
        promise.reject("NO_BRIDGE_CLASS", "RCTBridge class not found")
        return
      }
      
      // Use the Objective-C runtime to allocate and initialize the bridge
      // First, get the alloc method
      let allocMethod = class_getClassMethod(bridgeClass as? AnyClass, NSSelectorFromString("alloc"))
      let allocIMP = method_getImplementation(allocMethod!)
      typealias AllocFunc = @convention(c) (AnyClass, Selector) -> AnyObject
      let allocFunc = unsafeBitCast(allocIMP, to: AllocFunc.self)
      let allocatedBridge = allocFunc(bridgeClass as! AnyClass, NSSelectorFromString("alloc"))
      
      // Now initialize with delegate
      let initSelector = NSSelectorFromString("initWithDelegate:launchOptions:")
      let _ = (allocatedBridge as! NSObject).perform(initSelector, with: self, with: nil)
      
      // Store the initialized bridge
      self.appBridge = allocatedBridge as? NSObject
      
      // Get RCTRootView class
      guard let rootViewClass = NSClassFromString("RCTRootView") else {
        promise.reject("NO_ROOTVIEW_CLASS", "RCTRootView class not found")
        return
      }
      
      // Create root view
      let moduleName = manifest.slug() ?? "main"
      print("📦 Creating root view for module: \(moduleName)")
      
      // Use the Objective-C runtime to allocate RCTRootView
      let rootViewAllocMethod = class_getClassMethod(rootViewClass as? AnyClass, NSSelectorFromString("alloc"))
      let rootViewAllocIMP = method_getImplementation(rootViewAllocMethod!)
      typealias RootViewAllocFunc = @convention(c) (AnyClass, Selector) -> AnyObject
      let rootViewAllocFunc = unsafeBitCast(rootViewAllocIMP, to: RootViewAllocFunc.self)
      let allocatedRootView = rootViewAllocFunc(rootViewClass as! AnyClass, NSSelectorFromString("alloc")) as! NSObject
      
      // Initialize RCTRootView with bridge, module name, and initial properties
      let rootViewInitSelector = NSSelectorFromString("initWithBridge:moduleName:initialProperties:")
      let initialProperties = ["manifestUrl": manifest.bundleUrl()] as NSDictionary
      
      // Use Objective-C runtime to call the 3-parameter initializer
      typealias RootViewInitFunc = @convention(c) (NSObject, Selector, AnyObject?, NSString?, NSDictionary?) -> NSObject
      let rootViewMethod = allocatedRootView.method(for: rootViewInitSelector)
      let rootViewInitFunc = unsafeBitCast(rootViewMethod, to: RootViewInitFunc.self)
      let _ = rootViewInitFunc(allocatedRootView, rootViewInitSelector, self.appBridge, moduleName as NSString, initialProperties)
      
      // Cast to UIView for use
      guard let rootView = allocatedRootView as? UIView else {
        promise.reject("ROOTVIEW_CAST_FAILED", "Failed to cast RCTRootView to UIView")
        return
      }
      
      // Apply background color if specified
      if let bgColorHex = manifest.iosOrRootBackgroundColor() {
        rootView.backgroundColor = self.hexStringToUIColor(hex: bgColorHex)
        window.backgroundColor = rootView.backgroundColor
      }
      
      // Create root view controller
      let rootViewController = UIViewController()
      rootViewController.view = rootView
      self.appRootViewController = rootViewController
      
      // Set as window's root
      window.rootViewController = rootViewController
      window.makeKeyAndVisible()
      
      print("✅ External app loaded successfully!")
      
      promise.resolve([
        "success": true,
        "bundleUrl": bundleUrlString,
        "name": manifest.name() as Any,
        "slug": manifest.slug() as Any
      ])
    }
    
    // Execute work item on main queue
    DispatchQueue.main.async(execute: workItem)
  }
  
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

// MARK: - Dynamic Bridge Delegate Methods
extension AppLoader {
  
  // This will be called by RCTBridge via runtime
  @objc(sourceURLForBridge:)
  public func sourceURL(for bridge: AnyObject) -> URL? {
    print("🔗 Bridge requesting source URL: \(self.bundleURL?.absoluteString ?? "nil")")
    return self.bundleURL
  }
  
  // This will be called by RCTBridge via runtime for extra modules
  @objc(extraModulesForBridge:)
  public func extraModules(for bridge: AnyObject) -> [Any] {
    print("📦 Providing extra modules for bridge...")
    
    var modules: [Any] = []
    
    // 1. Add Expo modules using the generated ExpoModulesProvider
    if let expoModulesProviderClass = NSClassFromString("ExpoModulesProvider") as? NSObject.Type {
      let provider = expoModulesProviderClass.init()
      let selector = NSSelectorFromString("getModulesForBridge:")
      if provider.responds(to: selector),
         let result = provider.perform(selector, with: bridge),
         let expoModules = result.takeUnretainedValue() as? [Any] {
        print("   ✓ Added \(expoModules.count) Expo modules")
        modules.append(contentsOf: expoModules)
      }
    }
    
    // 2. Add essential React Native modules
    let essentialModuleClasses = [
      "RCTAsyncLocalStorage",
      "RCTNetworking",
      "RCTImageLoader",
      "RCTUIManager",
      "RCTEventDispatcher"
    ]
    
    for className in essentialModuleClasses {
      if let moduleClass = NSClassFromString(className) as? NSObject.Type {
        let module = moduleClass.init()
        modules.append(module)
        print("   ✓ Added essential module: \(className)")
      }
    }
    
    // 3. Add dev support modules in debug builds
    #if DEBUG
    let devModuleClasses = ["RCTDevMenu", "RCTDevSettings"]
    
    for className in devModuleClasses {
      if let moduleClass = NSClassFromString(className) as? NSObject.Type {
        let module = moduleClass.init()
        modules.append(module)
        print("   ✓ Added dev module: \(className)")
      }
    }
    #endif
    
    print("📦 Total modules provided: \(modules.count)")
    return modules
  }
  
  // Optional: Handle missing modules
  @objc(bridge:didNotFindModule:)
  public func bridge(_ bridge: AnyObject, didNotFindModule moduleName: String) -> Bool {
    print("⚠️ Bridge could not find module: \(moduleName)")
    // Return false to use default behavior
    return false
  }
}

