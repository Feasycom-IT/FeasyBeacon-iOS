/*
 *******************************************************************************
 *
 * Copyright (C) 2019-2020 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "HeaderInfo.h"

@interface HeaderInfo68x : HeaderInfo

/*
 typedef struct {
 uint8_t signature[2];     // 签名 (2 字节)
 uint16_t flags;           // 标志位 (2 字节)
 uint32_t code_size;       // 代码大小 (4 字节)
 uint32_t crc;             // CRC 校验 (4 字节)
 uint8_t version[16];      // 版本信息 (16 字节)
 uint32_t timestamp;       // 时间戳 (4 字节)
 uint32_t exec_location;   // 执行位置 (4 字节)
 } __attribute__((packed)) suota_1_1_image_header_t;
 
 #define SUOTA_1_1_IMAGE_HEADER_SIGNATURE_B1     0x70  // 签名字节 1
 #define SUOTA_1_1_IMAGE_HEADER_SIGNATURE_B2     0x61  // 签名字节 2
 */

@property (class, readonly) NSString* TYPE;  // 68x 头部类型
@property (class, readonly) int SIGNATURE;   // 68x 签名
@property (class, readonly) int HEADER_SIZE; // 68x 头部大小

@property uint16_t flags;        // 标志位
@property uint64_t execLocation; // 执行位置

// 使用头部数据和总字节数的初始化方法
- (instancetype) initWithHeader:(NSData*)header totalBytes:(uint64_t)totalBytes;

// 使用原始缓冲区数据的初始化方法
- (instancetype) initWithRawBuffer:(NSData*)rawBuffer;

@end
