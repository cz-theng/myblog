//
//  AUDPlayer.h
//  audiounitdemo
//
//  Created by apollo on 16/4/21.
//  Copyright © 2016年 projm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreFoundation/CoreFoundation.h>



@interface AUDPlayer : NSObject

+ (AUDPlayer *)sharedInstance;


- (void) playFile:(NSString *) filepath;
- (void) pause;
- (void) stop;
@end
