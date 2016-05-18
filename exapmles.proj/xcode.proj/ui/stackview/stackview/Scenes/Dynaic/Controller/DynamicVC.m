//
//  DynamicVC.m
//  stackview
//
//  Created by CZ on 5/15/16.
//  Copyright © 2016 projm. All rights reserved.
//

#import "DynamicVC.h"

@interface DynamicVC ()

@property (weak, nonatomic) IBOutlet UIStackView *starStackView;

@end

@implementation DynamicVC

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
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Dynamic" image:[UIImage imageNamed:@"test"] selectedImage:[UIImage imageNamed:@"test"]];
    }
    return  self;
}
- (IBAction)onUp:(id)sender {
    UIImageView *star = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dynamic_start"]];
    star.contentMode = UIViewContentModeScaleToFill;
    [self.starStackView addArrangedSubview:star];

    [UIView animateWithDuration:1.0 animations:^{
        [self.starStackView layoutIfNeeded];
    }];
}

- (IBAction)onDown:(id)sender {
    UIImageView *star = [self.starStackView.arrangedSubviews lastObject];
    [self.starStackView removeArrangedSubview:star];
    [star removeFromSuperview];
    [UIView animateWithDuration:1.0 animations:^{
        [self.starStackView layoutIfNeeded];
    }];
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
