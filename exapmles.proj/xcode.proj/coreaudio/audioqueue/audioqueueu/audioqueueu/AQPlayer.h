//
//  AQPlayer.h
//  audioqueueu
//
//  Created by apollo on 16/4/15.
//  Copyright © 2016年 projm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AQPlayer : NSObject


+ (AQPlayer *)sharedInstance ;
- (void) playback: (NSString *) filePath;
- (void) pause;
- (void) stop;
@end
