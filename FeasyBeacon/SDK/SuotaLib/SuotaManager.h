/*
 *******************************************************************************
 *
 * Copyright (C) 2019-2020 Dialog Semiconductor.
 * 本计算机程序包括Dialog Semiconductor的机密、专有信息。保留所有权利。
 *
 *******************************************************************************
 */

/*!
 @header SuotaManager.h
 @brief SuotaManager类的头文件。
 
 本头文件包含SuotaManager类的方法和属性声明。它还包含了SuotaManagerDelegate协议的声明。
 
 @copyright 2019 Dialog Semiconductor
 */

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKIt.h>
#import "SuotaProfile.h"

// 预声明相关类
@class DeviceInfo;
@class GattOperation;
@class SendChunkOperation;
@class SuotaBluetoothManager;
@class SuotaFile;
@class SuotaInfo;
@class SuotaProtocol;

enum SuotaLogType {
    INFO,   // 信息日志类型
    BLOCK,  // 数据块日志类型
    CHUNK,  // 数据块传输日志类型
};

/*!
 *  @protocol SuotaManagerDelegate
 *
 *  @discussion SuotaManager的委托必须采用<code>SuotaManagerDelegate</code>协议。此协议的方法用于获取有关SUOTA（固件更新）的过程信息。
 *
 */
@protocol SuotaManagerDelegate <NSObject>

@required

/*!
 * @method onConnectionStateChange:
 *
 * @param newStatus 新的连接状态。状态代码可以在SuotaManagerStatus中找到。
 *
 * @discussion 每次连接状态更改时触发此方法。
 */
- (void) onConnectionStateChange:(enum SuotaManagerStatus)newStatus;

@required

/*!
 * @method onServicesDiscovered
 *
 * @discussion 在服务发现时触发此方法。
 */
- (void) onServicesDiscovered;

@required

/*!
 * @method onCharacteristicRead:characteristic:
 *
 * @param characteristicGroup 当前的特征组。特征组可以在CharacteristicGroup中找到。
 * @param characteristic 读取到的特征。
 *
 * @discussion 在读取特征时触发此方法。
 */
- (void) onCharacteristicRead:(enum CharacteristicGroup)characteristicGroup characteristic:(CBCharacteristic*)characteristic;

@required

/*!
 * @method onDeviceInfoReadCompleted:
 *
 * @param status DeviceInfoReadStatus状态。指示是否成功读取到设备信息：SUCCESS表示成功，NO_DEVICE_INFO表示没有可读取的设备信息。
 *
 * @discussion 当所有设备信息读取完成时触发此方法。
 */
- (void) onDeviceInfoReadCompleted:(enum DeviceInfoReadStatus)status;

@required

/*!
 * @method onDeviceReady
 *
 * @discussion 当所有可用的SUOTA信息已读取完毕时触发此方法。如果AUTO_READ_DEVICE_INFO设置为<code>true</code>，则表示设备信息也已读取。
 */
- (void) onDeviceReady;

@required

/*!
 * @method onSuotaLog:type:log:
 *
 * @param state 当前的SuotaProtocolState。
 * @param type 日志类型。
 * @param log 关联的状态更新消息。
 *
 * @discussion 如果NOTIFY_SUOTA_STATUS为<code>true</code>，则会触发此方法。
 */
- (void) onSuotaLog:(enum SuotaProtocolState)state type:(enum SuotaLogType)type log:(NSString*)log;

@required

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
- (void) onChunkSend:(int)chunkCount totalChunks:(int)totalChunks chunk:(int)chunk block:(int)block blockChunks:(int)blockChunks totalBlocks:(int)totalBlocks;

@required

/*!
 * @method onBlockSent:
 *
 * @param block 当前的数据块数。
 * @param totalBlocks 总的数据块数。
 *
 * @discussion 在成功传输数据块后触发此方法。
 */
- (void) onBlockSent:(int)block totalBlocks:(int)totalBlocks;

@required

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
- (void) updateSpeedStatistics:(double)current max:(double)max min:(double)min avg:(double)avg;

@required

/*!
 * @method updateCurrentSpeed:
 *
 * @param currentSpeed 每秒发送的字节数。
 *
 * @discussion 如果CALCULATE_STATISTICS为<code>true</code>，则每1000ms触发此方法。这表示当前每秒发送的字节数，而不是平均值。
 */
- (void) updateCurrentSpeed:(double)currentSpeed;

