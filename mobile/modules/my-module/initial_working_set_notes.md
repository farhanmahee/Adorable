# Dynamic Expo App Loading System - Technical Documentation

## Overview

This system enables loading external Expo applications dynamically within a host Expo app on iOS. It fetches manifest data from a remote server and loads the app's JavaScript bundle into the host application at runtime.

## Architecture

### How It Works

1. **Manifest Fetching**: The system fetches an Expo manifest from a remote URL
2. **Bundle URL Extraction**: Extracts the JavaScript bundle URL from the manifest
3. **App Loading**: Uses `EXDevLauncherController` to load the external app with all necessary modules
4. **Presentation**: The loaded app appears in the host application

### Key Components

**Expo Module (`MyModule`):**
- `fetchAndLoadManifest(url)` - Main entry point that fetches manifest and loads app
- `loadAndShowAppFromManifest(manifest)` - Loads app from a manifest object
- `ManifestFetcher.swift` - Handles HTTP requests and manifest parsing
- `AppLoader.swift` - Orchestrates the app loading process

## Critical Learnings

### What Works

**✅ Using EXDevLauncherController**

The winning approach uses Expo's built-in dev launcher controller:

```swift
EXDevLauncherController.sharedInstance().loadApp(url, onSuccess: {}, onError: {})
```

This provides:
- Automatic module registration (EventDispatcher, RedBox, DevSettings, etc.)
- Proper bridge lifecycle management
- Full compatibility with Expo's module system
- No manual module wrangling needed

**✅ Manifest Processing**
- Expo manifests contain the bundle URL in `launchAsset.url`
- The URL needs protocol modification (http→https, adjust ports) for HTTPS servers
- Modern manifests use `expo-updates` format with `launchAsset` structure

### What Doesn't Work

**❌ Creating Custom RCTBridge**

Creating a raw `RCTBridge` with custom delegate leads to missing core modules. While you can manually provide modules via `extraModules(for:)`, this requires reimplementing React Native's module infrastructure.

**❌ Modifying Main Bridge**

Changing `bundleURL` on the main app's bridge and calling `reload()` destroys the main app's context rather than creating an isolated instance.

**❌ Using Factory's recreateRootView Directly**

The `ExpoReactNativeFactory.recreateRootView()` method exists but isn't exposed to Swift/Objective-C runtime in a way that's easily accessible from external modules.

**❌ Factory View Creation Returns Deferred Views**

When expo-dev-launcher is installed, `factory.rootViewFactory.view()` returns `EXDevLauncherDeferredRCTRootView` - a placeholder, not a real view.

## Pitfalls & Gotchas

### Version Compatibility

**CRITICAL**: The external app's React Native version MUST match the host app's version exactly.

- Mismatch causes: `React Native version mismatch` error
- Solution: Align React Native versions in both apps' `package.json`
- Easiest approach: Use the same Expo SDK version in both projects

### Module Access Issues

Module properties in AppDelegate need `@objc dynamic` for KVC access:

```swift
@objc dynamic var reactNativeFactory: RCTReactNativeFactory?
```

Without this, you get `NSUnknownKeyException: not key value coding-compliant`

### URL Protocol Handling

- Expo's metro bundler URL uses `http://` by default
- If your server requires HTTPS, you must transform the URL
- Port numbers may need adjustment (e.g., 8081→443)

### Swift Runtime Limitations

- Objective-C classes accessed via `NSClassFromString` need careful casting
- Use `perform(NSSelectorFromString())` for dynamic method calls
- Generic protocols like `RCTBridgeModule.Type` don't have `init()` - need concrete types

### Dependencies Required

Your podspec needs:

```ruby
s.dependency 'ExpoModulesCore'
s.dependency 'EXManifests'
s.dependency 'EXUpdatesInterface'
s.dependency 'React-Core'
s.dependency 'React-RCTAppDelegate'
s.dependency 'ReactAppDependencyProvider'
s.dependency 'Expo'
```

## Pros & Cons

### Advantages

- ✅ No app store approval needed for updates to loaded apps
- ✅ Dynamic content loading at runtime
- ✅ Reuses host app's Expo module infrastructure
- ✅ Full access to native modules in loaded app
- ✅ Leverages battle-tested expo-dev-launcher code

### Disadvantages

- ❌ Strict version coupling between host and loaded apps
- ❌ Requires expo-dev-launcher to be present (debug builds)
- ❌ Limited to development/testing scenarios (expo-dev-launcher is debug-only)
- ❌ Cannot load apps with different React Native versions
- ❌ Network dependency for manifest and bundle fetching

