//
//  main.m
//  XXNibBridgeDemo
//
//  Created by sunnyxx on 15/1/8.
//  Copyright (c) 2015年 sunnyxx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXAppDelegate.h"
#import "XXSarkView.h"
#import "XXDogeView.h"
#import "XXNibBridge.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        XXDogeView *dogeView = [XXDogeView xx_instantiateFromNib];
        
//        XXSarkView *sarkView = [XXSarkView xx_instantiateFromNib];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([XXAppDelegate class]));
    }
}
