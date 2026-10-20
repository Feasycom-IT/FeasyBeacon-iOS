/*
 *******************************************************************************
 *
 * Copyright (C) 2019-2020 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class SuotaManager;

/*!
 * @protocol BluetoothManagerScannerDelegate
 *
 * @brief 扫描器委托协议，定义了发现蓝牙设备时的回调方法。
 */
@protocol BluetoothManagerScannerDelegate <NSObject>

@required

/*!
 * @brief 当扫描到一个蓝牙外设时被调用。
 *
 * @param peripheral 扫描到的蓝牙外设。
 * @param advertisementData 该外设的广播数据。
 * @param RSSI 信号强度指示。
 */
- (void) didDiscoverPeripheral:(CBPeripheral*)peripheral advertisementData:(NSDictionary<NSString*,id>*)advertisementData RSSI:(NSNumber*)RSSI;

@end

// 蓝牙管理器状态更新的通知名称。
extern NSString* const SuotaBluetoothManagerUpdatedState;
// 蓝牙设备连接失败的通知名称。
extern NSString* const SuotaBluetoothManagerConnectionFailed;
// 蓝牙设备连接成功的通知名称。
extern NSString* const SuotaBluetoothManagerDeviceConnected;
// 蓝牙设备断开的通知名称。
extern NSString* const SuotaBluetoothManagerDeviceDisconnected;

/*!
 * @class SuotaBluetoothManager
 *
 * @brief 用于管理蓝牙操作的类，负责扫描、连接和断开蓝牙设备。
 */
@interface SuotaBluetoothManager : NSObject <CBCentralManagerDelegate>

/*!
 * @property bluetoothManager
 *
 * @brief 中央蓝牙管理器，用于管理蓝牙设备的发现、连接等操作。
 */
@property CBCentralManager* bluetoothManager;

/*!
 * @property bleQueue
 *
 * @brief 蓝牙操作的调度队列，确保蓝牙操作在串行队列中执行。
 */
@property dispatch_queue_t bleQueue;

/*!
 * @property scannerDelegate
 *
 * @brief 扫描器的委托，用于接收扫描结果的回调。
 */
@property (weak) id<BluetoothManagerScannerDelegate> scannerDelegate;

/*!
 * @property state
 *
 * @brief 当前蓝牙管理器的状态。
 */
@property enum CBCentralManagerState state;

/*!
 * @property bluetoothUpdatedState
 *
 * @brief 指示蓝牙状态是否已更新的标志。
 */
@property BOOL bluetoothUpdatedState;

/*!
 * @brief 获取 SuotaBluetoothManager 单例实例。
 *
 * @return SuotaBluetoothManager 单例实例。
 */
+ (SuotaBluetoothManager*) instance;

/*!
 * @brief 通过标识符检索已知的蓝牙外设。
 *
 * @param identifier 外设的标识符。
 * @return 检索到的蓝牙外设，或 nil 如果未找到。
 */
- (CBPeripheral*) retrievePeripheralWithIdentifier:(NSUUID*)identifier;

/*!
 * @brief 开始扫描蓝牙设备。
 */
- (void) scan;

/*!
 * @brief 停止扫描蓝牙设备。
 */
- (void) stopScan;

/*!
 * @brief 连接指定的蓝牙外设。
 *
 * @param peripheral 要连接的蓝牙外设。
 */
- (void) connectPeripheral:(CBPeripheral*)peripheral;

/*!
 * @brief 断开与指定蓝牙外设的连接。
 *
 * @param peripheral 要断开的蓝牙外设。
 */
- (void) disconnectPeripheral:(CBPeripheral*)peripheral;

- (void)initDelegate;

@end
