//
//  AVRecorder.m
//  avfoundation
//
//  Created by apollo on 16/4/20.
//  Copyright © 2016年 projm. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "AVFRecorder.h"


@interface AVFRecorder()
@property (nonatomic, strong) NSString *filepath;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) AVAudioSession *session;
@end

@implementation AVFRecorder
+ (AVFRecorder *)sharedInstance {
    static AVFRecorder *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


- (void) initRecorder : (NSString *) filepath {
    _filepath = filepath;
    _session = [AVAudioSession sharedInstance];
    NSError *error;
    [_session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    [_session setActive:YES error:nil];
    [_session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:(AVAudioSessionCategoryOptionDefaultToSpeaker) error:nil];
}

- (void) recording {
    NSError *error;
    NSDictionary *recordCfg = @{
                                AVLinearPCMBitDepthKey:@16,
                                AVSampleRateKey:@44100.0,
                                AVFormatIDKey: [NSNumber numberWithInt: kAudioFormatLinearPCM],
                                AVNumberOfChannelsKey: @2,
                                };
    _recorder = [[AVAudioRecorder alloc ] initWithURL:[NSURL URLWithString:_filepath ] settings:recordCfg error:&error];
    if (error != nil ) {
        NSLog(@"Create recorder error %@", error);
    }
    
    [_recorder record];
    
}

- (void) stopRecording {
    [_recorder stop];
}

- (void) play {
    {
        FILE *fp = fopen([_filepath cStringUsingEncoding:NSUTF8StringEncoding], "r");
        if (NULL != fp) {
            fseek(fp, 0, SEEK_END);
            size_t len = ftell(fp);
            NSLog(@" file len is %ld", len);
        }
        fclose(fp);
    }
    
    NSError *error;
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:_filepath] error:&error];
    if (error != nil ) {
        NSLog(@"init avaudioplayer error!");
        return;
    }
    _player.delegate = self;
    [_player play];
}

- (void) stopPlay {
    [_player stop];
}

@end
