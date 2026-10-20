/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2020 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "FileTableViewController.h"
#import "DeviceNavigationController.h"
#import "FileTableViewCell.h"
#import "Parameters.h"
#import "SUOTAParamsViewController.h"
#import "FileSettingsTableViewController.h"

@interface FileTableViewController () <UITableViewDataSource, UITableViewDelegate, UIDocumentPickerDelegate>

@property NSArray<SuotaFile*>* fileArray;
@property NSMutableArray<SuotaFile*>* displayedFiles;
@property (strong, nonatomic) IBOutlet UITableView* tableView;
@property (nonatomic) IBOutlet UIBarButtonItem* selectFile;// Doc中选择文件
- (IBAction) onSelectFile;// Doc中选择文件Action
- (IBAction)filterAction:(id)sender;// 过滤设置

@property NSUserDefaults* preferences;
@property SuotaManager* suotaManager;

- (void) invalidFirmwareCrc;
- (void) reloadData;

@end

@implementation FileTableViewController

static NSString* const DISPLAY_DETAILS = @"Display Details";
static NSString* const FILTER_58x = @"58x";
static NSString* const FILTER_68x = @"68x";
static NSString* const FILTER_69x = @"69x";
static NSString* const FILTER_UNKNOWN = @"Unknown";

+ (NSString*) DISPLAY_DETAILS {
    return DISPLAY_DETAILS;
}

+ (NSString*) FILTER_58x {
    return FILTER_58x;
}

+ (NSString*) FILTER_68x {
    return FILTER_68x;
}

+ (NSString*) FILTER_69x {
    return FILTER_69x;
}

+ (NSString*) FILTER_UNKNOWN {
    return FILTER_UNKNOWN;
}

- (void) viewDidLoad {
    [super viewDidLoad];

    self.suotaManager = Parameters.instance.suotaManager;

    [self.navigationItem setTitle:LS(@"File selection")];
    [self.navigationItem.backBarButtonItem setTitle:LS(@"Cancel")];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    if (@available(iOS 15, *)) {
        self.tableView.prefetchingEnabled = false;
    }

    if (@available(ios 12, *)) {} else {
        NSMutableArray* items = self.navigationItem.rightBarButtonItems.mutableCopy;
        [items removeObject:self.selectFile];
        self.navigationItem.rightBarButtonItems = items;
    }

    [self initializePreferences];
    self.fileArray = [SuotaFile listFilesWithHeaderInfo];
    if (!self.fileArray.count)
        [(DeviceNavigationController*)self.parentViewController displayHud:LS(@"No firmware found") dismissViewController:false];
}

- (void) initializePreferences {
    self.preferences = [NSUserDefaults standardUserDefaults];
    if ([self.preferences objectForKey:DISPLAY_DETAILS] == nil)
        [self.preferences setBool:true forKey:DISPLAY_DETAILS];
    if ([self.preferences objectForKey:FILTER_58x] == nil)
        [self.preferences setBool:true forKey:FILTER_58x];
    if ([self.preferences objectForKey:FILTER_68x] == nil)
        [self.preferences setBool:true forKey:FILTER_68x];
    if ([self.preferences objectForKey:FILTER_69x] == nil)
        [self.preferences setBool:true forKey:FILTER_69x];
    if ([self.preferences objectForKey:FILTER_UNKNOWN] == nil)
        [self.preferences setBool:true forKey:FILTER_UNKNOWN];
}

