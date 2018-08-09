//
//  ViewController.m
//  BeaconMac
//
//  Created by dongliyun on 2018/8/8.
//  Copyright © 2018年 LY. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController() 
@property (weak) IBOutlet NSButton *startBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewDidAppear{
    [super viewDidAppear];
}
- (void)viewWillDisappear{
    [super viewWillDisappear];
}

- (IBAction)clickStartBtn:(NSButton *)sender {
}
@end
