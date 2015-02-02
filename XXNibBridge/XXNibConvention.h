// XXNibConvention.h
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

@import UIKit;

@interface NSObject (XXNibConvention)

/// For convinent, using class name for identifier in IB.
/// etc. cell reuse id, storyboard id
+ (NSString *)xx_nibID;

/// UINib object with same name from main bundle
+ (UINib *)xx_nib;

@end

@interface UIView (XXNibConvention)

/// Specific "class name" as xib file name, in main bundle, with nil owner
///
/// Required:
///   FooView.h, FooView.m, FooView.xib
/// Usage:
///   FooView *view = [FooView xx_instantiateFromNib];
///
+ (id)xx_instantiateFromNib;

/// Specific "class name" as xib file name
/// See above
+ (id)xx_instantiateFromNibInBundle:(NSBundle *)bundle owner:(id)owner;

@end

@interface UIViewController (XXNibConvention)

/// Specific "class name" as view controller's "storyboard identifier"
+ (id)xx_instantiateFromStoryboardNamed:(NSString *)name;

@end

@interface NSObject (XXNibConventionDeprecated)

/// Load object of this class from IB file with SAME name
+ (id)xx_loadFromNib
__attribute__((deprecated("Use + xx_instantiateFromNib instead")));
+ (id)xx_loadFromNibWithOwner:(id)owner
__attribute__((deprecated("Use + xx_instantiateFromNibInBundle:owner: instead")));

/// Load UIViewController of this class from given storyboard name
+ (id/*UIViewController*/)xx_loadFromStoryboardNamed:(NSString *)name
__attribute__((deprecated("Use + xx_instantiateFromStoryboardNamed: instead")));

@end
