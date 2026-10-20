//
//  FWAddBeaconViewController.m
//  FeasyBeacon
//
//  Created by ericj on 2017/10/19.
//  Copyright © 2017年 LIDONG. All rights reserved.
//

#import "FWAddBeaconViewController.h"
#import "FWConfigureSwitchCell.h"
#import "FWConfigureValueSetCell.h"
#import "NSString+FscKit.h"
#import "FWConfigurePhyCell.h"
#import "FWPopoverViewController.h"
#import "FWConfigurePowerCell.h"
#import "FESettingBeaconModel.h"
#import "FEBeaconTitleInfoDetail.h"

#define TAG_SADV_INTERVAL 12
#define TAG_SADV_TIMEOUT 13

@interface TitleItem : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray<FEBeaconTitleInfoDetail *> *contents;
@property (nonatomic) FBBeaconType beaconType;

+ (instancetype)name:(NSString *)name contents:(NSArray<FEBeaconTitleInfoDetail *> *)contents beaconType:(FBBeaconType)beaconType isNormal:(BOOL)isNormal;
@end

@implementation TitleItem

- (instancetype)initWithName:(NSString *)name contents:(NSArray<FEBeaconTitleInfoDetail *> *)contents beaconType:(FBBeaconType)beaconType isNormal:(BOOL)isNormal{
    if (self = [super init]) {
        _name = [name copy];
        NSMutableArray<FEBeaconTitleInfoDetail *> *array = [contents mutableCopy];
        if (isNormal) {
            [array addObjectsFromArray:@[[FEBeaconTitleInfoDetail title:@"Enable:" placeholder:@""]]] ;
        } else {
            [array addObjectsFromArray:@[[FEBeaconTitleInfoDetail title:@"Sensor:" placeholder:@""],
                                         [FEBeaconTitleInfoDetail title:@"Action:" placeholder:@""],
                                         [FEBeaconTitleInfoDetail title:@"Internal(ms):" placeholder:[FESettingBeaconModel placeholder_Internal] keyboardType:UIKeyboardTypeNumberPad],
                                         [FEBeaconTitleInfoDetail title:@"Timeout(ms):" placeholder:[FESettingBeaconModel placeholder_Timeout] keyboardType:UIKeyboardTypeNumberPad],
                                         [FEBeaconTitleInfoDetail title:@"Enable:" placeholder:@""]]];
        }
        _contents = array;
        _beaconType = beaconType;
    }
    return self;
}

+ (instancetype)name:(NSString *)name contents:(NSArray<FEBeaconTitleInfoDetail *> *)contents beaconType:(FBBeaconType)beaconType isNormal:(BOOL)isNormal{
    return [[self alloc] initWithName:name contents:contents beaconType:beaconType isNormal:isNormal];
}

@end

@interface FWAddBeaconViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, UIScrollViewDelegate> {
    UITableView *_tableView;
    UITextField *_textFields[10];
    UILabel *_beaconTypeLabel;
    UISwitch *_switchControl;
    UIViewController *_popupViewController;
    NSMutableArray<TitleItem *> *_titles;
    
    FBBeaconType _beaconType;
    
    NSInteger _modelIndex;
    NSArray *_configTxPowers;
    
    // Condition
    NSArray *_sensors;
    NSArray *_keyActions;
    NSArray *_gsensorActions;
    NSString *_sensor;
    NSString *_action;
    int _sadvInternal;
    int _sadvTimeout;
    
    int _iPhy;
    NSString *_txPower;
    AddType _addType;
    
    // 记录位置
    NSIndexPath *_sensorIndexPath;
    NSIndexPath *_actionIndexPath;
}
@end

@implementation FWAddBeaconViewController

