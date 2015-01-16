// XXNibConveninets.m
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

#import "XXNibConvention.h"

#if !__has_feature(objc_arc)
#error XXNibConvention must use in arc mode.
#endif

@implementation NSObject (XXNibConvention)

+ (NSString *)xx_nibID
{
    return NSStringFromClass([self class]);
}

+ (UINib *)xx_nib
{
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
}

@end

@implementation UIView (XXNibConvention)

+ (id)xx_instantiateFromNib
{
    return [self xx_instantiateFromNibInBundle:nil owner:nil];
}

+ (id)xx_instantiateFromNibInBundle:(NSBundle *)bundle owner:(id)owner
{
    NSArray *views = [[self xx_nib] instantiateWithOwner:owner options:nil];
    for (UIView *view in views) {
        if ([view isMemberOfClass:[self class]]) {
            return view;
        }
    }
    NSAssert(NO, @"Expect file: %@", [NSString stringWithFormat:@"%@.xib", NSStringFromClass([self class])]);
    return nil;
}

@end

@implementation UIViewController (XXNibConvention)

+ (id)xx_instantiateFromStoryboardNamed:(NSString *)name
{
    NSParameterAssert(name.length > 0);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:name bundle:nil];
    NSAssert(storyboard != nil, @"Expect file: %@", [NSString stringWithFormat:@"%@.storyboard", name]);
    if (!storyboard) {
        return nil;
    }
    id viewController = [storyboard instantiateViewControllerWithIdentifier:[self xx_nibID]];
    return viewController;
}

@end

@implementation NSObject (XXNibConventionDeprecated)

+ (id)xx_loadFromNib
{
    return [self xx_loadFromNibWithOwner:nil];
}

+ (id)xx_loadFromNibWithOwner:(id)owner
{
    NSArray *objects = [[self xx_nib] instantiateWithOwner:owner options:nil];
    for (UIView *obj in objects) {
        if ([obj isMemberOfClass:[self class]]) {
            return obj;
        }
    }
    return nil;
}

+ (id)xx_loadFromStoryboardNamed:(NSString *)name
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:name bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:[self xx_nibID]];
}

@end
