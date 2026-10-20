/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2020 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "DeviceViewController.h"
#import "DeviceNavigationController.h"
#import "MBProgressHUD.h"
#import "Parameters.h"
#import "FileTableViewController.h"

@interface DeviceViewController ()

@end

@implementation DeviceViewController

// TAG：用于日志记录时标识该视图控制器的静态常量字符串
static NSString* const TAG = @"DeviceViewController";
// CONNECTION_TIMEOUT_MILLIS：定义了连接超时时间，单位为毫秒。该值用于控制蓝牙设备连接的超时设置
static int const CONNECTION_TIMEOUT_MILLIS = 20000;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"DeviceInfoViewController" bundle:nil];
    DeviceInfoViewController *deviceInfoViewController = [storyboard instantiateViewControllerWithIdentifier:@"DeviceInfoViewController"];
    [self addChildViewController:deviceInfoViewController];
    deviceInfoViewController.view.frame = CGRectMake(10, 20, self.view.frame.size.width - 20, 400);
    [self.view addSubview:deviceInfoViewController.view];  // 将其视图添加到当前控制器的视图中
    [deviceInfoViewController didMoveToParentViewController:self];
    containerView = deviceInfoViewController;
    
    Parameters* parameters = Parameters.instance;
    self.peripheral = parameters.peripheral;
    [self.updateButton setHidden:NO];

    if (!self.peripheral) {
        [(DeviceNavigationController*)self.parentViewController displayAlert:LS(@"Device error") message:LS(@"An error has occurred") dismissViewController:true];
        return;
    }
    
    containerView.deviceNameTextLabel.text = self.peripheral.name ? self.peripheral.name : @"N/A";
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.userInteractionEnabled = false;
    hud.detailsLabel.text = LS(@"Waiting");
    
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC));
    __weak typeof(self) weakSelf = self;
    dispatch_after(delay, dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.suotaManager = [[SuotaManager alloc] initWithPeripheral:strongSelf.peripheral suotaManagerDelegate:(DeviceNavigationController*)strongSelf.parentViewController pinCode:parameters.pinCode macAddress:parameters.macAddress];
        strongSelf.suotaManager.suotaViewController = (DeviceNavigationController*)strongSelf.parentViewController;
        parameters.suotaManager = strongSelf.suotaManager;
        
        if (strongSelf.suotaManager.state == DEVICE_DISCONNECTED) {
            [strongSelf.suotaManager connect];
            hud.detailsLabel.text = LS(@"Connecting");
            strongSelf.updateButton.userInteractionEnabled = false;
            strongSelf.connectTimer = [NSTimer scheduledTimerWithTimeInterval:((double)CONNECTION_TIMEOUT_MILLIS / 1000.0) target:strongSelf selector:@selector(connectionTimeout:) userInfo:nil repeats:NO];
        }
    });
}

- (void) notifyDismissed {
    if (self.connectTimer.isValid)
        [self.connectTimer invalidate];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"containerView"]) {
        containerView = segue.destinationViewController;
    }
}

- (IBAction)disconnect:(id)sender {
    [self.suotaManager close];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)updateButtonAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FileTableViewController" bundle:nil];
    FileTableViewController *fileTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"FileTableViewController"];
    
    [self.navigationController pushViewController:fileTableViewController animated:YES];
}

- (void) connectionTimeout:(NSTimer*)timer {
    SuotaLog(TAG, @"Connection timeout");
    self.connectionTimeout = true;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [(DeviceNavigationController*)self.parentViewController displayHud:LS(@"Unable to connect to device") dismissViewController:true];
}

- (void) onDeviceReady {
    SuotaLog(TAG, @"Device connected - info read");
    [self.connectTimer invalidate];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.updateButton.userInteractionEnabled = true;
}

- (void) onCharacteristicRead:(CBUUID*)uuid value:(NSString*)value {
    if ([uuid isEqual:SuotaProfile.CHARACTERISTIC_MANUFACTURER_NAME_STRING]) {
        containerView.manufacturerNameTextLabel.text = [value isEqualToString:@"Dialog Semi"] ? @"Dialog Semiconductor" : value;
        SuotaLog(TAG, @"Manufacturer: %@", value);
        return;
    }

    if ([uuid isEqual:SuotaProfile.CHARACTERISTIC_MODEL_NUMBER_STRING]) {
        containerView.modelNumberTextLabel.text = value;
        SuotaLog(TAG, @"Model Number: %@", value);
        return;
    }

    if ([uuid isEqual:SuotaProfile.CHARACTERISTIC_FIRMWARE_REVISION_STRING]) {
        containerView.firmwareRevisionTextLabel.text = value;
        SuotaLog(TAG, @"Firmware Revision: %@", value);
        return;
    }

    if ([uuid isEqual:SuotaProfile.CHARACTERISTIC_SOFTWARE_REVISION_STRING]) {
        containerView.softwareRevisionTextLabel.text = value;
        SuotaLog(TAG, @"Software Revision: %@", value);
        return;
    }

    SuotaLog(TAG, @"Unknown info: %@", value);
}

@end

/**
 核心代码
 1、初始化suotaManager对象
 self.suotaManager = [[SuotaManager alloc] initWithPeripheral:self.peripheral suotaManagerDelegate:(DeviceNavigationController*)self.parentViewController];
 self.suotaManager.suotaViewController = (DeviceNavigationController*)self.parentViewController;
 
 2、将suotaManager对象赋值保存在全局变量中
 Parameters* parameters = Parameters.instance;
 parameters.suotaManager = self.suotaManager;
 
 3、连接外设
 if (self.suotaManager.state == DEVICE_DISCONNECTED) {
 [self.suotaManager connect];
 }
 */
