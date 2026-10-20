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
 @header SuotaProfile.h
 @brief Header file about the library configuration.
 
 This header file contains global values about protocol states and error codes.
 
 @copyright 2019 Dialog Semiconductor
 */

#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>

#define SUOTA_DEFAULT_MTU 23

/*!
 * @abstract Scan status.
 * @constant STARTED, Scanning process started.
 * @constant STOPPED, Scanning process stopped.
 *
 */
enum ScanStatus {
    STARTED,  // 扫描已启动
    STOPPED   // 扫描已停止
};

/*!
 * @abstract Scan failure codes.
 * @constant FAIL, Generic scan failure.
 * @constant BLE_NOT_SUPPORTED, Bluetooth Low Energy is not supported on this device.
 * @constant BLUETOOTH_NOT_ENABLED, The Bluetooth adapter is disabled.
 *
 */
enum ScanFailure {
    FAIL,                 // 一般的扫描失败
    BLE_NOT_SUPPORTED,    // 设备不支持蓝牙低功耗（BLE）
    BLUETOOTH_NOT_ENABLED // 蓝牙适配器未启用
};

/*!
 * @abstract State of the {@link SuotaManager}.
 * @constant CONNECTED, The BLE device to perform the SUOTA is connected with the device.
 * @constant DISCONNECTED, The BLE device to perform the SUOTA is not connected with the device.
 *
 */
enum SuotaManagerStatus {
    CONNECTED,    // 蓝牙设备已连接
    DISCONNECTED  // 蓝牙设备未连接
};

/*!
 * @abstract State of the device info read process.
 * @constant NO_DEVICE_INFO, There are not any info characteristics to read from the device.
 * @constant SUCCESS, The specified info characteristics have been successfully read.
 *
 */
enum DeviceInfoReadStatus {
    NO_DEVICE_INFO, // 设备信息不可用或读取失败
    SUCCESS         // 设备信息成功读取
};

/*!
 * @abstract State of the SUOTA process.
 * @constant ENABLE_NOTIFICATIONS, Enables notifications on the <code>SUOTA_SERV_STATUS</code> characteristic.
 * @constant SET_MEMORY_DEVICE, Defines where the patch will be stored on the device upon reception.
 * @constant SET_GPIO_MAP, Defines the mapping of the interfaces on various GPIO pins.
 * @constant SEND_BLOCK, Sends a block of the patch to the device.
 * @constant END_SIGNAL, Sends the SUOTA end command to the device.
 * @constant ERROR, Error state.
 *
 */
enum SuotaProtocolState {
    ENABLE_NOTIFICATIONS,  // 启用通知
    SET_MEMORY_DEVICE,     // 设置内存设备
    SET_GPIO_MAP,          // 设置 GPIO 映射
    SEND_BLOCK,            // 发送固件数据块
    END_SIGNAL,            // 发送结束信号
    ERROR                  // 错误状态
    
    /**
     ENABLE_NOTIFICATIONS
     说明: 启用设备上与 SUOTA_SERV_STATUS 特征值相关的通知功能。通知用于监听设备固件更新过程中的状态变化。
     目的: 开启设备通知，以便在接收到固件数据时及时反馈。
     
     SET_MEMORY_DEVICE
     说明: 定义固件接收后将存储到设备上的位置。设备上的内存设备类型可能需要配置，例如存储在内部闪存或外部存储器中。
     目的: 设置设备的存储位置，以确保固件数据能够被正确保存和处理。
     
     SET_GPIO_MAP
     说明: 定义设备上各种接口在不同 GPIO 引脚上的映射。固件更新过程中可能需要正确配置设备引脚。
     目的: 配置设备的硬件接口以支持固件更新。
     
     SEND_BLOCK
     说明: 发送固件数据块到设备。固件通常被分成多个数据块，逐块传输到设备上。
     目的: 将固件数据分批发送到设备，确保完整地传输固件。
     
     END_SIGNAL
     说明: 向设备发送固件更新结束信号，通知设备固件更新过程已完成。
     目的: 通知设备固件更新已完成，设备可以开始执行固件验证或重启等操作。
     
     ERROR
     说明: 表示固件更新过程中发生错误的状态。
     目的: 当固件更新过程遇到问题时，系统会进入该状态，以便进行错误处理或回滚。
     */
};

/*!
 * @abstract Characteristic groups.
 * @constant DEVICE_INFO, Characteristics containing info about the device.
 * @constant SUOTA_INFO, Characteristics containing info about the SUOTA.
 * @constant OTHER, Characteristics that do not belong in any other group.
 *
 */
