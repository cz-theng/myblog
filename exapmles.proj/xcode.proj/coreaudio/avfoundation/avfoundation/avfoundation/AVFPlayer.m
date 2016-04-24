//
//  AVPlayer.m
//  avfoundation
//
//  Created by apollo on 16/4/20.
//  Copyright © 2016年 projm. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "AVFPlayer.h"

@interface AVFPlayer()
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic) NSTimeInterval playTime;
@end

@implementation AVFPlayer



+ (AVFPlayer *)sharedInstance {
    static AVFPlayer *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void) initPlayer : (NSString *) filepath {
    NSError *error;
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:filepath] error:&error];
    if (error != nil ) {
        NSLog(@"init avaudioplayer error!");
        return;
    }
    _player.delegate = self;
    _playTime = 0.0;
}

- (void) play {
    [_player play];
}

- (void) pause {
    [_player pause];
}

- (void) stop {
    [_player stop];
}

@end