- (instancetype)initWithAddType:(AddType)addType item:(FBPeripheralItem *)item{
    if (self = [super init]) {
        _addType = addType;
        UIBarButtonItem *finishItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Finish") style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonPressed:)];
        
        self.navigationItem.rightBarButtonItem = finishItem;
        NSMutableArray *ms = [NSMutableArray array];
        if (item && item.hasKey) {
            [ms addObject:@"Key"];
        }
        if (item && item.hasGsensor) {
            [ms addObject:@"G-Sensor"];
        }
        _sensors = ms;
        _keyActions = @[@"Click On",@"Click Off"];
        _gsensorActions = @[@"Motion"];
        BOOL isNormal = addType == AddType_Beacon;
        
        _titles = [NSMutableArray array];
        
        [_titles addObject:[TitleItem name:@"iBeacon"
                                  contents:[FESettingBeaconModel iBeaconListWithTxPower:NO] beaconType:FBBeaconTypeIBeacon isNormal:isNormal]];
        [_titles addObject:[TitleItem name:@"URL"
                                  contents:[FESettingBeaconModel urlListWithTxPower:NO] beaconType:FBBeaconTypeURL isNormal:isNormal]];
        [_titles addObject:[TitleItem name:@"UID"
                                  contents:[FESettingBeaconModel uidListWithTxPower:NO] beaconType:FBBeaconTypeUID isNormal:isNormal]];
        [_titles addObject:[TitleItem name:@"AltBeacon"
                                  contents:[FESettingBeaconModel altBeaconListWithTxPower:NO] beaconType:FBBeaconTypeAltBeacon isNormal:isNormal]];
        [_titles addObject:[TitleItem name:@""
                                  contents:@[] beaconType:FBBeaconTypeTLM isNormal:isNormal]];
        if (!isNormal) {
            // 可编程按键的有自定义广播
            [_titles addObject:[TitleItem name:@"Custom"
                                      contents:[FESettingBeaconModel customListWithTxPower:NO] beaconType:FBBeaconTypeUnknown isNormal:isNormal]];
        }
    }
    return self;
}

- (instancetype)initWithModelIndex:(NSInteger) modelIndex configTxPowers:(NSArray *)txPowers addType:(AddType)addType{
    if (self = [super init]) {
        _addType = addType;
        UIBarButtonItem *finishItem = [[UIBarButtonItem alloc]initWithTitle:LS(@"Finish") style:UIBarButtonItemStylePlain target:self action:@selector((saveButtonPressed:))];
        self.navigationItem.rightBarButtonItem = finishItem;
        _titles = [[NSMutableArray alloc]initWithCapacity:7];
        _modelIndex = modelIndex;
        _configTxPowers = txPowers;
        _txPower = txPowers[0];
        BOOL isNormal = addType == AddType_Beacon;
        if (78 == modelIndex || 91 == modelIndex || 98 == modelIndex) {
            _titles = [NSMutableArray array];
            [_titles addObject:[TitleItem name:@"iBeacon"
                                      contents:[FESettingBeaconModel iBeaconListWithTxPower:YES] beaconType:FBBeaconTypeIBeacon isNormal:isNormal]];
            [_titles addObject:[TitleItem name:@"URL"
                                      contents:[FESettingBeaconModel urlListWithTxPower:YES] beaconType:FBBeaconTypeURL isNormal:isNormal]];
            [_titles addObject:[TitleItem name:@"UID"
                                      contents:[FESettingBeaconModel uidListWithTxPower:YES] beaconType:FBBeaconTypeUID isNormal:isNormal]];
            [_titles addObject:[TitleItem name:@"AltBeacon"
                                      contents:[FESettingBeaconModel altBeaconListWithTxPower:YES] beaconType:FBBeaconTypeAltBeacon isNormal:isNormal]];
            [_titles addObject:[TitleItem name:@""
                                      contents:@[] beaconType:FBBeaconTypeTLM isNormal:isNormal]];
            [_titles addObject:[TitleItem name:@"Custom"
                                      contents:[FESettingBeaconModel customListWithTxPower:YES] beaconType:FBBeaconTypeUnknown isNormal:isNormal]];
        } else {
            _titles = [NSMutableArray array];
            [_titles addObject:[TitleItem name:@"iBeacon"
                                      contents:[FESettingBeaconModel iBeaconListWithTxPower:NO] beaconType:FBBeaconTypeIBeacon isNormal:isNormal]];
            [_titles addObject:[TitleItem name:@"URL"
                                      contents:[FESettingBeaconModel urlListWithTxPower:NO] beaconType:FBBeaconTypeURL isNormal:isNormal]];
            [_titles addObject:[TitleItem name:@"UID"
                                      contents:[FESettingBeaconModel uidListWithTxPower:NO] beaconType:FBBeaconTypeUID isNormal:isNormal]];
            [_titles addObject:[TitleItem name:@"AltBeacon"
                                      contents:[FESettingBeaconModel altBeaconListWithTxPower:NO] beaconType:FBBeaconTypeAltBeacon isNormal:isNormal]];
            [_titles addObject:[TitleItem name:@""
                                      contents:@[] beaconType:FBBeaconTypeTLM isNormal:isNormal]];
            [_titles addObject:[TitleItem name:@"Custom"
                                      contents:[FESettingBeaconModel customListWithTxPower:NO] beaconType:FBBeaconTypeUnknown isNormal:isNormal]];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 广播类型的选择
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1];
    [self.view addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(44);
    }];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 44)];
    switch (_addType) {
        case AddType_Beacon:
            titleLabel.text = LS(@"Broadcast Type");
            break;
        case AddType_Condition:
            titleLabel.text = LS(@"Broadcast Type");
            break;
        default:
            break;
    }
    
    [headerView addSubview:titleLabel];
    
    _beaconTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreen_Width - 124), 0, 80, 44)];
    [headerView addSubview:_beaconTypeLabel];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width-44, 0, 44, 44)];
    [button setImage:[UIImage imageNamed:@"bottom-1"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showPopupViewController:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:button];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.allowsSelection = NO;
    _tableView.rowHeight = 44;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(headerView.mas_bottom).offset(0);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

// 提取有name的数据
- (NSArray<TitleItem *> *)haveNameFromTitles {
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < _titles.count; i++) {
        TitleItem *item = _titles[i];
        if (item.name.length > 0){
            [array addObject:item];
        }
    }
    return array;
}

