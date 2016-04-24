//
//  ViewController.m
//  uilabelwithuifont
//
//  Created by CZ on 3/12/16.
//  Copyright © 2016 projm. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSArray *fonts = [UIFont familyNames];
    for ( NSString *font in fonts) {
        NSLog(@"Font Family:%@ and Font Name %@", font, [UIFont fontNamesForFamilyName:font]);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
