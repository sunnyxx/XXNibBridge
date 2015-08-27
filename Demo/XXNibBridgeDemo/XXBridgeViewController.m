//
//  XXBridgeViewController.m
//  XXNibBridgeDemo
//
//  Created by GuinsooMBP on 15/8/26.
//  Copyright (c) 2015年 sunnyxx. All rights reserved.
//

#import "XXBridgeViewController.h"
#import "XXNibBridge.h"
#import "XXDogeView.h"
@interface XXBridgeViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dogeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dogeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet XXDogeView *dogeView;

@end

@implementation XXBridgeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [XXNibBridge bridgeInstantiateConstraints:@[@"dogeViewWidthConstraint",@"dogeViewHeightConstraint"] Target:self ForSubview:self.dogeView];
    
    // Do any additional setup after loading the view.
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.dogeViewWidthConstraint.constant = 200;
    self.dogeViewHeightConstraint.constant = 200;

   [UIView animateWithDuration:2 animations:^{
       [self.view layoutIfNeeded];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
