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
 @header SuotaLibConfig.h
 @brief 库配置的头文件。
 
 这个头文件包含了库配置的值定义和属性声明。
 
 @copyright 2019 Dialog Semiconductor
 */

#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>

// SuotaScanner 配置
/*!
 * @defined SUOTA_LIB_CONFIG_ALLOW_DIALOG_DISPLAY
 *
 * @abstract 表示库是否应该显示对话框。
 *
 * @discussion 如果为 <code>false</code>，每当需要显示对话框时，例如蓝牙适配器被禁用，库只会触发相关的委托方法并让应用程序处理它。
 *
 */
#define SUOTA_LIB_CONFIG_ALLOW_DIALOG_DISPLAY true

// SUOTA Manager 和协议配置
/*!
 * @defined SUOTA_LIB_CONFIG_CHECK_HEADER_CRC
 *
 * @abstract 表示库是否应该检查固件文件头部的 CRC。
 *
 * @discussion 如果为 true，库将计算固件头部 CRC 并将其与有效负载 CRC 值进行比较。
 *
 */
#define SUOTA_LIB_CONFIG_CHECK_HEADER_CRC true

/*!
 * @defined SUOTA_LIB_CONFIG_CALCULATE_STATISTICS
 *
 * @abstract 表示库是否应该计算统计数据。
 *
 * @discussion 表示库是否应该计算速度统计数据，如最大、最小、平均、块和当前速度值。
 *
 */
#define SUOTA_LIB_CONFIG_CALCULATE_STATISTICS true

/*!
 * @defined SUOTA_LIB_CONFIG_UPLOAD_TIMEOUT
 *
 * @abstract 上传超时（毫秒）。
 *
 */
#define SUOTA_LIB_CONFIG_UPLOAD_TIMEOUT 30000 //ms

/*!
 * @defined SUOTA_LIB_CONFIG_AUTO_REBOOT
 *
 * @abstract 表示在成功更新后是否应该向设备发送重启信号。
 *
 * @discussion 如果 <code>false</code>，用户应该在 {@link onSuccess:imageUploadElapsedSeconds:} 方法调用时被提示向设备发送重启信号。
 *
 */
#define SUOTA_LIB_CONFIG_AUTO_REBOOT false

/*!
 * @defined SUOTA_LIB_CONFIG_AUTO_DISCONNECT_IF_REBOOT_DENIED
 *
 * @abstract 表示在成功更新后是否必须断开设备连接。
 *
 * @discussion 在成功的 SUOTA 更新后用于提示用户断开设备连接。如果为 <code>true</code>，无论用户的回答如何，设备都会断开连接。
 *
 */
#define SUOTA_LIB_CONFIG_AUTO_DISCONNECT_IF_REBOOT_DENIED false

/*!
 * @defined SUOTA_LIB_CONFIG_AUTO_READ_DEVICE_INFO
 *
 * @abstract 表示在与设备连接后是否应读取设备信息特性。
 *
 */
#define SUOTA_LIB_CONFIG_AUTO_READ_DEVICE_INFO true

/*!
 * @defined SUOTA_LIB_CONFIG_READ_DEVICE_INFO_FIRST
 *
 * @abstract 表示在读取 SUOTA 信息特性之前是否应该优先读取设备信息特性。
 *
 * @discussion 此值只有在 {@link SUOTA_LIB_CONFIG_AUTO_READ_DEVICE_INFO} 为 <code>true</code> 时才有意义。SUOTA 信息特性在任何情况下都会被读取。
 *
 */
#define SUOTA_LIB_CONFIG_READ_DEVICE_INFO_FIRST true

/*!
 * @defined SUOTA_LIB_CONFIG_READ_ALL_DEVICE_INFO
 *
 * @abstract 表示在与设备连接后是否会读取所有可用的设备信息特性。
 *
 * @discussion 如果为 <code>false</code>，只会读取 {@link DEVICE_INFO_TO_READ} 中指定的特性。此值只有在 {@link SUOTA_LIB_CONFIG_AUTO_READ_DEVICE_INFO} 为 <code>true</code> 时才有意义。
 *
 */
