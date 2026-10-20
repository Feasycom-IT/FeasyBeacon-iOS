//
//  FBMutableBeacon+FBeacon.m
//  FeasyBeacon
//
//  Created by chenchanghua on 2026/3/20.
//  Copyright © 2026 Feasycom. All rights reserved.
//

#import "FBMutableBeacon+FBeacon.h"

@implementation FBMutableBeacon (FBeacon)

+ (void)normalizeNorvIndexForBeacons:(NSArray<FBMutableBeacon *> *)beacons {
    __block NSInteger norvIndex = 0;
    
    [beacons enumerateObjectsUsingBlock:^(FBMutableBeacon * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.isSadv) {
            obj.index = (int)norvIndex;
            norvIndex++;
        }
    }];
}

+ (void)normalizeSadvIndexForBeacons:(NSArray<FBMutableBeacon *> *)beacons {
    __block NSInteger sadvIndex = 0;
    
    [beacons enumerateObjectsUsingBlock:^(FBMutableBeacon * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isSadv) {
            obj.index = (int)sadvIndex;
            sadvIndex++;
        }
    }];
}

+ (NSInteger)sadvCountForBeacons:(NSArray<FBMutableBeacon *> *)beacons {
    __block NSInteger count = 0;
    
    [beacons enumerateObjectsUsingBlock:^(FBMutableBeacon * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isSadv) {
            count++;
        }
    }];
    
    return count;
}

@end
