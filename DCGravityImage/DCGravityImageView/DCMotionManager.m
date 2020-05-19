//
//  DCMotionManager.m
//  LandzClient
//
//  Created by 戴川 on 2020/5/13.
//  Copyright © 2020 Landz. All rights reserved.
//

#import "DCMotionManager.h"


@interface DCMotionManager ()
@property (nonatomic, strong,readwrite) CMMotionManager *motionManager;
@end

@implementation DCMotionManager
+ (instancetype)shareManager{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
///停止设备运动
- (void)stopDeviceMotionUpdates{

    [self.motionManager stopDeviceMotionUpdates];
}

///开启陀螺仪
- (void)openDeviceMotionUpdates{
    //防止多次开启
    if(self.motionManager.deviceMotionActive) return;
    //没有陀螺仪，返回;
    if(!self.motionManager.deviceMotionAvailable) return;
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    [self.motionManager startDeviceMotionUpdatesToQueue:queue withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
        if(!error){
            [[NSNotificationCenter defaultCenter] postNotificationName:DCOpenDeviceMotionUpdatesNotification object:motion];
            
        }
        
    }];
}
- (CMMotionManager *)motionManager{
    if (!_motionManager) { 
        _motionManager = [[CMMotionManager alloc]init];
        _motionManager.accelerometerUpdateInterval = 1/60;        
    }
    return _motionManager;
}
@end
