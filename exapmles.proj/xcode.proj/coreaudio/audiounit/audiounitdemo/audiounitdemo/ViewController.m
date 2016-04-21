//
//  ViewController.m
//  audiounitdemo
//
//  Created by apollo on 16/4/21.
//  Copyright © 2016年 projm. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *playMP3Btn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPlayMP3:(id)sender {
    
    static BOOL clicked = NO;
    if (!clicked) {
        clicked = YES;
        [_playMP3Btn setTitle:@"Pause" forState: UIControlStateNormal];

    } else {
        [_playMP3Btn setTitle:@"PlayMP3" forState:UIControlStateNormal];
        clicked = NO;
    }
    
}
@end
