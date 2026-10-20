//
//  FWParametersViewController.m
//  FeasyBeacon
//
//  Created by ericj on 2017/7/26.
//  Copyright © 2017年 LIDONG. All rights reserved.
//

#import "FWParametersViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import "NSData+DataToHexString.h"
#import "NSString+FscKit.h"
#import "NSString+HexStringToData.h"
#import "FWConfigureValueGetCell.h"
#import "FWConfigureSwitchCell.h"
#import "FWConfigureValueSetCell.h"
#import "FWConfigurePowerCell.h"
#import "FWConfigureStateCell.h"
#import "FWConfigureGsens2Cell.h"
#import "FWConfigureGsensCell.h"
#import "FWUpdateViewController.h"
#import "FWAddBeaconViewController.h"
#import "FWBeaconsViewController.h"
#import "FWSettingsViewController.h"
#import "MBProgressHUD.h"
#import "FWAppDelegate.h"
#import "FBRootViewController.h"
#import "FWPopoverViewController.h"
#import "UIColor+FWColor.h"
#import "UIViewController+Extension.h"
#import "FWBatchHandleConfigureVC.h"
#import "FWConfigurePhyCell.h"
#import "FBAtEngineVC.h"
#import "FBSDKPublicHeader.h"
#import "Parameters.h"
#import "DeviceNavigationController.h"
#import "DeviceViewController.h"
#import "FESettingBeaconModel.h"
#import "FBMutableBeacon+FBeacon.h"

#define SECTION_HEIGH 44

@interface FWParametersViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPopoverPresentationControllerDelegate> {
    
    FBPeripheralManager *_peripheralManager;
    FBConfiguration *_configuration;
    FBPeripheralItem *_peripheralItem;
    NSString *_pinCode;
    
    UIButton *_addBeaconButton;// 添加Beacon按钮
    UIButton *_upgradeButton;// 升级按钮
    UIButton *_batchHandleButton;// 批量配置按钮
    UIButton *_resetDeviceButton;// 重置设备按钮
    UIButton *_atEngineButton;// 空中指令调试按钮
    
    UITextField *_nameTextField;// 模块型号
    UITextField *_intervalTextField;// 默认广播间隔时间
    UITextField *_pinTextField;// pin码
    UITextField *_keyIntervalTextField;// 按键广播间隔时间
    UITextField *_keyDurationTextField;// 按键广播持续时间
    UITextField *_gsensorIntervalTextField;// 加速触发广播间隔时间
    UITextField *_gsensorDurationTextField;// 加速触发广播持续时间
    UITextField *_gsensorSensitivityTextField;// 加速触发灵敏度
    
    /// 以下为单独Beacon广播的广播间隔时间
    UITextField *_intervalTextField_0;
    UITextField *_intervalTextField_1;
    UITextField *_intervalTextField_2;
    UITextField *_intervalTextField_3;
    UITextField *_intervalTextField_4;
    UITextField *_intervalTextField_5;
    UITextField *_intervalTextField_6;
    UITextField *_intervalTextField_7;
    UITextField *_intervalTextField_8;
    UITextField *_intervalTextField_9;
    NSMutableArray<UITextField *> *_phy_intervalTextFieldArrays;
    
    MBProgressHUD *_progressHUD;
    
    BOOL _enteringNextViewController;
    
    UIViewController *_popupViewController;
}

@property (nonatomic, strong, readonly) NSArray<FBMutableBeacon *> *sadvBeacons;
@property (nonatomic, strong, readonly) NSArray<FBMutableBeacon *> *normalBeacons;

@end

@implementation FWParametersViewController

- (id)initWithPeripheralItem:(FBPeripheralItem *)peripheralItem PINCode:(NSString *)PINCode {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        
        _peripheralItem = peripheralItem;
        _peripheralManager = [[FBPeripheralManager alloc] initWithPeripheralItem:peripheralItem PINCode:PINCode];
        _pinCode = PINCode;
        _phy_intervalTextFieldArrays = [NSMutableArray arrayWithArray:[NSArray arrayWithObjects:_intervalTextField_0, _intervalTextField_1, _intervalTextField_2, _intervalTextField_3, _intervalTextField_4, _intervalTextField_5, _intervalTextField_6, _intervalTextField_7, _intervalTextField_8, _intervalTextField_9, nil]];
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadData {
    __weak __typeof(self) weakSelf = self;
    [_peripheralManager loadConfigurationWithCompletionHandler:^(FBConfiguration * _Nullable configuration) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf->_configuration = configuration;
            [strongSelf.tableView reloadData];
        }
    }];
    
    if (NO == [_peripheralManager isHandleBusy]) {
        [self showProgressHUDWithTitle:LS(@"Loading...")];
        [_peripheralManager loadParametersWithCompletionHandler:^(NSError * _Nullable error) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            NSLog(@"error: %@", error);
            if (strongSelf) {
                const NSInteger code = error.code;
                if (code == FBErrorAuthorizationFailed) {
                    [strongSelf showAlertControllerAndPopWithTitle:LS(@"PIN code failed")];
                } else if (code == FBErrorConnectionTimeout || code == FBErrorOpeningTimeout) {
                    [strongSelf showAlertControllerAndPopWithTitle:LS(@"Connection timeout")];
                } else if (code == FBErrorLoadingParametersTimeout) {
                    [strongSelf showAlertControllerAndPopWithTitle:LS(@"Query parameters timeout")];
                } else if (code != FBErrorNone) {
                    [strongSelf showAlertControllerAndPopWithTitle:LS(@"Query parameters failed")];
                }
                
                if (!error) {
                    if (10 <= strongSelf.normalBeacons.count) {
                        strongSelf->_addBeaconButton.hidden = YES;
                    }
                    [strongSelf.tableView reloadData];
                    [strongSelf updateTextColorsAndWhetherShowAlertMessage:NO];
                    [strongSelf hideProgressHUD];
                }
            }
        }];
    }
    
    [_peripheralManager setCloseHandler:^(NSError * _Nullable error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
//        [strongSelf showAlertControllerAndPopWithTitle:LS(@"Connection closed")];
    }];
}

- (void)configureTableView {
    const CGRect bounds = [[UIScreen mainScreen] bounds];
    UITableView *tableView = self.tableView;
    
    tableView.frame = bounds;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.rowHeight = 44;
    tableView.allowsSelection = NO;
    
    tableView.tableHeaderView =  [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, bounds.size.width, CGFLOAT_MIN)];
    
    // 添加footView
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, 350)];
    
    // 添加Beacon广播的按钮
    _addBeaconButton = [[UIButton alloc] initWithFrame:CGRectMake(bounds.size.width - 20 - 150, 20, 150, 50)];
    [_addBeaconButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    // 有key或Gsensor，并且是可编程按键（暂时只有编号为120的）
    if (((_peripheralItem.hasKey) || (_peripheralItem.hasGsensor )) && _peripheralItem.modelIndex == 120){
        [_addBeaconButton addTarget:self action:@selector(showPopupViewController:) forControlEvents:UIControlEventTouchUpInside];
    }else {
        [_addBeaconButton addTarget:self action:@selector(clickToAddIBeacon:) forControlEvents:UIControlEventTouchUpInside];
    }
    [footerView addSubview:_addBeaconButton];
    
    // 升级按钮
    _upgradeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_upgradeButton setFrame:CGRectMake((bounds.size.width - 240) * 0.5, 90, 240, 50)];
    [_upgradeButton setBackgroundColor:[UIColor colorWithRed:88/255.0 green:133/255.0 blue:222/255.0 alpha:1]];
    [_upgradeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_upgradeButton setTitle:LS(@"Upgrade") forState:UIControlStateNormal];
    _upgradeButton.layer.masksToBounds = YES;
    _upgradeButton.layer.cornerRadius = 5;
    [_upgradeButton addTarget:self action:@selector(update) forControlEvents:UIControlEventTouchUpInside];
    
    // 添加长按手势识别器，长按时间设置为5秒
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressGesture.minimumPressDuration = 2.0;
    [_upgradeButton addGestureRecognizer:longPressGesture];
    
    [footerView addSubview:_upgradeButton];
    
    // 批量处理按钮
    _batchHandleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_batchHandleButton setFrame:CGRectMake((bounds.size.width - 240) * 0.5, 160, 240, 50)];
    [_batchHandleButton setBackgroundColor:[UIColor colorWithRed:88/255.0 green:133/255.0 blue:222/255.0 alpha:1]];
    [_batchHandleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_batchHandleButton setTitle:LS(@"BatchConfigSuchDevices") forState:UIControlStateNormal];
    _batchHandleButton.layer.masksToBounds = YES;
    _batchHandleButton.layer.cornerRadius = 5;
    [_batchHandleButton addTarget:self action:@selector(batchHandleButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:_batchHandleButton];
    
    // 重置设备按钮
    _resetDeviceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_resetDeviceButton setFrame:CGRectMake((bounds.size.width-240)*0.5, 230, 240, 50)];
    [_resetDeviceButton setBackgroundColor:[UIColor colorWithRed:88/255.0 green:133/255.0 blue:222/255.0 alpha:1]];
    [_resetDeviceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_resetDeviceButton setTitle:LS(@"ResetDevice") forState:UIControlStateNormal];
    _resetDeviceButton.layer.masksToBounds = YES;
    _resetDeviceButton.layer.cornerRadius = 5;
    [_resetDeviceButton addTarget:self action:@selector(resetDeviceButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:_resetDeviceButton];
    
    // AT指令调试按钮
    _atEngineButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_atEngineButton setFrame:CGRectMake((bounds.size.width-240)*0.5, 300, 240, 50)];
    [_atEngineButton setBackgroundColor:[UIColor colorWithRed:88/255.0 green:133/255.0 blue:222/255.0 alpha:1]];
    [_atEngineButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_atEngineButton setTitle:LS(@"AT Debug") forState:UIControlStateNormal];
    _atEngineButton.layer.masksToBounds = YES;
    _atEngineButton.layer.cornerRadius = 5;
    [_atEngineButton addTarget:self action:@selector(atEngineButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:_atEngineButton];
    
    tableView.tableFooterView = footerView;
}

