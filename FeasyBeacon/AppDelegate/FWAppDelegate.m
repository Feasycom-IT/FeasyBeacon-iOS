//
//  FWAppDelegate.m  com.feasycom.feasybeacon
//  FeasyBeacon
//
//  Created by LIDONG on 14-2-23.
//  Copyright (c) 2014年 LIDONG. All rights reserved.
//

#import "FWAppDelegate.h"
#import "FBRootViewController.h"
#import "FWUpdateViewController.h"
#import "NSString+FscKit.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <AFNetworking/AFNetworking.h>
#import "FSCLogExportManager.h"
#import "FBVersionCheck.h"

@implementation FWAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    /* Log */
    [FSCLogExportManagerShared startLogRecord];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    [SVProgressHUD setMinimumDismissTimeInterval:2.0];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    [self.window makeKeyAndVisible];
    
    FBRootViewController *fbRootVC = [[FBRootViewController alloc] init];
    [self.window setRootViewController:fbRootVC];

    // 检测App版本更新
    FBVersionCheck *versionCheck = [[FBVersionCheck alloc] init];
    [versionCheck checkForUpdate];
    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    if ([[url absoluteString] containsString:@"file"]) {
        NSString *fileName = [[url lastPathComponent] stringByRemovingPercentEncoding];
        NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/Inbox/%@", fileName];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:FWUpdateFilePathNotification object:nil userInfo:@{ @"url" : path }];
    }
    
    return YES;
}

@end
