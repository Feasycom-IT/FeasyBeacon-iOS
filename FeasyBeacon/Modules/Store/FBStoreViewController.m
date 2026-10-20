//
//  FBStoreViewController.m
//  FeasyBeacon
//
//  Created by wenyewei on 2020/9/11.
//  Copyright © 2020 LIDONG. All rights reserved.
//

#import "FBStoreViewController.h"
#import <WebKit/WebKit.h>
#import <AFNetworking/AFNetworking.h>
#import <SafariServices/SafariServices.h>

#define storefeasycom @"https://www.feasycom.com.cn/products/"
#define kNavBar_Height ([[UIApplication sharedApplication] statusBarFrame].size.height > 20 ? 88 : 64)
#define kTabBar_Height ([[UIApplication sharedApplication] statusBarFrame].size.height > 20 ? 83 : 49)

@interface FBStoreViewController () <WKNavigationDelegate,WKUIDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;
@end

@implementation FBStoreViewController

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:LS(@"Store") image:[UIImage imageNamed:@"on"] tag:3];
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
    self.title = LS(@"Store");
    
    [self setback];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, kNavBar_Height, self.view.frame.size.width, self.view.frame.size.height - kNavBar_Height - kTabBar_Height)];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    [self.view addSubview:self.webView];
    NSURL *url = [NSURL URLWithString:storefeasycom];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, kNavBar_Height, [[UIScreen mainScreen] bounds].size.width, 2)];
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    [self.view addSubview:self.progressView];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
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
    self.progressView.hidden = NO;
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    [self.view bringSubviewToFront:self.progressView];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
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
    NSURL *url = [NSURL URLWithString:storefeasycom];
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
    
    NSURL *URL = navigationAction.request.URL;
    NSString *urlString = URL.absoluteString ?: @"";
    
    if ([urlString containsString:@"/link.html"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    if ([URL.host.lowercaseString isEqualToString:@"affimvip.baidu.com"] &&
        [URL.path containsString:@"/cps5/mobile/chat"]) {
        
        [self openInSafariVC:URL];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (WKWebView *)webView:(WKWebView *)webView
createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
   forNavigationAction:(WKNavigationAction *)navigationAction
        windowFeatures:(WKWindowFeatures *)windowFeatures {
    
    NSURL *URL = navigationAction.request.URL;
    if (URL) {
        if ([URL.host.lowercaseString isEqualToString:@"affimvip.baidu.com"] &&
            [URL.path containsString:@"/cps5/mobile/chat"]) {
            [self openInSafariVC:URL];
        } else {
            [webView loadRequest:navigationAction.request];
        }
    }
    return nil;
}

- (void)openInSafariVC:(NSURL *)URL {
    if (!URL) return;
    SFSafariViewController *vc = [[SFSafariViewController alloc] initWithURL:URL];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