@required

/*!
 * @method onUploadProgress:
 *
 * @param percent 已发送到设备的固件文件的百分比。
 *
 * @discussion 如果NOTIFY_UPLOAD_PROGRESS为<code>true</code>，则在上传进度更新时触发此方法。
 */
- (void) onUploadProgress:(float)percent;

@required

/*!
 * @method onSuccess:imageUploadElapsedSeconds:
 *
 * @param totalElapsedSeconds 执行SUOTA协议的总耗时。
 * @param imageUploadElapsedSeconds 图像上传期间的耗时。
 *
 * @discussion 在SUOTA过程成功完成后触发此方法。如果无法计算耗时，时间参数值为<code>-1</code>。
 */
- (void) onSuccess:(double)totalElapsedSeconds imageUploadElapsedSeconds:(double)imageUploadElapsedSeconds;

@required

/*!
 * @method onFailure:
 *
 * @param errorCode 导致失败的原因。错误代码可以在SuotaErrors和ApplicationErrors中找到。
 *
 * @discussion 在发生意外事件时触发此方法。
 */
- (void) onFailure:(int)errorCode;

@required

/*!
 * @method onRebootSent
 *
 * @discussion 当重启信号发送到设备时触发此方法。
 */
- (void) onRebootSent;

@end

/*!
 * @class SuotaManager
 *
 * @discussion 此类处理BLE设备的SUOTA（固件更新）过程。
 *
 */
@interface SuotaManager : NSObject <CBPeripheralDelegate>

enum ManagerState {
    DEVICE_DISCONNECTED,  // 设备断开连接
    DEVICE_CONNECTING,    // 设备连接中
    DEVICE_CONNECTED,     // 设备已连接
};

// 类的属性声明
@property CBPeripheral* peripheral;
@property (weak) id<SuotaManagerDelegate> suotaManagerDelegate;
@property SuotaBluetoothManager* bluetoothManager;
@property enum ManagerState state;
@property SuotaProtocol* suotaProtocol;
@property (weak) UIViewController* suotaViewController;
@property NSMutableArray<SendChunkOperation*>* sendChunkOperationArray;
@property BOOL sendChunkOperationPending;
@property BOOL rebootSent;

// SUOTA配置属性
/*!
 *  @property suotaFile
 *
 *  @discussion 固件更新时使用的固件文件。
 *
 */
@property (nonatomic) SuotaFile* suotaFile;
@property int blockSize;
@property int chunkSize;
@property uint8_t imageBank;
@property uint8_t memoryType;
// SPI接口相关属性
@property uint8_t misoGpio;
@property uint8_t mosiGpio;
@property uint8_t csGpio;
@property uint8_t sckGpio;
//I2C接口相关属性
@property uint16_t i2cDeviceAddress;
@property uint8_t sclGpio;
@property uint8_t sdaGpio;

@property CBService* suotaService;
@property CBCharacteristic* memDevCharacteristic;
@property CBCharacteristic* gpioMapCharacteristic;
@property CBCharacteristic* memoryInfoCharacteristic;
@property CBCharacteristic* patchLengthCharacteristic;
@property CBCharacteristic* patchDataCharacteristic;
@property CBCharacteristic* serviceStatusCharacteristic;
@property CBCharacteristic* serviceStatusClientConfigDescriptor;

// SUOTA信息相关属性
@property CBCharacteristic* suotaVersionCharacteristic;
@property CBCharacteristic* patchDataSizeCharacteristic;
@property CBCharacteristic* mtuCharacteristic;
@property CBCharacteristic* l2capPsmCharacteristic;

/*!
 *  @property suotaVersion
 *
 *  @discussion SUOTA版本特征值。如果特征值尚未读取，默认为0。
 *
 */
@property int suotaVersion;

/*!
 *  @property mtu
 *
 *  @discussion MTU特征值。如果特征值尚未读取，默认为23。
 *
 */
@property int mtu;

/*!
 *  @property patchDataSize
 *
 *  @discussion 补丁数据大小特征值。如果特征值尚未读取，默认为20。
 *
 */
@property int patchDataSize;

/*!
 *  @property l2capPsm
 *
 *  @discussion L2CAP特征值。如果特征值尚未读取，默认为0。
 *
 */
@property int l2capPsm;

/*!
 *  @property suotaVersionRead
 *
 *  @discussion 检查是否已读取SUOTA版本特征。
 *
 */
