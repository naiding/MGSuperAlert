//
//  MGAlertView.m
//  MGFlipModalViewControllerDemo
//
//  Created by Nicholas Shipes on 12/21/12.
//  Copyright (c) 2012 Urban10 Interactive. All rights reserved.
//

#import "MGAlertView.h"

#define kMGAlertBackgroundRadius 8.0
#define kMGAlertFrameInset 7.0
#define kMGAlertPadding 7.0
#define kMGAlertTextFieldPadding 3.0
#define kMGAlertTextFieldHeight 28.0
#define kMGAlertButtonPadding 6.0
#define kMGAlertButtonHeight 30.0
#define kMGAlertButtonOffset 56.5


@interface MGAlertView ()

//button及其颜色的数组，textfield数组
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) NSMutableArray *btnColor;
@property (nonatomic, strong) NSMutableArray *keyboards;

//标题和副标题字体
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIFont *subtitleFont;

@property (nonatomic, strong) MGAlertWindowOverlay *overlay;
@property (nonatomic, assign) MGAlertAnimation animationType;
@property (nonatomic, strong) MGAlertViewBlock block;

@property (nonatomic, strong) UIView *blurredBackgroundView;
@property (nonatomic, strong) UIWindow *window;

- (CGRect)defaultFrame;
- (void)showOverlay:(BOOL)show;
- (UIView *)blurredBackground;
- (void)buttonTapped:(id)button;
- (void)animateWithType:(MGAlertAnimation)animation show:(BOOL)show completionBlock:(void(^)())completion;
- (void)cleanup;

@end

@implementation MGAlertView
{
@private
    struct
    {
        CGRect titleRect;
        CGRect subtitleRect;
        CGRect buttonRect;
        CGRect keyboradRect;
    } layout;
}

#pragma mark - Class methods

+ (MGAlertView *)dialogWithTitle:(NSString *)title subtitle:(NSString *)subtitle {
	return [[MGAlertView alloc] initWithTitle:title subtitle:subtitle];
}

#pragma mark - init

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:[self defaultFrame]];
	if (self) {
		self.titleFont = [UIFont boldSystemFontOfSize:18.0];
		self.subtitleFont = [UIFont systemFontOfSize:14.0];
		self.animationType = MGAlertAnimationDefault;
		self.buttons = [NSMutableArray array];
        self.keyboards = [NSMutableArray array];
		self.opaque = NO;
		self.alpha = 1.0;
		self.darkenBackground = YES;
		self.blurBackground = YES;
        self.btnColor = [[NSMutableArray alloc] initWithObjects:[UIColor colorWithRed:227.0/255.0 green:100.0/255.0 blue:83.0/255.0 alpha:1],
                                                                [UIColor colorWithRed:87.0/255.0 green:135.0/255.0 blue:173.0/255.0 alpha:1], nil];
	}
	return self;
}

- (id)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle {
	self = [super init];
	if (self) {
		self.title = title;
		self.subtitle = subtitle;
	}
	return self;
}

- (void)setHandlerBlock:(MGAlertViewBlock)block {
	self.block = block;
}

#pragma mark - Buttons

