/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2020 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "DeviceNavigationController.h"
#import "DeviceViewController.h"
#import "MBProgressHUD.h"
#import "Parameters.h"
#import "SUOTAViewController.h"

@implementation DeviceNavigationController

static NSString* const TAG = @"DeviceNavigationController";
static int const HUD_DISPLAY_TIME_MILLIS = 1200;

- (void) viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 15, *)) {
        UINavigationBarAppearance* appearance = [UINavigationBarAppearance new];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor colorWithRed:0.165 green:0.157 blue:0.616 alpha:1];
        appearance.titleTextAttributes = @{ NSForegroundColorAttributeName : UIColor.whiteColor };
        self.navigationBar.standardAppearance = appearance;
        self.navigationBar.scrollEdgeAppearance = appearance;
    }
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    NSUInteger index = [self.viewControllers indexOfObjectPassingTest:^BOOL (UIViewController* viewController, NSUInteger index, BOOL* stop){
        return *stop = [viewController isKindOfClass:DeviceViewController.class];
    }];
    if (index != NSNotFound)
        [(DeviceViewController*)self.viewControllers[index] notifyDismissed];

    [Parameters.instance.suotaManager destroy];
}

// Handle navigation when SUOTA is Running
- (nullable UIViewController*) popViewControllerAnimated:(BOOL)animated {
    if ([self.topViewController conformsToProtocol:@protocol(SuotaViewNavigation)]
        && [(id<SuotaViewNavigation>) self.topViewController handleNavigation:^{[self dismissViewControllerAnimated:true completion:nil];}])
        return nil;
    return [super popViewControllerAnimated:animated];
}

- (BOOL) navigationBar:(UINavigationBar*)navigationBar shouldPopItem:(UINavigationItem*)item {
    if (item == self.topViewController.navigationItem) {
        if ([self.topViewController conformsToProtocol:@protocol(SuotaViewNavigation)]
            && [(id<SuotaViewNavigation>) self.topViewController handleNavigation:^{[self dismissViewControllerAnimated:true completion:nil];}]) {
            if (UIDevice.currentDevice.systemVersion.floatValue < 11) {
                // Restore visual state of back button
                for (UIView* view in navigationBar.subviews) {
                    if (view.alpha > 0 && view.alpha < 1)
                        view.alpha = 1;
                }
            }
        } else {
            [super popViewControllerAnimated:true];
        }
        return false;
    }
    return true;
}

- (void) displayAlert:(NSString*)title message:(NSString*)message dismissViewController:(BOOL)dismissViewController {
    if (self.presentingAlertController)
        return;
    self.willBeDismissed = dismissViewController;
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    self.presentingAlertController = alert;
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:LS(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        self.presentingAlertController = nil;
        self.willBeDismissed = false;
        if (dismissViewController) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceControllerDismissed" object:nil];
        }
    }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) displayHud:(NSString*)message dismissViewController:(BOOL)dismissViewController {
    if (!self.willBeDismissed && dismissViewController) {
        if (self.presentingAlertController) {
            [self.presentingAlertController dismissViewControllerAnimated:NO completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceControllerDismissed" object:nil];
        }
    }
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabel.text = message;
    hud.detailsLabel.font = hud.label.font;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, HUD_DISPLAY_TIME_MILLIS / 1000.0 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!self.willBeDismissed && dismissViewController) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceControllerDismissed" object:nil];
        }
    });
}

#pragma mark - SuotaManagerDelegate

// TODO:1️⃣DeviceViewController
// TODO:2️⃣SUOTAViewController
/*!
 * @method onConnectionStateChange:
 *
 * @param newStatus 新的连接状态。状态代码可以在SuotaManagerStatus中找到。
 *
 * @discussion 每次连接状态更改时触发此方法。
 */
