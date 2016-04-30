//
//  AUDPlayer.m
//  audiounitdemo
//
//  Created by apollo on 16/4/21.
//  Copyright © 2016年 projm. All rights reserved.
//

#import "AUDPlayer.h"

#define WEAHTER_RETURN_VOID(stts, msg) do { \
    if ((stts) != noErr) { \
        NSLog((msg)); \
        return ; \
    } \
} while(0)\

@interface AUDPlayer() {
    AUGraph processingGraph;
    AUNode   ioNode;
    AUNode   fmtNode;
    AudioUnit ioUnit;
    AudioUnit fmtUnit;
}

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


- (void) playFile:(NSString *) filepath {
    [self initAudioSession];
    [self readSoundFile: filepath];
}


- (void) pause {

}

- (void) stop {

}

- (void) readSoundFile: (NSString *) filepath {
    AudioFileID afd;
    OSStatus stts;
    CFURLRef audioFileURL = CFURLCreateFromFileSystemRepresentation ( NULL, ( const UInt8 *) [filepath cStringUsingEncoding:NSUTF8StringEncoding], [filepath length], NO);
    stts = AudioFileOpenURL(audioFileURL, kAudioFileReadPermission, kAudioFileMP3Type, &afd);
    WEAHTER_RETURN_VOID(stts, @"AudioFileOpenURL Error");

    [self buildAUGraph];
}

- (void) buildAUGraph {
    OSStatus stts;
    stts = NewAUGraph(&processingGraph);
    WEAHTER_RETURN_VOID(stts, @"AudioFileOpenURL Error");
    
    // add node
    // I/O unit
    AudioComponentDescription iOUnitDesc;
    iOUnitDesc.componentType          = kAudioUnitType_Output;
    iOUnitDesc.componentSubType       = kAudioUnitSubType_RemoteIO;
    iOUnitDesc.componentManufacturer  = kAudioUnitManufacturer_Apple;
    iOUnitDesc.componentFlags         = 0;
    iOUnitDesc.componentFlagsMask     = 0;
    stts = AUGraphAddNode(processingGraph, &iOUnitDesc, &ioNode);
    WEAHTER_RETURN_VOID(stts, @"AUGraphAddNode ioNode error");
    
    AudioComponentDescription fmtUnitDesc;
    fmtUnitDesc.componentType          = kAudioUnitType_FormatConverter;
    fmtUnitDesc.componentSubType       = kAudioUnitSubType_AUConverter;
    fmtUnitDesc.componentManufacturer  = kAudioUnitManufacturer_Apple;
    fmtUnitDesc.componentFlags         = 0;
    fmtUnitDesc.componentFlagsMask     = 0;
    stts = AUGraphAddNode(processingGraph, &fmtUnitDesc, &fmtNode);
    WEAHTER_RETURN_VOID(stts, @"AUGraphAddNode fmtNode error");
    
    stts = AUGraphOpen(processingGraph);
    WEAHTER_RETURN_VOID(stts, @"AUGraphOpen error");
    
    stts = AUGraphNodeInfo(processingGraph, fmtNode, &fmtUnitDesc, &fmtUnit);
    WEAHTER_RETURN_VOID(stts, @"AUGraphNodeInfo fmtUnit Error");
    
    stts = AUGraphNodeInfo(processingGraph, ioNode, &iOUnitDesc, &ioUnit);
    WEAHTER_RETURN_VOID(stts, @"AUGraphNodeInfo fmtUnit Error");
    
    stts = AUGraphConnectNodeInput(processingGraph, fmtNode, 1, ioNode, 1);
    WEAHTER_RETURN_VOID(stts, @"AUGraphConnectNodeInput error");
    CAShow(processingGraph);
    
    // start node
    stts = AUGraphInitialize(processingGraph);
    WEAHTER_RETURN_VOID(stts, @"AUGraphInitialize");
    
    stts = AUGraphStart(processingGraph);
    WEAHTER_RETURN_VOID(stts, @"AUGraphStart");
}

- (void) initAudioSession {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (nil != error) {
        NSLog(@"setCategory Error");
        return ;
    }
    
    [session setActive:YES error:&error];
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (nil != error) {
        NSLog(@"setActive Error");
        return ;
    }
}
@end
