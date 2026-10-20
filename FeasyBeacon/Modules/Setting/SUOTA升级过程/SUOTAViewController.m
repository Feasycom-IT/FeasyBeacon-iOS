/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2020 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "SUOTAViewController.h"
#import "Parameters.h"

@interface SUOTAViewController ()

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *progressTextLabel;
@property (weak, nonatomic) IBOutlet UIView *progressUIView;
@property (weak, nonatomic) IBOutlet UIView *statisticsUIView;
@property (weak, nonatomic) IBOutlet LineChartView *chart;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UILabel *uploadInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *chunkLabel;
@property (weak, nonatomic) IBOutlet UILabel *blockLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxLabel;
@property (weak, nonatomic) IBOutlet UILabel *minLabel;
@property (weak, nonatomic) IBOutlet UILabel *avgLabel;
@property (weak, nonatomic) IBOutlet UILabel *blockSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *elapsedTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *uploadTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property UIColor* primaryColor;

@property SuotaManager* suotaManager;


@end

@implementation SUOTAViewController

static NSString* const TAG = @"SUOTAViewController";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.suotaManager = Parameters.instance.suotaManager;
    
    [self.navigationItem setTitle:LS(@"Uploading file")];
    
    // Create view corners and shadow
    self.progressUIView.layer.cornerRadius = 6.0;
    self.progressUIView.layer.shadowColor = [UIColor grayColor].CGColor;
    self.progressUIView.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.progressUIView.layer.shadowRadius = 3.0;
    self.progressUIView.layer.shadowOpacity = 0.8;
    
    // Change background view color
    UIColor* backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
    self.view.backgroundColor = backgroundColor;
    self.statisticsUIView.backgroundColor = backgroundColor;
    self.logTextView.backgroundColor = backgroundColor;
    self.buttonView.backgroundColor = backgroundColor;
    
    self.logTextView.text = @"";
    self.logTextView.textContainerInset = UIEdgeInsetsMake(0, -self.logTextView.textContainer.lineFragmentPadding, 0, -self.logTextView.textContainer.lineFragmentPadding);
    self.uploadInfoLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@.\n%@", LS(@"Uploading file"), self.suotaManager.suotaFile.fileName, Parameters.instance.peripheral.name, LS(@"to device"), LS(@"Please wait until the process is completed...")];
    
    [self.progressView setProgress:0];
    [self.progressTextLabel setText:[NSString stringWithFormat:@"%d%%", 0]];
    
    self.chunkLabel.text = @"";
    self.blockLabel.text = @"";
    
    self.primaryColor = [UIColor colorWithRed:42.0/255.0 green:40.0/255.0 blue:157.0/255.0 alpha:1.0];
    self.chart.userInteractionEnabled = true;
    self.chart.dragEnabled = true;
    self.chart.scaleXEnabled = true;
    self.chart.scaleYEnabled = true;
    self.chart.drawGridBackgroundEnabled = true;
    self.chart.pinchZoomEnabled = false;
    self.chart.highlightPerTapEnabled = false;
    self.chart.highlightPerDragEnabled = false;
    self.chart.backgroundColor = UIColor.whiteColor;
    self.chart.chartDescription = nil;
    
    LineChartData* data = [[LineChartData alloc] init];
    self.chart.data = data;
    ChartLegend* legend = self.chart.legend;
    legend.form = ChartLegendFormLine;
    legend.textColor = self.primaryColor;
    legend.horizontalAlignment = ChartLegendHorizontalAlignmentCenter;
    legend.font = [UIFont systemFontOfSize:12.0];
    ChartXAxis* xAxis = self.chart.xAxis;
    xAxis.enabled = false;
    ChartYAxis* leftAxis = self.chart.leftAxis;
    leftAxis.labelTextColor = self.primaryColor;
    leftAxis.drawGridLinesEnabled = true;
    ChartYAxis* rightAxis = self.chart.rightAxis;
    rightAxis.enabled = false;
    
    self.buttonView.hidden = true;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    self.isSuotaRunning = true;
    self.isSuotaCompleted = false;
    [self.suotaManager startUpdate];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void) updateLogCat:(NSString*)log {
    self.logTextView.text = [self.logTextView.text stringByAppendingString:self.logTextView.text.length ? [NSString stringWithFormat:@"\n%@", log] : log];
    [self.logTextView scrollRangeToVisible:NSMakeRange([self.logTextView.text length], 0)];
}

