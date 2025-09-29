#import <React/RCTBridgeModule.h>
#import <React/RCTBridgeDelegate.h>

#import <UIKit/UIKit.h>

// When `use_frameworks!` is used, the generated Swift header is inside modules.
// Otherwise, it's available only locally with double-quoted imports.
#if __has_include(<EXUpdatesInterface/EXUpdatesInterface-Swift.h>)
#import <EXUpdatesInterface/EXUpdatesInterface-Swift.h>
#else
#import "EXUpdatesInterface-Swift.h"
#endif
#if __has_include(<EXManifests/EXManifests-Swift.h>)
#import <EXManifests/EXManifests-Swift.h>
#else
#import "EXManifests-Swift.h"
#endif

#if __has_include(<React-RCTAppDelegate/RCTAppDelegate.h>)
#import <React-RCTAppDelegate/RCTAppDelegate.h>
#elif __has_include(<React_RCTAppDelegate/RCTAppDelegate.h>)
// for importing the header from framework, the dash will be transformed to underscore
#import <React_RCTAppDelegate/RCTAppDelegate.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class EXAppContext;
@class AdorableDevLauncherInstallationIDHelper;
@class AdorableDevLauncherPendingDeepLinkRegistry;
@class AdorableDevLauncherRecentlyOpenedAppsRegistry;
@class AdorableDevLauncherController;
@class AdorableDevLauncherErrorManager;

@protocol AdorableDevLauncherControllerDelegate <NSObject>

- (void)devLauncherController:(AdorableDevLauncherController *)developmentClientController
                didStartWithSuccess:(BOOL)success;

@end

@interface AdorableDevLauncherController : RCTDefaultReactNativeFactoryDelegate <RCTBridgeDelegate, EXUpdatesExternalInterfaceDelegate>

@property (nonatomic, weak) RCTBridge * _Nullable appBridge;
@property (nonatomic, weak) EXAppContext * _Nullable appContext;
@property (nonatomic, strong) AdorableDevLauncherPendingDeepLinkRegistry *pendingDeepLinkRegistry;
@property (nonatomic, strong) AdorableDevLauncherRecentlyOpenedAppsRegistry *recentlyOpenedAppsRegistry;
@property (nonatomic, strong) id<EXUpdatesExternalInterface> updatesInterface;
@property (nonatomic, readonly, assign) BOOL isStarted;

+ (instancetype)sharedInstance;

- (void)startWithWindow:(UIWindow *)window;

- (void)autoSetupPrepare:(id<AdorableDevLauncherControllerDelegate>)delegate launchOptions:(NSDictionary * _Nullable)launchOptions;

- (void)autoSetupStart:(UIWindow *)window;

- (nullable NSURL *)sourceUrl;

- (void)navigateToLauncher;

- (BOOL)onDeepLink:(NSURL *)url options:(NSDictionary *)options;

- (void)loadApp:(NSURL *)url onSuccess:(void (^ _Nullable)(void))onSuccess onError:(void (^ _Nullable)(NSError *error))onError;

- (void)loadApp:(NSURL *)expoUrl withProjectUrl:(NSURL  * _Nullable)projectUrl onSuccess:(void (^ _Nullable)(void))onSuccess onError:(void (^ _Nullable)(NSError *error))onError;

- (void)clearRecentlyOpenedApps;

- (NSDictionary *)getLaunchOptions;

- (EXManifestsManifest * _Nullable)appManifest;

- (NSURL * _Nullable)appManifestURL;

- (nullable NSURL *)appManifestURLWithFallback;

- (BOOL)isAppRunning;

- (BOOL)isStarted;

- (UIWindow * _Nullable)currentWindow;

- (AdorableDevLauncherErrorManager *)errorManager;

- (AdorableDevLauncherInstallationIDHelper *)installationIDHelper;

+ (NSString * _Nullable)version;

- (NSDictionary *)getBuildInfo;

- (void)copyToClipboard:(NSString *)content;

- (NSDictionary *)getUpdatesConfig: (nullable NSDictionary *) constants;

- (UIViewController *)createRootViewController;

- (void)setRootView:(UIView *)rootView toRootViewController:(UIViewController *)rootViewController;

@end

NS_ASSUME_NONNULL_END
