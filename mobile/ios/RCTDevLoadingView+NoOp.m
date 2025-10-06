#import "RCTDevLoadingView+NoOp.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@implementation RCTDevLoadingView (NoOp)

+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    Class class = [self class];

    // Swizzle showMessage:color:backgroundColor:
    SEL originalShowSelector = @selector(showMessage:color:backgroundColor:);
    SEL swizzledShowSelector = @selector(noop_showMessage:color:backgroundColor:);

    Method originalShowMethod = class_getInstanceMethod(class, originalShowSelector);
    Method swizzledShowMethod = class_getInstanceMethod(class, swizzledShowSelector);

    if (originalShowMethod && swizzledShowMethod) {
      method_exchangeImplementations(originalShowMethod, swizzledShowMethod);
    }

    // Swizzle showWithURL:
    SEL originalShowWithURLSelector = @selector(showWithURL:);
    SEL swizzledShowWithURLSelector = @selector(noop_showWithURL:);

    Method originalShowWithURLMethod = class_getInstanceMethod(class, originalShowWithURLSelector);
    Method swizzledShowWithURLMethod = class_getInstanceMethod(class, swizzledShowWithURLSelector);

    if (originalShowWithURLMethod && swizzledShowWithURLMethod) {
      method_exchangeImplementations(originalShowWithURLMethod, swizzledShowWithURLMethod);
    }

    // Swizzle updateProgress:
    SEL originalUpdateSelector = @selector(updateProgress:);
    SEL swizzledUpdateSelector = @selector(noop_updateProgress:);

    Method originalUpdateMethod = class_getInstanceMethod(class, originalUpdateSelector);
    Method swizzledUpdateMethod = class_getInstanceMethod(class, swizzledUpdateSelector);

    if (originalUpdateMethod && swizzledUpdateMethod) {
      method_exchangeImplementations(originalUpdateMethod, swizzledUpdateMethod);
    }

    // Swizzle hide
    SEL originalHideSelector = @selector(hide);
    SEL swizzledHideSelector = @selector(noop_hide);

    Method originalHideMethod = class_getInstanceMethod(class, originalHideSelector);
    Method swizzledHideMethod = class_getInstanceMethod(class, swizzledHideSelector);

    if (originalHideMethod && swizzledHideMethod) {
      method_exchangeImplementations(originalHideMethod, swizzledHideMethod);
    }
  });
}

- (void)noop_showMessage:(NSString *)message color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor {
  // No-op: Do nothing
}

- (void)noop_showWithURL:(NSURL *)URL {
  // No-op: Do nothing
}

- (void)noop_updateProgress:(NSDictionary *)progress {
  // No-op: Do nothing
}

- (void)noop_hide {
  // No-op: Do nothing
}

@end
