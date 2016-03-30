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
@property (strong, nonatomic) NSURLSessionDataTask *weatherTask;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Example: Get Weather Infomation
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURL *weaherURL = [NSURL URLWithString:@"http://www.weather.com.cn/adat/cityinfo/101280601.html"];
    NSURLRequest *weatherReq = [NSURLRequest requestWithURL:weaherURL];
    self.weatherTask = [self.defaultSession dataTaskWithRequest:weatherReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil ) {
            NSLog(@"http response with error %@", error);
            return ;
        }
        
        NSError *jsonError;
        NSDictionary *weatherData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        if (jsonError != nil ) {
            NSLog(@"parse json with error %@", jsonError);
            return;
        }
        NSDictionary *weatherInfo = [weatherData objectForKey:@"weatherinfo"];
        NSString *htemp = [weatherInfo objectForKey:@"temp1"];
        NSString *ltemp = [weatherInfo objectForKey:@"temp2"];
        NSString *weather = [weatherInfo objectForKey:@"weather"];
        NSString *city = [weatherInfo objectForKey:@"city"];
        NSLog(@"[%@]:天气%@  最高温：%@ 最低温：%@", city, weather, htemp, ltemp);
        
    }];
    [self.weatherTask resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
