//
//  UIView+BSVKAdditions.h
//  JSTakePhoto
//
//  Created by Will on 2018/1/16.
//  Copyright © 2018年 Will. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (BSVKAdditions)
@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize  size;

- (UIViewController *)viewController;
@end
