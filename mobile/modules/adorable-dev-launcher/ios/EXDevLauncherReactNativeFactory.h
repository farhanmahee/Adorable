#pragma once

#if __has_include(<React-RCTAppDelegate/RCTReactNativeFactory.h>)
#import <React-RCTAppDelegate/RCTReactNativeFactory.h>
#elif __has_include(<React_RCTAppDelegate/RCTReactNativeFactory.h>)
// for importing the header from framework, the dash will be transformed to underscore
#import <React_RCTAppDelegate/RCTReactNativeFactory.h>
#endif

#import <Foundation/Foundation.h>

@class UIView;
@class NSURL;
@class NSDictionary;
@class NSString;

NS_ASSUME_NONNULL_BEGIN

@interface RCTReactNativeFactory () <
    RCTComponentViewFactoryComponentProvider,
    RCTHostDelegate,
    RCTJSRuntimeConfiguratorProtocol,
    RCTTurboModuleManagerDelegate>
@end

@interface AdorableDevLauncherReactNativeFactory : RCTReactNativeFactory

/// Create a new root view for the given bundle and module, updating factory state as needed.
/// This provides the compatibility that used to exist on ExpoReactDelegate’s factory.
- (nonnull UIView *)recreateRootViewWithBundleURL:(NSURL *)bundleURL
                                       moduleName:(NSString * _Nullable)moduleName
                                     initialProps:(NSDictionary * _Nullable)initialProps
                                    launchOptions:(NSDictionary * _Nullable)launchOptions
NS_SWIFT_NAME(recreateRootView(withBundleURL:moduleName:initialProps:launchOptions:));

@end

NS_ASSUME_NONNULL_END