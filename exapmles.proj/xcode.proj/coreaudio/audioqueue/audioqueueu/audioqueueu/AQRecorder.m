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
    BOOL isRecording;
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
        NSLog(@"curPkg is %lld", playStat->curPkg);
    } else {
        playStat->isPlaying = NO;
        AudioQueueStop(playStat->aq, NO);
    }
}

static void aqo_record_callback( void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer, const AudioTimeStamp *inStartTime, UInt32 inNumberPacketDescriptions, const AudioStreamPacketDescription *inPacketDescs )
{
    OSStatus status;
    record_stat *recordStat = (record_stat *) inUserData;
    
    if (inNumberPacketDescriptions > 0) {
        status = AudioFileWritePackets(recordStat->fd, NO, inBuffer->mAudioDataByteSize, inPacketDescs, recordStat->curPkg, &inNumberPacketDescriptions, inBuffer->mAudioData);
        if (status != noErr) {
            NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
            NSLog(@"Error: %@", [error description]);
            return ;
        }
        recordStat->curPkg += inNumberPacketDescriptions;
        NSLog(@"curByte is %lld", recordStat->curPkg);
        
        if ( recordStat->isRecording) {
            AudioQueueEnqueueBuffer(recordStat->aq, inBuffer, 0, NULL);
        } else {
            NSLog(@"no recording");
        }
        
    }

}


@interface AQRecorder() {
    record_stat recordStat;
    play_stat playStat;
}
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

- (void) setRecordFormat {
    recordStat.fmt.mFormatID         = kAudioFormatLinearPCM;
    recordStat.fmt.mSampleRate       = 44100.0;
    recordStat.fmt.mChannelsPerFrame = 2;
    recordStat.fmt.mBitsPerChannel   = 16;
    recordStat.fmt.mFramesPerPacket  = 1;
    
    recordStat.fmt.mChannelsPerFrame = 2;
    recordStat.fmt.mBytesPerPacket   = recordStat.fmt.mBytesPerFrame = (recordStat.fmt.mBitsPerChannel / 8) * recordStat.fmt.mChannelsPerFrame;
    
    recordStat.fmt.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
}

- (void) startRecording: (NSString *)filepath {

    OSStatus status;
    memset(&recordStat.fmt, 0, sizeof(recordStat.fmt));
    [self setRecordFormat];
    
    status = AudioQueueNewInput(&recordStat.fmt, aqo_record_callback, &recordStat, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &recordStat.aq);
    if (status != noErr) {
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        NSLog(@"AudioQueueNewInput Error: %@", [error description]);
        return ;
    }
    CFURLRef audioFileURL =  CFURLCreateFromFileSystemRepresentation(NULL, (const UInt8 *) [filepath cStringUsingEncoding:NSUTF8StringEncoding], filepath.length, false);
    status = AudioFileCreateWithURL(audioFileURL, kAudioFileCAFType, &recordStat.fmt, kAudioFileFlags_EraseFile, &recordStat.fd);
    if (status != noErr) {
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        NSLog(@"AudioFileCreateWithURL Error: %@", [error description]);
        return ;
    }
    
    int frames = (int)ceil(kBufferDurationSeconds * recordStat.fmt.mSampleRate);
    int bytes = frames * recordStat.fmt.mBytesPerFrame;
    
    for (int i=0; i< AQB_BUFFER_NUM; i++ ) {
        status = AudioQueueAllocateBuffer(recordStat.aq, bytes, &recordStat.aqb[i]);
        if (status != noErr) {
            NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
            NSLog(@"AudioFileCreateWithURL Error: %@", [error description]);
            return ;
        }
        status = AudioQueueEnqueueBuffer(recordStat.aq, recordStat.aqb[i], 0, NULL);
        if (status != noErr) {
            NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
            NSLog(@"AudioQueueEnqueueBuffer Error: %@", [error description]);
            return ;
        }
    }
    recordStat.isRecording = YES;
    status = AudioQueueStart(recordStat.aq, NULL);
    if (status != noErr) {
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        NSLog(@"AudioQueueStart Error: %@", error.localizedDescription);
        return ;
    }
}


- (void) stopRecording{
    OSStatus status;
    status = AudioQueueStop(recordStat.aq, true);
    if (status != noErr) {
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        NSLog(@"AudioQueueStop Error: %@", [error description]);
        return ;
    }
    recordStat.isRecording = NO;
    recordStat.curPkg = 0;
    AudioQueueDispose(recordStat.aq, true);
    AudioFileClose(recordStat.fd);
}


- (void) startPlay: (NSString *)filepath  {
    
    {
        FILE *fp = fopen([filepath cStringUsingEncoding:NSUTF8StringEncoding], "r");
        if (NULL != fp) {
            fseek(fp, 0, SEEK_END);
            size_t len = ftell(fp);
            NSLog(@" file len is %ld", len);
        }
        fclose(fp);
    }
    
    OSStatus status;
    NSURL   *fileURL = [NSURL URLWithString:filepath];
    CFURLRef cfFile = (__bridge CFURLRef) fileURL;
    status = AudioFileOpenURL(cfFile, kAudioFileReadPermission, kAudioFileCAFType, &playStat.fd);
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
    
    status = AudioQueueNewOutput(&playStat.fmt, aqo_play_callback, &playStat, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &playStat.aq);
    
    BOOL rst;
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
        aqo_play_callback(&playStat, playStat.aq, playStat.aqb[i]);
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

- (void) stopPlay {
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
