//
//  AVPlayer.h
//  avfoundation
//
//  Created by apollo on 16/4/20.
//  Copyright © 2016年 projm. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

@interface AVFPlayer : NSObject <AVAudioPlayerDelegate>
+ (AVFPlayer *)sharedInstance;

- (void) initPlayer : (NSString *) filepath;
- (void) play;
- (void) pause;
- (void) stop;

@end
