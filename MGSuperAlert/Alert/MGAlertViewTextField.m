//
//  MGAlertViewTextField.m
//  MGSuperAlert
//
//  Created by LEON on 14/11/8.
//  Copyright (c) 2014年 LEON. All rights reserved.
//

#import "MGAlertViewTextField.h"

#pragma mark - MGAlertViewTextField

@implementation MGAlertViewTextField

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.borderStyle = UITextBorderStyleRoundedRect;
        self.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
        self.autocapitalizationType = UITextAutocapitalizationTypeWords;
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.layer.cornerRadius = 3.0f;
        self.layer.masksToBounds = YES;
        
        
    }
    return self;
}

@end