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

@interface FileTableViewController : UIViewController

//------以下方法供FileSettingsTableViewController调用-------
+ (NSString*) DISPLAY_DETAILS;
+ (NSString*) FILTER_58x;
+ (NSString*) FILTER_68x;
+ (NSString*) FILTER_69x;
+ (NSString*) FILTER_UNKNOWN;

@end
