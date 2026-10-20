//
//  FBRootViewController.m
//  FeasyBeacon
//
//  Created by LIDONG on 14-2-28.
//  Copyright (c) 2014年 LIDONG. All rights reserved.
//

#import "FBRootViewController.h"

@interface FBRootViewController ()
@property (nonatomic, strong) NSMutableArray *viewControllerArr;
@end

@implementation FBRootViewController

- (id)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.viewControllerArr = [NSMutableArray array];
        
        [self addViewController:@"FWBeaconsViewController"];
        [self addViewController:@"FWSensorViewController"];
        [self addViewController:@"FWSettingsViewController"];
        [self addViewController:@"FBStoreViewController"];
        [self addViewController:@"FBForumController"];
        [self addViewController:@"FWAboutVC"];
        
        [self setViewControllers:self.viewControllerArr];
        self.customizableViewControllers = nil;
    }
    return self;
}

- (void)addViewController:(NSString *)className {
    UIViewController *viewController = [[NSClassFromString(className) alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    [self.viewControllerArr addObject:navigationController];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UIInterfaceOrientationPortrait == toInterfaceOrientation);
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
