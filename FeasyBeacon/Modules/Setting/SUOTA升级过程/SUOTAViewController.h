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
#import "DeviceNavigationController.h"
#import "SuotaLib.h"
#import "FeasyBeacon-Swift.h"

@interface SUOTAViewController : UIViewController <SuotaViewNavigation>

// -------以下方式供Nav调用--------

@property BOOL isSuotaRunning;
@property BOOL isSuotaCompleted;
@property BOOL isSuotaFailed;

- (void) onSuotaLog:(enum SuotaProtocolState)state type:(enum SuotaLogType)type log:(NSString*)log;
- (void) onChunkSend:(int)chunkCount totalChunks:(int)totalChunks chunk:(int)chunk block:(int)block blockChunks:(int)blockChunks totalBlocks:(int)totalBlocks;
- (void) onUploadProgress:(float)percent;
- (void) onSuccess:(double)totalElapsedSeconds imageUploadElapsedSeconds:(double)imageUploadElapsedSeconds;
- (void) onRebootSent;
- (void) updateSpeedStatistics:(double)current max:(double)max min:(double)min avg:(double)avg;
- (void) updateCurrentSpeed:(double)currentSpeed;
- (void) notifySuotaFailed;

@end

/**
 这个 `SUOTAViewController` 类是一个用于管理和展示 SUOTA（Software Update Over The Air）过程的视图控制器。SUOTA 是一种通过蓝牙无线更新设备固件的技术。这个视图控制器的主要功能和用途如下：
 
 1. **展示上传进度**：
 - 通过 `UIProgressView` 和 `UILabel` 显示固件上传的进度和相关的文本描述，用户可以实时看到更新的进度。
 
 2. **展示上传速度和统计信息**：
 - 类中有多个 `UILabel` 用来显示上传过程中统计的各类数据，如当前速度、最大/最小速度、平均速度等。这些信息通过 `updateSpeedStatistics` 和 `updateCurrentSpeed` 方法更新。
 
 3. **管理和记录日志**：
 - `logTextView` 用于显示和记录更新过程中的日志信息，便于用户了解更新过程中的各类事件和状态。
 
 4. **展示上传速度的图表**：
 - 通过 `LineChartView` 展示上传速度的图表，图表数据会随着更新进程的进行不断刷新，给用户提供一个直观的速度变化视图。
 
 5. **处理更新状态**：
 - 类中有多个方法如 `onSuccess`、`onRebootSent` 和 `notifySuotaFailed`，分别用来处理更新成功、发送重启命令和更新失败的情况，并更新 UI。
 
 6. **禁用滑动手势**：
 - 当这个视图控制器被展示时，禁用了滑动手势，以防止用户在更新过程中误操作。
 
 7. **界面样式和布局设置**：
 - 在 `viewDidLoad` 中，对视图的一些基本属性如背景颜色、阴影效果等进行了设置，以确保界面符合设计要求。
 
 总体来说，`SUOTAViewController` 是一个专门为设备固件无线更新设计的视图控制器，它的主要任务是管理更新过程中的所有用户交互，展示更新进度、日志和速度统计信息，并处理更新成功或失败的各种情况。
 */
