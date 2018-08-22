//
//  ViewController.m
//  NEHotspotConfigurationManagerTest
//
//  Created by huangjian on 2018/8/11.
//  Copyright © 2018年 huangjian. All rights reserved.
//

#import "ViewController.h"
#import <NetworkExtension/NetworkExtension.h>
#import <SystemConfiguration/CaptiveNetwork.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 11.0, *)) {
        NEHotspotConfiguration *configuration=[[NEHotspotConfiguration alloc]initWithSSID:@"你好吗"];
       // configuration.joinOnce=YES;
//        NEHotspotConfiguration *configuration=[[NEHotspotConfiguration alloc]initWithSSID:@"mxchip-offices" passphrase:@"88888888" isWEP:NO];
        [[NEHotspotConfigurationManager sharedManager]applyConfiguration:configuration completionHandler:^(NSError * _Nullable error) {
            if ([[self getCurrentWifi] isEqualToString:configuration.SSID]) {
                if (error) {
                    NSLog(@"加入网络失败--%@",error);
                }else
                {
                    NSLog(@"加入网络成功");
                }
            }else
            {
                NSLog(@"加入网络失败--no error");
            }
            
        }];
        
        [[NEHotspotConfigurationManager sharedManager]getConfiguredSSIDsWithCompletionHandler:^(NSArray<NSString *> * _Nonnull aa) {
            NSLog(@"--%@",aa);
        }];
    } else {
        // Fallback on earlier versions
        
        
    }
}
-(NSString *)getCurrentWifi
{
    NSString *ssid = nil;
    NSArray *ifs = (__bridge   id)CNCopySupportedInterfaces();
    for (NSString *ifname in ifs) {
        NSDictionary *info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifname);
        if (info[@"SSID"])
        {
            ssid = info[@"SSID"];
        }
    }
    return ssid;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSString *jumpCode = @"App-Prefs:root=WIFI";
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:jumpCode]])
    {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:jumpCode] options:@{} completionHandler:nil];
        } else {
            // Fallback on earlier versions
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:jumpCode]];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
