//
//  FESettingBeaconModel.h
//  FeasyBeacon
//
//  Created by feasycom on 2025/12/4.
//  Copyright © 2025 Feasycom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FEBeaconTitleInfoDetail.h"

NS_ASSUME_NONNULL_BEGIN

@interface FESettingBeaconModel : NSObject

#pragma mark - 各种限制条件
// 是否满足条件 ============
// 网址
+ (BOOL)isValidEddystoneURL:(NSString *)urlString;
// 自定义数据
+ (NSString *)validCustomData:(NSString *)str;

#pragma mark - 每种类型组
+ (NSArray<FEBeaconTitleInfoDetail *> *)iBeaconListWithTxPower:(BOOL)isWithTxPower;
+ (NSArray<FEBeaconTitleInfoDetail *> *)urlListWithTxPower:(BOOL)isWithTxPower;
+ (NSArray<FEBeaconTitleInfoDetail *> *)uidListWithTxPower:(BOOL)isWithTxPower;
+ (NSArray<FEBeaconTitleInfoDetail *> *)altBeaconListWithTxPower:(BOOL)isWithTxPower;
+ (NSArray<FEBeaconTitleInfoDetail *> *)customListWithTxPower:(BOOL)isWithTxPower;

#pragma mark - placeholder
+ (NSString *)placeholder_UUID;
+ (NSString *)placeholder_RSSI;
+ (NSString *)placeholder_Major;
+ (NSString *)placeholder_Minor;
+ (NSString *)placeholder_URL;
+ (NSString *)placeholder_Namespace;
+ (NSString *)placeholder_Instance;
+ (NSString *)placeholder_Reserved;
+ (NSString *)placeholder_ID1;
+ (NSString *)placeholder_ID2;
+ (NSString *)placeholder_ID3;
+ (NSString *)placeholder_ManufacturerID;
+ (NSString *)placeholder_ManufacturerReserved;
+ (NSString *)placeholder_Data;
+ (NSString *)placeholder_Internal;
+ (NSString *)placeholder_Timeout;

#pragma mark - 输入限制
+ (BOOL)dealwith_UUID_TextField:(UITextField *)textField newText:(NSString *)newText;
+ (BOOL)dealwith_RSSI_TextField:(UITextField *)textField newText:(NSString *)newText inputString:(NSString *)string;
+ (BOOL)dealwith_Major_TextField:(UITextField *)textField newText:(NSString *)newText;
+ (BOOL)dealwith_Minor_TextField:(UITextField *)textField newText:(NSString *)newText;
+ (BOOL)dealwith_URL_TextField:(UITextField *)textField newText:(NSString *)newText inputString:(NSString *)string;
+ (BOOL)dealwith_Namespace_TextField:(UITextField *)textField newText:(NSString *)newText;
+ (BOOL)dealwith_Instance_TextField:(UITextField *)textField newText:(NSString *)newText;
+ (BOOL)dealwith_Reserved_TextField:(UITextField *)textField newText:(NSString *)newText;
+ (BOOL)dealwith_ID1_TextField:(UITextField *)textField newText:(NSString *)newText;
+ (BOOL)dealwith_ID2_TextField:(UITextField *)textField newText:(NSString *)newText;
+ (BOOL)dealwith_ID3_TextField:(UITextField *)textField newText:(NSString *)newText;
+ (BOOL)dealwith_ManufacturerID_TextField:(UITextField *)textField newText:(NSString *)newText;
+ (BOOL)dealwith_ManufacturerReserved_TextField:(UITextField *)textField newText:(NSString *)newText range:(NSRange)range;
+ (BOOL)dealwith_Data_TextField:(UITextField *)textField newText:(NSString *)newText;
+ (BOOL)dealwith_Internal_TextField:(UITextField *)textField newText:(NSString *)newText;
+ (BOOL)dealwith_Timeout_TextField:(UITextField *)textField newText:(NSString *)newText;

@end

NS_ASSUME_NONNULL_END