@property BOOL suotaVersionRead;

/*!
 *  @property patchDataSizeRead
 *
 *  @discussion 检查是否已读取补丁数据大小特征。
 *
 */
@property BOOL patchDataSizeRead;

/*!
 *  @property mtuRead
 *
 *  @discussion 检查是否已读取MTU特征。
 *
 */
@property BOOL mtuRead;

/*!
 *  @property l2capPsmRead
 *
 *  @discussion 检查是否已读取L2CAP特征。
 *
 */
@property BOOL l2capPsmRead;

// 设备信息相关属性
@property CBService* deviceInfoService;
@property CBCharacteristic* manufacturerNameCharacteristic;
@property CBCharacteristic* modelNumberCharacteristic;
@property CBCharacteristic* serialNumberCharacteristic;
@property CBCharacteristic* hardwareRevisionCharacteristic;
@property CBCharacteristic* firmwareRevisionCharacteristic;
@property CBCharacteristic* softwareRevisionCharacteristic;
@property CBCharacteristic* systemIdCharacteristic;
@property CBCharacteristic* ieee11073Characteristic;
@property CBCharacteristic* pnpIdCharacteristic;

/*!
 *  @property manufacturerName
 *
 *  @discussion 制造商名称特征值。如果特征值尚未读取，默认为nil。
 *
 */
@property NSString* manufacturerName;

/*!
 *  @property modelNumber
 *
 *  @discussion 型号编号特征值。如果特征值尚未读取，默认为nil。
 *
 */
@property NSString* modelNumber;

/*!
 *  @property serialNumber
 *
 *  @discussion 序列号特征值。如果特征值尚未读取，默认为nil。
 *
 */
@property NSString* serialNumber;

/*!
 *  @property hardwareRevision
 *
 *  @discussion 硬件版本特征值。如果特征值尚未读取，默认为nil。
 *
 */
@property NSString* hardwareRevision;

/*!
 *  @property firmwareRevision
 *
 *  @discussion 固件版本特征值。如果特征值尚未读取，默认为nil。
 *
 */
@property NSString* firmwareRevision;

/*!
 *  @property softwareRevision
 *
 *  @discussion 软件版本特征值。如果特征值尚未读取，默认为nil。
 *
 */
@property NSString* softwareRevision;

/*!
 *  @property systemId
 *
 *  @discussion 系统ID特征的最后读取值。
 *
 */
@property NSData* systemId;

/*!
 *  @property ieee11073
 *
 *  @discussion IEEE 11073特征的最后读取值。
 *
 */
@property NSData* ieee11073;

/*!
 *  @property pnpId
 *
 *  @discussion PNP ID特征的最后读取值。
 *
 */
@property NSData* pnpId;

/*!
 *  @property suotaInfoMap
 *
 *  @discussion SUOTA信息特征的NSDictionary。字典键是特征的CBUUID，值是CBCharacteristic对象。
 *
 */
@property NSMutableDictionary<CBUUID*, CBCharacteristic*>* suotaInfoMap;

/*!
 *  @property deviceInfoMap
 *
 *  @discussion 设备信息特征的NSDictionary。字典键是特征的CBUUID，值是CBCharacteristic对象。
 *
 */
@property NSMutableDictionary<CBUUID*, CBCharacteristic*>* deviceInfoMap;
@property BOOL isSuotaInfoReadGroupPending;
@property BOOL isDeviceInfoReadGroupPending;
@property int totalSuotaInfo;
@property int totalDeviceInfo;
@property (class, readonly) NSArray<CBUUID*>* suotaInfoUuids;
@property (class, readonly) NSArray<CBUUID*>* deviceInfoUuids;

/*!
 * @method initWithPeripheral:suotaManagerDelegate:
 *
 * @param peripheral 要执行SUOTA的BLE设备。
 * @param suotaManagerDelegate 将接收SuotaManager事件的委托对象。
 *
 * @discussion 使用给定参数初始化一个SuotaManager对象。
 */
- (instancetype) initWithPeripheral:(CBPeripheral*)peripheral suotaManagerDelegate:(id<SuotaManagerDelegate>)suotaManagerDelegate;

- (instancetype) initWithPeripheral:(CBPeripheral*)peripheral suotaManagerDelegate:(id<SuotaManagerDelegate>)suotaManagerDelegate pinCode:( NSString * _Nullable )pinCode macAddress:( NSString * _Nullable )macAddress;

