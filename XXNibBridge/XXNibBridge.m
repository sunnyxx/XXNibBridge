// XXNibBridge.m
// Version 2.1
//
// Copyright (c) 2015 sunnyxx ( http://github.com/sunnyxx )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "XXNibBridge.h"

@import ObjectiveC;

// Placeholder object mapping
// Using a dictionary mapping (rather than a single BOOL) is because
// nest UIViews will excuted recursively.
// Flag on view's class has a problem:
// Not support nested situation like "FooView.xib" in "FooView.xib"

static NSMutableDictionary *XXNibPlaceholderFlagMapping(void)
{
    static NSMutableDictionary *placeholderMapping;
    if (!placeholderMapping) {
        placeholderMapping = [NSMutableDictionary dictionary];
    }
    return placeholderMapping;
}

static void XXNibPlaceholderSetFlag(Class cls, BOOL flag)
{
    XXNibPlaceholderFlagMapping()[NSStringFromClass(cls)] = @(flag);
}

static BOOL XXNibPlaceholderGetFlag(Class cls)
{
    return [XXNibPlaceholderFlagMapping()[NSStringFromClass(cls)] boolValue];
}

@interface XXNibBridgeImplementation : NSObject

/// our new "- awakeAfterUserCoder:" with "NS_REPLACES_RECEIVER" attribute,
/// which the original method in NSObject has, by what compiler handles
/// right ownership for "self" under ARC.
- (id)hackedAwakeAfterUsingCoder:(NSCoder *)decoder NS_REPLACES_RECEIVER;

@end

@implementation XXNibBridgeImplementation

// Let's hack it
+ (void)load
{
    // Add our "- awakeAfterUsingCoder:" to NSObject class.
    // The original implementation simply returns self.
    // So, we just replace it, no need to call original method.
    SEL selector = @selector(awakeAfterUsingCoder:);
    SEL hackedSelector = @selector(hackedAwakeAfterUsingCoder:);
    IMP newIMP = [XXNibBridgeImplementation instanceMethodForSelector:hackedSelector];
    Method method = class_getInstanceMethod([NSObject class], selector);
    class_replaceMethod([NSObject class], selector, newIMP, method_getTypeEncoding(method));
}

- (id)hackedAwakeAfterUsingCoder:(NSCoder *)decoder
{
    if ([XXNibBridgeImplementation isObjectSupportsNibBridging:self]) {
        
        // Flags here is to break recursion
        if (!XXNibPlaceholderGetFlag([self class])) {
            XXNibPlaceholderSetFlag([self class], YES);
            // "self" is placeholder for this moment, replace it
            return [XXNibBridgeImplementation instantiateRealObjectFromPlaceholderObject:self];
        }
        
        // Reset for next call
        XXNibPlaceholderSetFlag([self class], NO);
    }
    
    return self;
}

+ (BOOL)isObjectSupportsNibBridging:(id)object
{
    // Check whether this class conforms to "<XXNibBridge>"
    if ([[object class] conformsToProtocol:@protocol(XXNibBridge)]) {
        return YES;
    }
    
    // Adapter for old version
    if ([[object class] respondsToSelector:@selector(xx_shouldApplyNibBridging)]) {
        return [[object class] xx_shouldApplyNibBridging];
    }
    
    return NO;
}

+ (id)instantiateRealObjectFromPlaceholderObject:(id)placeholder
{
    // Dispatch to instantiate real object.
    if ([placeholder isKindOfClass:[UIView class]]) {
        return [XXNibBridgeImplementation instantiateRealViewFromPlaceholderView:placeholder];
    } // else will be added for "View Controller bridging"
    return placeholder;
}

+ (UIView *)instantiateRealViewFromPlaceholderView:(UIView *)placeholderView
{
    // Required to conform "XXNibConvension"
    UIView *realView = [[placeholderView class] xx_instantiateFromNib];
    
    // Copy view's basic properties
    realView.frame = placeholderView.frame;
    realView.hidden = placeholderView.hidden;
    realView.tag = placeholderView.tag;
    
    // AutoresizingMasks follow placeholder view's
    realView.autoresizingMask = placeholderView.autoresizingMask;
    realView.translatesAutoresizingMaskIntoConstraints =
    placeholderView.translatesAutoresizingMaskIntoConstraints;
    
    // Copy autolayout constrains from placeholder view to real view
    if (placeholderView.constraints.count > 0) {
        
        // We only need to copy "self" constraints (like width/height constraints)
        // from placeholder to real view
        for (NSLayoutConstraint *constraint in placeholderView.constraints) {
            
            NSLayoutConstraint* newConstraint;
            
            // "Height" or "Width" constraint
            // "self" as its first item, no second item
            if (!constraint.secondItem) {
                newConstraint =
                [NSLayoutConstraint constraintWithItem:realView
                                             attribute:constraint.firstAttribute
                                             relatedBy:constraint.relation
                                                toItem:nil
                                             attribute:constraint.secondAttribute
                                            multiplier:constraint.multiplier
                                              constant:constraint.constant];
            }
            // "Aspect ratio" constraint
            // "self" as its first AND second item
            else if ([constraint.firstItem isEqual:constraint.secondItem]) {
                newConstraint =
                [NSLayoutConstraint constraintWithItem:realView
                                             attribute:constraint.firstAttribute
                                             relatedBy:constraint.relation
                                                toItem:realView
                                             attribute:constraint.secondAttribute
                                            multiplier:constraint.multiplier
                                              constant:constraint.constant];
            }
            
            // Copy properties to new constraint
            if (newConstraint) {
                newConstraint.shouldBeArchived = constraint.shouldBeArchived;
                newConstraint.priority = constraint.priority;
                if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f) {
                    newConstraint.identifier = constraint.identifier;
                }
                [realView addConstraint:newConstraint];
            }
        }
    }
    
    return realView;
}

@end

// Deprecated
@implementation UIView (XXNibBridgeDeprecated)

+ (BOOL)xx_shouldApplyNibBridging
{
    return NO;
}

@end
