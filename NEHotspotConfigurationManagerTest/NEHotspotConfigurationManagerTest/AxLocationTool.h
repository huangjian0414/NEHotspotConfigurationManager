//
//  AxLocationTool.h
//  AnXin
//
//  Created by mxchip on 2018/11/19.
//  Copyright © 2018年 huangjian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 定位模型
 */
@interface AxLocationModel : NSObject

/** 当前定位的经度纬度 */
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
//@property (nonatomic, strong) CLLocation    *currentLocation;
//当前城市
@property (nonatomic, strong) NSString  *currentCity;
@end


typedef void(^LocationBlock)(BOOL isSuccess,AxLocationModel *locationModel);

@interface AxLocationTool : NSObject

+(AxLocationTool *)shareInstance;

//开始定位
-(void)startLocationWithBlock:(LocationBlock)block;
@end

NS_ASSUME_NONNULL_END
