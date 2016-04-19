//
//  AQRecorder.m
//  audioqueueu
//
//  Created by apollo on 16/4/18.
//  Copyright © 2016年 projm. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioFile.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <CoreGraphics/CoreGraphics.h>
#import "AQRecorder.h"

#define AQB_BUFFER_NUM 3
#define kBufferDurationSeconds .5

typedef struct play_stat_t {
    AudioFileID fd;
    AudioStreamBasicDescription  fmt;
    AudioQueueRef                aq;
    AudioQueueBufferRef          aqb[AQB_BUFFER_NUM];
    BOOL isPlaying;
    SInt64 curPkg;
    UInt32 pkgsToRead;
    AudioStreamPacketDescription * pkgDesc;
    UInt32 pkgBytes;
} play_stat;

typedef struct record_stat_t {
    AudioFileID fd;
    AudioStreamBasicDescription  fmt;
    AudioQueueRef                aq;
    AudioQueueBufferRef          aqb[AQB_BUFFER_NUM];
    BOOL isPlaying;
    SInt64 curPkg;
    UInt32 pkgsToRead;
    AudioStreamPacketDescription * pkgDesc;
    UInt32 pkgBytes;
} record_stat;


static void aqo_play_callback( void * __nullable inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer)
{
    play_stat *playStat = (play_stat *) inUserData;
    
    if (0 == playStat->isPlaying) {
        NSLog(@" Not Playing");
        return ;
    }
    
    UInt32 bytesReading = playStat->pkgBytes;
    UInt32 pkgsToRead = playStat->pkgsToRead;
    OSStatus status;
    status = AudioFileReadPacketData(playStat->fd, false, &bytesReading, playStat->pkgDesc, playStat->curPkg, &pkgsToRead, inBuffer->mAudioData);
    if (0 != status) {
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        NSLog(@"Error: %@", [error description]);
        return ;
    }
    if (bytesReading > 0) {
        inBuffer->mAudioDataByteSize = bytesReading;
        AudioQueueEnqueueBuffer(playStat->aq, inBuffer, pkgsToRead, playStat->pkgDesc);
        playStat->curPkg += pkgsToRead;
    } else {
        playStat->isPlaying = NO;
        AudioQueueStop(playStat->aq, NO);
    }
}

static void aqo_record_callback( void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer, const AudioTimeStamp *inStartTime, UInt32 inNumberPacketDescriptions, const AudioStreamPacketDescription *inPacketDescs )
{
    record_stat *recordStat = (record_stat *) inUserData;
    
}


@interface AQRecorder()

@end

@implementation AQRecorder

+ (AQRecorder *)sharedInstance {
    static AQRecorder *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void) startRecording: (NSString *)filepath {

}


- (void) stopRecording{

}


- (void) startPlay: (NSString *)filepath  {

}

- (void) stopPlay {

}

@end
