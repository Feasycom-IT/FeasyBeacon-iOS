//
//  FBForumController.m
//  FeasyBeacon
//
//  Created by chenchanghua on 2025/10/15.
//  Copyright © 2025 Feasycom. All rights reserved.
//

#import "FBForumController.h"
#import <WebKit/WebKit.h>
#import <AFNetworking/AFNetworking.h>
#define forumfeasycom @"https://forum.feasycom.com/"

@interface FBForumController () <WKNavigationDelegate,WKUIDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;
@end

@implementation FBForumController

- (id)init {
    self = [super init];
    if (self) {
        
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:LS(@"Forum") image:[UIImage imageNamed:@"forum"] tag:0];
        
        [self setTabBarItem:tabBarItem];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    self.title = LS(@"Forum");;
    
    [self setback];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero];
    self.webView.navigationDelegate = self;
    NSURL *url = [NSURL URLWithString:forumfeasycom];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.webView.topAnchor constraintEqualToAnchor:guide.topAnchor],
        [self.webView.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor],
        [self.webView.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor],
        [self.webView.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor],
    ]];
    
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, self.view.safeAreaInsets.top, [[UIScreen mainScreen] bounds].size.width, 2)];
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    [self.view addSubview:self.progressView];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.progress = self.webView.estimatedProgress;
        if (self.progressView.progress == 1) {
            __weak typeof (self)weakSelf = self;
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                weakSelf.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
            } completion:^(BOOL finished) {
                weakSelf.progressView.hidden = YES;
            }];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"开始加载网页");
    self.progressView.hidden = NO;
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    [self.view bringSubviewToFront:self.progressView];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"加载失败");
}

- (void)setback {
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 54, 54)];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"shuaxin-2"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(rightClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem  = right;
}

- (void)createAlertController:(NSString *)string {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:string message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:LS(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:okAction];
    [self.navigationController presentViewController:alertController animated:YES completion:NULL];
}

- (void)rightClick {
    if ([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] <= AFNetworkReachabilityStatusNotReachable) {
        [self createAlertController:LS(@"NETWORK_NOT_REACHABLE")];
        return;
    }
    NSURL *url = [NSURL URLWithString:forumfeasycom];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)setLeftNav {
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [backBtn setImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    
    UIButton *closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [closeBtn setImage:[UIImage imageNamed:@"shanchu-2"] forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *closeBarButton = [[UIBarButtonItem alloc]initWithCustomView:closeBtn];
    
    self.navigationItem.leftBarButtonItems= @[barButton,closeBarButton];
}

- (void)backBtnClick {
    if (self.webView.canGoBack) {
        [self setLeftNav];
        [self.webView goBack];
    } else {
        self.navigationItem.leftBarButtonItems = nil;
    }
}

- (void)closeBtnClick {
    self.navigationItem.leftBarButtonItems = nil;
    if (self.webView.backForwardList.backList.count > 0) {
        WKBackForwardListItem * item = self.webView.backForwardList.currentItem;
        for (WKBackForwardListItem * backItem in self.webView.backForwardList.backList) {
            [self.webView goToBackForwardListItem:self.webView.backForwardList.backList.firstObject];
        }
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if (webView.canGoBack) {
        [self setLeftNav];
    } else {
        self.navigationItem.leftBarButtonItems = nil;
    }
}

- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *urlString = navigationAction.request.URL.absoluteString ?: @"";

    if ([urlString containsString:@"/link.html"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    if (navigationAction.targetFrame == nil || !navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }

    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

@end

