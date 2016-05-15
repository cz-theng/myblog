//
//  AttributeVC.m
//  stackview
//
//  Created by CZ on 5/15/16.
//  Copyright © 2016 projm. All rights reserved.
//

#import "AttributeVC.h"

@interface AttributeVC ()
@property (weak, nonatomic) IBOutlet UIStackView *horiStackView;
@property (weak, nonatomic) IBOutlet UIStackView *verStackView;

@end

@implementation AttributeVC

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
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Attribute" image:[UIImage imageNamed:@"test"] selectedImage:[UIImage imageNamed:@"test"]];
    }
    return  self;
}
- (IBAction)onHoriAliSelect:(UISegmentedControl *)sender {
    [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (sender.selectedSegmentIndex == 0) {
            self.horiStackView.alignment = UIStackViewAlignmentFill;
        }else if (sender.selectedSegmentIndex == 1) {
            self.horiStackView.alignment = UIStackViewAlignmentLeading;
        }else if (sender.selectedSegmentIndex == 2) {
            self.horiStackView.alignment = UIStackViewAlignmentLeading;
        }else if (sender.selectedSegmentIndex == 3) {
            self.horiStackView.alignment = UIStackViewAlignmentFirstBaseline;
        }else if (sender.selectedSegmentIndex == 4) {
            self.horiStackView.alignment = UIStackViewAlignmentCenter;
        }else if (sender.selectedSegmentIndex == 5) {
            self.horiStackView.alignment = UIStackViewAlignmentTrailing;
        }else if (sender.selectedSegmentIndex == 6) {
            self.horiStackView.alignment = UIStackViewAlignmentBottom;
        }else if (sender.selectedSegmentIndex == 7) {
            self.horiStackView.alignment = UIStackViewAlignmentLastBaseline;
        }
    } completion:nil];

}

- (IBAction)onHoriDistSelect:(UISegmentedControl *)sender {
    [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (sender.selectedSegmentIndex == 0) {
            self.horiStackView.distribution = UIStackViewDistributionFill;
        }else if (sender.selectedSegmentIndex == 1) {
            self.horiStackView.distribution = UIStackViewDistributionFillEqually;
        }else if (sender.selectedSegmentIndex == 2) {
            self.horiStackView.distribution = UIStackViewDistributionFillProportionally;
        }else if (sender.selectedSegmentIndex == 3) {
            self.horiStackView.distribution = UIStackViewDistributionEqualSpacing;
        }else if (sender.selectedSegmentIndex == 4) {
            self.horiStackView.distribution = UIStackViewDistributionEqualCentering;
        }
    } completion:nil];

}
- (IBAction)onVerAliSelect:(UISegmentedControl *)sender {
    [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (sender.selectedSegmentIndex == 0) {
            self.verStackView.alignment = UIStackViewAlignmentFill;
        }else if (sender.selectedSegmentIndex == 1) {
            self.verStackView.alignment = UIStackViewAlignmentLeading;
        }else if (sender.selectedSegmentIndex == 2) {
            self.verStackView.alignment = UIStackViewAlignmentLeading;
        }else if (sender.selectedSegmentIndex == 3) {
            self.verStackView.alignment = UIStackViewAlignmentFirstBaseline;
        }else if (sender.selectedSegmentIndex == 4) {
            self.verStackView.alignment = UIStackViewAlignmentCenter;
        }else if (sender.selectedSegmentIndex == 5) {
            self.verStackView.alignment = UIStackViewAlignmentTrailing;
        }else if (sender.selectedSegmentIndex == 6) {
            self.horiStackView.alignment = UIStackViewAlignmentBottom;
        }else if (sender.selectedSegmentIndex == 7) {
            self.verStackView.alignment = UIStackViewAlignmentLastBaseline;
        }
    } completion:nil];

}
- (IBAction)onVerDistSelect:(UISegmentedControl *)sender {
    [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (sender.selectedSegmentIndex == 0) {
            self.verStackView.distribution = UIStackViewDistributionFill;
        }else if (sender.selectedSegmentIndex == 1) {
            self.verStackView.distribution = UIStackViewDistributionFillEqually;
        }else if (sender.selectedSegmentIndex == 2) {
            self.verStackView.distribution = UIStackViewDistributionFillProportionally;
        }else if (sender.selectedSegmentIndex == 3) {
            self.verStackView.distribution = UIStackViewDistributionEqualSpacing;
        }else if (sender.selectedSegmentIndex == 4) {
            self.verStackView.distribution = UIStackViewDistributionEqualCentering;
        }
    } completion:nil];
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
