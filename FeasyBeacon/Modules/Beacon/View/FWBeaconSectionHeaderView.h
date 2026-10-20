//
//  FWBeaconSectionHeaderView.h
//  FeasyBeacon
//
//  Created by chenchanghua on 2026/2/7.
//  Copyright © 2026 Feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBSDKPublicHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface FWBeaconSectionHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subLabel;     // mac 或 accuracy+proximity
@property (nonatomic, strong) UILabel *rssiLabel;
@property (nonatomic, strong) UILabel *intervalLabel;
- (void)applyItem:(FBPeripheralItem *)item;

@end

NS_ASSUME_NONNULL_END
