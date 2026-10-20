/*
 *******************************************************************************
 *
 * Copyright (C) 2019-2020 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import <UIKit/UIKit.h>
#import "SuotaLib.h"

@protocol SuotaViewNavigation
- (BOOL) handleNavigation:(void(^)(void))onNavigation;
@end

@interface DeviceNavigationController : UINavigationController <SuotaManagerDelegate>

@property BOOL willBeDismissed;
@property UIAlertController* presentingAlertController;

- (void) displayAlert:(NSString*)title message:(NSString*)message dismissViewController:(BOOL)dismissViewController;
- (void) displayHud:(NSString*)message dismissViewController:(BOOL)dismissViewController;

@end