// 升级Action
- (void)update {
    [_peripheralManager.session closeSession];
    
    NSArray *modelIndices = @[@41, @71, @74, @75, @39, @72, @73, @68, @79, @46, @56, @54, @69, @98, @108, @116, @117, @120, @121,@131];
    if ([modelIndices containsObject:@(self->_peripheralItem.modelIndex)]) {
        _enteringNextViewController = YES;
        
        // 将用户选择的设备（即 UITableView 的某一行对应的设备）的 peripheral 对象赋值给 Parameters.instance.peripheral
        Parameters.instance.peripheral = _peripheralItem.peripheral;
        Parameters.instance.pinCode = _pinCode;
        Parameters.instance.macAddress = _peripheralItem.macAddress;
        
        // 从 Storyboard 中实例化 ScanNavigationController
        UIStoryboard *storyboardDeviceNavigationController = [UIStoryboard storyboardWithName:@"DeviceNavigationController" bundle:nil];
        DeviceNavigationController *deviceNavigationController = [storyboardDeviceNavigationController instantiateViewControllerWithIdentifier:@"DeviceNavigationController"];
        
        // 从 Storyboard 中实例化 DeviceViewController
        UIStoryboard *storyboardDeviceViewController = [UIStoryboard storyboardWithName:@"DeviceViewController" bundle:nil];
        DeviceViewController *deviceViewController = [storyboardDeviceViewController instantiateViewControllerWithIdentifier:@"DeviceViewController"];
        
        // 将 DeviceViewController 设置为 DeviceNavigationController 的根视图控制器
        [deviceNavigationController setViewControllers:@[deviceViewController] animated:NO];
        
        // 模态展示 deviceNavigationController
        [self presentViewController:deviceNavigationController animated:YES completion:nil];
    } else {
        FWUpdateViewController *viewController = [[FWUpdateViewController alloc] initWithPeripheralItem:_peripheralManager.session.peripheralItem PINCode:_pinCode];
        NSMutableArray *viewControllers = [[[self navigationController] viewControllers] mutableCopy];
        viewControllers[1] = viewController;
        [self.navigationController setViewControllers:viewControllers animated:YES];
    }
}

// 处理长按事件
- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        __weak typeof(self) weakSelf = self;
        
        // 创建弹框
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        
        // 添加第一个选项
        UIAlertAction *option1 = [UIAlertAction actionWithTitle:@"XModel OTA"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            FWUpdateViewController *viewController = [[FWUpdateViewController alloc] initWithPeripheralItem:_peripheralManager.session.peripheralItem PINCode:_pinCode];
            NSMutableArray *viewControllers = [[[strongSelf navigationController] viewControllers] mutableCopy];
            viewControllers[1] = viewController;
            [strongSelf.navigationController setViewControllers:viewControllers animated:YES];
        }];
        
        // 添加第二个选项
        UIAlertAction *option2 = [UIAlertAction actionWithTitle:@"Dialog OTA"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            strongSelf -> _enteringNextViewController = YES;
            
            // 将用户选择的设备（即 UITableView 的某一行对应的设备）的 peripheral 对象赋值给 Parameters.instance.peripheral
            Parameters.instance.peripheral = _peripheralItem.peripheral;
            Parameters.instance.pinCode = _pinCode;
            Parameters.instance.macAddress = _peripheralItem.macAddress;
            
            // 从 Storyboard 中实例化 ScanNavigationController
            UIStoryboard *storyboardDeviceNavigationController = [UIStoryboard storyboardWithName:@"DeviceNavigationController" bundle:nil];
            DeviceNavigationController *deviceNavigationController = [storyboardDeviceNavigationController instantiateViewControllerWithIdentifier:@"DeviceNavigationController"];
            
            // 从 Storyboard 中实例化 DeviceViewController
            UIStoryboard *storyboardDeviceViewController = [UIStoryboard storyboardWithName:@"DeviceViewController" bundle:nil];
            DeviceViewController *deviceViewController = [storyboardDeviceViewController instantiateViewControllerWithIdentifier:@"DeviceViewController"];
            
            // 将 DeviceViewController 设置为 DeviceNavigationController 的根视图控制器
            [deviceNavigationController setViewControllers:@[deviceViewController] animated:NO];
            
            // 模态展示 deviceNavigationController
            [strongSelf presentViewController:deviceNavigationController animated:YES completion:nil];
        }];
        
        // 添加取消按钮
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        
        // 将选项添加到弹框
        [alertController addAction:option1];
        [alertController addAction:option2];
        [alertController addAction:cancelAction];
        
        // 显示弹框
        [self presentViewController:alertController animated:YES completion:nil];
    }
}


// 批量处理Action
- (void)batchHandleButtonAction {
    _enteringNextViewController = NO;
    FWBatchHandleConfigureVC *batchHandleConfigureVC = [[FWBatchHandleConfigureVC alloc] initWithBeaconManager:_peripheralManager configurationRange:_configuration];
    [self.navigationController pushViewController:batchHandleConfigureVC animated:YES];
}

// 重置设备Action
- (void)resetDeviceButtonAction {
    // 创建一个确认弹框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LS(@"Confirm Reset") message:LS(@"Are you sure you want to reset the device?") preferredStyle:UIAlertControllerStyleAlert];
    
    // 确定按钮
    __weak __typeof(self) weakSelf = self;
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:LS(@"Confirm")
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * _Nonnull action) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (NO == [_peripheralManager isHandleBusy]) {
            [strongSelf showProgressHUDWithTitle:LS(@"Resetting...")];
            
            __weak __typeof(strongSelf) weakSelf = strongSelf;
            // 保存设备信息到模组中
            [_peripheralManager restoreWithCompletionHandler:^(NSError * _Nullable error) {
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                
                [strongSelf hideProgressHUD];
                
                if (error.code == 0) {
                    [strongSelf showAlertControllerAndPopWithTitle:LS(@"Reset success")];
                } else {
                    [strongSelf showAlertControllerAndPopWithTitle:LS(@"Reset failed")];
                }
            }];
        }
    }];
    
    // 取消按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LS(@"Cancel")
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    // 将按钮添加到弹框中
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 空中指令调试Action
- (void)atEngineButtonAction {
    _enteringNextViewController = YES;
    FBAtEngineVC *atEngineVC = [[FBAtEngineVC alloc] initWithSession:_peripheralManager.session];
    [self.navigationController pushViewController:atEngineVC animated:NO];
}