- (NSInteger)addButtonWithTitle:(NSString *)title {	

	MGAlertViewButton *button = [[MGAlertViewButton alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, kMGAlertButtonHeight)];
	[button setTitle:title forState:UIControlStateNormal];
	[button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
	button.titleLabel.font = [UIFont fontWithName:self.titleFont.fontName size:16.0];
    button.layer.cornerRadius = 7.0;
	[self.buttons addObject:button];
	
	return [self.buttons indexOfObject:button];
}

- (BOOL)deleteOneButton
{
    if([self.buttons count] > 0)
    {
        [self.buttons removeObjectAtIndex:[self.buttons count] - 1 ];
        return YES;
    }
    else return  NO;
}

#pragma mark - Keyboards

- (NSInteger)addKeyboardWithTitle:(NSString *)title SecureType:(BOOL)type
{
    MGAlertViewTextField *text = [[MGAlertViewTextField alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, kMGAlertTextFieldHeight)];
    text.placeholder = title;
    text.secureTextEntry = type;
    
    text.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    text.autocapitalizationType = UITextAutocapitalizationTypeNone;
    text.autocorrectionType = UITextAutocorrectionTypeNo;
    text.userInteractionEnabled = YES;
    [self.keyboards addObject:text];
    
    return [self.keyboards indexOfObject:text];
}

- (BOOL)deleteOneKeyboards
{
    if([self.keyboards count] > 0)
    {
        [self.keyboards removeObjectAtIndex:[self.keyboards count] - 1 ];
        return YES;
    }
    else return  NO;
}

#pragma mark - Animations

- (void)show {
	[self animateWithType:self.animationType show:YES completionBlock:nil];
}

- (void)showWithCompletionBlock:(void (^)())completion {
	[self animateWithType:self.animationType show:YES completionBlock:completion];
}

- (void)showWithAnimation:(MGAlertAnimation)animation {
	self.animationType = animation;
	[self animateWithType:self.animationType show:YES completionBlock:nil];
}

- (void)showWithAnimation:(MGAlertAnimation)animation completionBlock:(void (^)())completion {
	self.animationType = animation;
	[self animateWithType:animation show:YES completionBlock:completion];
}

- (void)hide {
	[self animateWithType:self.animationType show:NO completionBlock:nil];
}

- (void)hideWithCompletionBlock:(void (^)())completion {
	[self animateWithType:self.animationType show:NO completionBlock:completion];
}

- (void)hideWithAnimation:(MGAlertAnimation)animation {
	self.animationType = animation;
	[self animateWithType:self.animationType show:NO completionBlock:nil];
}

- (void)hideWithAnimation:(MGAlertAnimation)animation completionBlock:(void (^)())completion {
	self.animationType = animation;
	[self animateWithType:animation show:NO completionBlock:completion];
}

#pragma mark - Drawing

// 搭好框架
- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGFloat layoutFrameInset = kMGAlertFrameInset + kMGAlertPadding;
	CGRect layoutFrame = CGRectInset(self.bounds, layoutFrameInset, layoutFrameInset);
	CGFloat layoutWidth = CGRectGetWidth(layoutFrame);
	
	// title frame
	CGFloat titleHeight = 0;
	CGFloat minY = CGRectGetMinY(layoutFrame);
	if (self.title.length > 0) {
		titleHeight = [self.title sizeWithFont:self.titleFont constrainedToSize:CGSizeMake(layoutWidth, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping].height;
		minY += kMGAlertPadding;
	}
	layout.titleRect = CGRectMake(CGRectGetMinX(layoutFrame), minY, layoutWidth, titleHeight);
	
	// subtitle frame
	CGFloat subtitleHeight = 0;
	minY = CGRectGetMaxY(layout.titleRect);
	if (self.subtitle.length > 0) {
		subtitleHeight = [self.subtitle sizeWithFont:self.subtitleFont constrainedToSize:CGSizeMake(layoutWidth, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping].height + 1;
		minY += kMGAlertPadding;
	}
	layout.subtitleRect = CGRectMake(CGRectGetMinX(layoutFrame), minY, layoutWidth, subtitleHeight);
    
    // keyboards frame
    CGFloat keyboardsHeight = 0;
    minY = CGRectGetMaxY(layout.subtitleRect);
    if (self.keyboards.count > 0) {
        keyboardsHeight = kMGAlertTextFieldHeight;
        minY = kMGAlertPadding + minY + 3;
    }
    layout.keyboradRect = CGRectMake(CGRectGetMinX(layoutFrame), minY, layoutWidth, keyboardsHeight);
    
    // buttons frame
    CGFloat buttonsHeight = 0;
    minY = CGRectGetMaxY(layout.subtitleRect);
    if (self.buttons.count > 0) {
        buttonsHeight = kMGAlertButtonHeight;
        minY += kMGAlertPadding;
    }
    CGFloat buttonRegionPadding = ((kMGAlertButtonOffset - kMGAlertFrameInset) - kMGAlertButtonHeight) / 2.0 - 2.0;
    layout.buttonRect = CGRectMake(CGRectGetMinX(layoutFrame), CGRectGetMaxY(self.bounds) - kMGAlertButtonOffset + buttonRegionPadding, layoutWidth, buttonsHeight);
	
	// adjust layout frame
	layoutFrame.size.height = CGRectGetMaxY(layout.buttonRect);
	
	// layout buttons
	NSUInteger count = self.buttons.count;
	if (count > 0) {
		CGFloat buttonWidth = (CGRectGetWidth(layout.buttonRect) - kMGAlertButtonPadding * ((CGFloat)count - 1.0)) / (CGFloat)count;
        
        if(count == 2) //为count为2时特别支持的
        {
            CGRect addView1,addView2,addView3,addView4,addView5,addView6;
            
            addView1 = CGRectMake(7, CGRectGetHeight(self.frame) - kMGAlertButtonHeight - 7, 7,7);
            addView2 = CGRectMake(CGRectGetWidth(self.frame) * 0.5 - 7, CGRectGetHeight(self.frame) - kMGAlertButtonHeight - 7, 7, 7);
            addView3 = CGRectMake(CGRectGetWidth(self.frame) * 0.5, CGRectGetHeight(self.frame) - kMGAlertButtonHeight - 7, 7, 7);
            addView4 = CGRectMake(CGRectGetWidth(self.frame) - 14, CGRectGetHeight(self.frame) - kMGAlertButtonHeight - 7, 7, 7);
            addView5 = CGRectMake(CGRectGetWidth(self.frame) * 0.5 - 7, CGRectGetHeight(self.frame) - 14, 7, 7);
            addView6 = CGRectMake(CGRectGetWidth(self.frame) * 0.5, CGRectGetHeight(self.frame) - 14, 7, 7);
            
            UIView *add1 = [[UIView alloc] initWithFrame:addView1];
            UIView *add2 = [[UIView alloc] initWithFrame:addView2];
            UIView *add3 = [[UIView alloc] initWithFrame:addView3];
            UIView *add4 = [[UIView alloc] initWithFrame:addView4];
            UIView *add5 = [[UIView alloc] initWithFrame:addView5];
            UIView *add6 = [[UIView alloc] initWithFrame:addView6];
            
            add1.backgroundColor = add2.backgroundColor = add5.backgroundColor = [UIColor colorWithRed:87.0/255.0 green:135.0/255.0 blue:173.0/255.0 alpha:1];
            add3.backgroundColor = add4.backgroundColor = add6.backgroundColor =[UIColor colorWithRed:227.0/255.0 green:100.0/255.0 blue:83.0/255.0 alpha:1];
            
            [self addSubview:add1];
            [self addSubview:add2];
            [self addSubview:add3];
            [self addSubview:add4];
            [self addSubview:add5];
            [self addSubview:add6];
        }
        
		for (int i = 0; i < count; i++) {
			CGFloat xOffset = CGRectGetMinX(layout.buttonRect) + (kMGAlertButtonPadding + buttonWidth) * (CGFloat)i;
            CGRect frame;
            MGAlertViewButton *button = (MGAlertViewButton *)[self.buttons objectAtIndex:i];
            if (count == 2 ) {
                if ( i == 0 ) {
                    frame =CGRectIntegral(CGRectMake(xOffset - 7, CGRectGetHeight(self.frame) - kMGAlertButtonHeight - 7, (CGRectGetWidth(self.frame)-15 )/ 2, CGRectGetHeight(layout.buttonRect)));
                    button.frame = frame;
                }
                if (i == 1) {
                    frame =CGRectIntegral(CGRectMake(xOffset - 3, CGRectGetHeight(self.frame) - kMGAlertButtonHeight - 7, (CGRectGetWidth(self.frame)-15 )/ 2, CGRectGetHeight(layout.buttonRect)));
                    button.frame = frame;
                }
            }
            else
            {
                frame = CGRectIntegral(CGRectMake(xOffset, CGRectGetHeight(self.frame) - kMGAlertButtonHeight - 10 , buttonWidth, CGRectGetHeight(layout.buttonRect)));
                button.frame = frame;
            }
			button.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
            if (i % 2 == 1)
                [button setBackgroundImage:[UIImage imageWithColor:[self.btnColor objectAtIndex:0]] forState:UIControlStateNormal];
            if( i % 2 == 0)
                [button setBackgroundImage:[UIImage imageWithColor:[self.btnColor objectAtIndex:1]] forState:UIControlStateNormal];
			[self addSubview:button];
		}
	}
    
    //layout textFields
    NSUInteger n = self.keyboards.count;
    if (n > 0) {
        CGFloat keyboardHeight = 0;
        for (int i = 0; i < n; i++) {
            MGAlertViewTextField *text = (MGAlertViewTextField *)[self.keyboards objectAtIndex:i];
            
            keyboardHeight = CGRectGetMinY(layout.keyboradRect) + i * kMGAlertTextFieldHeight ;
            text.frame = CGRectMake(CGRectGetMinX(layoutFrame)+ 15, keyboardHeight, layoutWidth - 40, keyboardsHeight);
            
            text.autoresizingMask = UIViewAutoresizingNone;
            [self addSubview:text];
        }
    }
	
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	CGRect dialogFrame = self.frame;
	dialogFrame.size = self.bounds.size;
	dialogFrame.origin.x = (CGRectGetWidth(window.bounds) - CGRectGetWidth(dialogFrame)) / 2.0;
	dialogFrame.origin.y = (CGRectGetHeight(window.bounds) - CGRectGetHeight(dialogFrame)) / 2.0;
	self.frame = CGRectIntegral(dialogFrame);
	
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	/// Dialog Background Drawing ///
	
	// base shape
	CGRect activeBounds = self.bounds;
	CGFloat cornerRadius = kMGAlertBackgroundRadius;	
	CGRect pathFrame = CGRectInset(self.bounds, kMGAlertFrameInset, kMGAlertFrameInset);
	CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:pathFrame cornerRadius:cornerRadius].CGPath;
	
	// clip context to main shape
	CGContextSaveGState(context);
	CGContextAddPath(context, path);
	CGContextClip(context);
    
	 //background gradient
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	size_t count = 3;
	CGFloat locations[3] = {0.0f, 0.57f, 1.0f};
	CGFloat components[12] =
    {
        255.0f/255.0f, 255.0f/255.0f, 255.0f/255.0f, 1.0f,     //1
        255.0f/255.0f, 255.0f/255.0f, 255.0f/255.0f, 1.0f,     //2
        255.0f/255.0f, 255.0f/255.0f, 255.0f/255.0f, 1.0f      //3
    };
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, count);
	CGPoint startPoint = CGPointMake(activeBounds.size.width * 0.5f, 0.0f);
	CGPoint endPoint = CGPointMake(activeBounds.size.width * 0.5f, activeBounds.size.height);
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	CGColorSpaceRelease(colorSpace);
	CGGradientRelease(gradient);
	
	
	/// Text Drawing ///
	// draw title
	if (self.title.length > 0) {
		[[UIColor blackColor] set];
		[self.title drawInRect:layout.titleRect withFont:self.titleFont lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentCenter];
	}
	
	// draw subtitle
	if (self.subtitle.length > 0) {
		[[UIColor blackColor] set];
		[self.subtitle drawInRect:layout.subtitleRect withFont:self.subtitleFont lineBreakMode:0 alignment:NSTextAlignmentCenter];
	}	
}