#define SUOTA_LIB_CONFIG_READ_ALL_DEVICE_INFO false

/*!
 * @defined SUOTA_LIB_CONFIG_NOTIFY_DEVICE_INFO_READ
 *
 * @abstract 表示在每个设备信息特性值读取时是否调用 {@link onCharacteristicRead:characteristic:} 方法。
 *
 */
#define SUOTA_LIB_CONFIG_NOTIFY_DEVICE_INFO_READ true

/*!
 * @defined SUOTA_LIB_CONFIG_NOTIFY_DEVICE_INFO_READ_COMPLETED
 *
 * @abstract 表示在读取完所有可用的设备信息特性时是否调用 {@link onDeviceInfoReadCompleted:} 方法。
 *
 */
#define SUOTA_LIB_CONFIG_NOTIFY_DEVICE_INFO_READ_COMPLETED true

/*!
 * @defined SUOTA_LIB_CONFIG_NOTIFY_SUOTA_LOG
 *
 * @abstract 表示在更新过程中是否应在 SUOTA 协议状态更改时调用 {@link onSuotaLog:type:log:} 方法。
 *
 */
#define SUOTA_LIB_CONFIG_NOTIFY_SUOTA_LOG true

/*!
 * @defined SUOTA_LIB_CONFIG_NOTIFY_SUOTA_LOG_CHUNK
 *
 * @abstract 表示在发送数据块时是否应调用 {@link onSuotaLog:type:log:} 方法。
 *
 */
#define SUOTA_LIB_CONFIG_NOTIFY_SUOTA_LOG_CHUNK false

/*!
 * @defined SUOTA_LIB_CONFIG_NOTIFY_SUOTA_LOG_BLOCK
 *
 * @abstract 表示在发送块时是否应调用 {@link onSuotaLog:type:log:} 方法。
 *
 */
#define SUOTA_LIB_CONFIG_NOTIFY_SUOTA_LOG_BLOCK false

/*!
 * @defined SUOTA_LIB_CONFIG_NOTIFY_CHUNK_SEND
 *
 * @abstract 表示在 SUOTA 发送数据块时是否调用 {@link onChunkSend:totalChunks:chunk:block:blockChunks:totalBlocks:} 方法。
 *
 */
#define SUOTA_LIB_CONFIG_NOTIFY_CHUNK_SEND true

/*!
 * @defined SUOTA_LIB_CONFIG_NOTIFY_BLOCK_SENT
 *
 * @abstract 表示在 SUOTA 发送块时是否调用 {@link onBlockSent:totalBlocks:} 方法。
 *
 */
#define SUOTA_LIB_CONFIG_NOTIFY_BLOCK_SENT true

/*!
 * @defined SUOTA_LIB_CONFIG_NOTIFY_UPLOAD_PROGRESS
 *
 * @abstract 表示在镜像上传进度更新时是否调用 {@link onUploadProgress:} 方法。
 *
 */
#define SUOTA_LIB_CONFIG_NOTIFY_UPLOAD_PROGRESS true

/*!
 * @defined SUOTA_LIB_CONFIG_PROTOCOL_DEBUG
 *
 * @abstract 表示是否为 SUOTA 协议生成调试日志。
 *
 */
#define SUOTA_LIB_CONFIG_PROTOCOL_DEBUG false

// 默认值
/*!
 * @defined SUOTA_LIB_DEFAULT_SCAN_TIMEOUT
 *
 * @abstract 默认扫描持续时间。
 *
 */
#define SUOTA_LIB_DEFAULT_SCAN_TIMEOUT 10000 // ms

/*!
 * @defined SUOTA_LIB_DEFAULT_FILE_LIST_HEADER_INFO
 *
 * @abstract 表示是否应该初始化每个找到的固件文件的头部信息。
 *
 */
#define SUOTA_LIB_DEFAULT_FILE_LIST_HEADER_INFO false

/*!
 * @defined SUOTA_LIB_DEFAULT_BLOCK_SIZE
 *
 * @abstract 默认文件块大小（字节）。
 *
 */
#define SUOTA_LIB_DEFAULT_BLOCK_SIZE 240

