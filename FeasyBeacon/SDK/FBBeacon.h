//
//  FBBeacon.h
//  FeasyBeacon
//
//  Created by LiDong on 2021/6/26.
//  Copyright © 2021 LIDONG. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FBBeaconType) {
    FBBeaconTypeUnknown = 0,
    FBBeaconTypeIBeacon,
    FBBeaconTypeURL,
    FBBeaconTypeUID,
    FBBeaconTypeAltBeacon,
    FBBeaconTypeTLM,
    FBBeaconTypeAoA,
};

typedef NS_ENUM(NSUInteger, FBProximityType) {
    FBProximityTypeUnknown,
    FBProximityTypeImmediate,
    FBProximityTypeNear,
    FBProximityTypeFar
};

/// Beacon广播
@interface FBBeacon : NSObject

/// 类型
@property (nonatomic, assign, readonly) FBBeaconType type;

/// 两个 Beacon 的相等判断
- (BOOL)isEqual:(FBBeacon *)otherBeacon;

#pragma mark - iBeacon

/// iBeacon
@property (nonatomic, strong, readonly, nullable) NSString *proximityUUID;
/// iBeacon
@property (nonatomic, assign, readonly) int major;
/// iBeacon
@property (nonatomic, assign, readonly) int minor;
/// iBeacon
@property (nonatomic, assign, readonly) FBProximityType proximityType;
/// iBeacon
@property (nonatomic, assign, readonly) double accuracy;

#pragma mark - UID<0x00>

/// UID<0x00>
@property (nonatomic, assign, readonly) NSInteger calibratedTxPowerAt0m_uid;
/// UID<0x00>
@property (nonatomic, strong, readonly, nullable) NSString *namespaceString;
/// UID<0x00>
@property (nonatomic, strong, readonly, nullable) NSString *instanceString;
/// UID<0x00>
@property (nonatomic, strong, readonly, nullable) NSString *reservedString;

#pragma mark - URL<0x10>

/// URL<0x10>
@property (nonatomic, assign, readonly) NSInteger calibratedTxPowerAt0m_url;
/// URL<0x10>
@property (nonatomic, strong, readonly, nullable) NSString *URLString;

#pragma mark - TLM<0x20>

/// TLM<0x20>
@property (nonatomic, assign, readonly) NSInteger tlmVersion;
/// TLM<0x20>
@property (nonatomic, assign, readonly) NSInteger batteryVoltage;
/// TLM<0x20>
@property (nonatomic, assign, readonly) double beaconTemperature;
/// TLM<0x20>
@property (nonatomic, assign, readonly) NSInteger advertisingPDUCount;
/// TLM<0x20>
@property (nonatomic, assign, readonly) NSInteger timeSincePowerOnOrReboot;

#pragma mark - AltBeacon<0xBEAC>

/// AltBeacon<0xBEAC>
@property (nonatomic, strong, readonly, nullable) NSString *manufacturerID;
/// AltBeacon<0xBEAC>
@property (nonatomic, strong, readonly, nullable) NSString *IDString;
/// AltBeacon<0xBEAC>
@property (nonatomic, assign, readonly) NSInteger calibratedTxPowerAt1m_alt;
/// AltBeacon<0xBEAC>
@property (nonatomic, strong, readonly, nullable) NSString *manufacturerReservedString;

#pragma mark - AoA

/// AoA频道（配置字段）
@property (nonatomic, assign, readonly) int channel;
/// AoA Company ID
@property (nonatomic, assign, readonly) uint16_t aoaCompanyID;
/// AoA厂商协议子类型
@property (nonatomic, assign, readonly) uint8_t aoaSubType;
/// AoA原始CTE Info
@property (nonatomic, assign, readonly) uint8_t aoaCTEInfo;
/// AoA CTE长度
@property (nonatomic, assign, readonly) uint8_t aoaCTELength;
/// AoA CTE类型
@property (nonatomic, assign, readonly) uint8_t aoaCTEType;
/// AoA Beacon ID
@property (nonatomic, assign, readonly) uint32_t aoaBeaconID;
/// AoA Beacon类型
@property (nonatomic, assign, readonly) uint8_t aoaBeaconType;
/// AoA电量百分比
@property (nonatomic, assign, readonly) uint8_t aoaBatteryLevel;
/// AoA原始Manufacturer Data
@property (nonatomic, copy, readonly, nullable) NSData *aoaRawData;

@end

NS_ASSUME_NONNULL_END
