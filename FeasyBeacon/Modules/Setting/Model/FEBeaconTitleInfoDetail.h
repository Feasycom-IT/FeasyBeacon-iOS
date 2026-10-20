//
//  FEBeaconTitleInfoDetail.h
//  FeasyBeacon
//
//  Created by feasycom on 2025/12/16.
//  Copyright © 2025 Feasycom. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FEBeaconTitleInfoDetail : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic) UIKeyboardType keyboardType;
+ (FEBeaconTitleInfoDetail *)title:(NSString *)title placeholder:(NSString *)placeholder;
+ (FEBeaconTitleInfoDetail *)title:(NSString *)title placeholder:(NSString *)placeholder keyboardType:(UIKeyboardType)keyboardType;
@end

NS_ASSUME_NONNULL_END
