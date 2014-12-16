//
//  ViewController.m
//  MGSuperAlert
//
//  Created by LEON on 14/10/26.
//  Copyright (c) 2014年 LEON. All rights reserved.
//

#import "ViewController.h"
#import "MGAlertView.h"

@interface ViewController ()
- (IBAction)Animation1:(id)sender;
- (IBAction)Animation2:(id)sender;
- (IBAction)Animation3:(id)sender;
- (IBAction)Animation4:(id)sender;
- (IBAction)Animation5:(id)sender;
- (IBAction)Animation6:(id)sender;
- (IBAction)DoubleBtn:(id)sender;
@property (nonatomic, strong) MGAlertView *alertView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    
    MGAlertView *alertView = [MGAlertView dialogWithTitle:@"现在问题来了" subtitle:@"挖掘机学校哪家强？"];
    alertView.blurBackground = NO;
    [alertView addButtonWithTitle:@"华科"];
    [alertView addButtonWithTitle:@"蓝翔"];
    [alertView setHandlerBlock:^(NSInteger buttonIndex, MGAlertView *alertView) {
        NSLog(@"button tapped: index=%li", (long)buttonIndex);
        [self.alertView hideWithCompletionBlock:^{
            // stub
        }];
    }];
    
    self.alertView = alertView;
}

- (IBAction)Animation1:(id)sender {
    [self.alertView showWithAnimation:MGAlertAnimationDefault];
}

- (IBAction)Animation2:(id)sender {
    [self.alertView showWithAnimation:MGAlertAnimationFade];
}

- (IBAction)Animation3:(id)sender {
    [self.alertView showWithAnimation:MGAlertAnimationFlipHorizontal];
}

- (IBAction)Animation4:(id)sender {
    [self.alertView showWithAnimation:MGAlertAnimationFlipVertical];
}

- (IBAction)Animation5:(id)sender {
    [self.alertView showWithAnimation:MGAlertAnimationSlideLeft];
}

- (IBAction)Animation6:(id)sender {
    [self.alertView showWithAnimation:MGAlertAnimationTumble];
}

- (IBAction)DoubleBtn:(id)sender {
    
    MGAlertView *testAlert = [MGAlertView dialogWithTitle:@"登录到\"iTunes Store\"" subtitle:@"请为\"zhounaiding@qq.com\"输入密码。"];
    testAlert.blurBackground = NO;
    [testAlert addButtonWithTitle:@"确认"];
    [testAlert addButtonWithTitle:@"取消"];
    [testAlert addKeyboardWithTitle:@"账号" SecureType:NO];
    [testAlert addKeyboardWithTitle:@"密码" SecureType:YES];
    
    [testAlert setHandlerBlock:^(NSInteger buttonIndex, MGAlertView *testAlert) {
        NSLog(@"button tapped: index=%li", (long)buttonIndex);
        [testAlert hideWithCompletionBlock:^{
            // stub
        }];
    }];
    
    [testAlert showWithAnimation:MGAlertAnimationSlideRight];
}

@end
