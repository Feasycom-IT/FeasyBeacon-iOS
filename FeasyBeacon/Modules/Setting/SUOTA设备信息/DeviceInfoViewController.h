/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2019 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import <UIKit/UIKit.h>

@interface DeviceInfoViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *deviceNameTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *manufacturerNameTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *modelNumberTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *firmwareRevisionTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *softwareRevisionTextLabel;

@end