// 提取内容数据
- (NSArray<FEBeaconTitleInfoDetail *> *)contentFromBeaconType:(FBBeaconType)beaconType {
    for (int i = 0; i < _titles.count; i++) {
        TitleItem *item = _titles[i];
        if (beaconType == item.beaconType){
            return item.contents;
        }
    }
    return @[];
}

// 提取内容数据
- (TitleItem *)itemFromBeaconType:(FBBeaconType)beaconType {
    for (int i = 0; i < _titles.count; i++) {
        TitleItem *item = _titles[i];
        if (beaconType == item.beaconType){
            return item;
        }
    }
    return nil;
}

- (void)saveButtonPressed:(UIBarButtonItem *)sender {
    if (_completionHandler) {
        FBMutableBeacon *beacon = [[FBMutableBeacon alloc] init];
        int iCurrentTextField = 0;
        beacon.isSadv = _addType == AddType_Condition;
        beacon.type = _beaconType;
        beacon.enabled = _switchControl.isOn;
        if (FBBeaconTypeIBeacon == _beaconType) {
            beacon.proximityUUID = [_textFields[iCurrentTextField++] text];
            if (beacon.proximityUUID.length != 32) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
            beacon.major = [[_textFields[iCurrentTextField++] text] intValue];
            if (beacon.major < 0 || beacon.major > 65535) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
            beacon.minor = [[_textFields[iCurrentTextField++] text] intValue];
            if (beacon.minor < 0 || beacon.minor > 65535) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
            beacon.calibratedTxPowerAt1m_iBeacon = [[_textFields[iCurrentTextField++] text] intValue];
            if (beacon.calibratedTxPowerAt1m_iBeacon < -128 || beacon.calibratedTxPowerAt1m_iBeacon > 127) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
        } else if (FBBeaconTypeURL == _beaconType) {
            beacon.URLString = [_textFields[iCurrentTextField++] text];
            if (![FESettingBeaconModel isValidEddystoneURL:beacon.URLString]) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
            beacon.calibratedTxPowerAt0m_url = [[_textFields[iCurrentTextField++] text] intValue];
            if (beacon.calibratedTxPowerAt0m_url < -128 || beacon.calibratedTxPowerAt0m_url > 127) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
        } else if (FBBeaconTypeUID == _beaconType) {
            beacon.namespaceString = [_textFields[iCurrentTextField++] text];
            if (beacon.namespaceString.length != 20) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
            beacon.instanceString = [_textFields[iCurrentTextField++] text];
            if (beacon.instanceString.length != 12) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
            beacon.reservedString = [_textFields[iCurrentTextField++] text];
            if (beacon.reservedString.length != 4) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
            beacon.calibratedTxPowerAt0m_uid = [[_textFields[iCurrentTextField++] text] intValue];
            if (beacon.calibratedTxPowerAt0m_uid < -128 || beacon.calibratedTxPowerAt0m_uid > 127) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
        } else if (FBBeaconTypeAltBeacon == _beaconType) {
            beacon.IDString1 = [_textFields[iCurrentTextField++] text];
            if (beacon.IDString1.length != 32) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
            beacon.IDString2 = [_textFields[iCurrentTextField++] text];
            if (beacon.IDString2.length != 4) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
            beacon.IDString3 = [_textFields[iCurrentTextField++] text];
            if (beacon.IDString3.length != 4) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
            beacon.calibratedTxPowerAt1m_alt = [[_textFields[iCurrentTextField++] text] intValue];
            if (beacon.calibratedTxPowerAt1m_alt < -128 || beacon.calibratedTxPowerAt1m_alt > 127) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
            beacon.manufacturerID = [[_textFields[iCurrentTextField++] text] intValue];
            if (beacon.manufacturerID < 0 || beacon.manufacturerID > 65535) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
            beacon.manufacturerReservedString = [_textFields[iCurrentTextField++] text];
            if (beacon.manufacturerReservedString.length != 2) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.")];
                return;
            }
        } else if (FBBeaconTypeUnknown == _beaconType) {
            // 固定开头0201
            beacon.rawDataHex = [_textFields[0] text];
            if (beacon.rawDataHex.length == 0 || [FESettingBeaconModel validCustomData:beacon.rawDataHex]) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.") message:@"Data"];
                return;
            }
        } else {
            return;
        }
        // 如果是Condition
        if (beacon.isSadv) {
            beacon.sadv_sensor = (int)[_sensors indexOfObject:_sensor];
            if ([_sensor isEqualToString:@"Key"]) {
                beacon.sadv_action = (int)[_keyActions indexOfObject:_action];
            }else if ([_sensor isEqualToString:@"G-Sensor"]){
                beacon.sadv_action = (int)[_gsensorActions indexOfObject:_action];
            }
            if (_sadvInternal < 20 || _sadvInternal > 10000) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.") message:@"Internal"];
                return;
            }
            if (_sadvTimeout < 100 || _sadvTimeout > 65535) {
                [self showAlertControllerWithTitle:LS(@"Illegal parameter, please re-enter.") message:@"Timeout"];
                return;
            }
            beacon.sadv_interval = _sadvInternal;
            beacon.sadv_timeout = _sadvTimeout;
        }
        if(78 == _modelIndex || 91 == _modelIndex || 98 == _modelIndex) {
            beacon.iInterval = [[_textFields[iCurrentTextField++] text] intValue];
            beacon.txPower = _txPower;
            beacon.iPhy = _iPhy;
            beacon.numberOfParameters += 3;
        }
        _completionHandler(beacon);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showPopupViewController:(UIButton *)sender {
    if (nil == _popupViewController) {
        _popupViewController = [UIViewController new];
        NSArray<TitleItem *> *types = [self haveNameFromTitles];
        const CGSize size = { 120, types.count * 50 };
        
        _popupViewController.modalPresentationStyle = UIModalPresentationPopover;
        _popupViewController.preferredContentSize = size;
        
        UIView *view = _popupViewController.view;
        const CGFloat buttonHeight = size.height / types.count;
        
        for (NSInteger i = 0; i < types.count; i ++) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 13 + buttonHeight * i, size.width, buttonHeight)];
            
            [button setTag:(types[i].beaconType)];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setTitle:types[i].name forState:UIControlStateNormal];
            [button addTarget:self action:@selector(selectType:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:button];
        }
    }
    
    UIPopoverPresentationController *presentationController = _popupViewController.popoverPresentationController;
    
    presentationController.sourceView = sender;
    presentationController.sourceRect = sender.bounds;
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    presentationController.delegate = self;
    
    [self presentViewController:_popupViewController animated:YES completion:nil];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    return UIModalPresentationNone; //不适配
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController{
    return YES;   //点击蒙版popover消失， 默认YES
}


