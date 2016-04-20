//
//  AQPlayer.m
//  audioqueueu
//
//  Created by apollo on 16/4/15.
//  Copyright © 2016年 projm. All rights reserved.
//

#import "AQPlayer.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioFile.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <CoreGraphics/CoreGraphics.h>

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

static void aqo_callback( void * __nullable inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer)
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

@interface AQPlayer()
{
    play_stat playStat;
}
@end

@implementation AQPlayer

+ (AQPlayer *)sharedInstance {
    static AQPlayer *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void) playback: (NSString *) filePath {
    OSStatus status;
    NSURL   *fileURL = [NSURL URLWithString:filePath];
    CFURLRef cfFile = (__bridge CFURLRef) fileURL;
    status = AudioFileOpenURL(cfFile, kAudioFileReadPermission, kAudioFileMP3Type, &playStat.fd);
    //status = AudioFileOpenURL(cfFile, kAudioFileReadPermission, kAudioFileCAFType, &playStat.fd);
    if (0 != status) {
        NSLog(@"OpenURL Error!");
        return ;
    }
    playStat.curPkg = 0;
  
    UInt32 fmtLen = sizeof(playStat.fmt);
    status = AudioFileGetProperty(playStat.fd, kAudioFilePropertyDataFormat, &fmtLen, &playStat.fmt);
    if (0 != status) {
        NSLog(@"AudioFileGetProperty Error!");
        return ;
    }
    
    status = AudioQueueNewOutput(&playStat.fmt, aqo_callback, &playStat, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &playStat.aq);
    

    BOOL rst = [self setCookie ];
    if (! rst) {
        NSLog(@"ParseFileDesc Error!");
        return ;
    }

    rst = [self setChannelLayout ];
    if (! rst) {
        NSLog(@"setChannelLayout Error!");
        return ;
    }
    
    rst = [self setPackages: &playStat.fmt];
    if (! rst) {
        NSLog(@"setPackages Error!");
        return ;
    }

    playStat.isPlaying = true;
    for (int i = 0; i < AQB_BUFFER_NUM ; i++)
    {
        status = AudioQueueAllocateBuffer(playStat.aq, playStat.pkgBytes, &playStat.aqb[i]);
        if (status != 0)
        {
            NSLog(@"AudioQueueAllocateBuffer Error !");
            NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
            NSLog(@"Error: %@", [error description]);
            return ;
        }
        aqo_callback(&playStat, playStat.aq, playStat.aqb[i]);
    }
    status = AudioQueueStart(playStat.aq, NULL);
    if (status != 0)
    {
        NSLog(@"Audio Queue Start Error !");
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        NSLog(@"Error: %@", [error description]);
        return ;
    }
    NSLog(@"Start Queue Success!");
    return ;
}

- (BOOL) setPackages : (AudioStreamBasicDescription *)fmt{

    UInt32 maxPacketSize;
    UInt32 vs = sizeof(maxPacketSize);
    AudioFileGetProperty(playStat.fd, kAudioFilePropertyPacketSizeUpperBound, &vs, &maxPacketSize);
    if (0 != fmt->mFramesPerPacket) {
        playStat.pkgsToRead = fmt->mSampleRate / fmt->mFramesPerPacket * kBufferDurationSeconds;
        playStat.pkgBytes = playStat.pkgsToRead * maxPacketSize;
        playStat.pkgDesc = (AudioStreamPacketDescription *)malloc(sizeof(AudioStreamPacketDescription) * playStat.pkgsToRead);
        if(!playStat.pkgDesc) {
            return NO;
        }
        
    } else {
        return NO;
    }
    
    return YES;
}

- (BOOL) setChannelLayout {
    OSStatus status;
    UInt32 size;
    status = AudioFileGetPropertyInfo(playStat.fd, kAudioFilePropertyChannelLayout, &size, NULL);
    if (status == noErr && size > 0) {
        AudioChannelLayout *acl = (AudioChannelLayout *)malloc(size);
        
        status = AudioFileGetProperty(playStat.fd, kAudioFilePropertyChannelLayout, &size, acl);
        if (status) {
            free(acl);
            NSLog(@"get audio file's channel layout");
        }
        
        status = AudioQueueSetProperty(playStat.aq, kAudioQueueProperty_ChannelLayout, acl, size);
        if (status){
            free(acl);
            NSLog(@"set channel layout on queue");
        }
        
        free(acl);
    }
    
    return YES;
}

- (BOOL) setCookie {
    OSStatus status;
    UInt32 cookieLen;
    status = AudioFileGetPropertyInfo(playStat.fd, kAudioFilePropertyMagicCookieData, &cookieLen, NULL);
    if (0 != status || cookieLen<= 0) {
        NSLog(@"File has no cookie");
        return YES;
    }
    char *magCookie = (char *)malloc(cookieLen);
    if (NULL == magCookie) {
        return NO;
    }
    status = AudioFileGetProperty(playStat.fd, kAudioFilePropertyMagicCookieData, &cookieLen, magCookie);
    if (0 != status) {
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        NSLog(@"Error: %@", [error description]);
        free(magCookie);
        return NO;
    }
    
    status = AudioQueueSetProperty(playStat.aq, kAudioQueueProperty_MagicCookie, magCookie, cookieLen);
    if (0 != status) {
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        NSLog(@"Error: %@", [error description]);
        free(magCookie);
        return NO;
    }
    free(magCookie);
    return YES;
}

- (void) pause {
    AudioQueuePause(playStat.aq);
}

- (void) stop {
    playStat.isPlaying = NO;
    AudioQueueStop(playStat.aq, NO);
    if (playStat.aq)
    {
        AudioQueueDispose(playStat.aq, true);
        playStat.aq = NULL;
    }
    
    if (playStat.fd) {
        AudioFileClose(playStat.fd);
    }
    
    if (NULL != playStat.pkgDesc) {
        free(playStat.pkgDesc);
        playStat.pkgDesc = NULL;
    }
    
    
}
@end