#pragma mark - Private

- (CGRect)defaultFrame {
	CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
	// keep alert view in center of app frame
	CGRect insetFrame = CGRectIntegral(CGRectInset(appFrame, (appFrame.size.width - 280.0) / 2, (appFrame.size.height - 180.0) / 2));
	
	return insetFrame;
}

- (void)buttonTapped:(id)button {
	NSUInteger buttonIndex = [self.buttons indexOfObject:(MGAlertViewButton *)button];
	if (self.block)
		self.block(buttonIndex, self);
}

- (UIView *)blurredBackground {
	UIView *backgroundView = [[UIApplication sharedApplication] keyWindow];
	UIImageView *blurredView = [[UIImageView alloc] initWithFrame:backgroundView.bounds];
	blurredView.image = [[backgroundView screenshot] boxblurImageWithBlur:0.08];
	
	return blurredView;
}

- (void)animateWithType:(MGAlertAnimation)animation show:(BOOL)show completionBlock:(void (^)())completion {
	// make sure everything is laid out before we try animation, otherwise we get some sketchy things happening
	// especially with the buttons
	if (show) {
		[self setNeedsLayout];
		[self layoutIfNeeded];
	}
	
	// fade animation
	if (animation == MGAlertAnimationFade) {
        if(show)
        {
            [self showOverlay:YES];
            self.transform = CGAffineTransformMakeScale(0.97, 0.97);
            [UIView animateWithDuration:0.15 animations:^{
                self.transform = CGAffineTransformIdentity;
                self.alpha = 1.0f;
            } completion:^(BOOL finished) {
                if (completion)
                    completion();
            }];
        }
        else {
            [self showOverlay:NO];
            [UIView animateWithDuration:0.15 animations:^{
            self.transform = CGAffineTransformMakeScale(0.97, 0.97);
            self.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [self cleanup];
                if (completion)
                    completion();
            }];
        }
    }
	// horizontal flip animation
	else if (animation == MGAlertAnimationFlipHorizontal || animation == MGAlertAnimationFlipVertical) {
		
		CGFloat xAxis = (animation == MGAlertAnimationFlipVertical) ? 1.0 : 0.0;
		CGFloat yAxis = (animation == MGAlertAnimationFlipHorizontal) ? 1.0 : 0.0;
		
		if (show) {
			self.layer.zPosition = 100;
			
			CATransform3D perspectiveTransform = CATransform3DIdentity;
			perspectiveTransform.m34 = 1.0 / -500;
			
			// initial starting rotation
			self.layer.transform = CATransform3DConcat(CATransform3DMakeRotation(70.0 * M_PI / 180.0, xAxis, yAxis, 0.0), perspectiveTransform);
			self.alpha = 0.0f;
			
			[self showOverlay:YES];
			
			[UIView animateWithDuration:0.2 animations:^{ // flip remaining + bounce
				self.layer.transform = CATransform3DConcat(CATransform3DMakeRotation(-25.0 * M_PI / 180.0, xAxis, yAxis, 0.0), perspectiveTransform);
				self.alpha = 1.0f;
			} completion:^(BOOL finished) {
				[UIView animateWithDuration:0.13 animations:^{
				 self.layer.transform = CATransform3DConcat(CATransform3DMakeRotation(12.0 * M_PI / 180.0, xAxis, yAxis, 0.0), perspectiveTransform);
				} completion:^(BOOL finished) {
					[UIView animateWithDuration:0.1 animations:^{
						self.layer.transform = CATransform3DConcat(CATransform3DMakeRotation(-8.0 * M_PI / 180.0, xAxis, yAxis, 0.0), perspectiveTransform);
					} completion:^(BOOL finished) {
					   [UIView animateWithDuration:0.1 animations:^{
						   self.layer.transform = CATransform3DConcat(CATransform3DMakeRotation(0.0 * M_PI / 180.0, xAxis, yAxis, 0.0), perspectiveTransform);
					   } completion:^(BOOL finished) {
						   if (completion)
							   completion();
					   }];
					}];
				}];
			}];
		}
		else {
			[self showOverlay:NO];
			
			self.layer.zPosition = 100;
			self.alpha = 1.0f;
			
			CATransform3D perspectiveTransform = CATransform3DIdentity;
			perspectiveTransform.m34 = 1.0 / -500;
			
			[UIView animateWithDuration:0.08 animations:^{
				self.layer.transform = CATransform3DConcat(CATransform3DMakeRotation(-10.0 * M_PI / 180.0, xAxis, yAxis, 0.0), perspectiveTransform);
			} completion:^(BOOL finished) {
				[UIView animateWithDuration:0.17 animations:^{
					self.layer.transform = CATransform3DConcat(CATransform3DMakeRotation(70.0 * M_PI / 180.0, xAxis, yAxis, 0.0), perspectiveTransform);
					self.alpha = 0.0f;
				} completion:^(BOOL finished) {
					[self cleanup];
					if (completion)
						completion();
				}];
			}];
		}
	}
	
	// tumble animation
	else if (animation == MGAlertAnimationTumble) {
		if (show) {
			[self showOverlay:YES];
			
			CATransform3D rotate = CATransform3DMakeRotation(70.0 * M_PI / 180.0, 0.0, 0.0, 1.0);
			CATransform3D translate = CATransform3DMakeTranslation(20.0, -500.0, 0.0);
			self.layer.transform = CATransform3DConcat(rotate, translate);
			
			[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
				self.layer.transform = CATransform3DIdentity;
			} completion:^(BOOL finished) {
				if (completion)
					completion();
			}];
		}
		else {
			[self showOverlay:NO];
			
			[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
				CATransform3D rotate = CATransform3DMakeRotation(-70.0 * M_PI / 180.0, 0.0, 0.0, 1.0);
				CATransform3D translate = CATransform3DMakeTranslation(-20.0, 500.0, 0.0);
				self.layer.transform = CATransform3DConcat(rotate, translate);
			} completion:^(BOOL finished) {
				[self cleanup];
				if (completion)
					completion();
			}];
		}
	}
	
	// slide animation
	else if (animation == MGAlertAnimationSlideLeft || animation == MGAlertAnimationSlideRight) {		
		if (show) {
			[self showOverlay:YES];
			
			CGFloat startX = (animation == MGAlertAnimationSlideLeft) ? 200.0 : -200.0;
			CGFloat shiftX = 5.0;
			if (animation == MGAlertAnimationSlideLeft)
				shiftX *= -1.0;
			
			self.layer.transform = CATransform3DMakeTranslation(startX, 0.0, 0.0);
			[UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
				self.layer.transform = CATransform3DMakeTranslation(shiftX, 0.0, 0.0);
			} completion:^(BOOL finished) {
				[UIView animateWithDuration:0.1 animations:^{
					self.layer.transform = CATransform3DIdentity;
				} completion:^(BOOL finished) {
					if (completion)
						completion();
				}];
			}];
		}
		else {
			[self showOverlay:NO];
			
			CGFloat finalX = (animation == MGAlertAnimationSlideLeft) ? -400.0 : 400.0;
			CGFloat shiftX = 5.0;
			if (animation == MGAlertAnimationSlideRight)
				shiftX *= 1.0;
			
			[UIView animateWithDuration:0.1 animations:^{
				self.layer.transform = CATransform3DMakeTranslation(shiftX, 0.0, 0.0);
			} completion:^(BOOL finished) {
				[UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
					self.layer.transform = CATransform3DMakeTranslation(finalX, 0.0, 0.0);
				} completion:^(BOOL finished) {
					[self cleanup];
					if (completion)
						completion();
				}];
			}];
		}
	}
	
	// default "pop" animation like UIAlertView
	else {
		if (show) {
			[self showOverlay:YES];
			
			self.alpha = 0.0f;			
			[UIView animateWithDuration:0.17 animations:^{
				self.layer.transform = CATransform3DMakeScale(1.1, 1.1, 1.0);
				self.alpha = 1.0f;
			} completion:^(BOOL finished) {
				[UIView animateWithDuration:0.12 animations:^{
					self.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1.0);
				} completion:^(BOOL finished) {
					[UIView animateWithDuration:0.1 animations:^{
						self.layer.transform = CATransform3DIdentity;
					} completion:^(BOOL finished) {
						if (completion)
							completion();
					}];
				}];
			}];
		}
		else {
			[self showOverlay:NO];
			
			[UIView animateWithDuration:0.1 animations:^{
				self.layer.transform = CATransform3DMakeScale(1.1, 1.1, 1.0);
			} completion:^(BOOL finished) {
				[UIView animateWithDuration:0.15 animations:^{
					self.layer.transform = CATransform3DIdentity;
					self.alpha = 0.0f;
				} completion:^(BOOL finished) {
					[self cleanup];
					if (completion)
						completion();
				}];
			}];
		}
	}
}

