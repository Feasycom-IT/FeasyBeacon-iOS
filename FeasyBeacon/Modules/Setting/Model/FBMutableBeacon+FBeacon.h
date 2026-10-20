//
//  FBMutableBeacon+FBeacon.h
//  FeasyBeacon
//
//  Created by chenchanghua on 2026/3/20.
//  Copyright © 2026 Feasycom. All rights reserved.
//

#import "FBMutableBeacon.h"

NS_ASSUME_NONNULL_BEGIN

@interface FBMutableBeacon (FBeacon)

+ (void)normalizeNorvIndexForBeacons:(NSArray<FBMutableBeacon *> *)beacons;

+ (void)normalizeSadvIndexForBeacons:(NSArray<FBMutableBeacon *> *)beacons;

+ (NSInteger)sadvCountForBeacons:(NSArray<FBMutableBeacon *> *)beacons;

@end

NS_ASSUME_NONNULL_END
