//
//  ViewController.m
//  CaptureDemo
//
//  Created by apollo on 08/11/2016.
//  Copyright © 2016 projm. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MobileCoreServices;

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) UIImagePickerController *imgPicker;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _imgPicker = [[UIImagePickerController alloc] init];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTakeVideo:(id)sender {
    
}

- (IBAction)onTakePic:(id)sender {
    [self presentViewController:_imgPicker animated:YES completion:^{
        //
    }];
}

- (IBAction)onTestAvaible:(id)sender {
    NSArray *source = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    for (NSString *s in source) {
        NSLog(@"UIImagePickerControllerSourceTypePhotoLibrary with %@", s);
    }
    
    source = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    for (NSString *s in source) {
        NSLog(@"UIImagePickerControllerSourceTypeCamera with %@", s);
    }
    
    source = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    for (NSString *s in source) {
        NSLog(@"UIImagePickerControllerSourceTypeSavedPhotosAlbum with %@", s);
    }
    
    _imgPicker.allowsEditing = YES;
    _imgPicker.delegate = self;
    
    _imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    _imgPicker.mediaTypes =  @[(NSString *)kUTTypeImage];
    _imgPicker.showsCameraControls = NO;
}

#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {

}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIView *v = [[UIView alloc] initWithFrame: self.view.bounds];
    [v setBackgroundColor: [UIColor blueColor]];
    v.alpha = 0.1;
    _imgPicker.cameraOverlayView = v;
}

//- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
//
//}
//
//- (UIInterfaceOrientation)navigationControllerPreferredInterfaceOrientationForPresentation:(UINavigationController *)navigationController {
//
//}
//
//- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
//                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController {
//
//}
//
//- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
//                                            animationControllerForOperation:(UINavigationControllerOperation)operation
//                                                         fromViewController:(UIViewController *)fromVC
//                                                           toViewController:(UIViewController *)toVC  {
//
//}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
    [picker dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

@end
