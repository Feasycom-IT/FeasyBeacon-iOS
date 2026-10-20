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

@interface HeaderInfo69x : HeaderInfo

/*
 定义了 DA1469x 平台的 SUOTA 1.1 固件头部结构体
 
 typedef struct {
 uint8_t image_identifier[2];  // 图像标识符 (签名)
 uint32_t size;                // 图像大小
 uint32_t crc;                 // CRC 校验
 uint8_t version_string[16];   // 版本字符串
 uint32_t timestamp;           // 时间戳
 uint32_t pointer_to_ivt;      // IVT 的指针
 } __attribute__((packed)) suota_1_1_image_header_da1469x_t;
 
 #define SUOTA_1_1_IMAGE_DA1469x_HEADER_SIGNATURE_B1       0x51  // 签名字节1
 #define SUOTA_1_1_IMAGE_DA1469x_HEADER_SIGNATURE_B2       0x71  // 签名字节2
 */

@property (class, readonly) NSString* TYPE;
@property (class, readonly) int SIGNATURE;
@property (class, readonly) int HEADER_SIZE;

@property uint64_t pointerToIvt;  // IVT 的指针

- (instancetype) initWithHeader:(NSData*)header totalBytes:(uint64_t)totalBytes;
- (instancetype) initWithRawBuffer:(NSData*)rawBuffer;

@end
