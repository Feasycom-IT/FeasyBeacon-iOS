//
//  FWSettingsViewController.m
//  FeasyBeacon
//
//  Created by LIDONG on 14-2-28.
//  Copyright (c) 2014年 LIDONG. All rights reserved.
//

#import "FWSettingsViewController.h"
#import "FWParametersViewController.h"
#import "FWFilterViewController.h"
#import "MJRefresh.h"
#import "FBPeripheralCell.h"
#import "UIViewController+Extension.h"
#import "NSString+FscKit.h"
#import "FBSDKPublicHeader.h"
#import "FBQRCodeScannerVC.h"
#import "Parameters.h"
#import "FBUserDefaultCache.h"

@interface FWSettingsViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, FBBluetoothBrowserDelegate, QRCodeScannerViewControllerDelegate>

@property (nonatomic, strong) FBBluetoothBrowser *bluetoothBrowser;
@property (nonatomic, strong) NSArray<FBPeripheralItem *> *peripheralItems;
@property (nonatomic, strong) NSTimer *refreshRSSITimer;
@property (nonatomic, strong) UIBarButtonItem *filterItem;
@property (nonatomic, strong) NSTimer *uiRefreshTimer;
@property (atomic, assign) BOOL needsUIRefresh;

@end

@implementation FWSettingsViewController

- (id)init {
    if (self = [super init]) {
        self.bluetoothBrowser = [[FBBluetoothBrowser alloc] initWithType:FBBluetoothBrowserTypeSetting];
        [self.bluetoothBrowser setDelegate:self];
        self.bluetoothBrowser.isPrintLog = [FBUserDefaultCache getIsUseScanLog];
        [self setupTabBarView];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.bluetoothBrowser.isPrintLog = [FBUserDefaultCache getIsUseScanLog];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.refreshRSSITimer) {
        self.refreshRSSITimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(refreshRSSI) userInfo:nil repeats:YES];
    }
    [self.tableView.mj_header beginRefreshing];
    
    self.uiRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                           target:self
                                                         selector:@selector(onUIRefreshTick)
                                                         userInfo:nil
                                                          repeats:YES];
    
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
    [self.uiRefreshTimer invalidate];
    self.uiRefreshTimer = nil;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.bluetoothBrowser stopScanning];
    if (self.refreshRSSITimer) {
        [self.refreshRSSITimer invalidate];
        self.refreshRSSITimer = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FBPeripheralCell" bundle:nil]
         forCellReuseIdentifier:@"FBPeripheralCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 60;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    __weak __typeof(self) weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.peripheralItems = @[];
        [strongSelf.tableView reloadData];
        [strongSelf.bluetoothBrowser startScanning];
        [strongSelf.tableView.mj_header endRefreshing];
    }];
}

- (void)setupTabBarView {
    UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:LS(@"Setting") image:[UIImage imageNamed:@"设置"] tag:2];
    [self setTabBarItem:tabBarItem];
}

- (void)setupNavigationView {
    self.title = LS(@"Setting");
    
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
    
    UIBarButtonItem *sortItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Sort") style:UIBarButtonItemStylePlain target:self action:@selector(sortButtonPressed)];
    UIImage *image = [UIImage imageNamed:@"扫描"];
    CGSize newSize = CGSizeMake(40, 40);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIBarButtonItem *scanItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(scanButtonPressed)];
    [self.navigationItem setLeftBarButtonItems:@[sortItem, scanItem]];

    self.filterItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Filter") style:UIBarButtonItemStylePlain target:self action:@selector(filterButtonPressed)];
    [self.navigationItem setRightBarButtonItem:self.filterItem];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    return UIModalPresentationNone;
}

