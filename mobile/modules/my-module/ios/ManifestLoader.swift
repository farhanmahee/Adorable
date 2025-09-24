import Foundation
import EXManifests
import Alamofire
import ExpoModulesCore

public class ManifestLoader {
  
  // Modify a URL string to use https on port 443
  private static func modifyUrl(_ urlString: String) -> String {
    guard let url = URL(string: urlString),
          url.scheme != nil,
          url.host != nil else {
      return urlString
    }
    
    var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
    components?.scheme = "https"
    components?.port = 443
    
    return components?.url?.absoluteString ?? urlString
  }
  
  public static func loadManifest(
    from urlString: String,
    promise: Promise
  ) {
    guard let url = URL(string: urlString) else {
      promise.reject("INVALID_URL", "The provided URL is invalid")
      return
    }
    
    let headers: HTTPHeaders = [
      "expo-platform": "ios",
      "accept": "application/expo+json,application/json"
    ]
    
    AF.request(url, headers: headers)
      .validate(statusCode: 200..<300)
      .responseJSON { response in
        switch response.result {
        case .success(let value):
          guard var manifestJSON = value as? [String: Any] else {
            promise.reject("PARSE_ERROR", "Manifest is not a valid JSON object")
            return
          }
          
          // Modify bundleUrl if it exists
          if let launchAsset = manifestJSON["launchAsset"] as? [String: Any],
             let bundleUrl = launchAsset["url"] as? String {
            var modifiedLaunchAsset = launchAsset
            modifiedLaunchAsset["url"] = modifyUrl(bundleUrl)
            manifestJSON["launchAsset"] = modifiedLaunchAsset
            
            print("Original bundleUrl: \(bundleUrl)")
            print("Modified bundleUrl: \(modifiedLaunchAsset["url"]!)")
          }
          
          // Create manifest object using EXManifests factory with modified JSON
          let manifest = ManifestFactory.manifest(forManifestJSON: manifestJSON)
          
          // Return manifest data
          promise.resolve([
            "bundleUrl": manifest.bundleUrl(),
            "easProjectId": manifest.easProjectId() as Any,
            "scopeKey": manifest.scopeKey(),
            "name": manifest.name() as Any,
            "slug": manifest.slug() as Any,
            "version": manifest.version() as Any,
            "isUsingDeveloperTool": manifest.isUsingDeveloperTool(),
            "rawManifest": manifestJSON
          ])
          
        case .failure(let error):
          promise.reject(error)
        }
      }
  }
}