/*!
 *  @method deviceName
 *
 *  @discussion BLE设备的名称。
 *
 */
- (NSString*) deviceName;

/*!
 *  @method avg
 *
 *  @discussion 到目前为止的平均速度值。如果配置禁用了统计计算，则返回<code>-1</code>。
 *
 */
- (double) avg;

/*!
 *  @method max
 *
 *  @discussion 到目前为止的最大速度值。如果配置禁用了统计计算，则返回<code>-1</code>。
 *
 */
- (double) max;

/*!
 *  @method min
 *
 *  @discussion 到目前为止的最小速度值。如果配置禁用了统计计算，则返回<code>-1</code>。
 *
 */
- (double) min;

/*!
 * @method formatedDeviceInfoMap
 *
 * @discussion 返回已读取设备信息的NSDictionary对象。字典键是相应的CBUUID，值是特征值解析为字符串。
 *
 * @return 如果已读取设备信息，则返回设备信息的NSDictionary对象，否则返回一个空的NSDictionary对象。
 */
- (NSDictionary<CBUUID*, NSString*>*) formattedDeviceInfoMap;

/*!
 * @method formatedSuotaInfoMap
 *
 * @discussion 返回已读取SUOTA信息的NSDictionary对象。字典键是相应的CBUUID，值是特征值解析为字符串。
 *
 * @return 如果已读取SUOTA信息，则返回SUOTA信息的NSDictionary对象，否则返回一个空的NSDictionary对象。
 */
- (NSDictionary<CBUUID*, NSString*>*) formattedSuotaInfoMap;

/*!
 * @method readCharacteristic
 *
 * @param uuid 特征的UUID。
 *
 * @discussion 读取指定UUID的特征。
 *
 * @throws NSException 如果请求的特征不可用或BLE设备已断开连接。
 *
 */
- (void) readCharacteristic:(CBUUID*)uuid;

/*!
 * @method hasDeviceInfo
 *
 * @param uuid 设备信息特征的UUID，nil表示设备信息服务
 *
 * @discussion 检查设备信息服务的可用性。
 *
 */
- (BOOL) hasDeviceInfo:(CBUUID*)uuid;

/*!
 * @method readManufacturer
 *
 * @discussion 读取制造商特征。
 *
 * @throws NSException 如果与BLE设备没有连接，或请求的特征不可用。
 */
- (void) readManufacturer;

/*!
 * @method readModelNumber
 *
 * @discussion 读取型号编号特征。
 *
 * @throws NSException 如果与BLE设备没有连接，或请求的特征不可用。
 */
- (void) readModelNumber;

/*!
 * @method readSerialNumber
 *
 * @discussion 读取序列号特征。
 *
 * @throws NSException 如果与BLE设备没有连接，或请求的特征不可用。
 */
- (void) readSerialNumber;

/*!
 * @method readHardwareRevision
 *
 * @discussion 读取硬件版本特征。
 *
 * @throws NSException 如果与BLE设备没有连接，或请求的特征不可用。
 */
- (void) readHardwareRevision;

/*!
 * @method readFirmwareRevision
 *
 * @discussion 读取固件版本特征。
 *
 * @throws NSException 如果与BLE设备没有连接，或请求的特征不可用。
 */
- (void) readFirmwareRevision;

/*!
 * @method readSoftwareRevision
 *
 * @discussion 读取软件版本特征。
 *
 * @throws NSException 如果与BLE设备没有连接，或请求的特征不可用。
 */
- (void) readSoftwareRevision;

/*!
 * @method readSystemId
 *
 * @discussion 读取系统ID特征。
 *
 * @throws NSException 如果与BLE设备没有连接，或请求的特征不可用。
 */
- (void) readSystemId;

/*!
 * @method readIeee11073
 *
 * @discussion 读取IEEE 11073特征。
 *
 * @throws NSException 如果与BLE设备没有连接，或请求的特征不可用。
 */
- (void) readIeee11073;

/*!
 * @method readPnpId
 *
 * @discussion 读取PNP ID特征。
 *
 * @throws NSException 如果与BLE设备没有连接，或请求的特征不可用。
 */
- (void) readPnpId;

/*!
 * @method readSuotaVersion
 *
 * @discussion 读取SUOTA版本特征。
 *
 * @throws NSException 如果与BLE设备没有连接，或请求的特征不可用。
 */
