#import <AdorableDevLauncher/EXDevLauncherReactNativeFactory.h>
#import <EXDevMenu/DevClientNoOpLoadingView.h>
#import <React/RCTBridge.h>
#import <React/RCTRootView.h>

@implementation AdorableDevLauncherReactNativeFactory

- (Class)getModuleClassFromName:(const char *)name
{
  // Overrides DevLoadingView ("Connect to Metro to develop JavaScript") as no-op when loading dev-launcher bundle
  if (strcmp(name, "DevLoadingView") == 0) {
    return [DevClientNoOpLoadingView class];
  }
  return [super getModuleClassFromName:name];
}

- (UIView *)recreateRootViewWithBundleURL:(NSURL *)bundleURL
                               moduleName:(NSString * _Nullable)moduleName
                             initialProps:(NSDictionary * _Nullable)initialProps
                            launchOptions:(NSDictionary * _Nullable)launchOptions
{
  // Reset any existing bridge/rootViewFactory state so we create a fresh instance
  self.bridge = nil;
  self.rootViewFactory.bridge = nil;

  RCTBridge *bridge = [[RCTBridge alloc] initWithBundleURL:bundleURL
                                           moduleProvider:nil
                                            launchOptions:launchOptions];

  self.bridge = bridge;
  self.rootViewFactory.bridge = bridge;

  NSString *resolvedModuleName = moduleName ?: @"main";
  RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:bridge
                                                   moduleName:resolvedModuleName
                                            initialProperties:initialProps];
  return rootView;
}

@end