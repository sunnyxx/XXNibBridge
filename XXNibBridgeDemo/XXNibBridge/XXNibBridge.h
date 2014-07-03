//
//  XXNibBridge.h
//
//  Created by sunnyxx on 14-7-2.
//  Copyright (c) 2014 sunnyxx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (XXIBLoadingConvenient)

/// For convinent, using class name for identifier in IB.
/// etc cell reuse id, storyboard id
+ (NSString *)xx_nibID;

/// UINib object with same name from main bundle
+ (UINib *)xx_nib;

/// Load object of this class from IB file with SAME name
+ (id)xx_loadFromNib;

/// Load UIViewController of this class from given storyboard name
+ (id/*UIViewController*/)xx_loadFromStoryboardNamed:(NSString *)name;

@end


@interface UIView (XXNibBridge)

/// Subclass override it to switch On/Off IB bridging.
/// default -> NO
+ (BOOL)xx_shouldApplyNibBridging;

@end