//
//  ViewController.m
//  avfoundation
//
//  Created by apollo on 16/4/20.
//  Copyright © 2016年 projm. All rights reserved.
//

#import "AVFPlayer.h"
#import "AVFRecorder.h"
#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *playMP3Btn;
@property (weak, nonatomic) IBOutlet UIButton *recordingBtn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (nonatomic, strong) NSString *xxyPath;
@property (nonatomic, strong) NSString *recordingPath;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _xxyPath = [[NSBundle mainBundle] pathForResource:@"xiao_xing_yun" ofType:@"mp3"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    _recordingPath = [NSString stringWithFormat:@"%@/recording.caf", docDir];
    
    [[AVFPlayer sharedInstance] initPlayer: _xxyPath];
    [[AVFRecorder sharedInstance] initRecorder: _recordingPath];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPlayMP3:(id)sender {
    static BOOL clicked = NO;
    if (!clicked) {
        clicked = YES;
        [_playMP3Btn setTitle:@"pause" forState:UIControlStateNormal];
        [[AVFPlayer sharedInstance] play];
    } else {
        [_playMP3Btn setTitle:@"PlayMP3" forState:UIControlStateNormal];
        clicked = NO;
        [[AVFPlayer sharedInstance] pause];
    }
}

- (IBAction)onRecording:(id)sender {
    static BOOL clicked = NO;
    if (!clicked) {
        clicked = YES;
        [_recordingBtn setTitle:@"stop" forState:UIControlStateNormal];
        [[AVFRecorder sharedInstance] recording];
    } else {
        clicked = NO;
        [_recordingBtn setTitle:@"Recording" forState:UIControlStateNormal];
        [[AVFRecorder sharedInstance] stopRecording];
    }
}

- (IBAction)onPlay:(id)sender {
    static BOOL clicked = NO;
    if (!clicked) {
        clicked = YES;
        [_playBtn setTitle:@"stop" forState:UIControlStateNormal];
        [[AVFRecorder sharedInstance] play];
    } else {
        clicked = NO;
        [_playBtn setTitle:@"Play" forState:UIControlStateNormal];
        [[AVFRecorder sharedInstance] stopPlay];
    }
}

@end
