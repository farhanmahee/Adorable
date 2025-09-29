#import <AdorableDevLauncher/EXDevLauncherController.h>

@import EXDevMenuInterface;

@interface AdorableDevLauncherDevMenuExtensions : NSObject <RCTBridgeModule>

@end

@implementation AdorableDevLauncherDevMenuExtensions


// Need to explicitly define `moduleName` here for dev menu to pick it up
RCT_EXTERN void RCTRegisterModule(Class);

+ (NSString *)moduleName
{
  return @"AdorableDevLauncherExtension";
}

+ (void)load
{
  RCTRegisterModule(self);
}

+ (BOOL)requiresMainQueueSetup {
  return YES;
}

RCT_EXPORT_METHOD(navigateToLauncherAsync:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [[AdorableDevLauncherController sharedInstance] navigateToLauncher];
  });
  resolve(nil);
}

@end
