//
//  FWBeaconsViewController.m
//  FeasyBeacon
//
//  Created by LIDONG on 14-2-28.
//  Copyright (c) 2014年 LIDONG. All rights reserved.
//

#import "FWBeaconsViewController.h"
#import "FWFilterViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import "FWCentralIBeaconCell.h"
#import "FWCentralURLBeaconCell.h"
#import "FWCentralUIDBeaconCell.h"
#import "FWCentralTLMBeaconCell.h"
#import "FWCentralAltBeaconCell.h"
#import "NSString+HexStringToData.h"
#import "MJRefresh.h"
#import "NSData+DataToHexString.h"
#import "FWADView.h"
#import "FBCentrallBP104ELCell.h"
#import "FBSDKPublicHeader.h"
#import "FBBeaconUUIDConfigVC.h"
#import "FBBeaconBroadcastVC.h"
#import "FWBeaconSectionHeaderView.h"

@interface FWCentralAoABeaconCell : UITableViewCell

@property (nonatomic, strong) UIImageView *beaconIconView;
@property (nonatomic, strong) UILabel *beaconInfoLabel;

@end

@implementation FWCentralAoABeaconCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.beaconIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"beacon_aoa"]];
        self.beaconIconView.contentMode = UIViewContentModeScaleAspectFit;
        self.beaconIconView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.beaconIconView];

        self.beaconInfoLabel = [[UILabel alloc] init];
        self.beaconInfoLabel.font = [UIFont systemFontOfSize:14.0];
        self.beaconInfoLabel.numberOfLines = 0;
        self.beaconInfoLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.beaconInfoLabel];

        [NSLayoutConstraint activateConstraints:@[
            [self.beaconIconView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:8.0],
            [self.beaconIconView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
            [self.beaconIconView.widthAnchor constraintEqualToConstant:50.0],
            [self.beaconIconView.heightAnchor constraintEqualToConstant:50.0],
            [self.beaconInfoLabel.leadingAnchor constraintEqualToAnchor:self.beaconIconView.trailingAnchor constant:5.0],
            [self.beaconInfoLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.contentView.trailingAnchor constant:-8.0],
            [self.beaconInfoLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8.0],
            [self.beaconInfoLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8.0]
        ]];
    }
    return self;
}

@end

@interface FWBeaconsViewController () <UITableViewDataSource, UITableViewDelegate, FBBluetoothBrowserDelegate>

@property (nonatomic, strong) FBBluetoothBrowser *bluetoothBrowser;
@property (nonatomic, strong) NSArray<FBPeripheralItem *> *peripheralItems;
@property (nonatomic, strong) NSTimer *refreshRSSITimer;
@property (nonatomic, strong) UIBarButtonItem *filterItem;
@property (nonatomic, strong) NSTimer *uiRefreshTimer;
@property (atomic, assign) BOOL needsUIRefresh;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation FWBeaconsViewController

- (NSArray<FBBeacon *> *)displayBeaconsForPeripheralItem:(FBPeripheralItem *)item {
    NSMutableArray<FBBeacon *> *aoaBeacons = [NSMutableArray array];
    NSMutableArray<FBBeacon *> *otherBeacons = [NSMutableArray array];
    for (FBBeacon *beacon in item.beacons) {
        if (beacon.type == FBBeaconTypeAoA) {
            [aoaBeacons addObject:beacon];
        } else {
            [otherBeacons addObject:beacon];
        }
    }
    [aoaBeacons addObjectsFromArray:otherBeacons];
    return aoaBeacons;
}

- (instancetype)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.bluetoothBrowser = [[FBBluetoothBrowser alloc] initWithType:FBBluetoothBrowserTypeBeacon requestLocationAlways:YES];
        [self.bluetoothBrowser setDelegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationView];
    
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    } else {
        // Fallback on earlier versions
    }
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.tableView registerNib:[UINib nibWithNibName:@"FWCentralIBeaconCell" bundle:nil] forCellReuseIdentifier:@"FWCentralIBeaconCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"FWCentralURLBeaconCell" bundle:nil] forCellReuseIdentifier:@"FWCentralURLBeaconCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"FWCentralUIDBeaconCell" bundle:nil] forCellReuseIdentifier:@"FWCentralUIDBeaconCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"FWCentralTLMBeaconCell" bundle:nil] forCellReuseIdentifier:@"FWCentralTLMBeaconCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"FWCentralAltBeaconCell" bundle:nil] forCellReuseIdentifier:@"FWCentralAltBeaconCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"FBCentrallBP104ELCell" bundle:nil] forCellReuseIdentifier:@"FBCentrallBP104ELCell"];
    [self.tableView registerClass:[FWCentralAoABeaconCell class] forCellReuseIdentifier:@"FWCentralAoABeaconCell"];
    [self.tableView registerClass:[FWBeaconSectionHeaderView class]
forHeaderFooterViewReuseIdentifier:@"FWBeaconSectionHeaderView"];
    
    __weak __typeof(self) weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.bluetoothBrowser startScanning];
        [strongSelf.tableView.mj_header endRefreshing];
    }];
    [FWADView showWithSeconds:5];
    usleep(100);
}