- (void)showOverlay:(BOOL)show {
	if (show) {
		// create a new window to add our overlay and dialogs to
		UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		self.window = window;
		window.windowLevel = UIWindowLevelStatusBar + 1;
		window.opaque = NO;
		
		// darkened background
		if (self.darkenBackground) {
			self.overlay = [MGAlertWindowOverlay new];
			MGAlertWindowOverlay *overlay = self.overlay;
			overlay.opaque = NO;
			overlay.alertView = self;
			overlay.frame = self.window.bounds;
			overlay.alpha = 0.0;
		}
		
		// blurred background
		if (self.blurBackground) {
			self.blurredBackgroundView = [self blurredBackground];
			self.blurredBackgroundView.alpha = 0.0f;
			[self.window addSubview:self.blurredBackgroundView];
		}
		
		[self.window addSubview:self.overlay];
		[self.window addSubview:self];
		
		// window has to be un-hidden on the main thread
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.window makeKeyAndVisible];
			
			// fade in overlay
			[UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
				self.blurredBackgroundView.alpha = 1.0f;
				self.overlay.alpha = 1.0f;
			} completion:^(BOOL finished) {
				// stub
			}];
		});
	}
	else {
		[UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
			self.overlay.alpha = 0.0f;
			self.blurredBackground.alpha = 0.0f;
		} completion:^(BOOL finished) {
			self.blurredBackgroundView = nil;
		}];
	}
}

- (void)cleanup {
	self.layer.transform = CATransform3DIdentity;
	self.transform = CGAffineTransformIdentity;
	self.alpha = 1.0f;
	self.window = nil;
	// rekey main AppDelegate window
	[[[[UIApplication sharedApplication] delegate] window] makeKeyWindow];
}

@end