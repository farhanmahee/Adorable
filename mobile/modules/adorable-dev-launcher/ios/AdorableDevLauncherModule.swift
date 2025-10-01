import ExpoModulesCore
import UIKit

public class AdorableDevLauncherModule: Module {
  // Each module class must implement the definition function. The definition consists of components
  // that describes the module's functionality and behavior.
  // See https://docs.expo.dev/modules/module-api for more details about available components.
  public func definition() -> ModuleDefinition {
    // Sets the name of the module that JavaScript code will use to refer to the module. Takes a string as an argument.
    // Can be inferred from module's class name, but it's recommended to set it explicitly for clarity.
    // The module will be accessible from `requireNativeModule('AdorableDevLauncher')` in JavaScript.
    Name("AdorableDevLauncher")

    // Defines constant property on the module.
    Constant("PI") {
      Double.pi
    }

    // Defines event names that the module can send to JavaScript.
    Events("onChange")

    // Defines a JavaScript synchronous function that runs the native code on the JavaScript thread.
    Function("hello") {
      return "Hello worl👋"
    }

    // Defines a JavaScript function that always returns a Promise and whose native code
    // is by default dispatched on the different thread than the JavaScript runtime runs on.
    AsyncFunction("setValueAsync") { (value: String) in
      // Send an event to JavaScript.
      self.sendEvent("onChange", [
        "value": value
      ])
    }

    // Load a React Native app from a bundle URL in a modal
    AsyncFunction("loadAppFromBundleUrl") { (urlString: String) in
      guard let url = URL(string: urlString) else {
        throw Exception(name: "InvalidURL", description: "The provided URL string is invalid")
      }

      DispatchQueue.main.async {
        let reactViewController = ReactBundleViewController(bundleURL: url)

        // Get the root view controller to present from
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
          return
        }

        // Find the topmost presented view controller
        var topController = rootViewController
        while let presented = topController.presentedViewController {
          topController = presented
        }

        // Present the React Native view modally
        topController.present(reactViewController, animated: true)
      }
    }

    // Enables the module to be used as a native view. Definition components that are accepted as part of the
    // view definition: Prop, Events.
    View(AdorableDevLauncherView.self) {
      // Defines a setter for the `url` prop.
      Prop("url") { (view: AdorableDevLauncherView, url: URL) in
        if view.webView.url != url {
          view.webView.load(URLRequest(url: url))
        }
      }

      Events("onLoad")
    }
  }
}
