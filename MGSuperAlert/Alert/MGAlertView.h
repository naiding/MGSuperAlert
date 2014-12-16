//
//  MGAlertView.h
//  MGFlipModalViewControllerDemo
//
//  Created by Nicholas Shipes on 12/21/12.
//  Copyright (c) 2012 MGan10 Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGAlertViewSupport.h"
#import "MGAlertWindowOverlay.h"
#import "MGAlertViewButton.h"
#import "MGAlertViewTextField.h"

enum {
	MGAlertAnimationDefault = 0,
	MGAlertAnimationFade,
	MGAlertAnimationFlipHorizontal,
	MGAlertAnimationFlipVertical,
	MGAlertAnimationTumble,
	MGAlertAnimationSlideLeft,
	MGAlertAnimationSlideRight
};
typedef NSInteger MGAlertAnimation;

@interface MGAlertView : UIView

typedef void (^MGAlertViewBlock)(NSInteger buttonIndex, MGAlertView *alertView);

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) BOOL darkenBackground;
@property (nonatomic, assign) BOOL blurBackground;

+ (MGAlertView *)dialogWithTitle:(NSString *)title subtitle:(NSString *)subtitle;

- (NSInteger)addButtonWithTitle:(NSString *)title;
- (BOOL)deleteOneButton;
- (NSInteger)addKeyboardWithTitle:(NSString *)title SecureType:(BOOL)type;
- (BOOL)deleteOneKeyboards;
- (void)setHandlerBlock:(MGAlertViewBlock)block;

- (void)show;
- (void)showWithCompletionBlock:(void(^)())completion;
- (void)showWithAnimation:(MGAlertAnimation)animation;
- (void)showWithAnimation:(MGAlertAnimation)animation completionBlock:(void(^)())completion;

- (void)hide;
- (void)hideWithCompletionBlock:(void(^)())completion;
- (void)hideWithAnimation:(MGAlertAnimation)animation;
- (void)hideWithAnimation:(MGAlertAnimation)animation completionBlock:(void(^)())completion;

@end