- (void)refreshRSSI {
    NSArray<FBPeripheralItem *> *periphralItems = self.peripheralItems;
    const NSInteger count = periphralItems.count;
    
    for (NSInteger i = 0; i < count; i++) {
        FBPeripheralCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [cell refreshRSSI:[periphralItems[i] RSSI]];
        cell.intervalLabel.text = [NSString stringWithFormat:@"<->%.0lfms", periphralItems[i].advertisementRate];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.peripheralItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FBPeripheralItem *item = self.peripheralItems[indexPath.row];
    
    FBPeripheralCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FBPeripheralCell" forIndexPath:indexPath];
    cell.nameLabel.text = [NSString stringWithFormat:@"%@-%@",item.displayedName,item.nameSuffix];
    cell.macAddressLabel.text = item.macAddress;
    [cell.ElectricityImageView setImage:[UIImage imageNamed:[self getElectricityInfo:(NSInteger)item.quantityOfElectricity]]];
    cell.electricityLabel.text = [NSString stringWithFormat:@"%d%%", item.quantityOfElectricity];
    cell.intervalLabel.text = [NSString stringWithFormat:@"<->%.0lfms", item.advertisementRate];
    cell.rssiLabel.text = [NSString stringWithFormat:@"%ld", (long)(NSInteger)item.RSSI];
    [cell.rssiProgress setProgress:(100+(NSInteger)item.RSSI)/100.0 animated:NO];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self selectItem:indexPath.row];
}

