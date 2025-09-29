// Copyright 2015-present 650 Industries. All rights reserved.

import Foundation

@objc
public class AdorableDevLauncherRedBoxInterceptor: NSObject {
  @objc static let customRedBox = AdorableDevLauncherRedBox()

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
      selector: #selector(RCTCxxBridge.module(forName:)),
      withSelector: #selector(RCTCxxBridge.AdorableDevLauncher_module(forName:)),
      forClass: RCTCxxBridge.self
    )

    AdorableDevLauncherUtils.swizzle(
      selector: #selector(RCTCxxBridge.module(forName:lazilyLoadIfNecessary:)),
      withSelector: #selector(RCTCxxBridge.AdorableDevLauncher_module(forName:lazilyLoadIfNecessary:)),
      forClass: RCTCxxBridge.self
    )

    AdorableDevLauncherUtils.swizzle(
      selector: #selector(RCTCxxBridge.module(for:)),
      withSelector: #selector(RCTCxxBridge.AdorableDevLauncher_module(forClass:)),
      forClass: RCTCxxBridge.self
    )
  }
}

extension RCTCxxBridge {
  @objc
  func AdorableDevLauncher_module(forName name: String) -> Any? {
    let orginalModule = self.AdorableDevLauncher_module(forName: name)
    return replaceRedBox(orginalModule)
  }

  @objc
  func AdorableDevLauncher_module(forName name: String, lazilyLoadIfNecessary lazilyLoad: Bool) -> Any? {
    let orginalModule = self.AdorableDevLauncher_module(forName: name, lazilyLoadIfNecessary: lazilyLoad)
    return replaceRedBox(orginalModule)
  }

  @objc
  func AdorableDevLauncher_module(forClass clazz: Any) -> Any? {
    let orginalModule = self.AdorableDevLauncher_module(forClass: clazz)
    return replaceRedBox(orginalModule)
  }

  @objc
  private func replaceRedBox(_ module: Any?) -> Any? {
    if module is RCTRedBox {
      let logBox = AdorableDevLauncher_module(forClass: RCTLogBox.self) as? RCTLogBox
      let customRedBox = AdorableDevLauncherRedBoxInterceptor.customRedBox
      customRedBox.register(logBox)
      return customRedBox.unsafe_castToRCTRedBox()
    }

    return module
  }
}