/*!
 * @defined SUOTA_LIB_DEFAULT_CHUNK_SIZE
 *
 * @abstract 默认文件块大小（字节）。
 *
 */
#define SUOTA_LIB_DEFAULT_CHUNK_SIZE 20

// 内存类型
/*!
 * @defined SUOTA_LIB_DEFAULT_IMAGE_BANK
 *
 * @abstract 默认内存银行。
 *
 */
#define SUOTA_LIB_DEFAULT_IMAGE_BANK IMAGE_BANK_OLDEST

/*!
 * @defined SUOTA_LIB_DEFAULT_MEMORY_TYPE
 *
 * @abstract 默认内存类型。
 *
 */
#define SUOTA_LIB_DEFAULT_MEMORY_TYPE MEMORY_TYPE_EXTERNAL_SPI

// SPI 内存设置
/*!
 * @defined SUOTA_LIB_DEFAULT_MISO_GPIO
 *
 * @abstract 默认 SPI MISO 值。
 *
 */
#define SUOTA_LIB_DEFAULT_MISO_GPIO 0x05

/*!
 * @defined SUOTA_LIB_DEFAULT_MOSI_GPIO
 *
 * @abstract 默认 SPI MOSI 值。
 *
 */
#define SUOTA_LIB_DEFAULT_MOSI_GPIO 0x06

/*!
 * @defined SUOTA_LIB_DEFAULT_CS_GPIO
 *
 * @abstract 默认 SPI CS 值。
 *
 */
#define SUOTA_LIB_DEFAULT_CS_GPIO 0x03

/*!
 * @defined SUOTA_LIB_DEFAULT_SCK_GPIO
 *
 * @abstract 默认 SPI SCK 值。
 *
 */
#define SUOTA_LIB_DEFAULT_SCK_GPIO 0x00

// I2C 内存设置
/*!
 * @defined SUOTA_LIB_DEFAULT_I2C_DEVICE_ADDRESS
 *
 * @abstract 默认 I2C 设备地址。
 *
 */
#define SUOTA_LIB_DEFAULT_I2C_DEVICE_ADDRESS 0x50

/*!
 * @defined SUOTA_LIB_DEFAULT_SCL_GPIO
 *
 * @abstract 默认 I2C SCL GPIO 值。
 *
 */
#define SUOTA_LIB_DEFAULT_SCL_GPIO 0x02

/*!
 * @defined SUOTA_LIB_DEFAULT_SDA_GPIO
 *
 * @abstract 默认 I2C SDA GPIO 值。
 *
 */
#define SUOTA_LIB_DEFAULT_SDA_GPIO 0x03

/*!
 * @class SuotaLibConfig
 *
 * @discussion 库配置对象。
 *
 */
@interface SuotaLibConfig : NSObject

/*!
 * @property ALLOW_DIALOG_DISPLAY
 *
 * @discussion 包含 {@link SUOTA_LIB_CONFIG_ALLOW_DIALOG_DISPLAY} 值的属性。
 */
@property (class, readonly) BOOL ALLOW_DIALOG_DISPLAY;

/*!
 * @property CHECK_HEADER_CRC
 *
 * @discussion 包含 {@link SUOTA_LIB_CONFIG_CHECK_HEADER_CRC} 值的属性。
 */
@property (class, readonly) BOOL CHECK_HEADER_CRC;

/*!
 * @property CALCULATE_STATISTICS
 *
 * @discussion 包含 {@link SUOTA_LIB_CONFIG_CALCULATE_STATISTICS} 值的属性。
 */
@property (class, readonly) BOOL CALCULATE_STATISTICS;

/*!
 * @property UPLOAD_TIMEOUT
 *
 * @discussion 包含 {@link SUOTA_LIB_CONFIG_UPLOAD_TIMEOUT} 值的属性。
 */
@property (class, readonly) int UPLOAD_TIMEOUT;

/*!
 * @property AUTO_REBOOT
 *
 * @discussion 包含 {@link SUOTA_LIB_CONFIG_AUTO_REBOOT} 值的属性。
 */
@property (class, readonly) BOOL AUTO_REBOOT;

