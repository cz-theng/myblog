//
//  ViewController.m
//  testnsurlsession
//
//  Created by apollo on 16/3/11.
//  Copyright © 2016年 cz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) NSURLSession *defaultSession;
@property (strong, nonatomic) NSURLSessionDataTask *baiduTask;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: [NSOperationQueue mainQueue]];
    NSURL *baidu = [NSURL URLWithString:@"https://www.baidu.com"];
    NSURLRequest *baiduReq = [NSURLRequest requestWithURL:baidu];
    self.baiduTask = [self.defaultSession dataTaskWithRequest:baiduReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"completion");
    }];
    [self.baiduTask resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
