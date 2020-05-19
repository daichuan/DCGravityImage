//
//  DCMotionManager.h
//  LandzClient
//
//  Created by 戴川 on 2020/5/13.
//  Copyright © 2020 Landz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

#define DCOpenDeviceMotionUpdatesNotification @"DCOpenDeviceMotionUpdatesNotification"

NS_ASSUME_NONNULL_BEGIN



@interface DCMotionManager : NSObject

+ (instancetype)shareManager;
@property (nonatomic, strong,readonly) CMMotionManager *motionManager;
///停止设备运动
- (void)stopDeviceMotionUpdates;
///开启陀螺仪
- (void)openDeviceMotionUpdates;
@end

NS_ASSUME_NONNULL_END