enum CharacteristicGroup {
    DEVICE_INFO,  // 包含设备信息的特征
    SUOTA_INFO,   // 包含SUOTA（固件升级）信息的特征
    OTHER         // 不属于任何其他组的特征
};

/*!
 * @enum PhysicalDeviceType
 * @abstract Physical device where the patch will be saved.
 * @constant MEMORY_TYPE_EXTERNAL_I2C, Image is stored in I2C EEPROM.
 * @constant MEMORY_TYPE_EXTERNAL_SPI, Image is stored in SPI Flash.
 *
 */
enum {
    MEMORY_TYPE_EXTERNAL_I2C = 0x12,  // 图像存储在 I2C EEPROM 中
    MEMORY_TYPE_EXTERNAL_SPI = 0x13,  // 图像存储在 SPI Flash 中
};

/*!
 * @enum MemoryBank
 * @abstract Memory bank where the patch will be stored.
 * @constant IMAGE_BANK_OLDEST, Image bank oldest.
 * @constant IMAGE_BANK_1, Image bank #1.
 * @constant IMAGE_BANK_2, Image bank #2.
 *
 */
enum {
    IMAGE_BANK_OLDEST = 0x00,  // 图像存储在最旧的内存区
    IMAGE_BANK_1 = 0x01,      // 图像存储在内存区 #1
    IMAGE_BANK_2 = 0x02,      // 图像存储在内存区 #2
    /**
     IMAGE_BANK_OLDEST
     说明: 表示图像将存储在最旧的内存区。这通常是设备中最早分配的内存区，用于升级之前的固件。
     用途: 用于覆盖最旧的固件版本或进行存储前的清理操作。
     
     IMAGE_BANK_1
     说明: 表示图像将存储在第一个内存区。通常用于设备的主要固件存储区域。
     用途: 用于存储最新的固件版本，作为常规更新的目标内存区。
     
     IMAGE_BANK_2
     说明: 表示图像将存储在第二个内存区。可能用于备份固件或其他特殊用途。
     用途: 可以作为备用固件存储区，也可能用于某些设备特定的功能。
     */
};

enum {
    SERVICE_STATUS_OK = 0x02,  // 服务状态正常
    IMAGE_STARTED = 0x10,     // 图像（固件）开始
};

enum {
    SUOTA_END = 0xfe000000,   // SUOTA结束命令
    SUOTA_REBOOT = 0xfd000000, // SUOTA重启命令
    SUOTA_ABORT = 0xff000000,  // SUOTA中止命令
};


/*!
 * @abstract SUOTA protocol errors that may arise during a SUOTA process.
 * @constant SPOTA_SRV_STARTED, SPOTA service started instead of SUOTA.
 * @constant SRV_EXIT, Forced exit of SUOTA service.
 * @constant CRC_MISMATCH, Patch Data CRC mismatch.
 * @constant PATCH_LENGTH_ERROR, Received patch length not equal to <code>PATCH_LEN</code> characteristic value.
 * @constant EXTERNAL_MEMORY_ERROR, Writing to external device failed.
 * @constant INTERNAL_MEMORY_ERROR, Not enough internal memory space for patch.
 * @constant INVALID_MEMORY_TYPE, Invalid memory device.
 * @constant APPLICATION_ERROR, Application error.
 * @constant INVALID_IMAGE_BANK, Invalid image bank.
 * @constant INVALID_IMAGE_HEADER, Invalid image header.
 * @constant INVALID_IMAGE_SIZE, Invalid image size.
 * @constant INVALID_PRODUCT_HEADER, Invalid product header.
 * @constant SAME_IMAGE_ERROR, Same Image Error.
 * @constant EXTERNAL_MEMORY_READ_ERROR, Failed to read from external memory device.
 *
 */
enum SuotaErrors {
    SPOTA_SRV_STARTED = 0x01,       // SPOTA服务启动错误
    SRV_EXIT = 0x03,                // SUOTA服务强制退出
    CRC_MISMATCH = 0x04,            // 补丁数据CRC不匹配
    PATCH_LENGTH_ERROR = 0x05,     // 接收到的补丁长度与PATCH_LEN特征值不匹配
    EXTERNAL_MEMORY_ERROR = 0x06,   // 写入外部设备失败
    INTERNAL_MEMORY_ERROR = 0x07,   // 内部内存空间不足
    INVALID_MEMORY_TYPE = 0x08,     // 无效的内存设备
    APPLICATION_ERROR = 0x09,       // 应用程序错误
    INVALID_IMAGE_BANK = 0x11,      // 无效的镜像库
    INVALID_IMAGE_HEADER = 0x12,    // 无效的镜像头
    INVALID_IMAGE_SIZE = 0x13,      // 无效的镜像大小
    INVALID_PRODUCT_HEADER = 0x14,  // 无效的产品头
    SAME_IMAGE_ERROR = 0x15,        // 相同镜像错误
    EXTERNAL_MEMORY_READ_ERROR = 0x16, // 从外部内存设备读取失败
};

