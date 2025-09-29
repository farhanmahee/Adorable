// Copyright 2015-present 650 Industries. All rights reserved.

#import <React/RCTBridge+Private.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdorableDevLauncherRCTCxxBridge : RCTCxxBridge

- (NSArray<Class> *)filterModuleList:(NSArray<Class> *)modules;

@end

@interface AdorableDevLauncherRCTBridge : RCTBridge

- (Class)bridgeClass;

@end

NS_ASSUME_NONNULL_END
