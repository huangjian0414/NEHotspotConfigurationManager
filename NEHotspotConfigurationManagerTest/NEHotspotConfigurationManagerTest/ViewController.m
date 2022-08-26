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
#import "AxLocationTool.h"


typedef void(^GetWifiNameResult)(NSString *ssid);

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    if (@available(iOS 11.0, *)) {
        NEHotspotConfiguration *configuration=[[NEHotspotConfiguration alloc]initWithSSID:@"wiodo-cy07"];
       // configuration.joinOnce=YES;
//        NEHotspotConfiguration *configuration=[[NEHotspotConfiguration alloc]initWithSSID:@"guest" passphrase:@"sihuacloud" isWEP:NO];
        [[NEHotspotConfigurationManager sharedManager]applyConfiguration:configuration completionHandler:^(NSError * _Nullable error) {
            
            if (@available(iOS 13.0, *)) {
                [[AxLocationTool shareInstance]startLocationWithBlock:^(BOOL isSuccess, AxLocationModel * _Nonnull locationModel) {
                    [weakSelf getCurrentWifi:^(NSString *ssid) {
                        NSLog(@"iOS 13.0以上   %@",ssid);
                        [weakSelf checkWifiName:ssid configuration:configuration error:error];
                    }];
                }];
            }else{
                [weakSelf getCurrentWifi:^(NSString *ssid) {
                    NSLog(@"iOS 13.0以下   %@",ssid);
                    [weakSelf checkWifiName:ssid configuration:configuration error:error];
                }];
            }
            
        }];
        
        [[NEHotspotConfigurationManager sharedManager]getConfiguredSSIDsWithCompletionHandler:^(NSArray<NSString *> * _Nonnull aa) {
            NSLog(@"--%@",aa);
        }];
    } else {
        // Fallback on earlier versions
        
        
    }
}
-(void)checkWifiName:(NSString *)wifiName configuration:(NEHotspotConfiguration *)configuration error:(NSError *)error API_AVAILABLE(ios(11.0)){
    if ([wifiName isEqualToString:configuration.SSID]) {
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
}

-(void)getCurrentWifi:(GetWifiNameResult)result
{
    if(@available(iOS 14.0, *)){
        [NEHotspotNetwork fetchCurrentWithCompletionHandler:^(NEHotspotNetwork * _Nullable currentNetwork) {
            !result?:result(currentNetwork.SSID);
        }];
    }else{
        NSArray *ifs = (__bridge   id)CNCopySupportedInterfaces();
        NSString *ssid = nil;
        for (NSString *ifname in ifs) {
            NSDictionary *info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifname);
            if (info[@"SSID"])
            {
                ssid = info[@"SSID"];
            }
        }
        !result?:result(ssid);
    }
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
