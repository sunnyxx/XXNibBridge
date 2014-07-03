//
//  XXInterfaceBuilderBridge.m
//  XXInterfaceBuilderBridgeDemo
//
//  Created by sunnyxx on 14-7-2.
//  Copyright (c) 2014年 sunnyxx. All rights reserved.
//

#import "XXNibBridge.h"

@implementation NSObject (XXNibLoading)

+ (NSString *)xx_IBID
{
    return NSStringFromClass(self);
}

+ (id)xx_loadFromNib
{
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(self) bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    for (UIView *obj in objects)
    {
        if ([obj isMemberOfClass:self])
        {
            return obj;
        }
    }
    return nil;
}

+ (id)xx_loadFromStoryboardNamed:(NSString *)name
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:name bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:[self xx_IBID]];
}

+ (UINib *)xx_nib
{
    return [UINib nibWithNibName:[self xx_IBID] bundle:nil];
}

@end

// Mapping flags that whether a class has been replaced

static NSMutableDictionary * getIBReplaceFlagMapping()
{
    static NSMutableDictionary *mapping = nil;
    if (!mapping)
    {
        mapping = [NSMutableDictionary dictionary];
    }
    return mapping;
}

static BOOL getIBReplaceFlag(Class cls)
{
    NSMutableDictionary *mapping = getIBReplaceFlagMapping();
    BOOL flag = [mapping[NSStringFromClass(cls)] boolValue];
    return flag;
}

static void setIBReplaceFlag(Class cls, BOOL flag)
{
    NSMutableDictionary *mapping = getIBReplaceFlagMapping();
    mapping[NSStringFromClass(cls)] = @(flag);
}

@implementation UIView (XXNibBridge)

+ (BOOL)xx_shouldApplyIBBridging
{
    return NO;
}

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder
{
    self = [super awakeAfterUsingCoder:aDecoder];
    
    if (![[self class] xx_shouldApplyNibBridging])
    {
        return self;
    }
    
    // self will be replaced by object created from nib
    
    if (!getIBReplaceFlag([self class]))
    {
        setIBReplaceFlag([self class], YES);
        
        // Require nib name is equal to class name
        UIView *view = [[self class] xx_loadFromNib];
        
        NSAssert(view, @"View of class [%@] could not load from nib, check whether the view in nib binds the correct class", [[self class] xx_IBID]);
        
        view.frame = self.frame;
        view.autoresizingMask = self.autoresizingMask;
        
        // Autolayout support
        if ([view respondsToSelector:@selector(translatesAutoresizingMaskIntoConstraints)])
        {
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        // Autolayout constrains replacing
        // Replace all constrains from `placeholder(self)` view to `real` view
        if ([view respondsToSelector:@selector(constraints)] && self.constraints.count > 0)
        {
            [self replaceAutolayoutConstrainsFromView:self toView:view];
        }
        
        return view;
    }
    
    // Reset flag
    setIBReplaceFlag([self class], NO);
    
    return self;
}

- (void)replaceAutolayoutConstrainsFromView:(UIView *)placeholderView toView:(UIView *)realView
{
    // We only need to copy `self` constraints (like width/height constraints)
    // from placeholder to real view
    for (NSLayoutConstraint *constraint in placeholderView.constraints)
    {
        NSLayoutConstraint* newConstraint  = [NSLayoutConstraint constraintWithItem:realView
                                                 attribute:constraint.firstAttribute
                                                 relatedBy:constraint.relation
                                                 toItem:nil // Only first item
                                                 attribute:constraint.secondAttribute
                                                 multiplier:constraint.multiplier
                                                 constant:constraint.constant];
        newConstraint.shouldBeArchived = constraint.shouldBeArchived;
        newConstraint.priority = constraint.priority;
        [realView addConstraint:newConstraint];
    }
}
@end