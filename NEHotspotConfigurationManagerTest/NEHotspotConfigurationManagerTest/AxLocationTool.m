//
//  AxLocationTool.m
//  AnXin
//
//  Created by mxchip on 2018/11/19.
//  Copyright © 2018年 huangjian. All rights reserved.
//

#import "AxLocationTool.h"
#import <UIKit/UIKit.h>

@implementation AxLocationModel

-(instancetype)init
{
    if (self = [super init])
    {
        _currentCity = @"";
    }
    return self;
}

@end


@interface AxLocationTool()<CLLocationManagerDelegate>

@property(nonatomic,strong) CLLocationManager *locationManager;
@property(nonatomic,copy) LocationBlock locationBlock;

@end



@implementation AxLocationTool

+(AxLocationTool *)shareInstance
{
    static AxLocationTool *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AxLocationTool alloc] init];
    });
    return manager;
}

-(void)startLocationWithBlock:(LocationBlock)block
{
    //判断当前设备定位服务是否打开
    if (![CLLocationManager locationServicesEnabled])
    {
        NSLog(@"---设备尚未打开定位服务---");
        return;
    }
    
    self.locationBlock = block;

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        //持续授权
        [self.locationManager requestAlwaysAuthorization];
        //当用户使用的时候授权
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    //开始启动定位
    [self.locationManager startUpdatingLocation];
}

#pragma mark - <CLLocationManagerDelegate>
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    // 1.获取用户位置的对象
    CLLocation *currentLocation = [locations lastObject];
    AxLocationModel *locationModel = [AxLocationModel new];
     CLLocationCoordinate2D _coordinate = currentLocation.coordinate;
    NSLog(@"------纬度:%f 经度:%f", _coordinate.latitude, _coordinate.longitude);
    if(_coordinate.latitude)
    {
        locationModel.coordinate = currentLocation.coordinate;
        // 2.停止定位
        [manager stopUpdatingLocation];
    }
    
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    __block BOOL isExitCity = NO;
    //反编码
    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error)
     {
         NSLog(@"--placemarks:%@",placemarks);
         if (placemarks.count > 0)
         {
             CLPlacemark *placeMark = placemarks[0];
             NSString  *currentCity = placeMark.locality;
             
             NSLog(@"---城市：%@",currentCity); //这就是当前的城市
             NSLog(@"---地址:%@",placeMark.name);//具体地址:  xx市xx区xx街道
             if (currentCity)
             {
                 locationModel.currentCity = currentCity;
                 isExitCity = YES;
             }else
             {
                 //                 [AxToast ax_showText:@"无法定位当前城市" completion:nil];
             }
             
         }else if (error == nil && placemarks.count == 0)
         {
             NSLog(@"--No location and error return---");
         }else if (error)
         {
             NSLog(@"--location error: %@ ",error);
         }
         
         //block回调
         self.locationBlock ?self.locationBlock(isExitCity,locationModel):nil;
     }];
}

-(CLLocationManager *)locationManager
{
    if (_locationManager == nil)
    {
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 10000.0f;
    }
    return _locationManager;
}

@end
