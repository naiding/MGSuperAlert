//
//  MGSupport.m
//  MGSuperAlert
//
//  Created by LEON on 14/11/8.
//  Copyright (c) 2014年 LEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>


#pragma mark - UIImage + colorful

@interface UIImage (colorful)

+ (UIImage *)imageWithColor:(UIColor *)color;

@end

#pragma mark - UIDevice + OSVersion

@interface UIDevice (OSVersion)

- (BOOL)iOSVersionIsAtLeast:(NSString *)version;

@end


#pragma mark - UIView + Screenshot

@interface UIView (Screenshot)

- (UIImage*)screenshot;

@end

#pragma mark - UIImage + Blur

@interface UIImage (Blur)

-(UIImage *)boxblurImageWithBlur:(CGFloat)blur;

@end