/*!
 * @property AUTO_DISCONNECT_IF_REBOOT_DENIED
 *
 * @discussion 包含 {@link SUOTA_LIB_CONFIG_AUTO_DISCONNECT_IF_REBOOT_DENIED} 值的属性。
 */
@property (class, readonly) BOOL AUTO_DISCONNECT_IF_REBOOT_DENIED;

/*!
 * @property AUTO_READ_DEVICE_INFO
 *
 * @discussion 包含 {@link SUOTA_LIB_CONFIG_AUTO_READ_DEVICE_INFO} 值的属性。
 */
@property (class, readonly) BOOL AUTO_READ_DEVICE_INFO;

/*!
 * @property READ_DEVICE_INFO_FIRST
 *
 * @discussion 包含 {@link SUOTA_LIB_CONFIG_READ_DEVICE_INFO_FIRST} 值的属性。
 */
@property (class, readonly) BOOL READ_DEVICE_INFO_FIRST;

/*!
 * @property READ_ALL_DEVICE_INFO
 *
 * @discussion 包含 {@link SUOTA_LIB_CONFIG_READ_ALL_DEVICE_INFO} 值的属性。
 */
@property (class, readonly) BOOL READ_ALL_DEVICE_INFO;

/*!
 * @property NOTIFY_DEVICE_INFO_READ
 *
 * @discussion 包含 {@link SUOTA_LIB_CONFIG_NOTIFY_DEVICE_INFO_READ} 值的属性。
 */
@property (class, readonly) BOOL NOTIFY_DEVICE_INFO_READ;

/*!
 * @property NOTIFY_DEVICE_INFO_READ_COMPLETED
 *
 * @discussion 包含 {@link SUOTA_LIB_CONFIG_NOTIFY_DEVICE_INFO_READ_COMPLETED} 值的属性。
 */
@property (class, readonly) BOOL NOTIFY_DEVICE_INFO_READ_COMPLETED;

/*!
 * @property NOTIFY_SUOTA_LOG
 *
 * @discussion 包含 {@link SUOTA_LIB_CONFIG_NOTIFY_SUOTA_LOG} 值的属性。
 */
@property (class, readonly) BOOL NOTIFY_SUOTA_LOG;

/*!
 * @property NOTIFY_SUOTA_LOG_CHUNK
 *
 * @discussion 包含 {@link SUOTA_LIB_CONFIG_NOTIFY_SUOTA_LOG_CHUNK} 值的属性。
 */
@property (class, readonly) BOOL NOTIFY_SUOTA_LOG_CHUNK;

/*!
 * @property NOTIFY_SUOTA_LOG_BLOCK
 *
 * @discussion 包含 {@link SUOTA_LIB_CONFIG_NOTIFY_SUOTA_LOG_BLOCK} 值的属性。
 */
@property (class, readonly) BOOL NOTIFY_SUOTA_LOG_BLOCK;

/*!
 * @property NOTIFY_CHUNK_SEND
 *
 * @discussion 包含 {@link SUOTA_LIB_CONFIG_NOTIFY_CHUNK_SEND} 值的属性。
 */
@property (class, readonly) BOOL NOTIFY_CHUNK_SEND;

/*!
 * @property NOTIFY_BLOCK_SENT
 *
 * @discussion 包含 {@link SUOTA_LIB_CONFIG_NOTIFY_BLOCK_SENT} 值的属性。
 */
@property (class, readonly) BOOL NOTIFY_BLOCK_SENT;

/*!
 * @property NOTIFY_UPLOAD_PROGRESS
 *
 * @discussion 包含 {@link SUOTA_LIB_CONFIG_NOTIFY_UPLOAD_PROGRESS} 值的属性。
 */
@property (class, readonly) BOOL NOTIFY_UPLOAD_PROGRESS;

/*!
 * @property PROTOCOL_DEBUG
 *
 * @discussion 包含 {@link SUOTA_LIB_CONFIG_PROTOCOL_DEBUG} 值的属性。
 */
@property (class, readonly) BOOL PROTOCOL_DEBUG;