- (void)setupNavigationView {
    
    if (@available(iOS 13.0, *)) {
        NSDictionary *dic = @{NSForegroundColorAttributeName : [UIColor whiteColor],
                                  NSFontAttributeName : [UIFont systemFontOfSize:18 weight:UIFontWeightMedium]};
        
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor darkGrayColor];
        appearance.titleTextAttributes = dic;
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    }
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIImage *image = [UIImage imageNamed:@"搜索"];
    UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:LS(@"Beacon") image:image tag:0];
    [self setTabBarItem:tabBarItem];
    
    UINavigationItem *navigationItem = [self navigationItem];
    
    UIBarButtonItem *sortItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Sort") style:UIBarButtonItemStylePlain target:self action:@selector(sortButtonPressed)];
    UIBarButtonItem *broadcastItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Broadcast") style:UIBarButtonItemStylePlain target:self action:@selector(broadcastItemAction)];
    [navigationItem setLeftBarButtonItems:@[sortItem, broadcastItem]];
    
    self.filterItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Filter") style:UIBarButtonItemStylePlain target:self action:@selector(filterButtonPressed)];
    
    UIBarButtonItem *showUUIDItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"UUID") style:UIBarButtonItemStylePlain target:self action:@selector(showUUIDItemAction)];
    [navigationItem setRightBarButtonItems:@[self.filterItem, showUUIDItem]];
    
    self.navigationItem.titleView = self.titleLabel;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.refreshRSSITimer) {
        self.refreshRSSITimer =
        [NSTimer scheduledTimerWithTimeInterval:0.5
                                         target:self
                                       selector:@selector(refreshRSSI)
                                       userInfo:nil
                                        repeats:YES];
    }
    
    if (!self.uiRefreshTimer) {
        self.uiRefreshTimer =
        [NSTimer scheduledTimerWithTimeInterval:0.5
                                         target:self
                                       selector:@selector(onUIRefreshTick)
                                       userInfo:nil
                                        repeats:YES];
    }
    
    [self.tableView.mj_header beginRefreshing];
    
    FBFilter *filter = self.bluetoothBrowser.filter;
    if (filter.filterByNameEnabled || filter.minimumRSSI > -100) {
        self.filterItem.title = LS(@"Filting");
    } else {
        self.filterItem.title = LS(@"Filter");
    }
    [self.bluetoothBrowser applyFilterSnapshotFromFilter:filter];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.bluetoothBrowser stopScanning];
    
    [self.refreshRSSITimer invalidate];
    self.refreshRSSITimer = nil;
    
    [self.uiRefreshTimer invalidate];
    self.uiRefreshTimer = nil;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)refreshRSSI {
    NSArray<FBPeripheralItem *> *items = self.peripheralItems;
    if (items.count == 0) return;
    for (NSNumber *secNum in [self visibleSections]) {
        NSInteger section = secNum.integerValue;
        if (section >= items.count) continue;
        
        FWBeaconSectionHeaderView *hv = (FWBeaconSectionHeaderView *)[self.tableView headerViewForSection:section];
        if ([hv isKindOfClass:[FWBeaconSectionHeaderView class]]) {
            [hv applyItem:items[section]];
        }
    }
}

- (NSArray<NSNumber *> *)visibleSections {
    NSArray<NSIndexPath *> *visible = [self.tableView indexPathsForVisibleRows];
    if (visible.count == 0) return @[];
    
    NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
    for (NSIndexPath *ip in visible) [set addIndex:ip.section];
    
    NSMutableArray<NSNumber *> *arr = [NSMutableArray array];
    [set enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [arr addObject:@(idx)];
    }];
    return arr;
}

