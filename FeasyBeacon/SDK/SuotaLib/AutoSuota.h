/*
 *******************************************************************************
 *
 * Copyright (C) 2019-2020 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

/*!
 @header AutoSuota.h
 @brief AutoSuota 类的头文件。
 
 此头文件包含 AutoSuota 类的方法和属性声明，还包含 BaseSuotaDelegate 协议的声明。
 
 @copyright 2019 Dialog Semiconductor
 */

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>
#import "SuotaLibConfig.h"
#import "SuotaManager.h"

@class SuotaFile;

/*!
 *  @protocol BaseSuotaDelegate
 *  @brief BaseSuotaDelegate 协议定义了处理 SUOTA 过程的必要方法。
 *
 *  @discussion {@link suotaViewController} 必须实现 <code>BaseSuotaDelegate</code> 协议。协议中的方法用于获取 SUOTA 过程的信息。
 */
@protocol BaseSuotaDelegate

/*!
 * @method startSuota
 * @brief 当 {@link onDeviceReady} 方法被触发时调用此方法。
 *
 * @discussion 此方法在设备准备好开始 SUOTA 过程时触发。
 */
- (void) startSuota;

/*!
 * @method appendToLogcat:
 * @param log 要追加到日志中的消息。
 *
 * @discussion 当 {@link onSuotaLog:type:log:} 方法被触发时调用此方法。
 */
- (void) appendToLogcat:(NSString*)log;

/*!
 * @method onSuccess:imageUploadElapsedSecs:
 * @param totalElapsedSecs SUOTA 运行的总耗时（毫秒）。
 * @param imageUploadElapsedSecs 图像上传的总耗时（毫秒）。
 *
 * @discussion 当 {@link onSuccess:imageUploadElapsedSeconds:} 方法被触发时调用此方法。
 */
- (void) onSuccess:(double)totalElapsedSecs imageUploadElapsedSecs:(double)imageUploadElapsedSecs;

/*!
 * @method updateCurrentlySendingInfo:totalChunks:chunk:block:blockChunks:totalBlocks:
 * @param chunkCount 已发送的块数。
 * @param totalChunks 总块数。
 * @param chunk 当前块的序号。
 * @param block 当前块所在的块组号。
 * @param blockChunks 当前块组中的总块数。
 * @param totalBlocks 总块组数。
 *
 * @discussion 当 {@link onChunkSend:totalChunks:chunk:block:blockChunks:totalBlocks:} 方法被触发时调用此方法。
 */
- (void) updateCurrentlySendingInfo:(int)chunkCount totalChunks:(int)totalChunks chunk:(int)chunk block:(int)block blockChunks:(int)blockChunks totalBlocks:(int)totalBlocks;

/*!
 * @method updateProgress:
 * @param percent 更新进度百分比。值为 1.0 对应 100%。
 *
 * @discussion 当 {@link onUploadProgress:} 方法被触发时调用此方法。
 */
- (void) updateProgress:(float)percent;

/*!
 * @method rebootSent:
 * @brief 当设备收到重启命令时调用此方法。
 *
 * @discussion 当 {@link onRebootSent} 方法被触发时调用此方法。
 */
- (void) rebootSent;

/*!
 * @method displayErrorDialog:
 * @param errorSuotaLibCode 错误代码，可以在 {@link SuotaErrors} 和 {@link ApplicationErrors} 中找到。
 *
 * @discussion 当 {@link onFailure:} 方法被触发时调用此方法。
 */
- (void) displayErrorDialog:(int)errorSuotaLibCode;

/*!
 * @method displayErrorDialogString:
 * @param errorMsg 错误消息字符串。
 *
 * @discussion 上述方法的重载版本。
 */
- (void) displayErrorDialogString:(NSString*)errorMsg;

/*!
 * @method deviceDisconnected:
 * @brief 当 BLE 设备断开连接时调用此方法。
 *
 * @discussion 当由于 BLE 设备断开连接而触发 {@link onConnectionStateChange:} 回调时调用此方法。
 */
- (void) deviceDisconnected;

/*!
 * @method onSuotaFinished:
 * @brief 当 SUOTA 过程完成时调用此方法。
 *
 * @discussion 当 SUOTA 过程完成时调用此方法。
 */
- (void) onSuotaFinished;

/*!
 * @method updateSpeedStatistics:max:min:avg:
 * @param current 当前块的速度（字节每秒）。
 * @param max 最大块速度（字节每秒）。
 * @param min 最小块速度（字节每秒）。
 * @param avg 平均速度（字节每秒）。
 *
 * @discussion 当 {@link CALCULATE_STATISTICS} 设置为 <code>true</code> 时，每 500 毫秒触发此方法，以向应用程序发送速度统计信息。
 */
- (void) updateSpeedStatistics:(double)current max:(double)max min:(double)min avg:(double)avg;

@end

/*!
 * @class AutoSuota
 * @brief 一个辅助类，用于初始化并开始 SUOTA 过程。
 *
 * @discussion 该类初始化一个 {@link SuotaManager} 对象并开始 SUOTA 过程。所有必要的对象都在初始化时设置。类遵循 {@link SuotaManagerDelegate} 协议，以接收过程的更新。并且定义了 {@link BaseSuotaDelegate} 协议，以便将必要信息发送给 {@link suotaViewController}。
 */
@interface AutoSuota : NSObject <SuotaManagerDelegate>

/*!
 * @property delegate
 * @brief 遵循 BaseSuotaDelegate 协议的代理对象。
 */
@property id<BaseSuotaDelegate> delegate;

/*!
 * @property suotaFile
 * @brief 包含 SUOTA 补丁的 SuotaFile 对象。
 */
@property SuotaFile* suotaFile;

/*!
 * @property peripheral
 * @brief 需要执行 SUOTA 过程的 BLE 设备。
 */
@property CBPeripheral* peripheral;

/*!
 * @property suotaManager
 * @brief 用于管理 SUOTA 过程的 SuotaManager 对象。
 */
@property SuotaManager* suotaManager;

/*!
 * @property connectTimer
 * @brief 定时器，用于处理连接超时。
 */
@property NSTimer* connectTimer;

/*!
 * @method initWithSuotaFile:peripheral:delegate:
 * @param suotaFile 包含 SUOTA 补丁的 {@link SuotaFile} 对象。
 * @param peripheral 需要执行 SUOTA 的 BLE 设备。
 * @param delegate 遵循 {@link BaseSuotaDelegate} 协议的对象。
 *
 * @discussion 创建一个新的 {@link AutoSuota} 对象。需要一个遵循 {@link BaseSuotaDelegate} 协议的对象，以便了解 SUOTA 过程。
 */
- (instancetype) initWithSuotaFile:(SuotaFile*)suotaFile peripheral:(CBPeripheral*)peripheral delegate:(id<BaseSuotaDelegate>)delegate;

/*!
 * @method run:
 * @param suotaViewController 用于显示警告对话框的 {@link UIViewController} 对象。
 *
 * @discussion 初始化并开始 SUOTA 过程。当设备连接并准备好开始 SUOTA 文件传输时，委托对象上的 {@link startSuota} 方法将被调用。
 */
- (void) run:(UIViewController*)suotaViewController;

@end