// 选择类型
- (void)selectType:(UIButton *)sender {
    _beaconType = (FBBeaconType)sender.tag;
    _beaconTypeLabel.text = sender.titleLabel.text;
    
    [_popupViewController dismissViewControllerAnimated:YES completion:nil];
    _popupViewController = nil;
    for (int i=0; i<10; i++) {
        _textFields[i].text = nil;
    }
    [_tableView reloadData];
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
}

//输入检测
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (newText.length == 0) {
        return YES;
    }
    FWConfigureValueSetCell *cell = (FWConfigureValueSetCell *)[[textField superview] superview];
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    const NSInteger row = indexPath.row;
    
    if (FBBeaconTypeIBeacon == _beaconType) {
        if (0 == row) {
            return [FESettingBeaconModel dealwith_UUID_TextField:textField newText:newText];
        } else if (1 == row) { // major -> 0 ~ 65535
            return [FESettingBeaconModel dealwith_Major_TextField:textField newText:newText];
        } else if (2 == row) { // minor -> 0 ~ 65535
            return [FESettingBeaconModel dealwith_Minor_TextField:textField newText:newText];
        } else if (3 == row) {
            return [FESettingBeaconModel dealwith_RSSI_TextField:textField newText:newText inputString:string];
        } else if (4 == row && (_modelIndex == 78 || _modelIndex == 91 || _modelIndex == 98)) {
            if (![newText isUnsignedDigits]) {
                cell.inputTextField.textColor = [UIColor redColor];
                return  NO;
            }
            const int newValue = [newText intValue];
            if (100 <= newValue && newValue <= 10000) {
                cell.inputTextField.textColor = [UIColor darkGrayColor];
            } else {
                cell.inputTextField.textColor = [UIColor redColor];
            }
            return newValue <= 100000;
        }
    } else if (FBBeaconTypeURL == _beaconType) {
        if (0 == row) {
            return [FESettingBeaconModel dealwith_URL_TextField:textField newText:newText inputString:string];
        } else if (1 == row) {
            return [FESettingBeaconModel dealwith_RSSI_TextField:textField newText:newText inputString:string];
        } else if (2 == row && (_modelIndex == 78 || _modelIndex == 91 || _modelIndex == 98)) {
            if (![newText isUnsignedDigits]) {
                cell.inputTextField.textColor = [UIColor redColor];
                return  NO;
            }
            const int newValue = [newText intValue];
            if (100 <= newValue && newValue <= 10000) {
                cell.inputTextField.textColor = [UIColor darkGrayColor];
            } else {
                cell.inputTextField.textColor = [UIColor redColor];
            }
            return newValue <= 100000;
        }
    } else if (FBBeaconTypeUID == _beaconType) {
        if (0 == row) {
            return [FESettingBeaconModel dealwith_Namespace_TextField:textField newText:newText];
        } else if (1 == row) {
            return [FESettingBeaconModel dealwith_Instance_TextField:textField newText:newText];
        } else if (2 == row) {
            return [FESettingBeaconModel dealwith_Reserved_TextField:textField newText:newText];
        } else if (3 == row) {
            return [FESettingBeaconModel dealwith_RSSI_TextField:textField newText:newText inputString:string];
        } else if (4 == row && (_modelIndex == 78 || _modelIndex == 91 || _modelIndex == 98)) {
            if (![newText isUnsignedDigits]) {
                cell.inputTextField.textColor = [UIColor redColor];
                return  NO;
            }
            const int newValue = [newText intValue];
            if (100 <= newValue && newValue <= 10000) {
                cell.inputTextField.textColor = [UIColor darkGrayColor];
            } else {
                cell.inputTextField.textColor = [UIColor redColor];
            }
            return newValue <= 100000;
        }
    } else if (FBBeaconTypeAltBeacon == _beaconType) {
        if (0 == row) {
            return [FESettingBeaconModel dealwith_ID1_TextField:textField newText:newText];
        } else if (1 == row) {
            return [FESettingBeaconModel dealwith_ID2_TextField:textField newText:newText];
        } else if (2 == row) {
            return [FESettingBeaconModel dealwith_ID3_TextField:textField newText:newText];
        } else if (3 == row) {
            return [FESettingBeaconModel dealwith_RSSI_TextField:textField newText:newText inputString:string];
        } else if (4 == row) {
            return [FESettingBeaconModel dealwith_ManufacturerID_TextField:textField newText:newText];
        } else if (5 == row) {
            return [FESettingBeaconModel dealwith_ManufacturerReserved_TextField:textField newText:newText range:range];
        } else if (6 == row && (_modelIndex == 78 || _modelIndex == 91 || _modelIndex == 98)) {
            if (![newText isUnsignedDigits]) {
                cell.inputTextField.textColor = [UIColor redColor];
                return  NO;
            }
            const int newValue = [newText intValue];
            if (100 <= newValue && newValue <= 10000) {
                cell.inputTextField.textColor = [UIColor darkGrayColor];
            } else {
                cell.inputTextField.textColor = [UIColor redColor];
            }
            return newValue <= 100000;
        }
    } else if (FBBeaconTypeUnknown == _beaconType) {
        if (0 == row) {
            return [FESettingBeaconModel dealwith_Data_TextField:textField newText:newText];
        }
    }
    // conditon
    if (AddType_Condition == _addType) {
        if (TAG_SADV_INTERVAL == textField.tag) {
            BOOL isOK = [FESettingBeaconModel dealwith_Internal_TextField:textField newText:newText];
            _sadvInternal = [textField.text intValue];
            return isOK;
        }
        if (TAG_SADV_TIMEOUT == textField.tag) {
            BOOL isOK = [FESettingBeaconModel dealwith_Timeout_TextField:textField newText:newText];
            _sadvTimeout = [textField.text intValue];
            return isOK;
        }
    }
    return YES;
}