- (void) readSuotaVersion;

/*!
 * @method readPatchDataSize
 *
 * @discussion 读取补丁数据大小特征。
 *
 * @throws NSException 如果与BLE设备没有连接，或请求的特征不可用。
 */
- (void) readPatchDataSize;

/*!
 * @method readMtu
 *
 * @discussion 读取MTU特征。
 *
 * @throws NSException 如果与BLE设备没有连接，或请求的特征不可用。
 */
- (void) readMtu;

/*!
 * @method readL2capPsm
 *
 * @discussion 读取L2CAP特征。
 *
 * @throws NSException 如果与BLE设备没有连接，或请求的特征不可用。
 */
- (void) readL2capPsm;

/*!
 * @method readDeviceInfo
 *
 * @discussion 将设备信息读取命令排队执行。命令包含所有可用的特征或在DEVICE_INFO_TO_READ中指定的设备信息特征。
 *
 * @throws NSException 如果没有连接到设备。
 */
- (void) readDeviceInfo;

/*!
 * @method connect:
 *
 * @discussion 连接到作为构造函数参数传递的CBPeripheral设备。
 */
- (void) connect;

/*!
 * @method initializeSuota
 *
 * @discussion 使用默认值初始化SUOTA协议设置。如果SUOTA过程已在运行，此方法不执行任何操作。
 *
 * @see initializeSuota:misoGpio:mosiGpio:csGpio:sckGpio:imageBank:
 * @see initializeSuota:i2cAddress:sclGpio:sdaGpio:imageBank:
 * @see initializeSuota:blockSize:misoGpio:mosiGpio:csGpio:sckGpio:imageBank:
 * @see initializeSuota:blockSize:i2cAddress:sclGpio:sdaGpio:imageBank:
 */
- (void) initializeSuota;

/*!
 * @method initializeSuota:misoGpio:mosiGpio:csGpio:sckGpio:imageBank:
 *
 * @param blockSize 选择的数据块大小。
 * @param misoGpio 选择的MISO引脚。
 * @param mosiGpio 选择的MOSI引脚。
 * @param csGpio 选择的CS引脚。
 * @param sckGpio 选择的SCK引脚。
 * @param imageBank 选择的镜像库。
 *
 * @discussion 使用传入的参数初始化SUOTA协议设置。适用于使用SPI接口的内存类型。如果SUOTA过程已在运行，此方法不执行任何操作。
 *
 * @see initializeSuota
 * @see initializeSuota:i2cAddress:sclGpio:sdaGpio:imageBank:
 * @see initializeSuota:blockSize:misoGpio:mosiGpio:csGpio:sckGpio:imageBank:
 * @see initializeSuota:blockSize:i2cAddress:sclGpio:sdaGpio:imageBank:
 */
- (void) initializeSuota:(int)blockSize misoGpio:(int)misoGpio mosiGpio:(int)mosiGpio csGpio:(int)csGpio sckGpio:(int)sckGpio imageBank:(int)imageBank;

/*!
 * @method initializeSuota:i2cAddress:sclGpio:sdaGpio:imageBank:
 *
 * @param blockSize 选择的数据块大小。
 * @param i2cAddress 选择的I2C地址。
 * @param sclGpio 选择的SCL引脚。
 * @param sdaGpio 选择的SDA引脚。
 * @param imageBank 选择的镜像库。
 *
 * @discussion 使用传入的参数初始化SUOTA协议设置。适用于使用I2C接口的内存类型。如果SUOTA过程已在运行，此方法不执行任何操作。
 */
- (void) initializeSuota:(int)blockSize i2cAddress:(int)i2cAddress sclGpio:(int)sclGpio sdaGpio:(int)sdaGpio imageBank:(int)imageBank;

/*!
 * @method initializeSuota:blockSize:misoGpio:mosiGpio:csGpio:sckGpio:imageBank:
 *
 * @param firmware 要用于更新的固件。
 * @param blockSize 选择的数据块大小。
 * @param misoGpio 选择的MISO引脚。
 * @param mosiGpio 选择的MOSI引脚。
 * @param csGpio 选择的CS引脚。
 * @param sckGpio 选择的SCK引脚。
 * @param imageBank 选择的镜像库。
 *
 * @discussion 使用传入的参数初始化SUOTA协议设置。适用于使用SPI接口的内存类型。如果SUOTA过程已在运行，此方法不执行任何操作。
 */
