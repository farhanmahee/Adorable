// Copyright 2018-present 650 Industries. All rights reserved.

import ExpoModulesCore
import EXUpdatesInterface
import React
import AdorableDevLauncher

@objc
public class ExpoDevLauncherReactDelegateHandler: ExpoReactDelegateHandler, AdorableDevLauncherControllerDelegate {
  private var reactNativeFactory: AdorableDevLauncherReactNativeFactory?
  private weak var reactDelegate: ExpoReactDelegate?
  private var launchOptions: [AnyHashable: Any]?
  private var deferredRootView: AdorableDevLauncherDeferredRCTRootView?
  private var rootViewModuleName: String?
  private var rootViewInitialProperties: [AnyHashable: Any]?

  public override func createReactRootView(
    reactDelegate: ExpoReactDelegate,
    moduleName: String,
    initialProperties: [AnyHashable: Any]?,
    launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> UIView? {
    if !EXAppDefines.APP_DEBUG {
      return nil
    }

    print("[AdorableDevLauncher][Handler] createReactRootView called for module \(moduleName)")
    self.reactDelegate = reactDelegate
    self.launchOptions = launchOptions
    print("[AdorableDevLauncher][Handler] Calling autoSetupPrepare")
    AdorableDevLauncherController.sharedInstance().autoSetupPrepare(self, launchOptions: launchOptions)
    if let sharedController = UpdatesControllerRegistry.sharedInstance.controller {
      // for some reason the swift compiler and bridge are having issues here
      AdorableDevLauncherController.sharedInstance().updatesInterface = sharedController
      sharedController.updatesExternalInterfaceDelegate = AdorableDevLauncherController.sharedInstance()
    }

    self.rootViewModuleName = moduleName
    self.rootViewInitialProperties = initialProperties
    self.deferredRootView = AdorableDevLauncherDeferredRCTRootView()
    return self.deferredRootView
  }

  @objc
  public func isReactInstanceValid() -> Bool {
    return self.reactNativeFactory?.rootViewFactory.value(forKey: "reactHost") != nil
  }

  @objc
  public func destroyReactInstance() {
    self.reactNativeFactory?.rootViewFactory.setValue(nil, forKey: "reactHost")
  }

  // MARK: EXDevelopmentClientControllerDelegate implementations

  public func devLauncherController(_ developmentClientController: AdorableDevLauncherController, didStartWithSuccess success: Bool) {
    print("[AdorableDevLauncher][Handler] didStartWithSuccess=\(success)")
    guard let reactDelegate = self.reactDelegate else {
      fatalError("`reactDelegate` should not be nil")
    }

    // Instantiate our own factory (compat layer), since ExpoReactDelegate no longer exposes it
    self.reactNativeFactory = AdorableDevLauncherReactNativeFactory()

    // Reset rctAppDelegate so we can relaunch the app
    if RCTIsNewArchEnabled() {
      self.reactNativeFactory?.rootViewFactory.setValue(nil, forKey: "_reactHost")
    } else {
      self.reactNativeFactory?.bridge = nil
      self.reactNativeFactory?.rootViewFactory.bridge = nil
    }

    guard let factory = self.reactNativeFactory else {
      fatalError("`reactNativeFactory` should not be nil")
    }

    guard let bundleURL = developmentClientController.sourceUrl() else {
      fatalError("Expected non-nil source URL from AdorableDevLauncherController")
    }
    print("[AdorableDevLauncher][Handler] Using bundleURL: \(bundleURL)")

    let rootView = factory.recreateRootView(
      withBundleURL: bundleURL,
      moduleName: self.rootViewModuleName,
      initialProps: self.rootViewInitialProperties,
      launchOptions: developmentClientController.getLaunchOptions()
    )
    developmentClientController.appBridge = RCTBridge.current()
    rootView.backgroundColor = self.deferredRootView?.backgroundColor ?? UIColor.white
    let window = getWindow()

    // NOTE: this order of assignment seems to actually have an effect on behaviour
    // direct assignment of window.rootViewController.view = rootView does not work
    guard let rootViewController = self.reactDelegate?.createRootViewController() else {
      fatalError("Invalid rootViewController returned from ExpoReactDelegate")
    }
    // Ensure UI work happens on the main thread and the view fills the window
    DispatchQueue.main.async {
      rootView.frame = window.bounds
      rootView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      print("[AdorableDevLauncher][Handler] Mounting root view for module \(self.rootViewModuleName ?? "<nil>") on main thread")
      // Use controller helper to properly mount the React root view (handles Fabric/new arch nuances)
      AdorableDevLauncherController.sharedInstance().setRootView(rootView, toRootViewController: rootViewController)
      window.rootViewController = rootViewController
      window.makeKeyAndVisible()
      print("[AdorableDevLauncher][Handler] Root view set via controller helper and window made key and visible")
    }

    // it is purposeful that we don't clean up saved properties here, because we may initialize
    // several React instances over a single app lifetime and we want them all to have the same
    // initial properties
  }

  // MARK: Internals

  private func getWindow() -> UIWindow {
    guard let window = UIApplication.shared.windows.filter(\.isKeyWindow).first ?? UIApplication.shared.delegate?.window as? UIWindow else {
      fatalError("Cannot find the current window.")
    }
    return window
  }
}