// Application error codes (must be greater than 255 in order not to conflict with SUOTA error codes)
/*!
 * @abstract Application errors that may arise during a SUOTA process.
 * @constant SUOTA_NOT_SUPPORTED, The remote device does not support SUOTA.
 * @constant SERVICE_DISCOVERY_ERROR, Error discovering services.
 * @constant GATT_OPERATION_ERROR, Communication error.
 * @constant MTU_REQUEST_FAILED, Failed to request MTU size.
 * @constant FIRMWARE_LOAD_FAILED, Failed to load the firmware file.
 * @constant INVALID_FIRMWARE_CRC, Firmware validation failed.
 * @constant UPLOAD_TIMEOUT, File upload timeout.
 * @constant PROTOCOL_ERROR, Unexpected protocol behavior.
 * @constant NOT_CONNECTED, Isn't connected to a BLE device to perform SUOTA.
 *
 */
enum ApplicationErrors {
    SUOTA_NOT_SUPPORTED = 0xffff,   // 远程设备不支持SUOTA
    SERVICE_DISCOVERY_ERROR = 0xfffe, // 服务发现错误
    GATT_OPERATION_ERROR = 0xfffd, // 通信错误
    MTU_REQUEST_FAILED = 0xfffc,   // MTU大小请求失败
    FIRMWARE_LOAD_FAILED = 0xfffb, // 固件文件加载失败
    INVALID_FIRMWARE_CRC = 0xfffa, // 固件验证失败
    UPLOAD_TIMEOUT = 0xfff9,       // 文件上传超时
    PROTOCOL_ERROR = 0xfff8,       // 意外的协议行为
    NOT_CONNECTED = 0xfff7,        // 未连接到BLE设备进行SUOTA
};

@interface SuotaProfile : NSObject

/*!
 * @abstract SUOTA服务的UUID。
 * @discussion 这是BLE设备中用于SUOTA服务的UUID。
 */
@property (class, readonly) CBUUID* SUOTA_SERVICE_UUID;

/*!
 * @abstract SUOTA内存设备特征的UUID。
 * @discussion 这是用于指定SUOTA内存设备的特征的UUID。
 */
@property (class, readonly) CBUUID* SUOTA_MEM_DEV_UUID;

/*!
 * @abstract SUOTA GPIO映射特征的UUID。
 * @discussion 这是用于SUOTA GPIO映射的特征的UUID。
 */
@property (class, readonly) CBUUID* SUOTA_GPIO_MAP_UUID;

/*!
 * @abstract SUOTA内存信息特征的UUID。
 * @discussion 这是用于获取SUOTA内存信息的特征的UUID。
 */
@property (class, readonly) CBUUID* SUOTA_MEM_INFO_UUID;

/*!
 * @abstract SUOTA补丁长度特征的UUID。
 * @discussion 这是用于表示SUOTA补丁长度的特征的UUID。
 */
@property (class, readonly) CBUUID* SUOTA_PATCH_LEN_UUID;

/*!
 * @abstract SUOTA补丁数据特征的UUID。
 * @discussion 这是用于传输SUOTA补丁数据的特征的UUID。
 */
@property (class, readonly) CBUUID* SUOTA_PATCH_DATA_UUID;

/*!
 * @abstract SUOTA服务状态特征的UUID。
 * @discussion 这是用于获取SUOTA服务状态的特征的UUID。
 */
@property (class, readonly) CBUUID* SUOTA_SERV_STATUS_UUID;

/*!
 * @abstract 客户端配置描述符的UUID。
 * @discussion 这是用于配置通知和指示的客户端配置描述符的UUID。
 */
@property (class, readonly) CBUUID* CLIENT_CONFIG_DESCRIPTOR;

/*!
 * @abstract SUOTA版本特征的UUID。
 * @discussion 这是用于获取SUOTA版本信息的特征的UUID。
 */