- (void)onUIRefreshTick {
    if (!self.needsUIRefresh) return;
    self.needsUIRefresh = NO;
    
    self.peripheralItems = self.bluetoothBrowser.peripheralItems.copy;
    
    self.titleLabel.text =
    [NSString stringWithFormat:@"%@（%ld）", LS(@"Beacon"), (long)self.peripheralItems.count];
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.peripheralItems.count;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    FWBeaconSectionHeaderView *hv =
    [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"FWBeaconSectionHeaderView"];
    if (section < self.peripheralItems.count) {
        [hv applyItem:self.peripheralItems[section]];
    }
    return hv;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    FBPeripheralItem *peripheralItem = self.peripheralItems[section];
    return peripheralItem.beacons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FBPeripheralItem *item = self.peripheralItems[indexPath.section];
    BOOL isIBeacon = item.lastestBeacon.type == FBBeaconTypeIBeacon;
    if (YES == isIBeacon) {
        FBBeacon *ibeacon = item.beacons.firstObject;
        FWCentralIBeaconCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"FWCentralIBeaconCell" forIndexPath:indexPath];
        cell.iBeaconUUID.text = ibeacon.proximityUUID;
        cell.iBeaconMajor.text = [[NSString alloc] initWithFormat:@"%d", ibeacon.major];
        cell.iBeaconMinor.text = [[NSString alloc] initWithFormat:@"%d", ibeacon.minor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        NSArray<FBBeacon *> *displayBeacons = [self displayBeaconsForPeripheralItem:item];
        FBBeacon *beacon = displayBeacons[indexPath.row];
        FBBeaconType beaconType = beacon.type;
        
        if (beaconType == FBBeaconTypeURL) {
            FWCentralURLBeaconCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"FWCentralURLBeaconCell" forIndexPath:indexPath];
            cell.eddystonePower.text = [[NSString alloc] initWithFormat:@"%ld", beacon.calibratedTxPowerAt0m_url];
            [cell setupUrlPath:beacon.URLString];
            [cell.addressButton addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else if (beaconType == FBBeaconTypeUID) {
            FWCentralUIDBeaconCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"FWCentralUIDBeaconCell" forIndexPath:indexPath];
            cell.eddystoneUIDPower.text = [[NSString alloc] initWithFormat:@"%ld", beacon.calibratedTxPowerAt0m_uid];
            cell.nameSpace.text = beacon.namespaceString;
            cell.instance.text = beacon.instanceString;
            cell.reserved.text = beacon.reservedString;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else if (beaconType == FBBeaconTypeTLM) {
            FWCentralTLMBeaconCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"FWCentralTLMBeaconCell" forIndexPath:indexPath];
            cell.beaconImageView.image = [UIImage imageNamed:@"tlm"];
            cell.beaconNameLabel.text = @"Eddystone";
            cell.beaconFormatLabel.text = @"(TLM)";
            cell.beaconCodeLabel.text = @"<0x20>";
            cell.firstTitleLabel.text = @"Version:";
            cell.secondTitleLabel.text = @"Battery voltage:";
            cell.thirdTitleLabel.text = @"Temperature:";
            cell.fourthTitleLabel.text = @"Advertisements count:";
            cell.fifthTitleLabel.text = @"Time since power-up:";
            cell.secondUnitLabel.text = @"mV";
            cell.tlmVersionLabel.text = [[NSString alloc] initWithFormat:@"%ld", beacon.tlmVersion];
            if (beacon.beaconTemperature == -128) {
                cell.beaconTemperatureLabel.text = @"Not supported";
            } else {
                cell.beaconTemperatureLabel.text = [[NSString alloc] initWithFormat:@"%lf ˚C", beacon.beaconTemperature];
            }
            cell.batteryVoltageLabel.text = [[NSString alloc] initWithFormat:@"%ld", beacon.batteryVoltage];
            cell.advertisingPDUCountLabel.text = [[NSString alloc] initWithFormat:@"%ld", beacon.advertisingPDUCount];
            cell.timeSincePowerOnOrRebootLabel.text = [self convertSecondsToDHMS:beacon.timeSincePowerOnOrReboot];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else if (beaconType == FBBeaconTypeAltBeacon) {
            FWCentralAltBeaconCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"FWCentralAltBeaconCell" forIndexPath:indexPath];
            cell.mfgID.text = [[NSString alloc] initWithFormat:@"<0x%@>", beacon.manufacturerID];
            cell.altID.text = beacon.IDString;
            cell.altPower.text = [[NSString alloc] initWithFormat:@"%ld", beacon.calibratedTxPowerAt1m_alt];
            cell.altReserved.text = beacon.manufacturerReservedString;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else if (beaconType == FBBeaconTypeAoA) {
            FWCentralAoABeaconCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"FWCentralAoABeaconCell" forIndexPath:indexPath];
            cell.beaconIconView.image = [UIImage imageNamed:@"beacon_aoa"];
            cell.beaconInfoLabel.text = [NSString stringWithFormat:
                                         @"AOABeacon\n"
                                         @"Company ID: 0x%04x\n"
                                         @"Sub Type: 0x%02x\n"
                                         @"CTE Info: 0x%02x\n"
                                         @"Beacon ID: %08x\n"
                                         @"Beacon Type: 0x%02x\n"
                                         @"Battery: %u%%",
                                         (unsigned int)beacon.aoaCompanyID,
                                         (unsigned int)beacon.aoaSubType,
                                         (unsigned int)beacon.aoaCTEInfo,
                                         (unsigned int)beacon.aoaBeaconID,
                                         (unsigned int)beacon.aoaBeaconType,
                                         (unsigned int)beacon.aoaBatteryLevel];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else {
            static NSString * const UnknownBeaconCellIdentifier = @"FWCentralUnknownBeaconCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UnknownBeaconCellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:UnknownBeaconCellIdentifier];
            }
            cell.textLabel.text = [NSString stringWithFormat:@"Unknown Beacon (type: %ld)", (long)beaconType];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    FBPeripheralItem *item = self.peripheralItems[indexPath.section];
    NSArray<FBBeacon *> *displayBeacons = [self displayBeaconsForPeripheralItem:item];
    FBBeacon *beacon = displayBeacons[indexPath.row];
    const FBBeaconType beaconType = beacon.type;
    if (FBBeaconTypeUID == beaconType) {
        return 115;
    } else if (FBBeaconTypeAltBeacon == beaconType) {
        return 157;
    } else if (FBBeaconTypeIBeacon == beaconType) {
        return 95;
    } else if (FBBeaconTypeURL == beaconType) {
        return 75;
    } else if (FBBeaconTypeTLM == beaconType) {
        return 140;
    } else if (FBBeaconTypeAoA == beaconType) {
        return 145;
    } else if(item.modelIndex == 78){
        return 110;
    }
    return 44;
}

#pragma mark - FBBluetoothBrowserDelegate

- (void)bluetoothBrowser:(FBBluetoothBrowser *)bluetoothBrowser didAddPeripheralItem:(FBPeripheralItem *)peripheralItem {
    self.needsUIRefresh = YES;
}

- (void)bluetoothBrowserDidUpdatePeripheralItems:(FBBluetoothBrowser *)bluetoothBrowser {
    self.needsUIRefresh = YES;
}

- (void)bluetoothBrowserDidChangeState:(FBBluetoothBrowser *)bluetoothBrowser {
    const CBManagerState state = self.bluetoothBrowser.state;
    if (state == CBManagerStateUnknown || state == CBManagerStatePoweredOn) {
        [self.tableView.mj_header beginRefreshing];
    }
}

- (BOOL)bluetoothBrowser:(FBBluetoothBrowser *)bluetoothBrowser shouldAddPeripheralItem:(FBPeripheralItem *)peripheralItem {
    if (peripheralItem.lastestBeacon.type == FBBeaconTypeIBeacon) {
        return YES;
    }
    return YES;
}

- (void)bluetoothBrowser:(FBBluetoothBrowser *)bluetoothBrowser didUpdatePeripheralItemName:(FBPeripheralItem *)peripheralItem {
    
}

- (void)bluetoothBrowser:(FBBluetoothBrowser *)bluetoothBrowser didUpdatePeripheralItemAdvertisingName:(FBPeripheralItem *)peripheralItem {
    self.needsUIRefresh = YES;
}

- (void)bluetoothBrowser:(FBBluetoothBrowser *)bluetoothBrowser didUpdatePeripheralItemRSSI:(FBPeripheralItem *)peripheralItem {
    self.needsUIRefresh = YES;
}

- (void)click:(UIButton *)sender {
    NSURL *url = [NSURL URLWithString:sender.titleLabel.text];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            NSLog(@"openURL result: %d", success);
        }];
    }
}

