import ExpoModulesCore
import EXManifests
import Alamofire

public class MyModule: Module {
  private let appLoader = AppLoader()
  
  public func definition() -> ModuleDefinition {
    Name("MyModule")

    Constant("PI") {
      Double.pi
    }

    Events("onChange")

    Function("hello") {
      return "Hello from iOS — this is a function and I can go off of this 👋"
    }

    AsyncFunction("loadManifest") { (promise: Promise) in
      ManifestLoader.loadManifest(
        from: "https://fuely.vm.freestyle.sh",
        promise: promise
      )
    }

    AsyncFunction("loadAndShowAppFromManifest") { (promise: Promise) in
      // Use the new completion handler method
      ManifestLoader.loadManifestObject(from: "https://fuely.vm.freestyle.sh") { result in
        switch result {
        case .success(let manifest):
          // Load and show the app with the manifest
          self.appLoader.loadAndShowApp(manifest: manifest, promise: promise)
          
        case .failure(let error):
          promise.reject("MANIFEST_LOAD_ERROR", error.localizedDescription)
        }
      }
    }

    AsyncFunction("closeApp") { (promise: Promise) in
      self.appLoader.closeApp(promise: promise)
    }

    AsyncFunction("setValueAsync") { (value: String) in
      self.sendEvent("onChange", [
        "value": value
      ])
    }

    View(MyModuleView.self) {
      Prop("url") { (view: MyModuleView, url: URL) in
        if view.webView.url != url {
          view.webView.load(URLRequest(url: url))
        }
      }

      Events("onLoad")
    }
  }
}
