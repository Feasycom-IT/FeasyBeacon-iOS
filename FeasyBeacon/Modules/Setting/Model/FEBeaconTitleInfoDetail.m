//
//  FEBeaconTitleInfoDetail.m
//  FeasyBeacon
//
//  Created by feasycom on 2025/12/16.
//  Copyright © 2025 Feasycom. All rights reserved.
//

#import "FEBeaconTitleInfoDetail.h"

@implementation FEBeaconTitleInfoDetail

+ (FEBeaconTitleInfoDetail *)title:(NSString *)title placeholder:(NSString *)placeholder {
    FEBeaconTitleInfoDetail *detail = [[FEBeaconTitleInfoDetail alloc] init];
    detail.title = title;
    detail.placeholder = placeholder;
    detail.keyboardType = UIKeyboardTypeDefault;
    return detail;
}
+ (FEBeaconTitleInfoDetail *)title:(NSString *)title placeholder:(NSString *)placeholder keyboardType:(UIKeyboardType)keyboardType {
    FEBeaconTitleInfoDetail *detail = [[FEBeaconTitleInfoDetail alloc] init];
    detail.title = title;
    detail.placeholder = placeholder;
    detail.keyboardType = keyboardType;
    return detail;
}
@end