- (void) initializeSuota:(SuotaFile*)firmware blockSize:(int)blockSize misoGpio:(int)misoGpio mosiGpio:(int)mosiGpio csGpio:(int)csGpio sckGpio:(int)sckGpio imageBank:(int)imageBank;

/*!
 * @method initializeSuota:blockSize:i2cAddress:sclGpio:sdaGpio:imageBank:
 *
 * @param firmware 要用于更新的固件。
 * @param blockSize 选择的数据块大小。
 * @param i2cAddress 选择的I2C地址。
 * @param sclGpio 选择的SCL引脚。
 * @param sdaGpio 选择的SDA引脚。
 * @param imageBank 选择的镜像库。
 *
 * @discussion 使用传入的参数初始化SUOTA协议设置。适用于使用I2C接口的内存类型。如果SUOTA过程已在运行，此方法不执行任何操作。
 */
- (void) initializeSuota:(SuotaFile*)firmware blockSize:(int)blockSize i2cAddress:(int)i2cAddress sclGpio:(int)sclGpio sdaGpio:(int)sdaGpio imageBank:(int)imageBank;

/*!
 * @method startUpdate
 *
 * @discussion 该方法实际启动SuotaProtocol。确保只有在成功连接BLE设备后才调用此方法。否则，此方法不会执行任何操作。
 */
- (void) startUpdate;

/*!
 * @method disconnect
 *
 * @discussion 断开与连接的BLE设备的连接。
 */
- (void) disconnect;

/*!
 * @method destroy
 *
 * @discussion 清理所需的一切。
 */
- (void) destroy;

/*!
 * @method memoryDevice
 *
 * @discussion 获取内存设备信息。
 */
- (int) memoryDevice;

/*!
 * @method gpioMap
 *
 * @discussion 获取GPIO映射信息。
 */
- (int) gpioMap;

/*!
 * @method spiGpioMap
 *
 * @discussion 获取SPI GPIO映射信息。
 */
- (int) spiGpioMap;

/*!
 * @method i2cGpioMap
 *
 * @discussion 获取I2C GPIO映射信息。
 */
- (int) i2cGpioMap;

/*!
 * @method close
 *
 * @discussion 关闭所有活动并清理资源。
 */
- (void) close;

/*!
 * @method enqueueSendChunkOperation:
 *
 * @discussion 将发送块操作加入队列。
 */
- (void) enqueueSendChunkOperation:(SendChunkOperation*)sendChunkOperation;

/*!
 * @method executeOperation:
 *
 * @discussion 执行GattOperation操作。
 */
- (void) executeOperation:(GattOperation*)gattOperation;

/*!
 * @method executeOperationArray:
 *
 * @discussion 执行一组GattOperation操作。
 */
- (void) executeOperationArray:(NSArray<GattOperation*>*)gattOperationArray;

/*!
 * @method onSuotaProtocolSuccess
 *
 * @discussion 在SUOTA协议成功完成时调用。
 */
- (void) onSuotaProtocolSuccess;

/*!
 * @method onServicesDiscovered:
 *
 * @discussion 在服务被发现时调用。
 */
- (void) onServicesDiscovered:(NSArray<CBService*>*)services;

/*!
 * @method onCharacteristicsDiscovered:
 *
 * @discussion 在特征被发现时调用。
 */
- (void) onCharacteristicsDiscovered:(CBService*)service;

/*!
 * @method onDescriptorsDiscovered:
 *
 * @discussion 在描述符被发现时调用。
 */
- (void) onDescriptorsDiscovered:(CBCharacteristic*)characteristic;

/*!
 * @method onCharacteristicRead:
 *
 * @discussion 在特征值被读取时调用。
 */
- (void) onCharacteristicRead:(CBCharacteristic*)characteristic;

/*!
 * @method onCharacteristicWrite:
 *
 * @discussion 在特征值被写入时调用。
 */
- (void) onCharacteristicWrite:(CBCharacteristic*)characteristic;

/*!
 * @method onCharacteristicChanged:
 *
 * @discussion 在特征值发生变化时调用。
 */
- (void) onCharacteristicChanged:(CBCharacteristic*)characteristic;

/*!
 * @method onDescriptorWrite:
 *
 * @discussion 在描述符值被写入时调用。
 */
- (void) onDescriptorWrite:(CBCharacteristic*)characteristic;

@end
