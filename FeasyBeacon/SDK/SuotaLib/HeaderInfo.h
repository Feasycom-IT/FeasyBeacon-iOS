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

// 前置声明 SuotaByteBuffer 类
@class SuotaByteBuffer;

@interface HeaderInfo : NSObject

// 类属性：签名的长度常量，只读
@property (class, readonly) int SIGNATURE_LENGTH;

// 实例属性：表示签名
@property int signature;

// 实例属性：文件类型的字符串表示
@property NSString* type;

// 实例属性：头部大小，以字节为单位
@property int headerSize;

// 实例属性：负载数据的偏移量
@property uint64_t payloadOffset;

// 实例属性：负载大小的偏移量
@property int offsetPayloadSize;

// 实例属性：负载 CRC 校验值的偏移量
@property int offsetPayloadCrc;

// 实例属性：版本信息的偏移量
@property int offsetVersion;

// 实例属性：版本信息的长度，以字节为单位
@property int versionLength;

// 实例属性：时间戳的偏移量
@property int offsetTimestamp;

// 实例属性：表示整个头部数据的二进制数据
@property NSData* header;

// 实例属性：文件的总字节数
@property uint64_t totalBytes;

// 实例属性：表示头部缓冲区的对象
@property SuotaByteBuffer* buffer;

// 实例属性：负载数据的大小，以字节为单位
@property uint64_t payloadSize;

// 实例属性：负载数据的 CRC 校验值
@property uint64_t payloadCrc;

// 实例属性：版本信息的字符串表示
@property NSString* version;

// 实例属性：版本信息的原始二进制数据
@property NSData* versionRaw;

// 实例属性：时间戳，以毫秒为单位
@property uint64_t timestamp;

/**
 * 使用偏移量和头部数据初始化 HeaderInfo 对象
 *
 * @param offsetPayloadSize 负载大小的偏移量
 * @param offsetPayloadCrc 负载 CRC 校验值的偏移量
 * @param offsetVersion 版本信息的偏移量
 * @param versionLength 版本信息的长度
 * @param offsetTimestamp 时间戳的偏移量
 * @param header 头部数据的二进制表示
 * @param totalBytes 文件的总字节数
 *
 * @return 返回一个初始化后的 HeaderInfo 对象
 */
- (instancetype) initWithOffsetPayloadSize:(int)offsetPayloadSize offsetPayloadCrc:(int)offsetPayloadCrc offsetVersion:(int)offsetVersion versionLength:(int)versionLength offsetTimestamp:(int)offsetTimestamp header:(NSData*)header totalBytes:(uint64_t)totalBytes;

/**
 * 使用偏移量和原始缓冲区数据初始化 HeaderInfo 对象
 *
 * @param offsetPayloadSize 负载大小的偏移量
 * @param offsetPayloadCrc 负载 CRC 校验值的偏移量
 * @param offsetVersion 版本信息的偏移量
 * @param versionLength 版本信息的长度
 * @param offsetTimestamp 时间戳的偏移量
 * @param rawBuffer 原始缓冲区的二进制数据
 *
 * @return 返回一个初始化后的 HeaderInfo 对象
 */
- (instancetype) initWithOffsetPayloadSize:(int)offsetPayloadSize offsetPayloadCrc:(int)offsetPayloadCrc offsetVersion:(int)offsetVersion versionLength:(int)versionLength offsetTimestamp:(int)offsetTimestamp rawBuffer:(NSData*)rawBuffer;

@end