- (void) onConnectionStateChange:(enum SuotaManagerStatus)newStatus {
    if (newStatus != DISCONNECTED)
        return;

    /// 使用 indexOfObjectPassingTest: 方法查找 viewControllers 数组中是否存在 SUOTAViewController 的实例
    /// 如果找到 SUOTAViewController，判断 isSuotaCompleted 和 isSuotaFailed 状态。如果 SUOTA 操作已完成或失败，则设置 dismissViewController 为 false，表示不需要关闭视图控制器。否则，保持 dismissViewController 为 true，表示需要关闭视图控制器
    BOOL dismissViewController = true;
    NSUInteger index = [self.viewControllers indexOfObjectPassingTest:^BOOL (UIViewController* viewController, NSUInteger index, BOOL* stop){
        return *stop = [viewController isKindOfClass:SUOTAViewController.class];
    }];
    if (index != NSNotFound) {
        SUOTAViewController* vc = (SUOTAViewController*)self.viewControllers[index];
        dismissViewController = !vc.isSuotaCompleted && !vc.isSuotaFailed;
    }
    
    index = [self.viewControllers indexOfObjectPassingTest:^BOOL (UIViewController* viewController, NSUInteger index, BOOL* stop){
        return *stop = [viewController isKindOfClass:DeviceViewController.class];
    }];
    if (index != NSNotFound && dismissViewController)
        [(DeviceViewController*)self.viewControllers[index] notifyDismissed];

    [self displayHud:[NSString stringWithFormat:@"%@ %@", Parameters.instance.peripheral.name, LS(@"Disconnected")] dismissViewController:dismissViewController];
}// onConnectionStateChange: 方法在检测到设备断开连接时，执行了一系列逻辑来决定是否关闭当前视图控制器。通过查找 SUOTAViewController 和 DeviceViewController 的实例，方法根据设备连接的状态和 SUOTA 操作的结果，确定是否需要关闭视图控制器，并在需要时通知相关控制器。此外，方法还通过 HUD 向用户展示设备断开连接的消息。这种处理方式确保了用户界面在设备断开连接后的一致性和合理性

/*!
 * @method onServicesDiscovered
 *
 * @discussion 在服务发现时触发此方法。
 */
- (void) onServicesDiscovered {
    SuotaLog(TAG, @"Services discovered");
}

// TODO:1️⃣DeviceViewController
/*!
 * @method onCharacteristicRead:characteristic:
 *
 * @param characteristicGroup 当前的特征组。特征组可以在CharacteristicGroup中找到。
 * @param characteristic 读取到的特征。
 *
 * @discussion 在读取特征时触发此方法。
 */
- (void) onCharacteristicRead:(enum CharacteristicGroup)characteristicGroup characteristic:(CBCharacteristic*)characteristic {
    NSUInteger index = [self.viewControllers indexOfObjectPassingTest:^BOOL (UIViewController* viewController, NSUInteger index, BOOL* stop){
        return *stop = [viewController isKindOfClass:DeviceViewController.class];
    }];
    if (index != NSNotFound && characteristicGroup == DEVICE_INFO)
        [(DeviceViewController*)self.viewControllers[index] onCharacteristicRead:characteristic.UUID value:[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]];
}

/*!
 * @method onDeviceInfoReadCompleted:
 *
 * @param status DeviceInfoReadStatus状态。指示是否成功读取到设备信息：SUCCESS表示成功，NO_DEVICE_INFO表示没有可读取的设备信息。
 *
 * @discussion 当所有设备信息读取完成时触发此方法。
 */
- (void) onDeviceInfoReadCompleted:(enum DeviceInfoReadStatus)status {
    SuotaLog(TAG, @"onInfoReadCompleted");
}

// TODO:1️⃣DeviceViewController
/*!
 * @method onDeviceReady
 *
 * @discussion 当所有可用的SUOTA信息已读取完毕时触发此方法。如果AUTO_READ_DEVICE_INFO设置为<code>true</code>，则表示设备信息也已读取。
 */
- (void) onDeviceReady {
    NSUInteger index = [self.viewControllers indexOfObjectPassingTest:^BOOL (UIViewController* viewController, NSUInteger index, BOOL* stop){
        return *stop = [viewController isKindOfClass:DeviceViewController.class];
    }];
    if (index != NSNotFound)
        [(DeviceViewController*)self.viewControllers[index] onDeviceReady];
}

// TODO:2️⃣SUOTAViewController
/*!
 * @method onSuotaLog:type:log:
 *
 * @param state 当前的SuotaProtocolState。
 * @param type 日志类型。
 * @param log 关联的状态更新消息。
 *
 * @discussion 如果NOTIFY_SUOTA_STATUS为<code>true</code>，则会触发此方法。
 */
- (void) onSuotaLog:(enum SuotaProtocolState)state type:(enum SuotaLogType)type log:(NSString*)log {
    if ([self.topViewController isKindOfClass:SUOTAViewController.class]) {
        [(SUOTAViewController*)self.topViewController onSuotaLog:state type:type log:log];
    }
}

// TODO:2️⃣SUOTAViewController
/*!
 * @method onChunkSend:totalChunks:chunk:block:blockChunks:totalBlocks:
 *
 * @param chunkCount 当前块的数据块数。
 * @param totalChunks 总的数据块数。
 * @param chunk 当前块的数据块数。
 * @param block 当前的数据块。
 * @param blockChunks 当前块中的数据块总数。
 * @param totalBlocks 总的数据块数。
 *
 * @discussion 如果NOTIFY_CHUNK_SEND为<code>true</code>，则在发送数据块时触发此方法。
 */
