//
//  ViewController.m
//  audioqueueu
//
//  Created by apollo on 16/4/14.
//  Copyright © 2016年 projm. All rights reserved.
//

#import "ViewController.h"
#import "AQPlayer.h"
#import "AQRecorder.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *recrodingBtn;
@property (nonatomic, strong) NSString *xxyPath;
@property (nonatomic, strong) NSString *recordingPath;
@property (weak, nonatomic) IBOutlet UIButton *playRecordingBtn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _xxyPath = [[NSBundle mainBundle] pathForResource:@"xiao_xing_yun" ofType:@"mp3"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    _recordingPath = [NSString stringWithFormat:@"%@/recording.pcm", docDir];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onPlay:(id)sender {
    
    static BOOL clicked = NO;
    if (!clicked) {
        clicked = YES;
        [_playBtn setTitle:@"Pause" forState: UIControlStateNormal];
        [[AQPlayer sharedInstance] playback:_xxyPath];
    } else {
        [_playBtn setTitle:@"Play" forState:UIControlStateNormal];
        clicked = NO;
        [[AQPlayer sharedInstance] pause];
    }
}

- (IBAction)onRecording:(id)sender {
    static BOOL clicked = NO;
    if (!clicked) {
        clicked = YES;
        [_recrodingBtn setTitle:@"Stop" forState: UIControlStateNormal];
        [[AQRecorder sharedInstance] startRecording: _recordingPath];
    } else {
        [_recrodingBtn setTitle:@"Recording" forState:UIControlStateNormal];
        clicked = NO;
        [[AQRecorder sharedInstance] stopRecording];
    }
}

- (IBAction)onPlayRecoding:(id)sender {
    static BOOL clicked = NO;
    if (!clicked) {
        clicked = YES;
        [_playRecordingBtn setTitle:@"Stop" forState: UIControlStateNormal];
        [[AQRecorder sharedInstance] startPlay: _recordingPath];
    } else {
        [_playRecordingBtn setTitle:@"PlayRecording" forState:UIControlStateNormal];
        clicked = NO;
        [[AQRecorder sharedInstance] stopPlay];
    }
}
@end
