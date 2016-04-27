//
//  AUDRecorder.m
//  audiounitdemo
//
//  Created by apollo on 16/4/26.
//  Copyright © 2016年 projm. All rights reserved.
//

#import "AUDRecorder.h"

@interface AUDRecorder()

@end

@implementation AUDRecorder
+ (AUDRecorder *)sharedInstance {
    static AUDRecorder *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}
@end
