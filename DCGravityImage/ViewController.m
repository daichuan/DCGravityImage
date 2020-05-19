//
//  ViewController.m
//  DCGravityImage
//
//  Created by 戴川 on 2020/5/12.
//  Copyright © 2020 戴川. All rights reserved.
//

#import "ViewController.h"
#import "DCGravityImageView.h"
@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    DCGravityImageView *imageView = [[DCGravityImageView alloc]initWithFrame:CGRectMake(0, 100, 375, 200) ContentSize:CGSizeMake(600, 450)];
    [self.view addSubview:imageView];
    [imageView setupImage:[UIImage imageNamed:@"test"] placeholder:nil];
}


@end
