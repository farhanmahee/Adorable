import ExpoModulesCore
import UIKit
import React

public class DevLauncherModule: Module {
  public func definition() -> ModuleDefinition {
    Name("DevLauncher")

    Events("onLoad")

    // Expose ReactBundleView as a native view component
    View(ReactBundleView.self) {
      Events("onLoad")

      Prop("url") { (view: ReactBundleView, url: URL) in
        view.loadBundle(url: url)
      }
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
    AsyncFunction("detectMetroRunning") {
       if RCTBundleURLProvider.isPackagerRunning("nnyue.vm.freestyle.sh:8081") {
         return true
       } else {
         return false
       }
    }

    Function("isRCTDevEnabled") {
      #if RCT_DEV 
      return true
      #else
      return false
      #endif
    }

  }
}
