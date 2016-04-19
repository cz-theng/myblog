//
//  AQRecorder.h
//  audioqueueu
//
//  Created by apollo on 16/4/18.
//  Copyright © 2016年 projm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AQRecorder : NSObject

+ (AQRecorder *)sharedInstance ;

- (void) startRecording: (NSString *)filepath;
- (void) stopRecording;
- (void) startPlay:(NSString *)filepath;
- (void) stopPlay;
@end
