## 重力感应图片

### 使用方法

直接上代码

```objective-c
#import "DCGravityImageView.h"

DCGravityImageView *imageView = [[DCGravityImageView alloc]initWithFrame:CGRectMake(0, 100, 375, 200) ContentSize:CGSizeMake(600, 450)];
[self.view addSubview:imageView];
[imageView setupImage:[UIImage imageNamed:@"test"] placeholder:nil];

```

先引入DCGravityImageView，然后用提供的`initWithFrame:ContentSize:`方法创建一个实例，然后调用`setupImage:placeholder:`方法设置图片即可；

* `initWithFrame:ContentSize:`第一个参数`frame`，就是控件`DCGravityImageView`的frame；第二个参数`contentsize`,是重力感应图片的大小（一般大小设为frame的1.5倍）；
* `setupImage:placeholder:`第一个参数` image`，展示的图片，为id类型，可以传`UIImage`类型，也可以传`NSString`（网络图片的url）类型；第二个参数`placeholder`,站位图，可以传nil；

还有一个管理类`DCMotionManager`，提供了两个方法；

```objective-c
@interface DCMotionManager : NSObject

+ (instancetype)shareManager;
@property (nonatomic, strong,readonly) CMMotionManager *motionManager;
///停止设备运动
- (void)stopDeviceMotionUpdates;
///开启陀螺仪
- (void)openDeviceMotionUpdates;
@end

```

因为开启陀螺仪会非常耗电，为了节省性能，一般会在页面消失的时候停止陀螺仪，在页面即将显示的时候开启陀螺仪，所以可以通过这个类来控制是否开启陀螺仪；

### 实现原理

核心类`CMMotionManager`，这个类可以获取设备陀螺仪的数据，然后根据陀螺仪的数据来改变view；

首先要注意尽可能在 app 中只创建一个 `CMMotionManager` 对象，多个 `CMMotionManager` 对象会影响从加速计和陀螺仪接受数据的速率。其次，在启动接收设备传感器信息前要检查传感器是否硬件可达，可以用
`deviceMotionAvailable` 检测硬件是否正常，用 `deviceMotionActive `检测当前 `CMMotionManager` 是否正在提供数据更新。

因此我创建了一个`DCMotionManager`来管理`CMMotionManager`，提供了一个单例方法`shareManager;`来保证只有一个`CMMotionManager`，然后提供了两个方法,`stopDeviceMotionUpdates;`停止设备运动`openDeviceMotionUpdates;`开启设备运动；

```objective-c
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
```

开启设备运动，并发送通知，把设备运动数据传出去；停止设备运动，直接调用`CMMotionManager`的`stopDeviceMotionUpdates`即可；

为什么不把这两个方法封装在view里面？因为封装在view里面不能保证只有一个`CMMotionManager`，而且在controller里面，你是很难拿到这个view，因此封装了它，你无论在哪里都能直接停止设备运动监听；



`DCGravityImageView`包含两个view，一个`UIImageView`，一个`UIScrollView`，把`UIImageView`放在`UIScrollView`里面，根据陀螺仪的数据，改变`UIScrollView`的`ContentOffset`;

通知监听设备运动；在`setupImage:placeholder:`方法，设置好偏移量，把`UIImageView`放在`UIScrollView`的中间，然后调用`DCMotionManager`的`openDeviceMotionUpdates`，在`dealloc`方法停止设备运动，移除通知；

接收到设备运动数据的具体实现

```objective-c
- (void)openDeviceMotion:(NSNotification *)notification{
    if ([notification.object isKindOfClass:[CMDeviceMotion class]]) {
        CMDeviceMotion * motion = notification.object;
        CGFloat xRotationRate = motion.rotationRate.x;
        CGFloat yRotationRate = motion.rotationRate.y;
        static CGFloat kRotationMultiplier = 4.f;
        CGFloat invertedYRotationRate = yRotationRate * -1;
        CGFloat invertedXRotationRate = xRotationRate * -1;

        CGFloat zoomScaleX = (CGRectGetHeight(self.scrollView.bounds) / CGRectGetWidth(self.scrollView.bounds)) * (self.contentSize.width / self.contentSize.height);
        CGFloat zoomScaleY = (CGRectGetWidth(self.scrollView.bounds) / CGRectGetHeight(self.scrollView.bounds)) * (self.contentSize.height / self.contentSize.width);
        CGFloat interpretedXOffset = self.scrollView.contentOffset.x + (invertedYRotationRate * zoomScaleX * kRotationMultiplier);
        CGFloat interpretedYOffset = self.scrollView.contentOffset.y + (invertedXRotationRate * zoomScaleY * kRotationMultiplier);
        CGPoint contentOffset = [self __clampedContentOffsetForHorizontalOffset:interpretedXOffset verticalOffset:interpretedYOffset];
        static CGFloat kMovementSmoothing = 0.3f;
        [UIView animateWithDuration:kMovementSmoothing
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState|
                                    UIViewAnimationOptionAllowUserInteraction|
                                    UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self.scrollView setContentOffset:contentOffset animated:NO];
                         } completion:NULL];

    }

}

-(CGPoint)__clampedContentOffsetForHorizontalOffset:(CGFloat)horizontalOffset  verticalOffset:(CGFloat)VerticalOffset{
    CGFloat maximumXOffset = self.scrollView.contentSize.width - CGRectGetWidth(self.scrollView.bounds);
    CGFloat maximumYOffset = self.scrollView.contentSize.height - CGRectGetHeight(self.scrollView.bounds);
    CGFloat minimumXOffset = 0.f;
    CGFloat minimumYOffset = 0.f;
   
    CGFloat clampedXOffset = fmaxf(minimumXOffset, fmin(horizontalOffset, maximumXOffset));
    CGFloat clampedYOffset = fmaxf(minimumYOffset, fmin(VerticalOffset, maximumYOffset));

   return CGPointMake(clampedXOffset, clampedYOffset);
}

```