// 检测「部分输入框中内容」的合法性,不合法则输入框出现红色提醒
// 输入回调时检测、展示（间隔、Gsensor、Key）时检测
- (BOOL)updateTextColorsAndWhetherShowAlertMessage:(BOOL)isShowAlertMessage {
    
    // 字体颜色定义
    UIColor *normalTextColor = [UIColor darkTextColor];// 正常
    UIColor *warningTextColor = [UIColor redColor];// 警示、报错
    
    // 检测的对象--初始化为正常颜色
    [_intervalTextField setTextColor:normalTextColor];// 默认广播间隔时间
    [_keyIntervalTextField setTextColor:normalTextColor];// 按键间隔时间（Key）
    [_keyDurationTextField setTextColor:normalTextColor];// 按键持续时间（Key）
    [_gsensorIntervalTextField setTextColor:normalTextColor];// Gsensor间隔时间
    [_gsensorDurationTextField setTextColor:normalTextColor];// Gsensor持续时间
    [_gsensorSensitivityTextField setTextColor:normalTextColor];// Gsensor灵敏度
    
    // 检测值的变量初始化
    int interval = 0;// 默认广播间隔时间
    int keyInterval = 0;// 按键间隔时间（Key）
    int keyDuration = 0;// 按键持续时间（Key）
    int gsensorInterval = 0;// Gsensor间隔时间
    int gsensorDuration = 0;// Gsensor持续时间
    int gsensorSensitivity = 0;// Gsensor灵敏度
    
    FBPeripheralItem *peripheralItem = _peripheralManager.session.peripheralItem;
    
    // 设备包含默认广播间隔
    if ([_peripheralManager.paramKeys containsObject:kInterval]) {
        interval = [[_peripheralManager valueForName:kInterval] intValue];
    }
    
    // 设备包含Gsensor
    if (peripheralItem.hasGsensor) {
        NSArray *gsensorValues = [_peripheralManager valueForName:kGsensor];
        gsensorInterval = [gsensorValues[0] intValue];// Gsensor间隔
        gsensorDuration = [gsensorValues[1] intValue];// Gsensor持续时间
        if ([_configuration.modelName isEqualToString:@"BP108N"]) {
            gsensorSensitivity = [gsensorValues[2] intValue];// Gsensor灵敏度
        }
    }
    
    // 设备包含按键
    if (peripheralItem.hasKey) {
        NSArray *keyValues = [_peripheralManager valueForName:kKey];
        keyInterval = [keyValues[0] intValue];// 按键间隔时间（Key）
        keyDuration = [keyValues[1] intValue];// 按键持续时间（Key)
    }
    
    // 确保至少要有一项“间隔时间”是符合要求的
    if ((0 == interval + keyInterval + gsensorInterval) && [_peripheralManager.paramKeys containsObject:kInterval]) {
        [_intervalTextField setTextColor:warningTextColor];// 广播间隔
        [_keyIntervalTextField setTextColor:warningTextColor];// 按键间隔时间（Key）
        [_gsensorIntervalTextField setTextColor:warningTextColor];// Gsensor间隔时间
        
        if (isShowAlertMessage) {
            [self showAlertControllerWithTitle:LS(@"The broadcast interval cannot all be 0")];
        }
        
        return NO;
    }
    
    // 默认广播间隔取值范围
    FBRange *intervalRange = _configuration.intervalRange;
    if (intervalRange && [_peripheralManager.paramKeys containsObject:kInterval]) {
        if (0 != interval && (interval < intervalRange.minValue || interval > intervalRange.maxValue)) {
            [_intervalTextField setTextColor:warningTextColor];
            
            if (isShowAlertMessage) {
                [self showAlertControllerWithTitle:[[NSString alloc] initWithFormat:@"%@%@%d~%d%@", LS(@"Interval"), LS(@" is out of range "), intervalRange.minValue, intervalRange.maxValue, LS(@" and not 0")]];
            }
            
            return NO;
        }
    }
    
    // Gsensor间隔取值范围
    FBRange *gsensorIntervalRange = _configuration.gsensorIntervalRange;
    if (gsensorIntervalRange && peripheralItem.hasGsensor && peripheralItem.modelIndex != 120) {
        if (0 != gsensorInterval && (gsensorInterval < gsensorIntervalRange.minValue || gsensorInterval > gsensorIntervalRange.maxValue)) {
            [_gsensorIntervalTextField setTextColor:warningTextColor];
            
            if (isShowAlertMessage) {
                [self showAlertControllerWithTitle:[[NSString alloc] initWithFormat:@"Gsensor %@%@%d~%d%@", LS(@"interval"), LS(@" is out of range "), gsensorIntervalRange.minValue, gsensorIntervalRange.maxValue, LS(@" and not 0")]];
            }
            
            return NO;
        }
    }
    
    // Gsensor持续时间取值范围
    FBRange *gsensorDurationRange = _configuration.gsensorDurationRange;
    if (gsensorDurationRange && peripheralItem.hasGsensor && peripheralItem.modelIndex != 120) {
        if (gsensorDuration < gsensorDurationRange.minValue || gsensorDuration > gsensorDurationRange.maxValue) {
            [_gsensorDurationTextField setTextColor:warningTextColor];
            
            if (isShowAlertMessage) {
                [self showAlertControllerWithTitle:[[NSString alloc] initWithFormat:@"Gsensor %@%@%d~%d", LS(@"duration"), LS(@" is out of range "), gsensorDurationRange.minValue, gsensorDurationRange.maxValue]];
            }
            
            return NO;
        }
    }
    
    // Gsensor灵敏度取值范围
    FBRange *gsensorSensitivityRange = _configuration.gsensorSensitivityRange;
    if (gsensorSensitivityRange && peripheralItem.hasGsensor && [_configuration.modelName isEqualToString:@"BP108N"] && peripheralItem.modelIndex != 120) {
        if (gsensorSensitivity < gsensorSensitivityRange.minValue || gsensorSensitivity > gsensorSensitivityRange.maxValue) {
            [_gsensorSensitivityTextField setTextColor:warningTextColor];
            
            if (isShowAlertMessage) {
                [self showAlertControllerWithTitle:[[NSString alloc] initWithFormat:@"Gsensor %@%@%d~%d", LS(@"sensitivity"), LS(@" is out of range "), gsensorSensitivityRange.minValue, gsensorSensitivityRange.maxValue]];
            }
            
            return NO;
        }
    }
    
    // 按键间隔取值范围（Key）
    FBRange *keyIntervalRange = _configuration.keyIntervalRange;
    if (keyIntervalRange && peripheralItem.hasKey && peripheralItem.modelIndex != 120) {
        if (0 != keyInterval && (keyInterval < keyIntervalRange.minValue || keyInterval > keyIntervalRange.maxValue)) {
            [_keyIntervalTextField setTextColor:warningTextColor];
            
            if (isShowAlertMessage) {
                [self showAlertControllerWithTitle:[[NSString alloc] initWithFormat:@"Key %@%@%d~%d%@", LS(@"interval"), LS(@" is out of range "), keyIntervalRange.minValue, keyIntervalRange.maxValue, LS(@" and not 0")]];
            }
            
            return NO;
        }
    }
    
    // 按键持续时间取值范围（Key）
    FBRange *keyDurationRange = _configuration.keyDurationRange;
    if (keyDurationRange && peripheralItem.hasKey && peripheralItem.modelIndex != 120) {
        if (keyDuration < keyDurationRange.minValue || keyDuration > keyDurationRange.maxValue) {
            [_keyDurationTextField setTextColor:warningTextColor];
            
            if (isShowAlertMessage) {
                [self showAlertControllerWithTitle:[[NSString alloc] initWithFormat:@"Key %@%@%d~%d", LS(@"duration"), LS(@" is out of range "), keyDurationRange.minValue, keyDurationRange.maxValue]];
            }
            
            return NO;
        }
    }
    
    return YES;
}

// 保存Action
- (void)saveButtonPressed {
    NSMutableArray *arr1 = [NSMutableArray array];
    NSMutableArray *arr2 = [NSMutableArray array];
    for (int i = 0; i<_peripheralManager.beacons.count; i++) {
        FBMutableBeacon *item = _peripheralManager.beacons[i];
        if (item.isSadv) {
            [arr1 addObject:item];
        }else {
            [arr2 addObject:item];
        }
    }
    NSLog(@"数组：beacons-%ld condition-%ld", arr2.count, arr1.count);
    // 先收起键盘
    [self.view endEditing:YES];
    
    // 检验 PIN
    NSString *PINCode = _pinTextField.text;
    if (PINCode.length != 6 || ![PINCode isDigits] || [PINCode hasPrefix:@"-"]) {
        [self showAlertControllerWithTitle:LS(@"Please input six digits's PIN code")];
        return;
    }
    
    // 检验广播时间相关的值
    if (NO == [self updateTextColorsAndWhetherShowAlertMessage:YES]) {
        return;
    }
    
    // Phy广播间隔取值范围
    FBRange *intervalRange = _configuration.intervalRange;
    for (int i = 0; i < _phy_intervalTextFieldArrays.count; i++) {
        if (intervalRange && _phy_intervalTextFieldArrays[i]) {
            const int interval = [_phy_intervalTextFieldArrays[i].text intValue];
            if (0 == interval || (interval < intervalRange.minValue || interval > intervalRange.maxValue)) {
                [self showAlertControllerWithTitle:[[NSString alloc] initWithFormat:@"%@%@%d~%d%@", LS(@"Interval"), LS(@" is out of range "), intervalRange.minValue, intervalRange.maxValue, LS(@" and not 0")]];
                return;
            }
        }
    }
    
    // 名称
    [_peripheralManager setValue:_nameTextField.text forName:kName];
    // Pin
    [_peripheralManager setValue:_pinTextField.text forName:kPin];
    
    if (NO == [_peripheralManager isHandleBusy]) {
        [self showProgressHUDWithTitle:LS(@"Saving...")];
        
        __weak __typeof(self) weakSelf = self;
        // 保存设备信息到模组中
        [_peripheralManager saveParametersWithCompletionHandler:^(NSError * _Nullable error) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf hideProgressHUD];
            if (error.code == 0) {
                [strongSelf showAlertControllerAndPopWithTitle:LS(@"SET_SUCCESSFUL")];
            } else {
                [strongSelf showAlertControllerAndPopWithTitle:LS(@"SET_FAILED")];
            }
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _enteringNextViewController = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (!_enteringNextViewController) {
        [_peripheralManager.session closeSession];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:_peripheralItem.displayedName];
    [self setupNavigationContent];
    [self configureTableView];
    [self loadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDismissNotification:)
                                                 name:@"DeviceControllerDismissed"
                                               object:nil];
}

