// XXNibBridge.m
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

static UIView * XXNibBridgeCreateRealViewFromPlaceholderView(UIView *placeholderView)
{
    // Require nib name is same as class name
    UIView *realView = [[placeholderView class] xx_loadFromNibWithOwner:nil];
    
    // Copy properties
    realView.frame = placeholderView.frame;
    realView.autoresizingMask = placeholderView.autoresizingMask;
    realView.hidden = placeholderView.hidden;
    realView.tag = placeholderView.tag;
    
    // Copy autolayout constrains
    // We only need to copy `self` constraints
    // etc. `width`, `height`, `aspect ratio`
    if (placeholderView.constraints.count > 0) {
        
        // We only need to copy `self` constraints (like width/height constraints)
        // from placeholder to real view
        for (NSLayoutConstraint *constraint in placeholderView.constraints)
        {
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
            newConstraint.shouldBeArchived = constraint.shouldBeArchived;
            newConstraint.priority = constraint.priority;
            [realView addConstraint:newConstraint];
        }
    }
    
    return realView;
}

// Using the "constructor" function attribute, to make it be executed
// after all objc runtime setups (after all +load methods)
__attribute__((constructor)) static void XXNibBridgeHackAwakeAfterUsingCoder()
{
    // Placeholder object mapping
    // Using a dictionary mapping (rather than a single BOOL) is because
    // nest UIViews will excuted recursively
    // Flag on view's class has a problem:
    // Not support nested situation like `FooView.xib` in `FooView.xib`
    static NSMutableDictionary *placeholderMapping = nil;
    placeholderMapping = [NSMutableDictionary dictionary];
    BOOL (^isRealView)(UIView *) = ^BOOL (UIView *view) {
        return [placeholderMapping[NSStringFromClass(view.class)] boolValue];
    };
    void (^setIsRealView)(UIView *, BOOL) = ^(UIView *view, BOOL isPlaceholder) {
        placeholderMapping[NSStringFromClass(view.class)] = @(isPlaceholder);
    };
    
    // New -awakeAfterUsingCoder: body
    id (^newIMPBlock)(id, NSCoder *) = ^id (UIView *self, NSCoder *decoder) {
        
        // Must conform to <XXNibBridge>
        if (![[self class] conformsToProtocol:@protocol(XXNibBridge)]) {
            // Adapter for old version
            if ([(id)[self class] respondsToSelector:@selector(xx_shouldApplyNibBridging)]) {
                BOOL should = [[self class] xx_shouldApplyNibBridging];
                if (!should) {
                    return self;
                }
            }
        }
        
        // First time reach here, `self` is the placeholder view,
        // We need replace `self` to real view that creates from xib file.
        // When +xx_instantiateFromNib called, reaches here again.
        // This flag will break recursion
        if (!isRealView(self)) {
            setIsRealView(self, YES);
            UIView *realView = XXNibBridgeCreateRealViewFromPlaceholderView(self);
            return realView;
        }
        
        // Reset for next call
        setIsRealView(self, NO);
        
        return self;
    };
    
    // Add new method to UIView
    SEL selector = sel_registerName("awakeAfterUsingCoder:");
    Method method = class_getInstanceMethod([UIView class], selector);
    const char *typeEncoding = method_getTypeEncoding(method);
    IMP newIMP = imp_implementationWithBlock(newIMPBlock);
    class_addMethod([UIView class], selector, newIMP, typeEncoding);
}

// Deprecated
@implementation UIView (XXNibBridgeDeprecated)

+ (BOOL)xx_shouldApplyNibBridging
{
    return NO;
}

@end