/*!
 * @property DEVICE_INFO_TO_READ
 *
 * @discussion 包含需要读取的设备信息特性的 {@link CBUUID} 数组。
 */
@property (class, readonly) NSArray<CBUUID*>* DEVICE_INFO_TO_READ;

/*!
 * @property DEFAULT_SCAN_TIMEOUT
 *
 * @discussion 包含 {@link SUOTA_LIB_DEFAULT_SCAN_TIMEOUT} 值的属性。
 */
@property (class, readonly) int DEFAULT_SCAN_TIMEOUT;

/*!
 * @property DEFAULT_FIRMWARE_PATH
 *
 * @discussion 包含固件默认路径的属性。
 */
@property (class, readonly) NSString* DEFAULT_FIRMWARE_PATH;

/*!
 * @property FILE_LIST_HEADER_INFO
 *
 * @discussion 包含 {@link SUOTA_LIB_DEFAULT_FILE_LIST_HEADER_INFO} 值的属性。
 */
@property (class, readonly) BOOL FILE_LIST_HEADER_INFO;

/*!
 * @property DEFAULT_BLOCK_SIZE
 *
 * @discussion 包含 {@link SUOTA_LIB_DEFAULT_BLOCK_SIZE} 值的属性。
 */
@property (class, readonly) int DEFAULT_BLOCK_SIZE;

/*!
 * @property DEFAULT_CHUNK_SIZE
 *
 * @discussion 包含 {@link SUOTA_LIB_DEFAULT_CHUNK_SIZE} 值的属性。
 */
@property (class, readonly) int DEFAULT_CHUNK_SIZE;

/*!
 * @property DEFAULT_IMAGE_BANK
 *
 * @discussion 包含 {@link SUOTA_LIB_DEFAULT_IMAGE_BANK} 值的属性。
 */
@property (class, readonly) uint8_t DEFAULT_IMAGE_BANK;

/*!
 * @property DEFAULT_MEMORY_TYPE
 *
 * @discussion 包含 {@link SUOTA_LIB_DEFAULT_MEMORY_TYPE} 值的属性。
 */
@property (class, readonly) uint8_t DEFAULT_MEMORY_TYPE;

/*!
 * @property DEFAULT_MISO_GPIO
 *
 * @discussion 包含 {@link SUOTA_LIB_DEFAULT_MISO_GPIO} 值的属性。
 */
@property (class, readonly) uint8_t DEFAULT_MISO_GPIO;

/*!
 * @property DEFAULT_MOSI_GPIO
 *
 * @discussion 包含 {@link SUOTA_LIB_DEFAULT_MOSI_GPIO} 值的属性。
 */
@property (class, readonly) uint8_t DEFAULT_MOSI_GPIO;

/*!
 * @property DEFAULT_CS_GPIO
 *
 * @discussion 包含 {@link SUOTA_LIB_DEFAULT_CS_GPIO} 值的属性。
 */
@property (class, readonly) uint8_t DEFAULT_CS_GPIO;

/*!
 * @property DEFAULT_SCK_GPIO
 *
 * @discussion 包含 {@link SUOTA_LIB_DEFAULT_SCK_GPIO} 值的属性。
 */
@property (class, readonly) uint8_t DEFAULT_SCK_GPIO;

/*!
 * @property DEFAULT_I2C_DEVICE_ADDRESS
 *
 * @discussion 包含 {@link SUOTA_LIB_DEFAULT_I2C_DEVICE_ADDRESS} 值的属性。
 */
@property (class, readonly) uint8_t DEFAULT_I2C_DEVICE_ADDRESS;

/*!
 * @property DEFAULT_SCL_GPIO
 *
 * @discussion 包含 {@link SUOTA_LIB_DEFAULT_SCL_GPIO} 值的属性。
 */
@property (class, readonly) uint8_t DEFAULT_SCL_GPIO;

/*!
 * @property DEFAULT_SDA_GPIO
 *
 * @discussion 包含 {@link SUOTA_LIB_DEFAULT_SDA_GPIO} 值的属性。
 */
@property (class, readonly) uint8_t DEFAULT_SDA_GPIO;

@end
