// Copyright 2015-present 650 Industries. All rights reserved.

public protocol AdorableDevLauncherPendingDeepLinkListener: AnyObject {
  func onNewPendingDeepLink(_ deepLink: URL)
}