@property (class, readonly) CBUUID* SUOTA_VERSION_UUID;

/*!
 * @abstract SUOTA补丁数据特征大小的UUID。
 * @discussion 这是用于表示SUOTA补丁数据特征大小的UUID。
 */
@property (class, readonly) CBUUID* SUOTA_PATCH_DATA_CHAR_SIZE_UUID;

/*!
 * @abstract SUOTA MTU特征的UUID。
 * @discussion 这是用于获取SUOTA MTU（最大传输单元）大小的特征的UUID。
 */
@property (class, readonly) CBUUID* SUOTA_MTU_UUID;

/*!
 * @abstract SUOTA L2CAP PSM的UUID。
 * @discussion 这是用于SUOTA L2CAP协议的PSSM（协议服务多路复用）UUID。
 */
@property (class, readonly) CBUUID* SUOTA_L2CAP_PSM_UUID;

/*!
 * @abstract 设备信息服务的UUID。
 * @discussion 这是用于设备信息服务的UUID。
 */
@property (class, readonly) CBUUID* SERVICE_DEVICE_INFORMATION;

/*!
 * @abstract 制造商名称特征的UUID。
 * @discussion 这是用于获取设备制造商名称的特征的UUID。
 */
@property (class, readonly) CBUUID* CHARACTERISTIC_MANUFACTURER_NAME_STRING;

/*!
 * @abstract 型号编号特征的UUID。
 * @discussion 这是用于获取设备型号编号的特征的UUID。
 */
@property (class, readonly) CBUUID* CHARACTERISTIC_MODEL_NUMBER_STRING;

/*!
 * @abstract 序列号特征的UUID。
 * @discussion 这是用于获取设备序列号的特征的UUID。
 */
@property (class, readonly) CBUUID* CHARACTERISTIC_SERIAL_NUMBER_STRING;

/*!
 * @abstract 硬件修订版特征的UUID。
 * @discussion 这是用于获取设备硬件修订版的特征的UUID。
 */
@property (class, readonly) CBUUID* CHARACTERISTIC_HARDWARE_REVISION_STRING;

/*!
 * @abstract 固件修订版特征的UUID。
 * @discussion 这是用于获取设备固件修订版的特征的UUID。
 */
@property (class, readonly) CBUUID* CHARACTERISTIC_FIRMWARE_REVISION_STRING;

/*!
 * @abstract 软件修订版特征的UUID。
 * @discussion 这是用于获取设备软件修订版的特征的UUID。
 */
@property (class, readonly) CBUUID* CHARACTERISTIC_SOFTWARE_REVISION_STRING;

/*!
 * @abstract 系统ID特征的UUID。
 * @discussion 这是用于获取设备系统ID的特征的UUID。
 */
@property (class, readonly) CBUUID* CHARACTERISTIC_SYSTEM_ID;

/*!
 * @abstract IEEE 11073特征的UUID。
 * @discussion 这是用于获取IEEE 11073相关信息的特征的UUID。
 */
@property (class, readonly) CBUUID* CHARACTERISTIC_IEEE_11073;

/*!
 * @abstract PNP ID特征的UUID。
 * @discussion 这是用于获取设备PNP（即插即用）ID的特征的UUID。
 */
@property (class, readonly) CBUUID* CHARACTERISTIC_PNP_ID;

/*!
 * @abstract 默认MTU值。
 * @discussion 这是BLE连接的默认最大传输单元（MTU）大小。
 */
@property (class, readonly) int DEFAULT_MTU;

/*!
 * @abstract SUOTA错误代码列表。
 * @discussion 这是一个字典，映射SUOTA错误代码到其描述字符串。
 */
@property (class, readonly) NSMutableDictionary<NSNumber*, NSString*>* suotaErrorCodeList;

/*!
 * @abstract SUOTA协议状态数组。
 * @discussion 这是一个包含SUOTA协议所有可能状态的数组。
 */
@property (class, readonly) NSArray<NSNumber*>* suotaProtocolStateArray;

/*!
 * @abstract SUOTA状态描述列表。
 * @discussion 这是一个字典，映射SUOTA协议状态到其描述字符串。
 */
@property (class, readonly) NSMutableDictionary<NSNumber*, NSString*>* suotaStateDescriptionList;

/*!
 * @abstract 通知值描述列表。
 * @discussion 这是一个字典，映射通知值到其描述字符串。
 */
@property (class, readonly) NSMutableDictionary<NSNumber*, NSString*>* notificationValueDescriptionList;

@end