## Production Considerations

### Current Limitations

- `EXDevLauncherController` only exists in debug builds (when `EXAppDefines.APP_DEBUG` is true)
- For production, you'd need a different approach, possibly:
  - Using expo-updates for OTA updates
  - Building a custom bridge manager
  - Pre-bundling allowed apps

### Security Considerations

- Validates manifest structure but doesn't verify bundle authenticity
- Should add signature verification for production
- Consider allowlisting permitted bundle URLs
- Network requests should use certificate pinning

## Usage Example

```typescript
import { fetchAndLoadManifest } from './modules/my-module';

// Load an external Expo app
try {
  const result = await fetchAndLoadManifest(
    'https://example.com/api/manifest'
  );
  console.log('Loaded app:', result);
} catch (error) {
  console.error('Failed to load app:', error);
}
```

## Future Improvements

1. **Production Support**: Implement loading mechanism that works without expo-dev-launcher
2. **Version Detection**: Automatically detect version mismatches before loading
3. **Bundle Caching**: Cache downloaded bundles for offline use
4. **Security**: Add bundle signature verification
5. **UI States**: Add loading indicators and error states
6. **Multi-app Management**: Support loading multiple apps without conflicts

## File Reference

### Implementation Files Created

- `modules/my-module/ios/AppLoader.swift` - Core app loading logic
- `modules/my-module/ios/ManifestFetcher.swift` - Manifest HTTP fetching and parsing
- `modules/my-module/src/MyModule.tsx` - TypeScript module interface
- `modules/my-module/src/index.ts` - Module exports

### Modified Files

- `ios/AppDelegate.swift` - Added `@objc dynamic var reactNativeFactory`

### Key Expo Source References

Studied these Expo source files for understanding:

- `/packages/expo-dev-launcher/ios/EXDevLauncherController.m` - Main controller implementation
- `/packages/expo-dev-launcher/ios/ReactDelegateHandler/ExpoDevLauncherReactDelegateHandler.swift` - React delegate handling
- `/packages/expo/ios/AppDelegates/ExpoReactNativeFactory.swift` - Factory implementation
- `/packages/expo-modules-core/ios/AppDelegates/ExpoReactNativeFactoryProtocol.swift` - Protocol definitions
- `/packages/expo-dev-launcher/expo-dev-launcher.podspec` - Dependency configuration

### External Dependencies

- **freestyle-expo app** (https://github.com/freestyle-sh/freestyle-expo) - The loadable external app
- Manifest endpoint structure follows expo-updates manifest format

---

## Final Implementation

### AppLoader.swift

```swift
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
    
    // Get the EXDevLauncherController singleton
    guard let controllerClass = NSClassFromString("EXDevLauncherController") as? NSObject.Type else {
      promise.reject("NO_CONTROLLER", "EXDevLauncherController not found")
      return
    }
    
    guard let controller = controllerClass.perform(NSSelectorFromString("sharedInstance"))?.takeUnretainedValue() else {
      promise.reject("NO_INSTANCE", "Could not get EXDevLauncherController instance")
      return
    }
    
    // Call loadApp:onSuccess:onError:
    let loadAppSelector = NSSelectorFromString("loadApp:onSuccess:onError:")
    
    guard controller.responds(to: loadAppSelector) else {
      promise.reject("NO_METHOD", "loadApp method not found")
      return
    }
    
    // Create callback blocks
    let onSuccess: @convention(block) () -> Void = {
      promise.resolve([
        "success": true,
        "bundleUrl": bundleUrlString,
        "name": manifest.name() as Any,
        "slug": manifest.slug() as Any
      ])
    }
    
    let onError: @convention(block) (NSError) -> Void = { error in
      promise.reject("LOAD_FAILED", error.localizedDescription)
    }
    
    // Perform the method call
    typealias LoadAppFunc = @convention(c) (AnyObject, Selector, URL, Any?, Any?) -> Void
    let method = class_getInstanceMethod(type(of: controller), loadAppSelector)!
    let implementation = method_getImplementation(method)
    let typedFunc = unsafeBitCast(implementation, to: LoadAppFunc.self)
    
    typedFunc(controller, loadAppSelector, bundleUrl, onSuccess, onError)
  }
}
```

### Key AppDelegate Modification

```swift
@UIApplicationMain
public class AppDelegate: ExpoAppDelegate {
  var window: UIWindow?

  var reactNativeDelegate: ExpoReactNativeFactoryDelegate?
  @objc dynamic var reactNativeFactory: RCTReactNativeFactory?  // @objc dynamic is critical!

  // ... rest of implementation
}
```