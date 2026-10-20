/*
 *******************************************************************************
 *
 * Copyright (C) 2019-2020 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "HeaderInfo68x.h"

@interface HeaderInfo58x : HeaderInfo

/*
 typedef struct
 {
 uint8_t signature[2];     // 签名，表示图像头部的标识符
 uint8_t validflag;        // 有效标志，在图像更新结束时设置为 STATUS_VALID_IMAGE
 uint8_t imageid;          // 用于确定最新图像的 ID
 uint32_t code_size;       // 图像的大小
 uint32_t CRC ;            // 图像的 CRC 校验值
 uint8_t version[16];      // 图像的版本信息
 uint32_t timestamp;       // 时间戳
 uint8_t encryption;       // 加密标志
 uint8_t reserved[31];     // 保留字段
 } image_header_t;
 
 #define IMAGE_HEADER_SIGNATURE1     0x70
 #define IMAGE_HEADER_SIGNATURE2     0x51
 */

@property (class, readonly) NSString* TYPE;  // 类属性，表示头部类型
@property (class, readonly) int SIGNATURE;   // 类属性，表示头部签名
@property (class, readonly) int HEADER_SIZE; // 类属性，表示头部大小

@property uint8_t validFlag;   // 有效标志
@property uint8_t imageId;     // 图像 ID
@property uint8_t encryption;  // 加密标志

// 初始化方法，使用头部数据和总字节数
- (instancetype) initWithHeader:(NSData*)header totalBytes:(uint64_t)totalBytes;

// 初始化方法，使用原始缓冲区数据
- (instancetype) initWithRawBuffer:(NSData*)rawBuffer;

@end
