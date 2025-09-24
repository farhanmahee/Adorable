import Foundation
import ExpoModulesCore
import EXManifests

/**
 * Production-ready AppLoader that works the same in dev and prod
 * Creates its own bridge with proper module registration
 * Uses runtime reflection to avoid import issues with React framework
 */
public class AppLoader: NSObject {
  
  private var appBridge: AnyObject? // Will hold RCTBridge
  private weak var window: UIWindow?
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
      
      // Invalidate the bridge if it exists
      if let bridge = self.appBridge {
        print("🔴 Closing app and invalidating bridge")
        _ = bridge.perform(NSSelectorFromString("invalidate"))
        self.appBridge = nil
      }
      
      // Reset the window to show the original app
      promise.resolve(["success": true, "closed": true])
    }
  }
  
  public func loadAndShowApp(
    manifest: Manifest,
    promise: Promise
  ) {
    print("⚡️ loadAndShowApp called at: \(Date())")
    print("📍 Call stack: \(Thread.callStackSymbols.prefix(5).joined(separator: "\n"))")
    
    let bundleUrlString = manifest.bundleUrl()
    
    guard let bundleUrl = URL(string: bundleUrlString) else {
      promise.reject("INVALID_URL", "Invalid bundle URL from manifest: \(bundleUrlString)")
      return
    }
    
    self.bundleURL = bundleUrl
    
    print("🟢 Loading app from: \(bundleUrl.absoluteString)")
    
    // Get the main window
    guard let window = UIApplication.shared.delegate?.window as? UIWindow else {
      promise.reject("NO_WINDOW", "Could not access application window")
      return
    }
    self.window = window
    
    // Clean up existing bridge if any
    if let existingBridge = self.appBridge {
      print("🔄 Invalidating existing bridge...")
      _ = existingBridge.perform(NSSelectorFromString("invalidate"))
      self.appBridge = nil
    }
    
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      
      // Get RCTBridge class
      guard let bridgeClass = NSClassFromString("RCTBridge") as? NSObject.Type else {
        promise.reject("NO_BRIDGE_CLASS", "RCTBridge class not found")
        return
      }
      
      // Create the bridge with proper configuration
      print("🔨 Creating new bridge...")
      
      // Create an instance of RCTBridge
      let bridge = bridgeClass.init()
      
      // Set the delegate and launch options using setValue
      bridge.setValue(self, forKey: "delegate")
      bridge.setValue([:] as [String: Any], forKey: "launchOptions")
      
      // Initialize the bridge
      bridge.perform(NSSelectorFromString("setUp"))
      
      self.appBridge = bridge
      
      // Get RCTRootView class
      guard let rootViewClass = NSClassFromString("RCTRootView") as? UIView.Type else {
        promise.reject("NO_ROOTVIEW_CLASS", "RCTRootView class not found")
        return
      }
      
      // Create root view
      let moduleName = manifest.slug() ?? "main"
      print("📦 Creating root view for module: \(moduleName)")
      
      // Create RCTRootView instance
      let rootView = rootViewClass.init()
      
      // Configure the root view with bridge and module name
      rootView.setValue(self.appBridge, forKey: "bridge")
      rootView.setValue(moduleName, forKey: "moduleName")
      rootView.setValue([:] as [String: Any], forKey: "appProperties")
      
      // Trigger the root view to load
      if rootView.responds(to: NSSelectorFromString("runApplication")) {
        rootView.perform(NSSelectorFromString("runApplication"))
      }
      
      // Apply background color if specified
      if let bgColorHex = manifest.iosOrRootBackgroundColor() {
        rootView.backgroundColor = self.hexStringToUIColor(hex: bgColorHex)
        window.backgroundColor = rootView.backgroundColor
      }
      
      // Create root view controller
      let rootViewController = UIViewController()
      rootViewController.view = rootView
      
      // Set as window's root
      window.rootViewController = rootViewController
      window.makeKeyAndVisible()
      
      print("✅ App loaded successfully!")
      
      promise.resolve([
        "success": true,
        "bundleUrl": bundleUrlString,
        "name": manifest.name() as Any,
        "slug": manifest.slug() as Any
      ])
    }
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
  @objc public func sourceURL(for bridge: AnyObject) -> URL? {
    print("🔗 Bridge requesting source URL: \(self.bundleURL?.absoluteString ?? "nil")")
    return self.bundleURL
  }
  
  // This will be called by RCTBridge via runtime for extra modules
  @objc public func extraModules(for bridge: AnyObject) -> [Any] {
    print("📦 Providing extra modules for bridge...")
    
    var modules: [Any] = []
    
    // 1. Get modules from the AppDelegate if available
    if let appDelegate = UIApplication.shared.delegate {
      let selector = NSSelectorFromString("extraModulesForBridge:")
      if appDelegate.responds(to: selector),
         let result = appDelegate.perform(selector, with: bridge),
         let delegateModules = result.takeUnretainedValue() as? [Any] {
        print("   ✓ Added \(delegateModules.count) modules from AppDelegate")
        modules.append(contentsOf: delegateModules)
      }
    }
    
    // 2. Add Expo modules using the generated ExpoModulesProvider
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
    
    // 3. Manually add essential React Native modules if not already present
    #if DEBUG
    // Add dev support modules in debug builds
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
  @objc public func bridge(_ bridge: AnyObject, didNotFindModule moduleName: String) -> Bool {
    print("⚠️ Bridge could not find module: \(moduleName)")
    // Return false to use default behavior
    return false
  }
}

