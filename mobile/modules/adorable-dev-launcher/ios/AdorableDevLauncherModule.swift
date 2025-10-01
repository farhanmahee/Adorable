import ExpoModulesCore
import AdorableDevLauncher
import React

public class AdorableDevLauncherModule: Module {
  // Each module class must implement the definition function. The definition consists of components
  // that describes the module's functionality and behavior.
  // See https://docs.expo.dev/modules/module-api for more details about available components.
  public func definition() -> ModuleDefinition {
    // Sets the name of the module that JavaScript code will use to refer to the module. Takes a string as an argument.
    // Can be inferred from module's class name, but it's recommended to set it explicitly for clarity.
    // The module will be accessible from `requireNativeModule('AdorableDevLauncher')` in JavaScript.
    Name("AdorableDevLauncher")

    // Defines event names that the module can send to JavaScript.
    Events("onChange")



   
    // Loads the app from an explicit Metro bundle URL (preserves host/path)
    AsyncFunction("loadAppWithURL") { (urlString: String, promise: Promise) in
      print("[AdorableDevLauncher] loadAppWithURL() invoked with \(urlString)")
      guard let url = URL(string: urlString) else {
        self.sendEvent("onChange", [
          "event": "loadAppInvalidUrl",
          "url": urlString
        ])
        promise.reject("ERR_DEV_LAUNCHER_INVALID_URL", "Invalid URL: \(urlString)")
        return
      }

      self.sendEvent("onChange", [
        "event": "loadAppCalled",
        "url": url.absoluteString
      ])
      let controller = AdorableDevLauncherController.sharedInstance()
      print("Controller instance: \(controller!)")
      controller.loadApp(url, onSuccess: {
        let resolved = controller.sourceUrl()
        if let resolved = resolved {
          print("[AdorableDevLauncher] controller sourceUrl: \(resolved)")
          self.sendEvent("onChange", [
            "event": "loadAppResolvedSource",
            "url": resolved.absoluteString
          ])
        } else {
          print("[AdorableDevLauncher] controller sourceUrl is nil")
        }
        print("[AdorableDevLauncher] loadAppWithURL success")
        self.sendEvent("onChange", [
          "event": "loadAppSuccess",
          "url": url.absoluteString
        ])
        promise.resolve(nil)
      }, onError: { error in
        let nsError = error as NSError
        print("[AdorableDevLauncher] loadAppWithURL error: \(nsError.localizedDescription) domain=\(nsError.domain) code=\(nsError.code)")
        self.sendEvent("onChange", [
          "event": "loadAppError",
          "message": nsError.localizedDescription,
          "domain": nsError.domain,
          "code": nsError.code
        ])
        promise.reject("ERR_DEV_LAUNCHER_LOAD", nsError.localizedDescription)
      })
    }


  }
}
