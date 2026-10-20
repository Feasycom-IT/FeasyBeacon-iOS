/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2020 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import <UIKit/UIKit.h>
#import "DeviceInfoViewController.h"
#import "SuotaLib.h"

@interface DeviceViewController : UIViewController {
    DeviceInfoViewController *containerView;
}

// 升级控制器
@property SuotaManager* suotaManager;
// 蓝牙外设
@property CBPeripheral* peripheral;
// 连接超时时间
@property NSTimer* connectTimer;
// 连接是否超时
@property BOOL connectionTimeout;

// 升级按钮
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
// 升级按钮Action
- (IBAction)updateButtonAction:(id)sender;
// 断开连接按钮Action
- (IBAction)disconnect:(id)sender;

// -------以下方式供Nav调用--------

// 某个特征属性值读取成功Action
- (void) onCharacteristicRead:(CBUUID*)uuid value:(NSString*)value;
// 连接已经就绪、特征属性值全部读取完成Action
- (void) onDeviceReady;
// Nav界面即将消失Action
- (void) notifyDismissed;

@end
