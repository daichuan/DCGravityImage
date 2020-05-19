//
//  DCGravityImageView.h
//  DCGravityImage
//
//  Created by 戴川 on 2020/5/13.
//  Copyright © 2020 戴川. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface DCGravityImageView : UIView
/// 初始化方法
/// @param contentSize 图片的实际大小
/// @param frame frame
- (instancetype)initWithFrame:(CGRect)frame ContentSize:(CGSize)contentSize;
/// 设置图片
/// @param image 图片，UIImage类型或者NSString（图片地址）
/// @param placeholderImage 站位图片，用于图片是url链接时加载图片时的站位图，可以为空；
- (void)setupImage:(id)image placeholder:(nullable UIImage *)placeholderImage;

@end

NS_ASSUME_NONNULL_END