- (void)selectItem:(NSInteger)row {
    FBPeripheralItem *item = self.peripheralItems[row];
    
    if (item.hasPINCode) {
        NSString *deviceInfo = [NSString stringWithFormat:@"\n%@\n%@", item.displayedName, item.macAddress];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LS(@"Please input PIN code") message:deviceInfo preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.delegate = self;
            textField.placeholder = LS(@"Please input six PIN code");
        }];
        
        __weak __typeof(self) weakSelf = self;
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LS(@"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertController addAction:cancelAction];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:LS(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField *textField = alertController.textFields[0];
            [textField resignFirstResponder];
            [weakSelf gotoParameterViewControllerWithPINCode:textField.text peripheralItem:item];
        }];
        [alertController addAction:okAction];
        
        [self.tabBarController presentViewController:alertController animated:YES completion:NULL];
    } else {
        FWParametersViewController *viewController = [[FWParametersViewController alloc] initWithPeripheralItem:item PINCode:nil];
        viewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)gotoParameterViewControllerWithPINCode:(NSString *)PINCode peripheralItem:(FBPeripheralItem *)peripheralItem {
    if (PINCode.length != 6) {
        [self showAlertControllerWithTitle:LS(@"PIN_CODE_LENGTH_ERROR")];
        return;
    }
    
    if (![PINCode isDigits]) {
        [self showAlertControllerWithTitle:LS(@"PIN_CODE_CHARACTER_ERROR")];
        return;
    }
    
    [self.bluetoothBrowser stopScanning];
    FWParametersViewController *viewController = [[FWParametersViewController alloc] initWithPeripheralItem:peripheralItem PINCode:PINCode];
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - FBBluetoothBrowserDelegate

- (void)bluetoothBrowserDidChangeState:(FBBluetoothBrowser *)bluetoothBrowser {
    const CBManagerState state = self.bluetoothBrowser.state;
    if (state == CBManagerStateUnknown || state == CBManagerStatePoweredOn) {
        [self.tableView.mj_header beginRefreshing];
    }
    Parameters *parameters = Parameters.instance;
    parameters.centralManager = bluetoothBrowser.centralManager;
}

- (BOOL)bluetoothBrowser:(FBBluetoothBrowser *)bluetoothBrowser shouldAddPeripheralItem:(FBPeripheralItem *)peripheralItem {
    Parameters *parameters = Parameters.instance;
    parameters.centralManager = bluetoothBrowser.centralManager;
    
    /* fix bug：beacon设备刚上电时有可能出现mac地址显示为0的情况 */
    if ([peripheralItem.macAddress isEqualToString:@"00:00:00:00:00:00"]) {
        return NO;
    }
    return YES;
}

- (void)bluetoothBrowser:(FBBluetoothBrowser *)bluetoothBrowser didAddPeripheralItem:(FBPeripheralItem *)peripheralItem {
    self.needsUIRefresh = YES;
}

- (void)bluetoothBrowserDidUpdatePeripheralItems:(FBBluetoothBrowser *)bluetoothBrowser {
    self.needsUIRefresh = YES;
}

- (void)bluetoothBrowser:(FBBluetoothBrowser *)bluetoothBrowser didUpdatePeripheralItemAdvertisingName:(FBPeripheralItem *)peripheralItem {
    self.needsUIRefresh = YES;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (![newText isDigits]) {
        return NO;
    }
    return (newText.length <= 6);
}

- (NSString *)getElectricityInfo:(NSInteger)number {
    if (number == 0) {
        return @"百分比电量0";
    } else if (number > 0 && number <= 10) {
        return @"百分比电量10";
    } else if (number > 10 && number <= 20) {
        return @"百分比电量20";
    } else if (number > 20 && number <= 30) {
        return @"百分比电量30";
    } else if (number > 30 && number <= 40) {
        return @"百分比电量40";
    } else if (number > 40 && number <= 50) {
        return @"百分比电量50";
    } else if (number > 50 && number <= 60) {
        return @"百分比电量60";
    } else if (number > 60 && number <= 70) {
        return @"百分比电量70";
    } else if (number > 70 && number <= 80) {
        return @"百分比电量80";
    } else if (number > 80 && number <= 90) {
        return @"百分比电量90";
    } else if (number > 90 && number <= 100) {
        return @"百分比电量100";
    } else {
        return @"百分比电量充电";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)sortButtonPressed {
    [self.bluetoothBrowser sortByRSSI];
}

- (void)scanButtonPressed {
    FBQRCodeScannerVC *scannerVC = [[FBQRCodeScannerVC alloc] init];
    scannerVC.delegate = self;
    [self presentViewController:scannerVC animated:YES completion:nil];
}

- (void)filterButtonPressed {
    FWFilterViewController *viewController = [[FWFilterViewController alloc] initWithFilter:self.bluetoothBrowser.filter];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)onUIRefreshTick {
    if (!self.needsUIRefresh) return;
    self.needsUIRefresh = NO;
    self.peripheralItems = self.bluetoothBrowser.peripheralItems.copy;
    self.navigationItem.title = [NSString stringWithFormat:@"%@（%ld）", LS(@"Setting"), self.peripheralItems.count];
    [self.tableView reloadData];
}

#pragma mark - QRCodeScannerViewControllerDelegate

- (void)didScanQRCodeWithContent:(NSString *)content {
    NSLog(@"Scanned QR Code Content: %@", content);
    NSString *macContent = [self formattedMACAddress:content];
    NSLog(@"macContent: %@", macContent);
    NSMutableArray *peripherals = self.peripheralItems.mutableCopy;
    NSLog(@"peripherals: %@", peripherals);
    for (int i = 0; i < peripherals.count; i++) {
        FBPeripheralItem *peripheralItem = peripherals[i];
        NSString *mac = peripheralItem.macAddress;
        NSLog(@"mac = %@", mac);
        if ([macContent isEqualToString:mac]) {
            NSLog(@"mac = macContent");
            [self selectItem:i];
        } else if (i == peripherals.count -1) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"未检索/识别到该设备，请靠近设备后重试" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

- (NSString *)formattedMACAddress:(NSString *)mac {
    if (mac.length != 12) {
        return nil;
    }
    NSMutableString *formattedString = [NSMutableString stringWithString:mac];
    [formattedString insertString:@":" atIndex:2];
    [formattedString insertString:@":" atIndex:5];
    [formattedString insertString:@":" atIndex:8];
    [formattedString insertString:@":" atIndex:11];
    [formattedString insertString:@":" atIndex:14];
    
    return formattedString;
}

@end

