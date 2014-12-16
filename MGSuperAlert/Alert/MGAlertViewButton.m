//
//  MGAlertViewButton.m
//  MGSuperAlert
//
//  Created by LEON on 14/11/8.
//  Copyright (c) 2014年 LEON. All rights reserved.
//

#import "MGAlertViewButton.h"


#pragma mark - MGAlertViewButton

@implementation MGAlertViewButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self = [UIButton buttonWithType:UIButtonTypeCustom];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 3.0;
    }
    return self;
}
@end