- (void) onChunkSend:(int)chunkCount totalChunks:(int)totalChunks chunk:(int)chunk block:(int)block blockChunks:(int)blockChunks totalBlocks:(int)totalBlocks {
    if ([self.topViewController isKindOfClass:SUOTAViewController.class]) {
        [(SUOTAViewController*)self.topViewController onChunkSend:chunkCount totalChunks:totalChunks chunk:chunk block:block blockChunks:blockChunks totalBlocks:totalBlocks];
    }
}

/*!
 * @method onBlockSent:
 *
 * @param block 当前的数据块数。
 * @param totalBlocks 总的数据块数。
 *
 * @discussion 在成功传输数据块后触发此方法。
 */
- (void) onBlockSent:(int)block totalBlocks:(int)totalBlocks {
}

// TODO:2️⃣SUOTAViewController
/*!
 * @method onUploadProgress:
 *
 * @param percent 已发送到设备的固件文件的百分比。
 *
 * @discussion 如果NOTIFY_UPLOAD_PROGRESS为<code>true</code>，则在上传进度更新时触发此方法。
 */
- (void) onUploadProgress:(float)percent {
    if ([self.topViewController isKindOfClass:SUOTAViewController.class]) {
        [(SUOTAViewController*)self.topViewController onUploadProgress:percent];
    }
}

// TODO:2️⃣SUOTAViewController
/*!
 * @method onSuccess:imageUploadElapsedSeconds:
 *
 * @param totalElapsedSeconds 执行SUOTA协议的总耗时。
 * @param imageUploadElapsedSeconds 图像上传期间的耗时。
 *
 * @discussion 在SUOTA过程成功完成后触发此方法。如果无法计算耗时，时间参数值为<code>-1</code>。
 */
- (void) onSuccess:(double)totalElapsedSeconds imageUploadElapsedSeconds:(double)imageUploadElapsedSeconds {
    if ([self.topViewController isKindOfClass:SUOTAViewController.class]) {
        [(SUOTAViewController*)self.topViewController onSuccess:totalElapsedSeconds imageUploadElapsedSeconds:imageUploadElapsedSeconds];
    }
}

// TODO:2️⃣SUOTAViewController
/*!
 * @method onFailure:
 *
 * @param errorCode 导致失败的原因。错误代码可以在SuotaErrors和ApplicationErrors中找到。
 *
 * @discussion 在发生意外事件时触发此方法。
 */
- (void) onFailure:(int)errorCode {
    if (errorCode != INVALID_FIRMWARE_CRC && [self.topViewController isKindOfClass:SUOTAViewController.class]) {
        [(SUOTAViewController*)self.topViewController notifySuotaFailed];
    }
    [self displayAlert:LS(@"An Error Occurred") message:SuotaProfile.suotaErrorCodeList[@(errorCode)] dismissViewController:errorCode != INVALID_FIRMWARE_CRC];
}

// TODO:2️⃣SUOTAViewController
/*!
 * @method onRebootSent
 *
 * @discussion 当重启信号发送到设备时触发此方法。
 */
- (void) onRebootSent {
    if ([self.topViewController isKindOfClass:SUOTAViewController.class]) {
        [(SUOTAViewController*)self.topViewController onRebootSent];
    }
}

// TODO:2️⃣SUOTAViewController
/*!
 * @method updateSpeedStatistics:max:min:avg:
 *
 * @param current 当前块的传输速度（Bps）。
 * @param max 最大传输速度（Bps）。
 * @param min 最小传输速度（Bps）。
 * @param avg 平均传输速度（Bps）。
 *
 * @discussion 如果CALCULATE_STATISTICS为<code>true</code>，则每500ms触发此方法。
 */
- (void) updateSpeedStatistics:(double)current max:(double)max min:(double)min avg:(double)avg {
    if ([self.topViewController isKindOfClass:SUOTAViewController.class]) {
        [(SUOTAViewController*)self.topViewController updateSpeedStatistics:current max:max min:min avg:avg];
    }
}

// TODO:2️⃣SUOTAViewController
/*!
 * @method updateCurrentSpeed:
 *
 * @param currentSpeed 每秒发送的字节数。
 *
 * @discussion 如果CALCULATE_STATISTICS为<code>true</code>，则每1000ms触发此方法。这表示当前每秒发送的字节数，而不是平均值。
 */
- (void) updateCurrentSpeed:(double)currentSpeed {
    if ([self.topViewController isKindOfClass:SUOTAViewController.class]) {
        [(SUOTAViewController*)self.topViewController updateCurrentSpeed:currentSpeed];
    }
}

@end

/**
 
 // 销毁对象
 [Parameters.instance.suotaManager destroy];
 */