- (void)handleDismissNotification:(NSNotification *)notification {
    // 让 strongSelf pop 出去
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupNavigationContent {
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Save") style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonPressed)];
    
    self.navigationItem.rightBarButtonItem = rightBarItem;
}

- (void)showProgressHUDWithTitle:(NSString *)title {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(progressHUDDidHide:) object:_progressHUD];
    
    UIView *view = self.view;
    
    if (nil == _progressHUD) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:view];
    }
    
    _progressHUD.label.text = title;
    
    [view setUserInteractionEnabled:NO];
    [view addSubview:_progressHUD];
    
    [_progressHUD showAnimated:YES];
}

- (void)hideProgressHUD {
    if (_progressHUD) {
        [_progressHUD hideAnimated:YES];
        [self performSelector:@selector(progressHUDDidHide:) withObject:_progressHUD afterDelay:0.5];
    }
}

- (void)progressHUDDidHide:(UIView *)progressHUD {
    if (progressHUD == _progressHUD) {
        [self.view setUserInteractionEnabled:YES];
        [_progressHUD removeFromSuperview];
        _progressHUD = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 删除按钮
- (void)deleteButtonPressed:(UIButton *)sender {
    
    NSInteger section = sender.tag;
    NSLog(@"tag:%ld", section);
    NSArray *beacons = self.normalBeacons;
    if (section > 10){
        beacons = self.sadvBeacons;
        section -= 10;
    }
    
    NSLog(@"section: %d", (int)section);
    
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LS(@"Are you sure to delete the broadcast?") message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertActionOK = [UIAlertAction actionWithTitle:LS(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong typeof(weakSelf) StrongSelf = weakSelf;
        
        FBMutableBeacon *beacon = [beacons objectAtIndex:section - 1];
        NSLog(@"beacon:%d", beacon.isSadv);
        [StrongSelf->_peripheralManager.beacons removeObject:beacon];
        
        if (10 > beacons.count) {
            _addBeaconButton.hidden = NO;
        }
        
        [self.tableView reloadData];
    }];
    [alertController addAction:alertActionOK];
    UIAlertAction *alertActionCancel = [UIAlertAction actionWithTitle:LS(@"CANCEL") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:alertActionCancel];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}

// 添加eddystone
- (void)clickToAddIBeacon:(UIButton *)sender {
    [self gotoBeacon];
}

#pragma mark - UITableViewDataSource

/*
 tableview的布局说明：
 1、整体上使用section做分组
 2、最上面关于设备信息作为一个section
 3、每一个beacon广播作为一个section
 4、添加一个新的beacon、升级、批量修改按钮，放入到tableview的footview中
 */

// Sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"normalBeacons:%ld sadvBeacons:%ld", self.normalBeacons.count, self.sadvBeacons.count);
    return self.normalBeacons.count + self.sadvBeacons.count + 3;
}

// SectionHeaderView
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    if (section == 1) {
        if (self.normalBeacons.count > 0) {
            return [self headerViewTitle:@"Beacon Slot"];
        } else {
            return nil;
        }
    }
    if (section > 1 && section < self.normalBeacons.count + 2) {
        return [self beaconHeaderView:self.normalBeacons index:section - 2 isSadv:NO];
    }
    if (section == self.normalBeacons.count + 2) {
        if (self.sadvBeacons.count > 0) {
            return [self headerViewTitle:@"Condition Slot"];
        } else {
            return nil;
        }
    }
    if (section > self.normalBeacons.count + 2) {
        return [self beaconHeaderView:self.sadvBeacons index:section - self.normalBeacons.count - 3 isSadv:YES];
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        // 当前设备的配置数量
        return _peripheralManager.paramKeys.count;
    } else if (section > 1 && section < self.normalBeacons.count + 2) {
        // 当前beacon下的属性数量
        FBMutableBeacon *beacon = self.normalBeacons[section - 2];
        if (!beacon.isSadv && FBBeaconTypeUnknown == beacon.type) {
            beacon.numberOfParameters = 2;
        }
        return self.normalBeacons[section - 2].numberOfParameters;
    } else if (section > self.normalBeacons.count + 2) {
        FBMutableBeacon *beacon = self.sadvBeacons[section - self.normalBeacons.count - 3];
        if (beacon.isSadv && FBBeaconTypeUnknown == beacon.type) {
            beacon.numberOfParameters = 6;
        }
        // 当前beacon下的属性数量
        return self.sadvBeacons[section - self.normalBeacons.count - 3].numberOfParameters;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    } else if (section == self.normalBeacons.count + 2 && self.sadvBeacons.count == 0) {
        return 0;
    }
    return SECTION_HEIGH;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    const NSInteger section = indexPath.section;
    const NSInteger row = indexPath.row;
    
    if (section == 0) {
        NSString *name = _peripheralManager.paramKeys[row];
        id value = _peripheralManager.paramValues[row];
        if ([name isEqualToString:kModel]) {// 模型
            FWConfigureValueGetCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigureValueGetCell" owner:self options:nil] firstObject];
            
            NSString *key = [[NSString alloc] initWithFormat:@"%@:", name];
            
            cell.textLabel.font = [UIFont systemFontOfSize:17];
            cell.textLabel.text = LS(key);
            cell.nameLabel.textColor = [UIColor colorWithHexString:@"7b7b7b"];
            cell.nameLabel.text = [NSString stringWithFormat:@"%@   (No.%d)", value, self->_peripheralItem.modelIndex];
            return cell;
        } else if ([name isEqualToString:kVersion]) {// 版本
            FWConfigureValueGetCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigureValueGetCell" owner:self options:nil] firstObject];
            
            NSString *key = [[NSString alloc] initWithFormat:@"%@:", name];
            
            cell.textLabel.font = [UIFont systemFontOfSize:17];
            cell.textLabel.text = LS(key);
            cell.nameLabel.textColor = [UIColor colorWithHexString:@"7b7b7b"];
            cell.nameLabel.text = value;
            return cell;
        } else if ([name isEqualToString:kName]) {// 名称
            FWConfigureValueSetCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigureValueSetCell" owner:self options:nil] firstObject];
            
            NSString *key = [[NSString alloc] initWithFormat:@"%@:", name];
            
            cell.titleLabel.font = [UIFont systemFontOfSize:17];
            cell.titleLabel.text = LS(key);
            cell.inputTextField.textColor = [UIColor colorWithHexString:@"0e74bd"];
            cell.inputTextField.text = value;
            cell.inputTextField.delegate = self;
            _nameTextField = cell.inputTextField;
            return cell;
        } else if ([name isEqualToString:kInterval]) {// 默认间隔时间
            FWConfigureValueSetCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigureValueSetCell" owner:self options:nil] firstObject];
            
            cell.titleLabel.font = [UIFont systemFontOfSize:17];
            cell.titleLabel.text = LS(@"Interval(ms):");
            cell.inputTextField.keyboardType = UIKeyboardTypeNumberPad;
            cell.inputTextField.text = value;
            cell.inputTextField.delegate = self;
            _intervalTextField = cell.inputTextField;
            return cell;
        } else if ([name isEqualToString:kPin]) {// Pin
            FWConfigureValueSetCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigureValueSetCell" owner:self options:nil] firstObject];
            
            cell.titleLabel.font = [UIFont systemFontOfSize:17];
            cell.titleLabel.text = @"Pin:";
            cell.inputTextField.textColor = [UIColor colorWithHexString:@"0e74bd"];
            cell.inputTextField.keyboardType = UIKeyboardTypeNumberPad;
            cell.inputTextField.text = value;
            cell.inputTextField.delegate = self;
            _pinTextField = cell.inputTextField;
            return cell;
        } else if ([name isEqualToString:kTxPower]) {// TxPower
            FWConfigurePowerCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigurePowerCell" owner:self options:nil] firstObject];
            
            cell.powerLabel.text = @"TxPower(db):";
            cell.txPowerLabel.text = value;
            [cell.powerButton addTarget:self action:@selector(txPowerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        } else if ([name isEqualToString:kGsensor]) {// GSensor
            if ([value count] == 3) {
                FWConfigureGsensCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigureGsensCell" owner:self options:nil] firstObject];
                
                cell.titleLabel.text = @"Gsensor(ms):";
                
                cell.intervalTextField.text = [[NSString alloc] initWithFormat:@"%d", [value[0] intValue]];
                cell.intervalTextField.delegate = self;
                _gsensorIntervalTextField = cell.intervalTextField;
                
                cell.durationTextField.text = [[NSString alloc] initWithFormat:@"%d", [value[1] intValue]];
                cell.durationTextField.delegate = self;
                _gsensorDurationTextField = cell.durationTextField;
                
                cell.sensitiveTextField.text = [[NSString alloc] initWithFormat:@"%d", [value[2] intValue]];
                cell.sensitiveTextField.delegate = self;
                _gsensorSensitivityTextField = cell.sensitiveTextField;
                return cell;
            } else if ([value count] == 2) {
                FWConfigureGsens2Cell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigureGsens2Cell" owner:self options:nil] firstObject];
                
                cell.titleLabel.text = @"Gsensor(ms):";
                
                cell.intervalTextField.text = [[NSString alloc] initWithFormat:@"%d", [value[0] intValue]];
                cell.intervalTextField.delegate = self;
                _gsensorIntervalTextField = cell.intervalTextField;
                
                cell.durationTextField.text = [[NSString alloc] initWithFormat:@"%d", [value[1] intValue]];
                cell.durationTextField.delegate = self;
                _gsensorDurationTextField = cell.durationTextField;
                return cell;
            }
        } else if ([name isEqualToString:kKey]) {// Key
            FWConfigureStateCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigureStateCell" owner:self options:nil] firstObject];
            
            cell.titleLabel.text = @"Key(ms):";
            
            cell.intervalTextField.text = [[NSString alloc] initWithFormat:@"%d", [value[0] intValue]];
            cell.intervalTextField.delegate = self;
            _keyIntervalTextField = cell.intervalTextField;
            
            cell.durationTextField.text = [[NSString alloc] initWithFormat:@"%d", [value[1] intValue]];
            cell.durationTextField.delegate = self;
            _keyDurationTextField = cell.durationTextField;
            return cell;
        } else if ([name isEqualToString:kTLM]) {// TLM
            FWConfigureSwitchCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigureSwitchCell" owner:self options:nil] firstObject];
            
            cell.textLabel.text = @"TLM:";
            cell.textLabel.font = [UIFont systemFontOfSize:17];
            cell.switchBtn.on = [value boolValue];
            
            __weak FBPeripheralManager *weakManager = _peripheralManager;
            cell.indexPathBlock = ^(NSIndexPath *newIndexPath, BOOL switchBtnState) {
                [weakManager setValue:[NSString stringWithFormat:@"%d", (int)switchBtnState] forName:name];
            };
            
            return cell;
        } else if ([name isEqualToString:kAoA]) {// AoA
            FWConfigureSwitchCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigureSwitchCell" owner:self options:nil] firstObject];

            cell.textLabel.text = @"AoA:";
            cell.textLabel.font = [UIFont systemFontOfSize:17];
            cell.switchBtn.on = [value boolValue];

            __weak FBPeripheralManager *weakManager = _peripheralManager;
            cell.indexPathBlock = ^(NSIndexPath *newIndexPath, BOOL switchBtnState) {
                [weakManager setValue:[NSString stringWithFormat:@"%d", (int)switchBtnState] forName:kAoA];
            };

            return cell;
        } else if ([name isEqualToString:kLongRange]) {// LongRange
            FWConfigureSwitchCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigureSwitchCell" owner:self options:nil] firstObject];
            
            cell.textLabel.text = @"Longrange:";
            cell.textLabel.font = [UIFont systemFontOfSize:17];
            cell.switchBtn.on = [value boolValue];
            
            __weak FBPeripheralManager *weakManager = _peripheralManager;
            cell.indexPathBlock = ^(NSIndexPath *newIndexPath, BOOL switchBtnState) {
                [weakManager setValue:[NSString stringWithFormat:@"%d", (int)switchBtnState] forName:name];
            };
            
            return cell;
        } else {
            return nil;
        }
    } else if (section > 1 && section < self.normalBeacons.count + 2){
        return [self cellFrom:self.normalBeacons index:section-2 row:row];
    } else if (section > self.normalBeacons.count + 2){
        return [self cellFrom:self.sadvBeacons index:section-self.normalBeacons.count-3 row:row];
    }
    return nil;
}

- (UIView *)headerViewTitle:(NSString *)title{
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, SECTION_HEIGH)];
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectMake((headerView.frame.size.width - 150) * 0.5, 0, 150, SECTION_HEIGH)];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.opaque = NO;
    headerLabel.highlightedTextColor = [UIColor blackColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:17];
    headerLabel.text = title;
    [headerView addSubview:headerLabel];
    return headerView;
}