- (void) onSuotaLog:(enum SuotaProtocolState)state type:(enum SuotaLogType)type log:(NSString*)log {
    [self updateLogCat:log];
}

- (void) onChunkSend:(int)chunkCount totalChunks:(int)totalChunks chunk:(int)chunk block:(int)block blockChunks:(int)blockChunks totalBlocks:(int)totalBlocks {
    self.chunkLabel.text = [NSString stringWithFormat:@"%@ %d of %d", LS(@"Sending chunk"), chunkCount, totalChunks];
    self.blockLabel.text = [NSString stringWithFormat:@"%@ %d of %d", LS(@"Block"), block, totalBlocks];
}

- (void) onUploadProgress:(float)percent {
    [self.progressView setProgress:percent / 100.f animated:true];
    [self.progressTextLabel setText:[NSString stringWithFormat:@"%d%%", (int)percent]];
}

- (void) onSuccess:(double)totalElapsedSeconds imageUploadElapsedSeconds:(double)imageUploadElapsedSeconds {
    self.isSuotaRunning = false;
    self.isSuotaCompleted = true;

    self.blockSpeedLabel.hidden = true;
    self.currentSpeedLabel.hidden = true;
    self.elapsedTimeLabel.hidden = false;
    self.uploadTimeLabel.hidden = false;
    self.elapsedTimeLabel.text = [NSString stringWithFormat:@"%@: %.3lf %@", LS(@"Elapsed Time"), totalElapsedSeconds, LS(@"seconds")];
    self.uploadTimeLabel.text = [NSString stringWithFormat:@"%@: %.3lf %@", LS(@"Upload Time"), imageUploadElapsedSeconds, LS(@"seconds")];

    self.buttonView.hidden = false;
}

- (void) onRebootSent {
    [self updateLogCat:LS(@"Send reboot command")];
}

- (void) updateSpeedStatistics:(double)current max:(double)max min:(double)min avg:(double)avg {
    [self updateChart:current];
    self.blockSpeedLabel.text = [NSString stringWithFormat:@"%@: %.0lf B/s", LS(@"Block Speed"), current];
    self.avgLabel.text = [NSString stringWithFormat:@"%@: %.0lf B/s", LS(@"Average Speed"), avg];
    self.maxLabel.text = [NSString stringWithFormat:@"%@: %.0lf B/s", LS(@"Max Block Speed"), max];
    self.minLabel.text = [NSString stringWithFormat:@"%@: %.0lf B/s", LS(@"Min Block Speed"), min];
}

- (void) updateCurrentSpeed:(double)currentSpeed {
    self.currentSpeedLabel.text = [NSString stringWithFormat:@"%@: %.0lf B/s", LS(@"Current Speed"), currentSpeed];
}

- (void) notifySuotaFailed {
    self.isSuotaRunning = false;
    self.isSuotaFailed = true;
}

- (void) updateChart:(double)speed {
    ChartData* data = self.chart.data;
    if (!data)
        return;
    NSArray<id<IChartDataSet>>* sets = data.dataSets;
    if (!sets || !sets.count) {
        id<IChartDataSet> set = [self createSet];
        [data addDataSet:set];
    }
    id<IChartDataSet> set = data.dataSets[0];
    [data addEntry:[[ChartDataEntry alloc] initWithX:set.entryCount y:(speed / 1000)] dataSetIndex:0];
    [self.chart notifyDataSetChanged];
    self.chart.visibleXRangeMaximum = 100;
    [self.chart moveViewToX:data.entryCount];
}

- (LineChartDataSet*) createSet {
    LineChartDataSet* set = [[LineChartDataSet alloc] initWithEntries:nil label:[NSString stringWithFormat:@"%@ (KB/s)", LS(@"Block Speed")]];
    set.axisDependency = AxisDependencyLeft;
    set.color = self.primaryColor;
    set.drawCirclesEnabled = false;
    set.lineWidth = 2.f;
    set.mode = LineChartModeHorizontalBezier;
    set.cubicIntensity = 0.05f;
    set.highlightColor = self.primaryColor;
    set.drawValuesEnabled = false;
    return set;
}

- (IBAction) onCloseButtonTouched:(id)sender {
    [self dismissViewControllerAnimated:true completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceControllerDismissed" object:nil];
    }];
}

- (BOOL) handleNavigation:(void(^)(void))onNavigation {
    onNavigation();
    return true;
}

@end

/**
 核心代码
 启动OTA升级：
 [self.suotaManager startUpdate];
 */
