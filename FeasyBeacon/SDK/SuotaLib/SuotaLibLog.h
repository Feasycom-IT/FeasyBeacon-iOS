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

// 定义日志输出宏，带标签和格式化字符串
#define SuotaLog(TAG, fmt, ...) NSLog(@"%@: " fmt, TAG, ##__VA_ARGS__)
// 定义可选日志输出宏，只有在启用时才会输出日志
#define SuotaLogOpt(enabled, TAG, fmt, ...) do { if (enabled) NSLog(@"%@: " fmt, TAG, ##__VA_ARGS__); } while(0)

// 日志控制常量，设置为 true 表示启用该类型日志
#define SUOTA_LIB_LOG_SCAN_DEBUG true
#define SUOTA_LIB_LOG_SCAN_ERROR true

#define SUOTA_LIB_LOG_MANAGER true
#define SUOTA_LIB_LOG_PROTOCOL true
#define SUOTA_LIB_LOG_BLOCK true
#define SUOTA_LIB_LOG_CHUNK true
#define SUOTA_LIB_LOG_GATT_OPERATION true
#define SUOTA_LIB_LOG_SUOTA_FILE true

// SuotaLibLog 类，提供各类日志的启用状态
@interface SuotaLibLog : NSObject

// 扫描调试日志的启用状态
@property (class, readonly) BOOL SCAN_DEBUG;
// 扫描错误日志的启用状态
@property (class, readonly) BOOL SCAN_ERROR;
// 管理器日志的启用状态
@property (class, readonly) BOOL MANAGER;
// 协议日志的启用状态
@property (class, readonly) BOOL PROTOCOL;
// 块日志的启用状态
@property (class, readonly) BOOL BLOCK;
// 数据块日志的启用状态
@property (class, readonly) BOOL CHUNK;
// GATT 操作日志的启用状态
@property (class, readonly) BOOL GATT_OPERATION;
// SUOTA 文件日志的启用状态
@property (class, readonly) BOOL SUOTA_FILE;

@end
