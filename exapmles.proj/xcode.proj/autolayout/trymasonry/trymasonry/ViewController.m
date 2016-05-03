//
//  ViewController.m
//  trymasonry
//
//  Created by CZ on 5/3/16.
//  Copyright © 2016 projm. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) UIView *topLeft;
@property (nonatomic, strong) UIView *topRight;
@property (nonatomic, strong) UIView *bottom;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _topLeft = [UIView new];
    [_topLeft setBackgroundColor: [UIColor yellowColor]];
    _topRight = [UIView new];
    [_topRight setBackgroundColor:[UIColor redColor]];
    _bottom = [UIView new];
    [_bottom setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:_topLeft];
    [self.view addSubview:_topRight];
    [self.view addSubview:_bottom];
    
    
    // AutoLayout with Masonry
    [_topLeft mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(_topRight.mas_width);
        make.top.equalTo(self.view.mas_top).offset(20);
        make.left.equalTo(self.view.mas_left).offset(10);
        make.right.equalTo(_topRight.mas_left).offset(-10);
        make.bottom.equalTo(_bottom.mas_top).offset(-10);
    }];

    [_topRight mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.width.equalTo(_topLeft);
        make.top.equalTo(self.view.mas_top).offset(20);
        make.right.equalTo(self.view.mas_right).offset(-10);
        //make.left.equalTo(_topLeft.mas_left).offset(10);
        make.bottom.equalTo(_bottom.mas_top).offset(-10);
    }];
    
    [_bottom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(_topLeft.mas_height);
        make.left.equalTo(self.view.mas_left).offset(10);
        make.right.equalTo(self.view.mas_right).offset(-10);
        make.bottom.equalTo(self.view.mas_bottom).offset(-10);
    }];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
