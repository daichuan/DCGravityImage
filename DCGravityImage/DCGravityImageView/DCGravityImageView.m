//
//  DCGravityImageView.m
//  DCGravityImage
//
//  Created by 戴川 on 2020/5/13.
//  Copyright © 2020 戴川. All rights reserved.
//

#import "DCGravityImageView.h"
#import "DCMotionManager.h"
#import <UIImageView+WebCache.h>

@interface DCGravityImageView ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic,assign) CGSize contentSize;

@end

@implementation DCGravityImageView
-(void)dealloc{
    //关闭陀螺仪
    [[DCMotionManager shareManager] stopDeviceMotionUpdates];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame ContentSize:(CGSize)contentSize{
    if(self = [super initWithFrame:frame]){
        _contentSize = contentSize;
        [self __setupUI];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openDeviceMotion:) name:DCOpenDeviceMotionUpdatesNotification object:nil];

    }
    return self;
}
#pragma mark - public methods
- (void)openDeviceMotion:(NSNotification *)notification{
    if ([notification.object isKindOfClass:[CMDeviceMotion class]]) {
        CMDeviceMotion * motion = notification.object;
        CGFloat xRotationRate = motion.rotationRate.x;
        CGFloat yRotationRate = motion.rotationRate.y;
//        CGFloat zRotationRate = motion.rotationRate.z;
        static CGFloat kRotationMultiplier = 2.f;
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
- (void)startAnimation{
    
    [[DCMotionManager shareManager] openDeviceMotionUpdates];
}
#pragma mark - private methods
-(CGPoint)__clampedContentOffsetForHorizontalOffset:(CGFloat)horizontalOffset  verticalOffset:(CGFloat)VerticalOffset{
    CGFloat maximumXOffset = self.scrollView.contentSize.width - CGRectGetWidth(self.scrollView.bounds);
    CGFloat maximumYOffset = self.scrollView.contentSize.height - CGRectGetHeight(self.scrollView.bounds);
    CGFloat minimumXOffset = 0.f;
    CGFloat minimumYOffset = 0.f;
   
    CGFloat clampedXOffset = fmaxf(minimumXOffset, fmin(horizontalOffset, maximumXOffset));
    CGFloat clampedYOffset = fmaxf(minimumYOffset, fmin(VerticalOffset, maximumYOffset));

   return CGPointMake(clampedXOffset, clampedYOffset);
}


- (void)__setupUI{
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];

    self.scrollView.frame = self.frame;
    self.imageView.frame = self.frame;

    self.scrollView.contentSize = self.contentSize;
    
}

- (void)setupImage:(id)image placeholder:(UIImage *)placeholderImage{
    if([image isKindOfClass:[UIImage class]]){
        self.imageView.image = (UIImage *)image;
        //设置偏移量
        self.imageView.hidden = NO;
        self.imageView.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
        CGFloat offsetX = (self.contentSize.width - CGRectGetWidth(self.bounds)) / 2;
        CGFloat offsetY = (self.contentSize.height - CGRectGetHeight(self.bounds)) / 2;
        self.scrollView.contentOffset = CGPointMake(offsetX, offsetY);
        [self startAnimation];
    }else if([image isKindOfClass:[NSString class]]){
        NSString *imageURL = (NSString *)image;
        __weak typeof(self) weak_self = self;
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:placeholderImage completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if(image){
                dispatch_async(dispatch_get_main_queue(), ^{
                    //设置偏移量
                    weak_self.imageView.hidden = NO;
                    weak_self.imageView.frame = CGRectMake(0, 0, weak_self.contentSize.width, weak_self.contentSize.height);
                    CGFloat offsetX = (weak_self.contentSize.width - CGRectGetWidth(weak_self.bounds)) / 2;
                    CGFloat offsetY = (weak_self.contentSize.height - CGRectGetHeight(weak_self.bounds)) / 2;
                    weak_self.scrollView.contentOffset = CGPointMake(offsetX, offsetY);
                    [weak_self startAnimation];
                });
            }else{
                [[DCMotionManager shareManager] stopDeviceMotionUpdates];
                weak_self.imageView.hidden = YES;
            }
        }];
    }
}

#pragma mark - getter && setter
- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
    }
    return _imageView;
}
- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.userInteractionEnabled = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        
    }
    return _scrollView;
}



@end
