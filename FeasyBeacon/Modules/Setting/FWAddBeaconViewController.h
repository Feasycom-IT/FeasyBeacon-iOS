//
//  FWAddBeaconViewController.h
//  FeasyBeacon
//
//  Created by ericj on 2017/10/19.
//  Copyright © 2017年 LIDONG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBSDKPublicHeader.h"
#import "FBPeripheralItem.h"

typedef enum : NSInteger{
    AddType_Beacon,
    AddType_Condition,
}AddType;

/// 新增BeaconVC
@interface FWAddBeaconViewController : UIViewController

@property (nonatomic, copy) void(^completionHandler)(FBMutableBeacon *beacon);

- (instancetype)initWithAddType:(AddType)addType item:(FBPeripheralItem *)item;
- (instancetype)initWithModelIndex:(NSInteger) modelIndex configTxPowers:(NSArray *)txPowers addType:(AddType)addType;

@end
