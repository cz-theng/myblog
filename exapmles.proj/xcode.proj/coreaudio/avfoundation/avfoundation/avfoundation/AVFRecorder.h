//
//  AVRecorder.h
//  avfoundation
//
//  Created by apollo on 16/4/20.
//  Copyright © 2016年 projm. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

@interface AVFRecorder : NSObject <AVAudioRecorderDelegate, AVAudioPlayerDelegate>
+ (AVFRecorder *)sharedInstance;

- (void) initRecorder : (NSString *) filepath;
- (void) recording;
- (void) stopRecording;
- (void) play;
- (void) stopPlay;
@end
