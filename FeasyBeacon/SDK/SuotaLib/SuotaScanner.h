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
 @header SuotaScanner.h
 @brief SuotaScanner 类的头文件。
 
 该头文件包含 SuotaScanner 和 ScannerBuilder 类的方法和属性声明，并包含 SuotaScannerDelegate 协议的声明。
 
 @copyright 2019 Dialog Semiconductor
 */

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>
#import "SuotaBluetoothManager.h"
#import "SuotaProfile.h"

/*!
 *  @protocol SuotaScannerDelegate
 *
 *  @discussion 扫描的委托对象必须遵循 <code>SuotaScannerDelegate</code> 协议。该协议的方法允许获取扫描过程中的信息。
 *
 */
@protocol SuotaScannerDelegate <NSObject>

@required

/*!
 * @method onFailure:
 *
 * @param failure 扫描失败的原因。
 *
 * @discussion 每次扫描失败时触发该方法。
 *
 */
- (void) onFailure:(enum ScanFailure)failure;

@required

/*!
 * @method onDeviceScan:rssi:scanRecord:
 *
 * @param peripheral 发现的 BLE 设备。
 * @param rssi 设备的信号强度 (RSSI)。
 * @param scanRecord 设备的扫描记录。
 *
 * @discussion 每次通过扫描发现新 BLE 设备时触发该方法。
 */
- (void) onDeviceScan:(CBPeripheral*)peripheral rssi:(NSNumber*)rssi scanRecord:(NSDictionary*)scanRecord;

@required

/*!
 * @method onScanStatusChange:
 *
 * @param newStatus 新的扫描状态。
 *
 * @discussion 每次扫描状态变化时触发该方法。
 */
- (void) onScanStatusChange:(enum ScanStatus)newStatus;

@end


/*!
 * @class ScannerBuilder
 *
 * @brief 使用构建者模式创建 SuotaScanner 对象。用户可以重写一些库的配置。
 *
 * @discussion 构建者使用示例:
 *
 * <tt> @textblock
 SuotaScanner* scanner = [SuotaScanner scannerWithBuilderBlock:^(ScannerBuilder* builder){
 builder.allowDialogDisplay = true;
 builder.viewController = self;
 builder.scanTimeout = 20000;
 }];
 @/textblock </tt>
 *
 */
@interface ScannerBuilder : NSObject

/*!
 * @property viewController
 *
 * @discussion 用于显示用户对话框的 {@link UIViewController} 对象。如果 {@link allowDialogDisplay} 属性的值为 <code>true</code>，则必须设置 {@link UIViewController} 对象。
 */
@property UIViewController* viewController;

/*!
 * @property allowDialogDisplay
 *
 * @discussion 指示应用是否允许创建用户对话框。仅对这个 SuotaScanner 对象覆盖 {@link ALLOW_DIALOG_DISPLAY} 的默认值。
 *
 */
@property BOOL allowDialogDisplay;

/*!
 * @property scanTimeout
 *
 * @discussion 扫描超时时间。仅对这个 SuotaScanner 对象覆盖 {@link DEFAULT_SCAN_TIMEOUT} 的默认值。
 */
@property long scanTimeout;

/*!
 * @method build
 * @brief 根据 ScannerBuilder 的配置构建 SuotaScanner 对象。
 * @return 构建后的 SuotaScanner 对象。
 */
- (id) build;

@end


/*!
 * @class SuotaScanner
 *
 * @discussion 用于扫描 BLE 设备的扫描器。
 *
 */
@interface SuotaScanner : NSObject <BluetoothManagerScannerDelegate>

/*!
 *  @property scanDelegate
 *
 *  @discussion 接收 {@link SuotaScanner} 事件的委托对象。
 *
 */
@property (weak) id<SuotaScannerDelegate> scanDelegate;
@property SuotaBluetoothManager* bluetoothManager;
@property (weak) UIViewController* viewController;

/*!
 * @property isScanning
 *
 * @discussion 指示当前是否有正在进行的扫描。
 *
 */