- (void)didReceiveMemoryWarning { 
    [super didReceiveMemoryWarning];
}

- (void)sortButtonPressed {
    [self.bluetoothBrowser sortByRSSI];
}

- (void)filterButtonPressed {
    FWFilterViewController *viewController = [[FWFilterViewController alloc] initWithFilter:self.bluetoothBrowser.filter];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)showUUIDItemAction {
    FBBeaconUUIDConfigVC *viewController = [[FBBeaconUUIDConfigVC alloc] init];
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)broadcastItemAction {
    FBBeaconBroadcastVC *viewController = [[FBBeaconBroadcastVC alloc] init];
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (NSString *)convertSecondsToDHMS:(NSInteger)seconds {
    NSInteger totalSeconds = seconds / 10;
    NSInteger milliseconds = seconds % 10 * 100;
    NSInteger days = totalSeconds / 86400;
    totalSeconds = totalSeconds % 86400;
    NSInteger hours = totalSeconds / 3600;
    totalSeconds = totalSeconds % 3600;
    NSInteger minutes = totalSeconds / 60;
    totalSeconds = totalSeconds % 60;
    
    return [NSString stringWithFormat:@"%ld days + %02ld:%02ld:%02ld.%ld", days, (long)hours, minutes, totalSeconds, milliseconds];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.lineBreakMode = NSLineBreakByClipping;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.minimumScaleFactor = 0.5; 
        _titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        
        CGFloat screenW = UIScreen.mainScreen.bounds.size.width;
        CGFloat maxW = screenW - 140;
        _titleLabel.frame = CGRectMake(0, 0, MAX(80, maxW), 44); 
    }
    return _titleLabel;
}

@end
