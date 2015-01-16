// XXNibBridge.m
// Version 2.0
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

#if !__has_feature(objc_arc)
#error XXNibBridge must use in arc mode.
#endif

@import ObjectiveC;

static UIView *XXNibBridgeCreateRealViewFromPlaceholderView(UIView *placeholderView)
{
    // Require conform "XXNibConvension"
    UIView *realView = [[placeholderView class] xx_instantiateFromNib];
    
    // Copy view's basic properties
    realView.frame = placeholderView.frame;
    realView.hidden = placeholderView.hidden;
    realView.tag = placeholderView.tag;
    
    // AutoresizingMasks follow placeholder view
    realView.autoresizingMask = placeholderView.autoresizingMask;
    realView.translatesAutoresizingMaskIntoConstraints =
    placeholderView.translatesAutoresizingMaskIntoConstraints;
    
    // Copy autolayout constrains
    // We only need to copy "self" constraints
    // etc. "width", "height", "aspect ratio"
    if (placeholderView.constraints.count > 0) {
        
        // We only need to copy "self" constraints (like width/height constraints)
        // from placeholder to real view
        for (NSLayoutConstraint *constraint in placeholderView.constraints) {
            
            NSLayoutConstraint* newConstraint;
            
            // "Height" or "Width" constraint
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

// Placeholder object mapping
// Using a dictionary mapping (rather than a single BOOL) is because
// nest UIViews will excuted recursively
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

// Using the "constructor" function attribute, to make it be executed
// after all objc runtime setups (after all +load methods)
__attribute__((constructor)) static void XXNibBridgeHackAwakeAfterUsingCoder(void)
{
    // New "-awakeAfterUsingCoder:" body
    // Important:
    //   This method is declared appending with "NS_REPLACES_RECEIVER" attribute,
    //   it changes memory management ownership of return value. So our block version
    //   has to obey it, looks weird, must put this attribute in block's declaration.
    id (^newIMPBlock)(id, NSCoder *) NS_REPLACES_RECEIVER =
    ^id (UIView *self, __unused NSCoder *decoder) NS_REPLACES_RECEIVER {
        
        // Check whether conform to "<XXNibBridge>"
        if (![self.class conformsToProtocol:@protocol(XXNibBridge)]) {
            
            // Adapter for old version
            if ([(id)self.class respondsToSelector:@selector(xx_shouldApplyNibBridging)]) {
                BOOL should = [self.class xx_shouldApplyNibBridging];
                if (!should) {
                    return self;
                }
            }
        }
        
        // First time reach here, "self" is the placeholder view,
        // We need replace "self" to real view that creates from xib file.
        // When +xx_instantiateFromNib called, reaches here again.
        // This flag will break recursion
        if (!XXNibPlaceholderGetFlag(self.class)) {
            XXNibPlaceholderSetFlag(self.class, YES);
            UIView *realView = XXNibBridgeCreateRealViewFromPlaceholderView(self);
            return realView;
        }
        
        // Reset for next call
        XXNibPlaceholderSetFlag(self.class, NO);
        
        return self;
    };
    
    // Add new method to UIView
    SEL selector = @selector(awakeAfterUsingCoder:);
    Method method = class_getInstanceMethod([UIView class], selector);
    IMP newIMP = imp_implementationWithBlock(newIMPBlock);
    const char *typeEncoding = method_getTypeEncoding(method);
    class_addMethod([UIView class], selector, newIMP, typeEncoding);
}

// Deprecated
@implementation UIView (XXNibBridgeDeprecated)

+ (BOOL)xx_shouldApplyNibBridging
{
    return NO;
}

@end
