//
//  XXDogeView.m
//  XXInterfaceBuilderBridgeDemo
//
//  Created by sunnyxx on 14-7-2.
//  Copyright (c) 2014年 sunnyxx. All rights reserved.
//

#import "XXDogeView.h"
#import "XXNibBridge.h"

@interface XXDogeView () <XXNibBridge>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomconstraint;

@end

@implementation XXDogeView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
}
//+ (BOOL)xx_shouldApplyNibBridging
//{
//    return YES;
//}
- (IBAction)buttonAction:(id)sender
{
     
}
- (IBAction)fuckMe:(id)sender
{
    
}

@end
