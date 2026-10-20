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
#import "SuotaLib.h"

// Parameters 是一个单例类，通过 instance 属性访问全局实例。这个类用于存储应用程序运行时的一些全局参数，方便在不同视图控制器之间共享数据
@interface Parameters : NSObject

+ (Parameters*) instance;

@property SuotaManager* suotaManager;
@property CBPeripheral* peripheral;
@property NSString *pinCode;
@property NSString *macAddress;
@property CBCentralManager *centralManager;

@end
