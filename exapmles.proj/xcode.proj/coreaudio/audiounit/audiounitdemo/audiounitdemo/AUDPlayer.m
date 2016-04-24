//
//  AUDPlayer.m
//  audiounitdemo
//
//  Created by apollo on 16/4/21.
//  Copyright © 2016年 projm. All rights reserved.
//

#import "AUDPlayer.h"

@interface AUDPlayer()

@end

@implementation AUDPlayer
+ (AUDPlayer *)sharedInstance {
    static AUDPlayer *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}
@end
