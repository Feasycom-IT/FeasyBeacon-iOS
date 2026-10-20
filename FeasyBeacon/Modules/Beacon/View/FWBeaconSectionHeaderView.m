//
//  FWBeaconSectionHeaderView.m
//  FeasyBeacon
//
//  Created by chenchanghua on 2026/2/7.
//  Copyright © 2026 Feasycom. All rights reserved.
//

#import "FWBeaconSectionHeaderView.h"

@implementation FWBeaconSectionHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor lightGrayColor];
        
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:17];
        [self.contentView addSubview:_titleLabel];
        
        _subLabel = [UILabel new];
        _subLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_subLabel];
        
        _rssiLabel = [UILabel new];
        _rssiLabel.font = [UIFont systemFontOfSize:14];
        _rssiLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_rssiLabel];
        
        _intervalLabel = [UILabel new];
        _intervalLabel.font = [UIFont systemFontOfSize:14];
        _intervalLabel.textAlignment = NSTextAlignmentRight;
        _intervalLabel.hidden = YES;
        [self.contentView addSubview:_intervalLabel];
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).offset(10);
            make.left.equalTo(self.contentView.mas_left).offset(10);
        }];
        
        [_subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(5);
            make.left.equalTo(self.contentView.mas_left).offset(10);
        }];
        
        [_rssiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).offset(10);
            make.right.equalTo(self.contentView.mas_right).offset(-10);
            make.width.mas_equalTo(70);
        }];
        
        [_intervalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).offset(10);
            make.right.equalTo(self.rssiLabel.mas_left).offset(-10);
            make.width.mas_equalTo(110);
        }];
    }
    return self;
}

- (void)applyItem:(FBPeripheralItem *)item {
    BOOL isIBeacon = (item.lastestBeacon.type == FBBeaconTypeIBeacon);
    
    if (isIBeacon) {
        self.titleLabel.text = @"iBeacon";
        NSString *prox = @"Unknow";
        if (item.lastestBeacon.proximityType == FBProximityTypeImmediate) prox = @"Immediate";
        else if (item.lastestBeacon.proximityType == FBProximityTypeNear) prox = @"Near";
        else if (item.lastestBeacon.proximityType == FBProximityTypeFar) prox = @"Far";
        
        self.subLabel.text = [NSString stringWithFormat:@"%.1f m (%@)", item.lastestBeacon.accuracy, prox];
    } else {
        self.titleLabel.text = item.displayedName ?: @"";
        self.subLabel.text = item.macAddress ?: @"";
    }
    
    self.rssiLabel.text = [NSString stringWithFormat:@"%lddBm", (long)item.RSSI];
    self.intervalLabel.text = [NSString stringWithFormat:@"<->%.0lfms", item.advertisementRate];
}

@end
