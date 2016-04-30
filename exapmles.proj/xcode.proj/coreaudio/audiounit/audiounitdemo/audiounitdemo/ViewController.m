//
//  ViewController.m
//  audiounitdemo
//
//  Created by apollo on 16/4/21.
//  Copyright © 2016年 projm. All rights reserved.
//

#import "ViewController.h"
#import "AUDPlayer.h"
#import "AUDRecorder.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *playMP3Btn;
@property (nonatomic, strong) NSString *xxyPath;
@property (nonatomic, strong) NSString *recordingPath;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Do any additional setup after loading the view, typically from a nib.
    _xxyPath = [[NSBundle mainBundle] pathForResource:@"xiao_xing_yun" ofType:@"mp3"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    _recordingPath = [NSString stringWithFormat:@"%@/recording.caf", docDir];
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
        [[AUDPlayer sharedInstance] playFile: _xxyPath];

    } else {
        [_playMP3Btn setTitle:@"PlayMP3" forState:UIControlStateNormal];
        clicked = NO;
        [[AUDPlayer sharedInstance] stop];
    }
    
}
@end