- (void) viewWillAppear:(BOOL)animated {
    [self reloadData];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.displayedFiles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FileTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"DetailedFileCell" forIndexPath:indexPath];
    SuotaFile* file = self.displayedFiles[indexPath.row];
    
    BOOL hidden = ![self.preferences boolForKey:DISPLAY_DETAILS];
    
    cell.stackView.spacing = !hidden ? (CGFloat)5.0 : (CGFloat)0.0;
    cell.filename.text = file.filename;
    
    cell.typeLabel.hidden = hidden;
    cell.versionLabel.hidden = hidden;
    cell.sizeLabel.hidden = hidden;
    cell.type.hidden = hidden;
    cell.version.hidden = hidden;
    cell.size.hidden = hidden;
    if (!hidden) {
        cell.type.text = !file.headerInfo ? @"N/A" : file.headerInfo.type;
        cell.version.text = !file.headerInfo ? @"N/A" : file.headerInfo.version;
        cell.size.text = !file.headerInfo ? @"N/A" : [NSString stringWithFormat:@"%lld", file.headerInfo.totalBytes];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.suotaManager.suotaFile = self.displayedFiles[indexPath.row];
    [self.tableView deselectRowAtIndexPath:indexPath animated:false];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SUOTAParamsViewController" bundle:nil];
    SUOTAParamsViewController *sUOTAParamsViewController = [storyboard instantiateViewControllerWithIdentifier:@"SUOTAParamsViewController"];
    
    [self.navigationController pushViewController:sUOTAParamsViewController animated:YES];
}

- (void) invalidFirmwareCrc {
    [(DeviceNavigationController*)self.parentViewController displayAlert:@"Error" message:SuotaProfile.suotaErrorCodeList[@(INVALID_FIRMWARE_CRC)] dismissViewController:false];
}

- (void) reloadData {
    self.fileArray = [SuotaFile listFilesWithHeaderInfo];
    self.displayedFiles = [NSMutableArray arrayWithCapacity:self.fileArray.count];
    for (SuotaFile* file in self.fileArray) {
        if ((file.headerInfo.type == HeaderInfo58x.TYPE && [self.preferences boolForKey:FILTER_58x])
            || (file.headerInfo.type == HeaderInfo68x.TYPE && [self.preferences boolForKey:FILTER_68x])
            || (file.headerInfo.type == HeaderInfo69x.TYPE && [self.preferences boolForKey:FILTER_69x])
            || (!file.headerInfo && [self.preferences boolForKey:FILTER_UNKNOWN]))
            [self.displayedFiles addObject:file];
    }
}

- (IBAction) onSelectFile {
    UIDocumentPickerViewController* picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data"] inMode:UIDocumentPickerModeImport];
    picker.delegate = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController presentViewController:picker animated:true completion:nil];
    });
}

- (void) documentPicker:(UIDocumentPickerViewController*)controller didPickDocumentAtURL:(NSURL*)url {
    
    // 获取选中的文件名
    NSString *fileName = [url lastPathComponent];
    
    // 构建目标路径
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *destinationPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    // 拷贝文件
    NSError *error;
    NSURL *destinationURL = [NSURL fileURLWithPath:destinationPath];
    [[NSFileManager defaultManager] copyItemAtURL:url toURL:destinationURL error:&error];
    
    if (error) {
        NSLog(@"Error copying file: %@", [error localizedDescription]);
    } else {
        NSLog(@"File copied successfully to %@", destinationPath);
    }
    
    self.suotaManager.suotaFile = [[SuotaFile alloc] initWithURL:url];
    
    // 从 Storyboard 中实例化 FileSettingsTableViewController
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SUOTAParamsViewController" bundle:nil];
    SUOTAParamsViewController *sUOTAParamsViewController = [storyboard instantiateViewControllerWithIdentifier:@"SUOTAParamsViewController"];
    
    [self.navigationController pushViewController:sUOTAParamsViewController animated:YES];
}

- (void) documentPicker:(UIDocumentPickerViewController*)controller didPickDocumentsAtURLs:(NSArray<NSURL*>*)urls {
    [self documentPicker:controller didPickDocumentAtURL:urls[0]];
}

- (IBAction)filterAction:(id)sender {
    // 从 Storyboard 中实例化 FileSettingsTableViewController
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FileSettingsTableViewController" bundle:nil];
    FileSettingsTableViewController *fileSettingsTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"FileSettingsTableViewController"];
    
    [self.navigationController pushViewController:fileSettingsTableViewController animated:YES];
}

@end

/**
 核心代码就是：
 1、取得suotaManager的全局对象
 self.suotaManager = Parameters.instance.suotaManager;
 2、对suotaManager中的文件进行赋值
 self.suotaManager.suotaFile = [[SuotaFile alloc] initWithURL:url];
 */
