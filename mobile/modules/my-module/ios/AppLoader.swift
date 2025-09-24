import Foundation
import ExpoModulesCore
import EXManifests
import React

public class AppLoader: NSObject {
  
  public override init() {
    super.init()
  }
  
  public func loadAndShowApp(
    manifest: Manifest,
    promise: Promise
  ) {
    let bundleUrlString = manifest.bundleUrl()
    
    guard let bundleUrl = URL(string: bundleUrlString) else {
      promise.reject("INVALID_URL", "Invalid bundle URL from manifest: \(bundleUrlString)")
      return
    }
    
    print("🟢 Loading app via EXDevLauncherController: \(bundleUrl.absoluteString)")
    
    // Get the EXDevLauncherController singleton
    guard let controllerClass = NSClassFromString("EXDevLauncherController") as? NSObject.Type else {
      promise.reject("NO_CONTROLLER", "EXDevLauncherController not found")
      return
    }
    
    guard let controller = controllerClass.perform(NSSelectorFromString("sharedInstance"))?.takeUnretainedValue() else {
      promise.reject("NO_INSTANCE", "Could not get EXDevLauncherController instance")
      return
    }
    
    // Call loadApp:onSuccess:onError: using Objective-C runtime
    let loadAppSelector = NSSelectorFromString("loadApp:onSuccess:onError:")
    
    guard controller.responds(to: loadAppSelector) else {
      promise.reject("NO_METHOD", "loadApp method not found")
      return
    }
    
    // Create callback blocks
    let onSuccess: @convention(block) () -> Void = {
      print("🟢 App loaded successfully!")
      promise.resolve([
        "success": true,
        "bundleUrl": bundleUrlString,
        "name": manifest.name() as Any,
        "slug": manifest.slug() as Any
      ])
    }
    
    let onError: @convention(block) (NSError) -> Void = { error in
      print("❌ Failed to load app: \(error.localizedDescription)")
      promise.reject("LOAD_FAILED", error.localizedDescription)
    }
    
    // Perform the method call
    typealias LoadAppFunc = @convention(c) (AnyObject, Selector, URL, Any?, Any?) -> Void
    let method = class_getInstanceMethod(type(of: controller), loadAppSelector)!
    let implementation = method_getImplementation(method)
    let typedFunc = unsafeBitCast(implementation, to: LoadAppFunc.self)
    
    typedFunc(controller, loadAppSelector, bundleUrl, onSuccess, onError)
    
    print("🟢 loadApp called, waiting for response...")
  }
}