@property BOOL isScanning;
@property BOOL onlySUOTAUuidSearch;
@property BOOL allowDialogDisplay;

/*!
 * @property scanTimeout
 *
 * @discussion 扫描超时时间。
 *
 */
@property long scanTimeout;

/*!
 * @property uuids
 *
 * @discussion 要在广告数据中搜索的 UUID 值。
 *
 */
@property NSArray<CBUUID*>* uuids;

/*!
 * @method scannerWithBuilderBlock:
 *
 * @param block 用于初始化 {@link ScannerBuilder} 属性值的块。
 *
 * @discussion 使用构建者模式创建 {@link SuotaScanner} 对象。如果 {@link allowDialogDisplay} 值设置为 true 但未提供任何视图控制器，则返回 nil。
 *
 * 构建者使用示例:
 *
 * <tt> @textblock
 SuotaScanner* scanner = [SuotaScanner scannerWithBuilderBlock:^(ScannerBuilder* builder){
 builder.allowDialogDisplay = true;
 builder.viewController = self;
 builder.scanTimeout = 20000;
 }];
 @/textblock </tt>
 *
 * @return {@link SuotaScanner} 对象。
 *
 */
+ (instancetype) scannerWithBuilderBlock:(void(^)(ScannerBuilder*))block;

/*!
 * @method initWithBuilder:
 *
 * @param builder 配置 SuotaScanner 的 ScannerBuilder 实例。
 *
 * @discussion 使用 ScannerBuilder 实例初始化 SuotaScanner 对象。
 *
 * @return 初始化后的 SuotaScanner 对象。
 */
- (id) initWithBuilder:(ScannerBuilder*)builder;

/*!
 * @method scan:
 *
 * @param scanDelegate 接收扫描状态更新的委托对象。
 *
 * @discussion 扫描广播 <code>SUOTA_SERVICE_UUID</code> 的设备。使用 {@link //apple_ref/occ/instp/SuotaScanner/scanTimeout} 值。
 *
 */
- (void) scan:(id<SuotaScannerDelegate>)scanDelegate;

/*!
 * @method scan:scanTimeout
 *
 * @param scanDelegate 接收扫描状态更新的委托对象。
 * @param scanTimeout 扫描超时时间。
 *
 * @discussion 扫描广播 <code>SUOTA_SERVICE_UUID</code> 的设备。
 *
 * @see scan:
 */
- (void) scan:(id<SuotaScannerDelegate>)scanDelegate scanTimeout:(long)scanTimeout;

/*!
 * @method scan:uuids
 *
 * @param scanDelegate 接收扫描状态更新的委托对象。
 * @param uuids 在广告数据中搜索的 UUID 值。
 *
 * @discussion 扫描广播任何给定 UUID 值的设备。使用 {@link //apple_ref/occ/instp/SuotaScanner/scanTimeout} 值。
 *
 * @see scan:
 */
- (void) scan:(id<SuotaScannerDelegate>)scanDelegate uuids:(NSArray<CBUUID*>*)uuids;

/*!
 * @method scan:uuids:scanTimeout
 *
 * @param scanDelegate 接收扫描状态更新的委托对象。
 * @param uuids 在广告数据中搜索的 UUID 值。
 * @param scanTimeout 扫描超时时间。
 *
 * @discussion 扫描广播任何给定 UUID 值的设备。
 *
 * @see scan:
 */
- (void) scan:(id<SuotaScannerDelegate>)scanDelegate uuids:(NSArray<CBUUID*>*)uuids scanTimeout:(long)scanTimeout;

/*!
 * @method stopScan
 *
 * @discussion 如果有正在进行的扫描进程，则停止扫描。
 *
 */
- (void) stopScan;

/*!
 * @method destroy
 *
 * @discussion 如果正在运行，停止扫描，将委托设置为 nil，如果有可见的对话框则将其关闭。
 *
 */
-(void) destroy;

@end
