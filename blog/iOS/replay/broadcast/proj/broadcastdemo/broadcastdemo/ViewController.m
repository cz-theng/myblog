//
//  ViewController.m
//  broadcastdemo
//
//  Created by apollo on 14/10/2016.
//  Copyright © 2016 projm. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *startBroadcastBtn;
@property (weak, nonatomic) IBOutlet UIButton *enableCameraBtn;
@property (weak, nonatomic) IBOutlet UIButton *enableMicrophoneBtn;

@property (strong, nonatomic) RPBroadcastController *broadcastVC;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPopBroadcastServices:(id)sender {
    [RPBroadcastActivityViewController loadBroadcastActivityViewControllerWithHandler:^(RPBroadcastActivityViewController * _Nullable broadcastActivityViewController, NSError * _Nullable error) {
        if (nil != error) {
            NSLog(@"loadBroadcastActivityViewControllerWithHandler with error %@", error.domain);
            return ;
        }
        
        broadcastActivityViewController.delegate = self;
        [self presentViewController:broadcastActivityViewController animated:YES completion:^{
            //
        }];
    }];
}

- (IBAction)onStartBroadcast:(id)sender {
    static BOOL once = NO;
    if (!once) {
        [_startBroadcastBtn setTitle:@"StopBroadcast" forState:UIControlStateNormal];
        [_broadcastVC startBroadcastWithHandler:^(NSError * _Nullable error) {
            //
            if (nil != error) {
                return ;
            }
            [[RPScreenRecorder sharedRecorder].cameraPreviewView setFrame: CGRectMake(100, 100, 300, 300)];
            [self.view addSubview: [RPScreenRecorder sharedRecorder].cameraPreviewView];
        }];
        once = YES;
    } else {
        [_startBroadcastBtn setTitle:@"StartBroadcast" forState:UIControlStateNormal];
        [_broadcastVC finishBroadcastWithHandler:^(NSError * _Nullable error) {
            //
        }];
        once = NO;
    }
}

- (IBAction)onPauseBroadcast:(id)sender {
    [_broadcastVC pauseBroadcast];
}

- (IBAction)EnableCamera:(id)sender {
    static BOOL once = NO;
    if (!once) {
        [_enableCameraBtn setTitle:@"DisableCamera" forState:UIControlStateNormal];
        [RPScreenRecorder sharedRecorder].cameraEnabled = YES;
        once = YES;
    } else {
        [_enableCameraBtn setTitle:@"EnableCamera" forState:UIControlStateNormal];
        [RPScreenRecorder sharedRecorder].cameraEnabled = NO;
        once = NO;
    }
}

- (IBAction)onEnableMichpone:(id)sender {
    static BOOL once = NO;
    if (!once) {
        [_enableMicrophoneBtn setTitle:@"DisableMicrophone" forState:UIControlStateNormal];
        [RPScreenRecorder sharedRecorder].microphoneEnabled = YES;
        once = YES;
    } else {
        [_enableMicrophoneBtn setTitle:@"EnableMicrophone" forState:UIControlStateNormal];
        [RPScreenRecorder sharedRecorder].microphoneEnabled = NO;
        once = NO;
    }
}


#pragma mark RPBroadcastActivityViewControllerDelegate

- (void)broadcastActivityViewController:(RPBroadcastActivityViewController *)broadcastActivityViewController didFinishWithBroadcastController:(nullable RPBroadcastController *)broadcastController error:(nullable NSError *)error {

    if (nil != error) {
        NSLog(@"didFinishWithBroadcastController with error %@", error.domain);
    }
    
    _broadcastVC = broadcastController;
    [broadcastActivityViewController dismissViewControllerAnimated:YES completion:^{
        //
    }];
}




@end
