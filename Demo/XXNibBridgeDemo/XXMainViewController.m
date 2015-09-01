//
//  XXMainViewController.m
//  XXNibBridgeDemo
//
//  Created by sunnyxx on 15/9/1.
//  Copyright (c) 2015年 sunnyxx. All rights reserved.
//

#import "XXMainViewController.h"
#import "XXNibConvention.h"
#import "XXConvensionCell.h"

@interface XXMainViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@end

@implementation XXMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Use convention for cell reuse identifier.
    [self.tableView registerNib:[XXConvensionCell nib] forCellReuseIdentifier:[XXConvensionCell nibid]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[XXConvensionCell nibid]];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"DetailSegue" sender:nil];
}

@end
