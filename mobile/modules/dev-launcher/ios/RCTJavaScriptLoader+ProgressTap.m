// RCTJavaScriptLoader+ProgressTap.m
// Hooks into RN's JS bundle loading to relay progress to our Swift overlay via NSNotification.

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <React/RCTJavaScriptLoader.h>

// Public notification name and userInfo keys for Swift to observe.
NSString *const BundleLoadingProgressNotification = @"BundleLoadingProgressNotification";
// userInfo keys: @"doneBytes" (NSNumber), @"totalBytes" (NSNumber), @"status" (NSString)

@implementation RCTJavaScriptLoader (ProgressTap)

+ (void)load
{
  NSLog(@"[BLV] RCTJavaScriptLoader+ProgressTap loaded");
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    Class cls = object_getClass((id)self); // meta-class for class methods
    SEL originalSel = @selector(loadBundleAtURL:onProgress:onComplete:);
    SEL swizzledSel = @selector(_blv_loadBundleAtURL:onProgress:onComplete:);

    Method original = class_getClassMethod(cls, originalSel);
    Method swizzled = class_getClassMethod(cls, swizzledSel);

    if (original && swizzled) {
      method_exchangeImplementations(original, swizzled);
    }
  });
}

+ (void)_blv_loadBundleAtURL:(NSURL *)scriptURL
                  onProgress:(RCTSourceLoadProgressBlock)onProgress
                  onComplete:(RCTSourceLoadBlock)onComplete
{
  // Wrap the provided onProgress to relay progress via NotificationCenter while preserving original behavior.
  RCTSourceLoadProgressBlock wrappedProgress = ^(RCTLoadingProgress *progress) {
    // Post our own notification with raw values if available.
    NSNumber *done = progress.done ?: @(0);
    NSNumber *total = progress.total ?: @(0);
    NSString *status = progress.status ?: @"Loading App";

    NSDictionary *userInfo = @{
      @"doneBytes" : done,
      @"totalBytes" : total,
      @"status" : status,
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:BundleLoadingProgressNotification
                                                        object:nil
                                                      userInfo:userInfo];
    if (onProgress) {
      onProgress(progress);
    }
  };

  // Call original implementation (now _blv_... due to swizzle) with our wrapped progress.
  [self _blv_loadBundleAtURL:scriptURL onProgress:wrappedProgress onComplete:onComplete];
}

@end