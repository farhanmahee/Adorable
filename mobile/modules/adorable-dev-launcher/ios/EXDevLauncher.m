// Copyright 2015-present 650 Industries. All rights reserved.

#import <AdorableDevLauncher/EXDevLauncher.h>
#import <AdorableDevLauncher/EXDevLauncherController.h>

#if __has_include(<AdorableDevLauncher/AdorableDevLauncher-Swift.h>)
// For cocoapods framework, the generated swift header will be inside AdorableDevLauncher module
#import <AdorableDevLauncher/AdorableDevLauncher-Swift.h>
#else
#import <AdorableDevLauncher-Swift.h>
#endif

@implementation AdorableDevLauncher

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

- (NSDictionary *)constantsToExport
{
  NSDictionary *rawManifestJSON = [AdorableDevLauncherController.sharedInstance appManifest].rawManifestJSON;
  NSData *manifestStringData = rawManifestJSON ? [NSJSONSerialization dataWithJSONObject:rawManifestJSON options:kNilOptions error:NULL] : nil;
  NSString *manifestURLString = [AdorableDevLauncherController.sharedInstance appManifestURL].absoluteString;
  return @{
    @"manifestString": manifestStringData ? [[NSString alloc] initWithData:manifestStringData encoding:NSUTF8StringEncoding] : [NSNull null],
    @"manifestURL": manifestURLString ?: [NSNull null]
  };
}

@end
