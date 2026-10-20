//
//  FBMutableBeacon.h
//  FeasyBeacon
//
//  Created by LiDong on 2021/6/26.
//  Copyright © 2021 LIDONG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBBeacon.h"

NS_ASSUME_NONNULL_BEGIN

/// 抽象出来的Beacon对象（配置用）
@interface FBMutableBeacon : NSObject

/// 类型（Unknown、iBeacon、URL、UID、TLM、AltBeacon、AoA）
@property (nonatomic, assign) FBBeaconType type;
/// 是否开启广播
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) NSUInteger numberOfParameters;
@property (nonatomic, assign) int index;// 0...9

/// 用于支持phy功能的模块（URL、UID、AltBeacon）
@property (nonatomic, assign) int iPhy;
@property (nonatomic, assign) int iInterval;
@property (nonatomic, strong, nullable) NSString *txPower;

/// SADV 相关
@property (nonatomic, assign) BOOL isSadv;
@property (nonatomic, assign) int sadv_sensor;
@property (nonatomic, assign) int sadv_action;
@property (nonatomic, assign) int sadv_interval;// ms
@property (nonatomic, assign) int sadv_timeout; // ms

/// 无论是否解析成功，始终保留原始 data 的 16 进制串
@property (nonatomic, copy, nullable) NSString *rawDataHex;

/// iBeacon
@property (nonatomic, strong, nullable) NSString *proximityUUID;
/// iBeacon
@property (nonatomic, assign) int major;
/// iBeacon
@property (nonatomic, assign) int minor;
/// iBeacon
@property (nonatomic, assign) int calibratedTxPowerAt1m_iBeacon;

/// URL
@property (nonatomic, strong, nullable) NSString *URLString;
/// URL
@property (nonatomic, assign) int calibratedTxPowerAt0m_url;

/// UID
@property (nonatomic, strong, nullable) NSString *namespaceString;
/// UID
@property (nonatomic, strong, nullable) NSString *instanceString;
/// UID
@property (nonatomic, strong, nullable) NSString *reservedString;
/// UID
@property (nonatomic, assign) int calibratedTxPowerAt0m_uid;

/// AltBeacon
@property (nonatomic, strong, nullable) NSString *IDString1;
/// AltBeacon
@property (nonatomic, strong, nullable) NSString *IDString2;
/// AltBeacon
@property (nonatomic, strong, nullable) NSString *IDString3;
/// AltBeacon
@property (nonatomic, assign) int manufacturerID;
/// AltBeacon
@property (nonatomic, strong, nullable) NSString *manufacturerReservedString;
/// AltBeacon
@property (nonatomic, assign) int calibratedTxPowerAt1m_alt;

/// AoA
@property (nonatomic, assign) int channel;

@end

NS_ASSUME_NONNULL_END
