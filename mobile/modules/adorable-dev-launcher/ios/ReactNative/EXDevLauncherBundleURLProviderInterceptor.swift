// Copyright 2015-present 650 Industries. All rights reserved.

// swiftlint:disable type_name
@objc
public class AdorableDevLauncherBundleURLProviderInterceptor: NSObject {
  @objc
  public static var isInstalled: Bool = false {
    willSet {
      if isInstalled != newValue {
        swizzle()
      }
    }
  }

  static private func swizzle() {
    AdorableDevLauncherUtils.swizzle(
      selector: #selector(RCTBundleURLProvider.guessPackagerHost),
      withSelector: #selector(RCTBundleURLProvider.AdorableDevLauncher_guessPackagerHost),
      forClass: RCTBundleURLProvider.self
    )
  }
}

extension RCTBundleURLProvider {
  @objc
  func AdorableDevLauncher_guessPackagerHost() -> String? {
    // We set the packager host by hand.
    // So we don't want to guess the packager host, cause it can take a lot of time.
    return nil
  }
}
// swiftlint:enable type_name
