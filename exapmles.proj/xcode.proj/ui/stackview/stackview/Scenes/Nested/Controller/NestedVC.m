//
//  NestedVC.m
//  stackview
//
//  Created by CZ on 5/15/16.
//  Copyright © 2016 projm. All rights reserved.
//

#import "NestedVC.h"

@interface NestedVC ()

@end

@implementation NestedVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder  {
    if ( self = [super initWithCoder:aDecoder]) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Nested" image:[UIImage imageNamed:@"test"] selectedImage:[UIImage imageNamed:@"test"]];
    }
    return  self;
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
