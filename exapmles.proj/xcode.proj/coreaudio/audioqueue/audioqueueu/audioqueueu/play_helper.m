//
//  play_helper.m
//  audioqueueu
//
//  Created by apollo on 16/4/14.
//  Copyright © 2016年 projm. All rights reserved.
//

#import "play_helper.h"
#import <stddef.h>
#import <stdint.h>
#import <AudioToolbox/AudioToolbox.h>


void audio_queue_output_callback ( void *user_data, AudioQueueRef aq, AudioQueueBufferRef aqb )
{

}

void playback_file(char *filepath)
{
    if (NULL == filepath ) {
        return ;
    }
    stop_playback();
}

void stop_playback()
{

}