- (UIView *)beaconHeaderView:(NSArray *)beacons index:(NSInteger)index isSadv:(BOOL)isSadv{
    if (index >= beacons.count) return nil;
    FBMutableBeacon *beacon = beacons[index];
    const FBBeaconType type = beacon.type;
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, SECTION_HEIGH)];
    
    // 序号
    UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 50, 44)];
    numLabel.text = [[NSString alloc] initWithFormat:@"%ld", index+1];
    
    // 类型名
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectMake((headerView.frame.size.width - 100) * 0.5, 0, 100, SECTION_HEIGH)];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.opaque = NO;
    headerLabel.highlightedTextColor = [UIColor blackColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:17];
    if (type == FBBeaconTypeIBeacon) {
        headerLabel.text = @"iBeacon";
    } else if (type == FBBeaconTypeURL) {
        headerLabel.text = @"URL";
    } else if (type == FBBeaconTypeUID) {
        headerLabel.text = @"UID";
    } else if (type == FBBeaconTypeAltBeacon) {
        headerLabel.text = @"AltBeacon";
    } else if (type == FBBeaconTypeUnknown) {
        headerLabel.text = @"Custom";
    }
    
    // 删除按钮
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(headerView.frame.size.width - 20 - 8, (SECTION_HEIGH - 20) / 2, 20, 20);
    // condition 的tag加多10，方便区分
    closeButton.tag = isSadv ? index+11 : index + 1;
    [closeButton setImage:[UIImage imageNamed:@"x"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [headerView addSubview:headerLabel];
    [headerView addSubview:numLabel];
    [headerView addSubview:closeButton];
    return headerView;
}

- (UITableViewCell *)cellFrom:(NSArray *)beacons index:(NSInteger)index row:(NSInteger)row{
    FBMutableBeacon *beacon = beacons[index];
    const NSInteger lastRow = beacon.numberOfParameters - 1;
    
    // Enabled开关Cell
    if (row == lastRow) {
        FWConfigureSwitchCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigureSwitchCell" owner:self options:nil] firstObject];
        UIView *backgroundView = [[UIView alloc] init];
        backgroundView.backgroundColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1];
        cell.backgroundView = backgroundView;
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        cell.textLabel.text = @"Enabled:";
        cell.switchBtn.on = beacon.enabled;
        
        __weak FBMutableBeacon *weakBeacon = beacon;
        cell.indexPathBlock = ^(NSIndexPath *newIndexPath, BOOL switchBtnState) {
            weakBeacon.enabled = switchBtnState;
        };
        return cell;
    }
    // Phy广播间隔时间Cell
    if (beacon.iPhy != -1 && row == lastRow-3 && (91 == _peripheralManager.peripheralItem.modelIndex || 98 == _peripheralManager.peripheralItem.modelIndex)) {
        FWConfigureValueSetCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigureValueSetCell" owner:self options:nil] firstObject];
        UIView *backgroundView = [[UIView alloc] init];
        backgroundView.backgroundColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1];
        cell.backgroundView = backgroundView;
        cell.titleLabel.font = [UIFont systemFontOfSize:17];
        cell.titleLabel.text = LS(@"Interval(ms):");
        cell.inputTextField.keyboardType = UIKeyboardTypeNumberPad;
        cell.inputTextField.text = [[NSString alloc] initWithFormat:@"%d",beacon.iInterval];
        cell.inputTextField.delegate = self;
        _phy_intervalTextFieldArrays[index] = cell.inputTextField;
        return cell;
    }
    // Phy的TxPower值Cell
    if (beacon.iPhy != -1 && row == lastRow-2 && (91 == _peripheralManager.peripheralItem.modelIndex || 98 == _peripheralManager.peripheralItem.modelIndex)) {
        FWConfigurePowerCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigurePowerCell" owner:self options:nil] firstObject];
        UIView *backgroundView = [[UIView alloc] init];
        backgroundView.backgroundColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1];
        cell.backgroundView = backgroundView;
        cell.powerLabel.text = @"TxPower(db):";
        cell.txPowerLabel.text = beacon.txPower;
        cell.powerButton.tag = index;
        [cell.powerButton addTarget:self action:@selector(beaconTxPowerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    // Phy的coded类型配置Cell
    if (row == lastRow-1 && beacon.iPhy != -1 && (91 == _peripheralManager.peripheralItem.modelIndex || 98 == _peripheralManager.peripheralItem.modelIndex)) {
        FWConfigurePhyCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigurePhyCell" owner:self options:nil] firstObject];
        UIView *backgroundView = [[UIView alloc] init];
        backgroundView.backgroundColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1];
        cell.backgroundView = backgroundView;
        cell.phyLabel.font = [UIFont systemFontOfSize:17];
        cell.phyLabel.text = @"Phy:";
        if (beacon.iPhy == 0) {
            cell.phyValueLabel.text = [NSString stringWithFormat:@"%@",@"phy_1m"];
        } else if (beacon.iPhy == 1) {
            cell.phyValueLabel.text = [NSString stringWithFormat:@"%@",@"phy_2m"];
        } else {
            cell.phyValueLabel.text = [NSString stringWithFormat:@"%@",@"phy_coded"];
        }
        cell.phyButton.tag = index;
        [cell.phyButton addTarget:self action:@selector(phyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        if (98 == _peripheralManager.peripheralItem.modelIndex) {
            cell.phyButton.hidden = YES;
        }
        
        return cell;
        
    }
    // cell的普遍样式设置
    FWConfigureValueSetCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigureValueSetCell" owner:self options:nil] firstObject];
    cell.titleLabel.font = [UIFont systemFontOfSize:17];
    cell.inputTextField.textColor = [UIColor darkTextColor];
    cell.inputTextField.delegate = self;
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1];
    cell.backgroundView = backgroundView;
    
    const FBBeaconType type = beacon.type;
    // iBeacon
    if (type == FBBeaconTypeIBeacon) {
        if (row == 0) {
            cell.titleLabel.text = @"UUID:";
            cell.inputTextField.text = beacon.proximityUUID;
            cell.inputTextField.placeholder = [FESettingBeaconModel placeholder_UUID];
        } else if (row == 1) {
            cell.titleLabel.text = @"Major:";
            cell.inputTextField.text = [[NSString alloc] initWithFormat:@"%d", beacon.major];
            cell.inputTextField.placeholder = [FESettingBeaconModel placeholder_Major];
        } else if (row == 2) {
            cell.titleLabel.text = @"Minor:";
            cell.inputTextField.text = [[NSString alloc] initWithFormat:@"%d", beacon.minor];
            cell.inputTextField.placeholder = [FESettingBeaconModel placeholder_Minor];
        } else if (row == 3) {
            cell.titleLabel.text = @"RSSI at 1m:";
            cell.inputTextField.text = [[NSString alloc] initWithFormat:@"%d", beacon.calibratedTxPowerAt1m_iBeacon];
            cell.inputTextField.placeholder = [FESettingBeaconModel placeholder_RSSI];
        }
    } else if (type == FBBeaconTypeURL) {
        if (row == 0) {
            if([FESettingBeaconModel isValidEddystoneURL:beacon.URLString]){
                cell.inputTextField.textColor = [UIColor darkGrayColor];
            }else{
                cell.inputTextField.textColor = [UIColor redColor];
            }
            cell.titleLabel.text = @"URL:";
            cell.inputTextField.text = beacon.URLString;
            cell.inputTextField.placeholder = [FESettingBeaconModel placeholder_URL];
        } else if (row == 1) {
            cell.titleLabel.text = @"RSSI at 0m:";
            cell.inputTextField.text = [[NSString alloc] initWithFormat:@"%d", beacon.calibratedTxPowerAt0m_url];
            cell.inputTextField.placeholder = [FESettingBeaconModel placeholder_RSSI];
        }
    } else if (type == FBBeaconTypeUID) {
        if (row == 0) {
            cell.titleLabel.text = @"Namespace:";
            cell.inputTextField.text = beacon.namespaceString;
            cell.inputTextField.placeholder = [FESettingBeaconModel placeholder_Namespace];
        } else if (row == 1) {
            cell.titleLabel.text = @"Instance:";
            cell.inputTextField.text = beacon.instanceString;
            cell.inputTextField.placeholder = [FESettingBeaconModel placeholder_Instance];
        } else if (row == 2) {
            cell.titleLabel.text = @"Reserved:";
            cell.inputTextField.text = beacon.reservedString;
            cell.inputTextField.placeholder = [FESettingBeaconModel placeholder_Reserved];
        } else if (row == 3) {
            cell.titleLabel.text = @"RSSI at 0m:";
            cell.inputTextField.text = [[NSString alloc] initWithFormat:@"%d", beacon.calibratedTxPowerAt0m_uid];
            cell.inputTextField.placeholder = [FESettingBeaconModel placeholder_RSSI];
        }
    } else if (type == FBBeaconTypeAltBeacon) {
        if (row == 0) {
            cell.titleLabel.text = @"ID1:";
            cell.inputTextField.text = beacon.IDString1;
            cell.inputTextField.placeholder = [FESettingBeaconModel placeholder_ID1];
        } else if (row == 1) {
            cell.titleLabel.text = @"ID2:";
            cell.inputTextField.text = beacon.IDString2;
            cell.inputTextField.placeholder = [FESettingBeaconModel placeholder_ID2];
        } else if (row == 2) {
            cell.titleLabel.text = @"ID3:";
            cell.inputTextField.text = beacon.IDString3;
            cell.inputTextField.placeholder = [FESettingBeaconModel placeholder_ID3];
        } else if (row == 3) {
            cell.titleLabel.text = @"RSSI at 0m:";
            cell.inputTextField.text = [[NSString alloc] initWithFormat:@"%d", beacon.calibratedTxPowerAt1m_alt];
            cell.inputTextField.placeholder = [FESettingBeaconModel placeholder_RSSI];
        } else if (row == 4) {
            cell.titleLabel.text = @"Manufacturer ID:";
            cell.inputTextField.text = [[NSString alloc] initWithFormat:@"%d", beacon.manufacturerID];
            cell.inputTextField.placeholder = [FESettingBeaconModel placeholder_ManufacturerID];
        } else if (row == 5) {
            cell.titleLabel.text = @"Manufacturer Reserved:";
            cell.inputTextField.text = beacon.manufacturerReservedString;
            cell.inputTextField.placeholder = [FESettingBeaconModel placeholder_ManufacturerReserved];
        }
    } else if (type == FBBeaconTypeUnknown) {
        switch (row) {
            case 0:
                cell.titleLabel.text = @"Data:";
                cell.inputTextField.text = beacon.rawDataHex;
                cell.inputTextField.placeholder = [FESettingBeaconModel placeholder_Data];
                break;
            default:
                break;
        }
    } else {
        return nil;
    }
    // condition
    if (beacon.isSadv) {
        if (lastRow - 4 == row) {
            FWConfigurePowerCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigurePowerCell" owner:self options:nil] firstObject];
            UIView *backgroundView = [[UIView alloc] init];
            backgroundView.backgroundColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1];
            cell.backgroundView = backgroundView;
            cell.powerLabel.text = @"Sensor:";
            cell.txPowerLabel.text = beacon.sadv_sensor == 0 ? @"Key" : @"G-Sensor";
            cell.powerButton.tag = index;
            [cell.powerButton addTarget:self action:@selector(addSensorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
        if (lastRow - 3 == row) {
            FWConfigurePowerCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigurePowerCell" owner:self options:nil] firstObject];
            UIView *backgroundView = [[UIView alloc] init];
            backgroundView.backgroundColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1];
            cell.backgroundView = backgroundView;
            cell.powerLabel.text = @"Action:";
            if (beacon.sadv_sensor == 0) {
                cell.txPowerLabel.text = beacon.sadv_action == 0 ? @"Click On" : @"Click Off";
            } else {
                cell.txPowerLabel.text = @"Motion";
            }
            cell.powerButton.tag = index;
            [cell.powerButton addTarget:self action:@selector(addActionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
        if (lastRow - 2 == row) {
            cell.titleLabel.text = @"Internal(ms):";
            cell.inputTextField.text = [NSString stringWithFormat:@"%d", beacon.sadv_interval];
        }
        if (lastRow - 1 == row) {
            cell.titleLabel.text = @"Timeout(ms):";
            cell.inputTextField.text = [NSString stringWithFormat:@"%d", beacon.sadv_timeout];
        }
    }
    
    [cell.titleLabel sizeToFit];
    
    if ([cell.titleLabel.text isEqualToString:@"UUID:"] || [cell.titleLabel.text isEqualToString:@"ID1:"]) {
        cell.inputTextField.font = [UIFont systemFontOfSize:12];
    } else {
        cell.inputTextField.font = [UIFont systemFontOfSize:14];
    }
    return cell;
}

// 选项按钮Action
- (void)txPowerButtonPressed:(UIButton *)sender {
    FWPopoverViewController * popoverViewController = [[FWPopoverViewController alloc] initWithTitles:_configuration.txPowers sourceView:sender];
    __weak typeof(self) weakSelf = self;
    
    popoverViewController.selectionHandler = ^(NSString *powerString) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (strongSelf) {
            [strongSelf->_peripheralManager setValue:powerString forName:kTxPower];
            
            [strongSelf.tableView reloadData];
        }
    };
    [self presentViewController:popoverViewController animated:YES completion:nil];
}

// TxPower选项Action
- (void)beaconTxPowerButtonPressed:(UIButton *)sender{
    FWPopoverViewController *popoverViewController = [[FWPopoverViewController alloc] initWithTitles:_configuration.txPowers sourceView:sender];
    __weak typeof(self) weakSelf = self;
    popoverViewController.selectionHandler = ^(NSString *powerString) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf){
            strongSelf.normalBeacons[sender.tag].txPower = powerString;
            [strongSelf.tableView reloadData];
        }
    };
    [self presentViewController:popoverViewController animated:YES completion:nil];
}

// TxPower选项Action
- (void)phyButtonPressed:(UIButton *)sender {
    FWPopoverViewController *popoverViewController = [[FWPopoverViewController alloc] initWithTitles:_configuration.phys sourceView:sender];
    __weak typeof(self) weakSelf = self;
    popoverViewController.selectionHandler = ^(NSString *phy){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf){
            //[strongSelf->_peripheralManager setValue:phy forName:kPhy];
            if([phy isEqualToString:@"phy_1m"]){
                strongSelf.normalBeacons[sender.tag].iPhy = 0;
            }else if([phy isEqualToString:@"phy_2m"]){
                strongSelf.normalBeacons[sender.tag].iPhy = 1;
            }else{
                strongSelf.normalBeacons[sender.tag].iPhy = 2;
            }
            
            [strongSelf.tableView reloadData];
        }
    };
    [self presentViewController:popoverViewController animated:YES completion:nil];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

// 输入检测
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = textField.text;
    NSString *newText = [text stringByReplacingCharactersInRange:range withString:string];
    
    if (newText.length == 0) {
        return YES;
    }
    if (range.length == 0 &&
        string.length == 0 &&
        [newText isEqualToString:text]) {
        return YES;
    }
    
    const NSInteger newLength = newText.length;
    
    if (textField == _intervalTextField ||
        textField == _pinTextField ||
        [_phy_intervalTextFieldArrays containsObject:textField] ||
        textField == _keyIntervalTextField ||
        textField == _keyDurationTextField ||
        textField == _gsensorIntervalTextField ||
        textField == _gsensorDurationTextField ||
        textField == _gsensorSensitivityTextField ||
        textField == _nameTextField) {
        
        if (textField == _intervalTextField || [_phy_intervalTextFieldArrays containsObject:textField]) {
            
            FBRange *intervalRange = _configuration.intervalRange;
            const int newValue = [newText intValue];
            if (intervalRange && intervalRange.minValue <= newValue && newValue <= intervalRange.maxValue) {
                textField.textColor = [UIColor darkGrayColor];
            } else {
                textField.textColor = [UIColor redColor];
            }
        }
        
        // 单独Beacon广播的广播间隔时间
        if ([_phy_intervalTextFieldArrays containsObject:textField]) {
            NSUInteger index = [_phy_intervalTextFieldArrays indexOfObject:textField];
            self.normalBeacons[index].iInterval = [newText intValue];
            
        } else if (textField == _intervalTextField) {
            // 广播间隔
            [_peripheralManager setValue:newText forName:kInterval];
            
        } else if (textField == _pinTextField) {
            // Pin
            [_peripheralManager setValue:newText forName:kPin];
            
        } else if (textField == _keyIntervalTextField) {
            // 按键间隔时间（Key）
            NSMutableArray *keyValues = [_peripheralManager valueForName:kKey];
            keyValues[0] = newText;
            
        } else if (textField == _keyDurationTextField) {
            // 按键持续时间（Key）
            NSMutableArray *keyValues = [_peripheralManager valueForName:kKey];
            keyValues[1] = newText;
            
        } else if (textField == _gsensorIntervalTextField) {
            // Gsensor间隔
            NSMutableArray *gsensorValues = [_peripheralManager valueForName:kGsensor];
            gsensorValues[0] = newText;
            
        } else if (textField == _gsensorDurationTextField) {
            // Gsensor持续时间
            NSMutableArray *gsensorValues = [_peripheralManager valueForName:kGsensor];
            gsensorValues[1] = newText;
            
        } else if (textField == _gsensorSensitivityTextField) {
            // Gsensor灵敏度
            NSMutableArray *gsensorValues = [_peripheralManager valueForName:kGsensor];
            gsensorValues[2] = newText;
        } else if (textField == _nameTextField) {
            [_peripheralManager setValue:newText forName:kName];
        }
        
        [self updateTextColorsAndWhetherShowAlertMessage:NO];
        
        return YES;
    }
    
    FWConfigureValueSetCell *cell = (FWConfigureValueSetCell *)[[textField superview] superview];
    // 获取cell对应的section
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    const NSInteger section = indexPath.section;
    const NSInteger row = indexPath.row;
    
    if (section == 0) {
        if (textField == _nameTextField) { // 名称
            const NSInteger lengthOfBytes = [newText lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
            
            if (lengthOfBytes > 25 && string.length > 0) {
                return NO;
            }
            return YES;
        } else if (textField == _pinTextField) { // Pin
            textField.textColor = [UIColor darkTextColor];
            
            if (newLength != 6) {
                textField.textColor = [UIColor redColor];
            } else if (![newText isDigits]) {
                return NO;
            } else if ([newText hasPrefix:@"-"]) {
                return NO;
            }
            return YES;
        }
    } else {
        FBMutableBeacon *beacon;
        if (section > 1 && section < self.normalBeacons.count + 2){
            beacon = self.normalBeacons[section - 2];
        }else if (section > self.normalBeacons.count + 2) {
            beacon = self.sadvBeacons[section - self.normalBeacons.count - 3];
        }
        // sadv 位置
        NSInteger sadvIndex = 0;
        
        const FBBeaconType beaconType = beacon.type;
        
        if (beaconType == FBBeaconTypeIBeacon) { // iBeacon广播
            sadvIndex = 4;
            if (row == 0) { // UUID
                BOOL isOK = [FESettingBeaconModel dealwith_UUID_TextField:textField newText:newText];
                if (isOK) {
                    beacon.proximityUUID = newText;
                }
                return isOK;
            } else if (row == 1) { // Major -> 0 ~ 65535
                BOOL isOK = [FESettingBeaconModel dealwith_Major_TextField:textField newText:newText];
                beacon.major = [textField.text intValue];
                return isOK;
            } else if (row == 2) { // Minor -> 0 ~ 65535
                BOOL isOK = [FESettingBeaconModel dealwith_Minor_TextField:textField newText:newText];
                beacon.minor = [textField.text intValue];
                return isOK;
            } else if (row == 3) { // RSSI at 1m
                BOOL isOK = [FESettingBeaconModel dealwith_RSSI_TextField:textField newText:newText inputString:string];
                beacon.calibratedTxPowerAt1m_iBeacon = [textField.text intValue];
                return isOK;
            }
        } else if (beaconType == FBBeaconTypeURL) { // URL广播
            sadvIndex = 2;
            if (row == 0) { // url
                BOOL isOK = [FESettingBeaconModel dealwith_URL_TextField:textField newText:newText inputString:string];
                beacon.URLString = textField.text;
                return isOK;
            } else if (row == 1) { // RSSI at 0m
                BOOL isOK = [FESettingBeaconModel dealwith_RSSI_TextField:textField newText:newText inputString:string];
                beacon.calibratedTxPowerAt0m_url = [textField.text intValue];
                return isOK;
            }
        } else if (beaconType == FBBeaconTypeUID) { // UID广播
            sadvIndex = 4;
            if (row == 0) { // Namespace
                BOOL isOK = [FESettingBeaconModel dealwith_Namespace_TextField:textField newText:newText];
                beacon.namespaceString = textField.text;
                return isOK;
            } else if (row == 1) { // Instance
                BOOL isOK = [FESettingBeaconModel dealwith_Instance_TextField:textField newText:newText];
                beacon.instanceString = textField.text;
                return isOK;
            } else if (row == 2) { // Reserved
                BOOL isOK = [FESettingBeaconModel dealwith_Reserved_TextField:textField newText:newText];
                beacon.reservedString = textField.text;
                return isOK;
            } else if (row == 3) { // RSSI at 0m
                BOOL isOK = [FESettingBeaconModel dealwith_RSSI_TextField:textField newText:newText inputString:string];
                beacon.calibratedTxPowerAt0m_uid = [textField.text intValue];
                return isOK;
            }
        } else if (beaconType == FBBeaconTypeAltBeacon) { // AltBeacon广播
            sadvIndex = 6;
            if (row == 0) { // ID1
                BOOL isOK = [FESettingBeaconModel dealwith_ID1_TextField:textField newText:newText];
                beacon.IDString1 = textField.text;
                return isOK;
            } else if (row == 1) { // ID2
                BOOL isOK = [FESettingBeaconModel dealwith_ID2_TextField:textField newText:newText];
                beacon.IDString2 = textField.text;
                return isOK;
            } else if (row == 2) { // ID3
                BOOL isOK = [FESettingBeaconModel dealwith_ID3_TextField:textField newText:newText];
                beacon.IDString3 = textField.text;
                return isOK;
            } else if (row == 3) { // RSSI at 1m
                BOOL isOK = [FESettingBeaconModel dealwith_RSSI_TextField:textField newText:newText inputString:string];
                beacon.calibratedTxPowerAt1m_alt = [textField.text intValue];
                return isOK;
            } else if (row == 4) { // Manufacturer ID
                BOOL isOK = [FESettingBeaconModel dealwith_ManufacturerID_TextField:textField newText:newText];
                beacon.manufacturerID = [textField.text intValue];
                return isOK;
            } else if (row == 5) { // Manufacturer Reserved
                BOOL isOK = [FESettingBeaconModel dealwith_ManufacturerReserved_TextField:textField newText:newText range:range];
                beacon.manufacturerReservedString = textField.text;
                return isOK;
            }
        }else if (beaconType == FBBeaconTypeUnknown){
            sadvIndex = 1;
            if (0 == row) {
                BOOL isOK = [FESettingBeaconModel dealwith_Data_TextField:textField newText:newText];
                beacon.rawDataHex = textField.text;
                return isOK;
            }
        }
        if (beacon.isSadv) {
            if (sadvIndex + 2 == row) {
                BOOL isOK = [FESettingBeaconModel dealwith_Internal_TextField:textField newText:newText];
                beacon.sadv_interval = [textField.text intValue];
                return isOK;
            }
            if (sadvIndex + 3 == row) {
                BOOL isOK = [FESettingBeaconModel dealwith_Timeout_TextField:textField newText:newText];
                beacon.sadv_timeout = [textField.text intValue];
                return isOK;
            }
        }
    }
    
    return YES;
}

#pragma mark - UIPopoverPresentationControllerDelegate
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    return UIModalPresentationNone; //不适配
}
- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController{
    return YES;   //点击蒙版popover消失， 默认YES
}

- (void)showPopupViewController:(UIButton *)sender {
    //    if (nil == _popupViewController) {
    _popupViewController = [UIViewController new];
    NSMutableArray *types = [NSMutableArray array];
    // 少于10个才能添加
    if (self.normalBeacons.count < 10) {
        [types addObject:@"Beacon Slot"];
    }
    
    if (self.sadvBeacons.count < 10) {
        [types addObject:@"Condition Slot"];
    }
    
    const CGSize size = { 120, types.count * 50 };
    
    _popupViewController.modalPresentationStyle = UIModalPresentationPopover;
    _popupViewController.preferredContentSize = size;
    
    UIView *view = _popupViewController.view;
    const CGFloat buttonHeight = size.height / types.count;
    
    for (NSInteger i = 0; i < types.count; i ++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 13 + buttonHeight * i, size.width, buttonHeight)];
        
        [button setTag:(i + 1)];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:types[i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(selectAdd:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
    }
    //    }
    
    UIPopoverPresentationController *presentationController = _popupViewController.popoverPresentationController;
    
    presentationController.sourceView = sender;
    presentationController.sourceRect = sender.bounds;
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    presentationController.delegate = self;
    
    [self presentViewController:_popupViewController animated:YES completion:nil];
}

// 选择类型
- (void)selectAdd:(UIButton *)sender {
    NSInteger index = sender.tag;
    [_popupViewController dismissViewControllerAnimated:YES completion:nil];
    _popupViewController = nil;
    switch (index) {
        case 1:
            [self gotoBeacon];
            break;
        case 2:
            [self gotoCondition];
            //            [self gotoKey];
            break;
        case 3:
            //            [self gotoMove];
            break;
        default:
            break;
    }
}

- (void)gotoBeacon{
    if (98 == _peripheralManager.peripheralItem.modelIndex && self.normalBeacons.count >= 2) {
        return;
    }
    
    _enteringNextViewController = YES;
    
    FWAddBeaconViewController *viewController;
    if (91 == _peripheralManager.peripheralItem.modelIndex || 98 == _peripheralManager.peripheralItem.modelIndex) {
        viewController = [[FWAddBeaconViewController alloc] initWithModelIndex:_peripheralManager.peripheralItem.modelIndex configTxPowers:_configuration.txPowers addType:AddType_Beacon];
    }else{
        viewController = [[FWAddBeaconViewController alloc] initWithAddType:AddType_Beacon item:nil];
    }
    
    __weak typeof(self) weakSelf = self;
    
    viewController.completionHandler = ^(FBMutableBeacon *beacon) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            NSMutableArray *beacons = strongSelf.normalBeacons.mutableCopy;
            const NSInteger newIndex = beacons.count;
            [FBMutableBeacon normalizeNorvIndexForBeacons:strongSelf->_peripheralManager.beacons];
            strongSelf->_addBeaconButton.hidden = 9 <= newIndex && self.sadvBeacons.count == 10;
            
            beacon.index = (int)newIndex;
            //            [beacons insertObject:beacon atIndex:newIndex];
            [strongSelf->_peripheralManager.beacons addObject:beacon];
            
            [strongSelf.tableView reloadData];
        }
    };
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)gotoCondition{
    if (98 == _peripheralManager.peripheralItem.modelIndex && _peripheralManager.beacons.count >= 2) {
        return;
    }
    
    _enteringNextViewController = YES;
    FWAddBeaconViewController *viewController = [[FWAddBeaconViewController alloc] initWithAddType:AddType_Condition item:_peripheralItem];
    __weak typeof(self) weakSelf = self;
    viewController.completionHandler = ^(FBMutableBeacon *beacon) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            NSMutableArray *beacons = strongSelf.sadvBeacons.mutableCopy;
            const NSInteger newIndex = beacons.count;
            [FBMutableBeacon normalizeSadvIndexForBeacons:strongSelf->_peripheralManager.beacons];
            strongSelf->_addBeaconButton.hidden = 9 <= newIndex && strongSelf.normalBeacons.count == 10;
            
            beacon.index = (int)newIndex;
            [strongSelf->_peripheralManager.beacons addObject:beacon];
            [strongSelf.tableView reloadData];
        }
    };
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)addSensorButtonPressed:(UIButton *)sender{
    FWPopoverViewController *popoverViewController = [[FWPopoverViewController alloc] initWithTitles:@[@"Key",@"G-Sensor"] sourceView:sender];
    __weak typeof(self) weakSelf = self;
    popoverViewController.selectionHandler = ^(NSString *powerString) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf){
            strongSelf.sadvBeacons[sender.tag].sadv_sensor = [powerString isEqualToString:@"Key"]?0:1;
            [strongSelf.tableView reloadData];
        }
    };
    [self presentViewController:popoverViewController animated:YES completion:nil];
}

