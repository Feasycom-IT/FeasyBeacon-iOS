/*
 *******************************************************************************
 *
 * Copyright (C) 2019-2020 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "FileSettingsTableViewController.h"
#import "FileTableViewController.h"

@interface FileSettingsTableViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *displayDetailsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *filter58xSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *filter68xSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *filter69xSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *filterUnknownSwitch;
@property IBOutletCollection(NSLayoutConstraint) NSArray* customCellLeadingConstraints;

@property NSUserDefaults* preferences;

@end

@implementation FileSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.preferences = [NSUserDefaults standardUserDefaults];
    
    // Fix leading constraint for custom cells
    if (UIDevice.currentDevice.systemVersion.floatValue < 11) {
        // iOS version/device dependent: 11 -> 0 (storyboard), < 11 -> 8 iPhone, 12 iPad
        int margin = UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPad ? 8 : 12;
        for (NSLayoutConstraint* c in self.customCellLeadingConstraints)
            c.constant = margin;
    }

    [self.displayDetailsSwitch setOn:[self.preferences boolForKey:FileTableViewController.DISPLAY_DETAILS]];
    [self.filter58xSwitch setOn:[self.preferences boolForKey:FileTableViewController.FILTER_58x]];
    [self.filter68xSwitch setOn:[self.preferences boolForKey:FileTableViewController.FILTER_68x]];
    [self.filter69xSwitch setOn:[self.preferences boolForKey:FileTableViewController.FILTER_69x]];
    [self.filterUnknownSwitch setOn:[self.preferences boolForKey:FileTableViewController.FILTER_UNKNOWN]];
}

- (IBAction)onDetailsDisplaySwitchChanged:(id)sender {
    [self.preferences setBool:self.displayDetailsSwitch.isOn forKey:FileTableViewController.DISPLAY_DETAILS];
}

- (IBAction)on58xFilterSwitchChanged:(id)sender {
    [self.preferences setBool:self.filter58xSwitch.isOn forKey:FileTableViewController.FILTER_58x];
}

- (IBAction)on68xFilterSwitchChanged:(id)sender {
    [self.preferences setBool:self.filter68xSwitch.isOn forKey:FileTableViewController.FILTER_68x];
}

- (IBAction)on69xFilterSwitchChanged:(id)sender {
    [self.preferences setBool:self.filter69xSwitch.isOn forKey:FileTableViewController.FILTER_69x];
}

- (IBAction)onUnknownFilterSwitchChanged:(id)sender {
    [self.preferences setBool:self.filterUnknownSwitch.isOn forKey:FileTableViewController.FILTER_UNKNOWN];
}


@end