#pragma mark - UITableViewDataSoure
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self contentFromBeaconType:_beaconType] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    const NSInteger lastRow = [[self contentFromBeaconType:_beaconType] count] - 1;
    const NSInteger row = indexPath.row;
    
    if (78 == _modelIndex || 91 == _modelIndex || 98 == _modelIndex) {
        if (row == lastRow-2) {
            FWConfigurePowerCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigurePowerCell" owner:self options:nil] firstObject];
            UIView *backgroundView = [[UIView alloc] init];
            cell.backgroundView = backgroundView;
            cell.powerLabel.text = @"TxPower(db):";
            cell.txPowerLabel.text = _txPower;
            [cell.powerButton addTarget:self action:@selector(addBeaconTxPowerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        } else if (row == lastRow-1) {
            FWConfigurePhyCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigurePhyCell" owner:self options:nil] firstObject];
            UIView *backgroundView = [[UIView alloc] init];
            cell.backgroundView = backgroundView;
            cell.phyLabel.font = [UIFont systemFontOfSize:17];
            cell.phyLabel.text = @"Phy:";
            cell.phyValueLabel.text = [NSString stringWithFormat:@"%@",@"phy_1m"];
            if(_iPhy == 0){
                cell.phyValueLabel.text = [NSString stringWithFormat:@"%@",@"phy_1m"];
            }else if(_iPhy == 1){
                cell.phyValueLabel.text = [NSString stringWithFormat:@"%@",@"phy_2m"];
            }else{
                cell.phyValueLabel.text = [NSString stringWithFormat:@"%@",@"phy_coded"];
            }
            [cell.phyButton addTarget:self action:@selector(addBeaconPhyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            if (98 == _modelIndex) {
                cell.phyButton.hidden = YES;
            }
            return cell;
        }
    }
    NSArray<FEBeaconTitleInfoDetail *> *contents = [self contentFromBeaconType:_beaconType];
    if (row == lastRow) {
        FWConfigureSwitchCell *twoCell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigureSwitchCell" owner:self options:nil] firstObject];
        
        twoCell.textLabel.text = contents[row].title;
        _switchControl = twoCell.switchBtn;
        
        return twoCell;
    }else {
        if ([contents[row].title isEqualToString:@"Sensor:"]){
            FWConfigurePowerCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigurePowerCell" owner:self options:nil] firstObject];
            UIView *backgroundView = [[UIView alloc] init];
            cell.backgroundView = backgroundView;
            cell.powerLabel.text = [self contentFromBeaconType:_beaconType][row].title;
            cell.txPowerLabel.text = _sensor;
            [cell.powerButton addTarget:self action:@selector(addSensorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            _sensorIndexPath = indexPath;
            return cell;
        } else if ([contents[row].title isEqualToString:@"Action:"]){
            FWConfigurePowerCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigurePowerCell" owner:self options:nil] firstObject];
            UIView *backgroundView = [[UIView alloc] init];
            cell.backgroundView = backgroundView;
            cell.powerLabel.text = [self contentFromBeaconType:_beaconType][row].title;
            cell.txPowerLabel.text = _action;
            [cell.powerButton addTarget:self action:@selector(addActionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            _actionIndexPath = indexPath;
            return cell;
        }
    }
    FEBeaconTitleInfoDetail *item = [self contentFromBeaconType:_beaconType][row];
    FWConfigureValueSetCell *fourCell = [[[NSBundle mainBundle] loadNibNamed:@"FWConfigureValueSetCell" owner:self options:nil] firstObject];
    fourCell.inputTextField.delegate = self;
    fourCell.titleLabel.text = item.title;
    [fourCell.titleLabel sizeToFit];
    
    fourCell.inputTextField.text = _textFields[row].text;
    fourCell.inputTextField.placeholder = item.placeholder;
    fourCell.inputTextField.keyboardType = item.keyboardType;
    fourCell.inputTextField.delegate = self;
    
    _textFields[row] = fourCell.inputTextField;
    // condition
    if ([contents[row].title isEqualToString:@"Internal(ms):"]){
        _textFields[row].tag = TAG_SADV_INTERVAL;
    } else if ([contents[row].title isEqualToString:@"Timeout(ms):"]){
        _textFields[row].tag = TAG_SADV_TIMEOUT;
    }
    
    return fourCell;
    
}
- (void)addBeaconPhyButtonPressed:(UIButton *)sender {
    NSArray *phys = @[@"phy_1m", @"phy_2m", @"phy_coded"];
    FWPopoverViewController *popoverViewController = [[FWPopoverViewController alloc] initWithTitles:phys sourceView:sender];
    __weak typeof(self) weakSelf = self;
    popoverViewController.selectionHandler = ^(NSString *phy){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf){
            if([phy isEqualToString:@"phy_1m"]){
                _iPhy = 0;
            }else if([phy isEqualToString:@"phy_2m"]){
                _iPhy = 1;
            }else{
                _iPhy = 2;
            }
            [_tableView reloadData];
        }
    };
    [self presentViewController:popoverViewController animated:YES completion:nil];
}

- (void)addBeaconTxPowerButtonPressed:(UIButton *)sender {
    FWPopoverViewController *popoverViewController = [[FWPopoverViewController alloc] initWithTitles:_configTxPowers sourceView:sender];
    __weak typeof(self) weakSelf = self;
    popoverViewController.selectionHandler = ^(NSString *powerString) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf){
            _txPower = powerString;
            [_tableView reloadData];
        }
    };
    [self presentViewController:popoverViewController animated:YES completion:nil];
}

- (void)addSensorButtonPressed:(UIButton *)sender{
    FWPopoverViewController *popoverViewController = [[FWPopoverViewController alloc] initWithTitles:_sensors sourceView:sender];
    __weak typeof(self) weakSelf = self;
    popoverViewController.selectionHandler = ^(NSString *powerString) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf){
            _sensor = powerString;
            _action = @"";
            [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:_sensorIndexPath, _actionIndexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
        }
    };
    [self presentViewController:popoverViewController animated:YES completion:nil];
}

- (void)addActionButtonPressed:(UIButton *)sender{
    NSArray *list = @[];
    if ([_sensor isEqualToString:@"Key"]){
        list = _keyActions;
    } else if ([_sensor isEqualToString:@"G-Sensor"]){
        list = _gsensorActions;
    } else {
        // 提醒先选Sensor
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:LS(@"tips")
                                                                       message:LS(@"sensor first")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LS(@"Cancel")
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    FWPopoverViewController *popoverViewController = [[FWPopoverViewController alloc] initWithTitles:list sourceView:sender];
    __weak typeof(self) weakSelf = self;
    popoverViewController.selectionHandler = ^(NSString *powerString) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf){
            _action = powerString;
            [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:_sensorIndexPath, _actionIndexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
        }
    };
    [self presentViewController:popoverViewController animated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

@end