- (void)addActionButtonPressed:(UIButton *)sender{
    NSArray *keyArray = @[@"Click On",@"Click Off"];
    NSArray *gsensorArray = @[@"Motion"];
    NSArray *list = keyArray;
    if (self.sadvBeacons[sender.tag].sadv_sensor == 1){
        list = gsensorArray;
    }
    FWPopoverViewController *popoverViewController = [[FWPopoverViewController alloc] initWithTitles:list sourceView:sender];
    __weak typeof(self) weakSelf = self;
    popoverViewController.selectionHandler = ^(NSString *powerString) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf){
            strongSelf.sadvBeacons[sender.tag].sadv_action = [powerString isEqualToString:list[0]]?0:1;
            [strongSelf.tableView reloadData];
        }
    };
    [self presentViewController:popoverViewController animated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (NSArray<FBMutableBeacon *> *)sadvBeacons {
    NSMutableArray *arr = [NSMutableArray array];
    for (FBMutableBeacon *b in _peripheralManager.beacons) {
        if (b.isSadv) {
            [arr addObject:b];
        }
    }
    return arr;
}

- (NSArray<FBMutableBeacon *> *)normalBeacons {
    NSMutableArray *arr = [NSMutableArray array];
    for (FBMutableBeacon *b in _peripheralManager.beacons) {
        if (!b.isSadv) {
            [arr addObject:b];
        }
    }
    return arr;
}

@end
