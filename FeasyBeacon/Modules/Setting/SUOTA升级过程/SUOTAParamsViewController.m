/*
 *******************************************************************************
 *
 * Copyright (C) 2019-2020 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "SUOTAParamsViewController.h"
#import "ActionSheetStringPicker.h"
#import "DeviceNavigationController.h"
#import "Parameters.h"
#import "SUOTAViewController.h"

@interface SUOTAParamsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *memoryTypeControl;

@property (weak, nonatomic) IBOutlet UIView *i2cView;
@property (weak, nonatomic) IBOutlet UITextField *i2cAddress;
@property (weak, nonatomic) IBOutlet UITextField *i2cSDAGPIO;
@property (weak, nonatomic) IBOutlet UITextField *i2cSCLGPIO;

@property (weak, nonatomic) IBOutlet UIView *spiView;
@property (weak, nonatomic) IBOutlet UITextField *spiMISOGPIO;
@property (weak, nonatomic) IBOutlet UITextField *spiMOSIGPIO;
@property (weak, nonatomic) IBOutlet UITextField *spiCSGPIO;
@property (weak, nonatomic) IBOutlet UITextField *spiSCKGPIO;

@property (weak, nonatomic) IBOutlet UISegmentedControl *imageBank;
@property (weak, nonatomic) IBOutlet UITextField *blockSize;

@property (weak, nonatomic) IBOutlet UIView *fileView;
@property (weak, nonatomic) IBOutlet UIView *blockSizeView;
@property (weak, nonatomic) IBOutlet UIView *memoryTypeView;

@property SuotaManager* suotaManager;

- (IBAction) onMemoryTypeChange:(id)sender;
- (void) selectItemFromListForTextField:(UITextField*)textField withTitle:(NSString*)title;
- (void) gpioScannerWithString:(NSString*)gpio toInt:(unsigned*)output;
- (IBAction)sendToDeviceAction:(id)sender;

@end

@implementation SUOTAParamsViewController

static NSArray<NSString*>* gpioTitles;
static NSArray<NSNumber*>* gpioValues;

+ (void) initialize {
    if (self != SUOTAParamsViewController.class)
        return;
    
    gpioTitles = @[
            @"P0_0", @"P0_1", @"P0_2", @"P0_3", @"P0_4", @"P0_5", @"P0_6", @"P0_7", @"P0_8", @"P0_9", @"P0_10", @"P0_11",
            @"P1_0", @"P1_1", @"P1_2", @"P1_3",
            @"P2_0", @"P2_1", @"P2_2", @"P2_3", @"P2_4", @"P2_5", @"P2_6", @"P2_7", @"P2_8", @"P2_9",
            @"P3_0", @"P3_1", @"P3_2", @"P3_3", @"P3_4", @"P3_5", @"P3_6", @"P3_7"
    ];
    
    gpioValues = @[
            @0x00, @0x01, @0x02, @0x03, @0x04, @0x05, @0x06, @0x07, @0x08, @0x09, @0x0A, @0x0B,
            @0x10, @0x11, @0x12, @0x13,
            @0x20, @0x21, @0x22, @0x23, @0x24, @0x25, @0x26, @0x27, @0x28, @0x29,
            @0x30, @0x31, @0x32, @0x33, @0x34, @0x35, @0x36, @0x37
    ];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:LS(@"Parameter settings")];
    
    self.suotaManager = Parameters.instance.suotaManager;
    
    self.fileTextField.text = self.suotaManager.suotaFile.filename;
    self.deviceNameLabel.text = Parameters.instance.peripheral.name;
    
    NSArray<UIView*>* views = @[ self.fileView, self.blockSizeView, self.memoryTypeView ];
    for (UIView* view in views) {
        // Create view corners and shadow
        view.layer.cornerRadius = 6.0;
        view.layer.shadowColor = [UIColor grayColor].CGColor;
        view.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        view.layer.shadowRadius = 3.0;
        view.layer.shadowOpacity = 0.8;
    }
    // Change background view color
    UIColor* backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
    self.view.backgroundColor = backgroundColor;

    if (@available(iOS 13, *)) {
        [self.imageBank setTitleTextAttributes:@{ NSForegroundColorAttributeName : UIColor.whiteColor } forState:UIControlStateSelected];
        [self.memoryTypeControl setTitleTextAttributes:@{ NSForegroundColorAttributeName : UIColor.whiteColor } forState:UIControlStateSelected];
    }

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:@"memoryTypeIndex"]) 
        [self.memoryTypeControl setSelectedSegmentIndex:[[defaults objectForKey:@"memoryTypeIndex"] integerValue]];
    
    if ([defaults objectForKey:@"imageBank"])
        [self.imageBank setSelectedSegmentIndex:[[defaults objectForKey:@"imageBank"] integerValue]];
    if ([defaults objectForKey:@"blockSize"])
        self.blockSize.text = [[defaults objectForKey:@"blockSize"] stringValue];
    
    if ([defaults objectForKey:@"i2cAddress"])
        self.i2cAddress.text = [defaults objectForKey:@"i2cAddress"];
    if ([defaults objectForKey:@"i2cSDAGPIO"])
        self.i2cSDAGPIO.text = [defaults objectForKey:@"i2cSDAGPIO"];
    if ([defaults objectForKey:@"i2cSCLGPIO"])
        self.i2cSCLGPIO.text = [defaults objectForKey:@"i2cSCLGPIO"];
    
    if ([defaults objectForKey:@"spiMISOGPIO"])
        self.spiMISOGPIO.text = [defaults objectForKey:@"spiMISOGPIO"];
    if ([defaults objectForKey:@"spiMOSIGPIO"])
        self.spiMOSIGPIO.text = [defaults objectForKey:@"spiMOSIGPIO"];
    if ([defaults objectForKey:@"spiCSGPIO"])
        self.spiCSGPIO.text = [defaults objectForKey:@"spiCSGPIO"];
    if ([defaults objectForKey:@"spiSCKGPIO"])
        self.spiSCKGPIO.text = [defaults objectForKey:@"spiSCKGPIO"];
    
    // default
    [self.memoryTypeControl setSelectedSegmentIndex:0];
    [self.imageBank setSelectedSegmentIndex:2];
    self.blockSize.text = @"240";
    self.spiMISOGPIO.text = @"P0_3";
    self.spiMOSIGPIO.text = @"P0_0";
    self.spiCSGPIO.text = @"P0_1";
    self.spiSCKGPIO.text = @"P0_4";
    
    [self onMemoryTypeChange:self];
}

- (void) selectItemFromListForTextField:(UITextField*)textField withTitle:(NSString*)title {
    NSInteger initialSelection = 0;
    for (int n = 0; n < gpioTitles.count; n++) {
        if ([textField.text isEqualToString:gpioTitles[n]]) {
            initialSelection = n;
            break;
        }
    }
    
    [ActionSheetStringPicker showPickerWithTitle:title
                                            rows:gpioTitles
                                initialSelection:initialSelection
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           [textField setText:gpioTitles[selectedIndex]];
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                     }
                                          origin:textField];
}

- (IBAction)sendToDeviceAction:(id)sender {
    // 检查条件：如果 memoryTypeControl 的 selectedSegmentIndex 为 1（I2C 模式）
    if (self.memoryTypeControl.selectedSegmentIndex == 1) {
        uint value;
        
        // 使用 NSScanner 来验证 i2cAddress.text 是否是有效的十六进制数
        if (![[NSScanner scannerWithString:self.i2cAddress.text] scanHexInt:&value]) {
            // 如果 i2cAddress 无效，显示 HUD 并返回，不执行跳转
            [(DeviceNavigationController*)self.parentViewController displayHud:LS(@"Invalid I2C device address") dismissViewController:false];
            return;
        }
    }
    
    // 如果一切正常，准备数据并进行视图控制器跳转
    int blockSize;
    unsigned int i2cAddress, i2cSDA, i2cSCL, spiMOSI, spiMISO, spiCS, spiSCK = 0;
    
    // 保存默认设置
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    int imageBank = (int)self.imageBank.selectedSegmentIndex;
    [defaults setObject:@(imageBank) forKey:@"imageBank"];
    
    [[NSScanner scannerWithString:self.blockSize.text] scanInt:&blockSize];
    [defaults setObject:@(blockSize) forKey:@"blockSize"];
    
    [defaults setObject:@(self.memoryTypeControl.selectedSegmentIndex) forKey:@"memoryTypeIndex"];
    
    // 判断内存类型是否是 SPI
    if ([self.memoryTypeControl selectedSegmentIndex] == 0) {
        [self gpioScannerWithString:self.spiMISOGPIO.text toInt:&spiMISO];
        [self gpioScannerWithString:self.spiMOSIGPIO.text toInt:&spiMOSI];
        [self gpioScannerWithString:self.spiCSGPIO.text toInt:&spiCS];
        [self gpioScannerWithString:self.spiSCKGPIO.text toInt:&spiSCK];
        
        [defaults setObject:self.spiMISOGPIO.text forKey:@"spiMISOGPIO"];
        [defaults setObject:self.spiMOSIGPIO.text forKey:@"spiMOSIGPIO"];
        [defaults setObject:self.spiCSGPIO.text forKey:@"spiCSGPIO"];
        [defaults setObject:self.spiSCKGPIO.text forKey:@"spiSCKGPIO"];
        
        NSLog(@"suotaManager.suotaFile.filename = %@", self.suotaManager.suotaFile.filename);
        NSLog(@"suotaManager initializeSuota : \nblockSize = %d, spiMISO = %d, spiMOSI = %d, spiCS = %d, spiSCK = %d, imageBank = %d", blockSize, spiMISO, spiMOSI, spiCS, spiSCK, imageBank);
        
        // 初始化 SuotaManager
        [self.suotaManager initializeSuota:blockSize misoGpio:spiMISO mosiGpio:spiMOSI csGpio:spiCS sckGpio:spiSCK imageBank:imageBank];
        
    } else if ([self.memoryTypeControl selectedSegmentIndex] == 1) { // I2C
        [[NSScanner scannerWithString:self.i2cAddress.text] scanHexInt:&i2cAddress];
        [self gpioScannerWithString:self.i2cSDAGPIO.text toInt:&i2cSDA];
        [self gpioScannerWithString:self.i2cSCLGPIO.text toInt:&i2cSCL];
        
        [defaults setObject:self.i2cAddress.text forKey:@"i2cAddress"];
        [defaults setObject:self.i2cSDAGPIO.text forKey:@"i2cSDAGPIO"];
        [defaults setObject:self.i2cSCLGPIO.text forKey:@"i2cSCLGPIO"];
        
        // 初始化 SuotaManager
        [self.suotaManager initializeSuota:blockSize i2cAddress:i2cAddress sclGpio:i2cSCL sdaGpio:i2cSDA imageBank:imageBank];
    }
    
    // 跳转到 SuotaViewController
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SUOTAViewController" bundle:nil];
    SUOTAViewController *sUOTAViewController = [storyboard instantiateViewControllerWithIdentifier:@"SUOTAViewController"];

    [self.navigationController pushViewController:sUOTAViewController animated:YES];
}

- (void) gpioScannerWithString:(NSString*)gpio toInt:(unsigned*)output {
    for (int n = 0; n < gpioTitles.count; n++) {
        if ([gpio isEqualToString:gpioTitles[n]]) {
            *output = gpioValues[n].unsignedIntValue;
            break;
        }
    }
}

- (IBAction) onMemoryTypeChange:(id)sender {
    if ([self.memoryTypeControl selectedSegmentIndex] == 0) {
        [self.spiView setHidden:NO];
        [self.i2cView setHidden:YES];
    } else if ([self.memoryTypeControl selectedSegmentIndex] == 1) {
        [self.spiView setHidden:YES];
        [self.i2cView setHidden:NO];
    }
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.i2cSCLGPIO  ||
        textField == self.i2cSDAGPIO  ||
        textField == self.spiMOSIGPIO ||
        textField == self.spiMISOGPIO ||
        textField == self.spiCSGPIO   ||
        textField == self.spiSCKGPIO)
    {
        [self selectItemFromListForTextField:textField withTitle:LS(@"Select a GPIO")];
        return NO;
    }
    return YES;
}

- (BOOL) shouldPerformSegueWithIdentifier:(NSString*)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"SuotaViewControllerSegue"] && self.memoryTypeControl.selectedSegmentIndex == 1) {
        uint value;
        if (![[NSScanner scannerWithString:self.i2cAddress.text] scanHexInt:&value]) {
            [(DeviceNavigationController*)self.parentViewController displayHud:@"Invalid I2C deviceTv address" dismissViewController:false];
            return false;
        }
    }
    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}

- (void) prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
    int blockSize;
    
    unsigned int i2cAddress, i2cSDA, i2cSCL,
    spiMOSI, spiMISO, spiCS, spiSCK = 0;
    
    // Save default settings
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    int imageBank = (int) self.imageBank.selectedSegmentIndex;
    [defaults setObject:@(imageBank) forKey:@"imageBank"];
    
    [[NSScanner scannerWithString:self.blockSize.text] scanInt:&blockSize];
    [defaults setObject:@(blockSize) forKey:@"blockSize"];
    
    [defaults setObject:@(self.memoryTypeControl.selectedSegmentIndex) forKey:@"memoryTypeIndex"];
    
    if ([self.memoryTypeControl selectedSegmentIndex] == 0) { // SPI
        
        [self gpioScannerWithString:self.spiMISOGPIO.text toInt:&spiMISO];
        [self gpioScannerWithString:self.spiMOSIGPIO.text toInt:&spiMOSI];
        [self gpioScannerWithString:self.spiCSGPIO.text toInt:&spiCS];
        [self gpioScannerWithString:self.spiSCKGPIO.text toInt:&spiSCK];
        
        [defaults setObject:self.spiMISOGPIO.text forKey:@"spiMISOGPIO"];
        [defaults setObject:self.spiMOSIGPIO.text forKey:@"spiMOSIGPIO"];
        [defaults setObject:self.spiCSGPIO.text forKey:@"spiCSGPIO"];
        [defaults setObject:self.spiSCKGPIO.text forKey:@"spiSCKGPIO"];
        
        NSLog(@"suotaManager.suotaFile.filename = %@", self.suotaManager.suotaFile.filename);
        NSLog(@"suotaManager initializeSuota : \nblockSize = %d, spiMISO = %d, spiMOSI = %d, spiCS = %d, spiSCK = %d, imageBank = %d", blockSize, spiMISO, spiMOSI, spiCS, spiSCK, imageBank);
        [self.suotaManager initializeSuota:blockSize misoGpio:spiMISO mosiGpio:spiMOSI csGpio:spiCS sckGpio:spiSCK imageBank:imageBank];
        
    } else if ([self.memoryTypeControl selectedSegmentIndex] == 1) { // I2C
        
        [[NSScanner scannerWithString:self.i2cAddress.text] scanHexInt:&i2cAddress];
        [self gpioScannerWithString:self.i2cSDAGPIO.text toInt:&i2cSDA];
        [self gpioScannerWithString:self.i2cSCLGPIO.text toInt:&i2cSCL];
        
        [defaults setObject:self.i2cAddress.text forKey:@"i2cAddress"];
        [defaults setObject:self.i2cSDAGPIO.text forKey:@"i2cSDAGPIO"];
        [defaults setObject:self.i2cSCLGPIO.text forKey:@"i2cSCLGPIO"];
        
        [self.suotaManager initializeSuota:blockSize i2cAddress:i2cAddress sclGpio:i2cSCL sdaGpio:i2cSDA imageBank:imageBank];
        
    }
}

@end

/**
 核心代码
 对OTA升级做配置：
 [self.suotaManager initializeSuota:blockSize misoGpio:spiMISO mosiGpio:spiMOSI csGpio:spiCS sckGpio:spiSCK imageBank:imageBank];
 */
