//
//  ViewController.m
//  avaudioplayerdemo
//
//  Created by apollo on 16/4/13.
//  Copyright © 2016年 projm. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (weak, nonatomic) IBOutlet UIButton *pauseBtn;
@property (nonatomic) NSTimeInterval playTime;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initPlayer];
}

- (void) initPlayer {
    NSError *error;
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"xiao_xing_yun" ofType:@"mp3"];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:soundPath] error:&error];
    if (error != nil ) {
        NSLog(@"init avaudioplayer error!");
        return;
    }
    _playTime = 0.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onPlayClick:(id)sender {
    static BOOL clicked = NO;
    if (!clicked) {
        clicked = YES;
        [_playBtn setTitle:@"Stop" forState:UIControlStateNormal];
        [_player play];
        //[_player playAtTime:0+_player.deviceCurrentTime];
    } else {
        clicked = NO;
        [_playBtn setTitle:@"Play" forState:UIControlStateNormal];
        [_player stop];
        _playTime = _player.currentTime;
        NSLog(@"curTime is %g, and device time is %g", _player.currentTime, _player.deviceCurrentTime);
    }
}
- (IBAction)onPause:(id)sender {
    static BOOL clicked = NO;
    if (!clicked) {
        clicked = YES;
        [_pauseBtn setTitle:@"Play" forState:UIControlStateNormal];
        [_player pause];
    } else {
        clicked = NO;
        [_pauseBtn setTitle:@"Pause" forState:UIControlStateNormal];
        [_player play];
    }
}

@end
