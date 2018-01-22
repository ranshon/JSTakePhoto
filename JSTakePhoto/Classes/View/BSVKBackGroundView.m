//
//  BSVKBackGroundView.m
//  JSTakePhoto
//
//  Created by Will on 2017/12/5.
//  Copyright © 2017年 BSVK. All rights reserved.
//

#import "BSVKBackGroundView.h"

@interface BSVKBackGroundView() {
    CGFloat _rectHeight;
}
@property (nonatomic, strong) UILabel *warningLbl;

@end
@implementation BSVKBackGroundView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;   //透明
        
        _warningLbl = [UILabel new];
        _warningLbl.font = [UIFont systemFontOfSize:12];
        _warningLbl.textColor = [UIColor blueColor];
        _warningLbl.frame = CGRectMake(((self.frame.size.width  * 5)/ 6) - 40, (self.frame.size.height - 14)/2 , 100, 14);
        _warningLbl.textAlignment =NSTextAlignmentCenter;
        _warningLbl.transform = CGAffineTransformMakeRotation(M_PI / 2);
        [self addSubview:_warningLbl];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGFloat viewWidth = self.frame.size.height > self.frame.size.width ? self.frame.size.width :self.frame.size.height;
    _rectHeight = (2 * viewWidth * 856) / (540 * 3);
    CGRect cleanRect = CGRectMake(viewWidth / 6, viewWidth / 6, 2 * viewWidth / 3, _rectHeight);
    
    [self addClearRect:cleanRect];
    [self addFourBorder:cleanRect];
    
}

//设置中间透明区域
- (void)addClearRect:(CGRect)cleanRect {
    [[UIColor colorWithWhite:0 alpha:0.1] setFill];
    CGRect mainRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    UIRectFill(mainRect);
    CGRect clearIntersection = CGRectIntersection(cleanRect, mainRect);
    [[UIColor clearColor] setFill];
    UIRectFill(clearIntersection);
}

//设置四个角线
- (void)addFourBorder:(CGRect)borderRect {
    CGFloat borderRectX = borderRect.origin.x;
    CGFloat borderRectY = borderRect.origin.y;
    //CGFloat borderRectWidth = borderRect.size.width;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 4);
    CGContextSetStrokeColorWithColor(ctx, [UIColor blueColor].CGColor);
    CGContextSetLineCap(ctx, kCGLineCapSquare);
    CGPoint upLeftPoints[] = {CGPointMake(borderRectX, borderRectY), CGPointMake(borderRectX + 20, borderRectY), CGPointMake(borderRectX, borderRectY), CGPointMake(borderRectX, borderRectY + 20)};
    CGPoint upRightPoints[] = {CGPointMake(5 * borderRectX - 20, borderRectY), CGPointMake(5 * borderRectX, borderRectY), CGPointMake(5 * borderRectX, borderRectY), CGPointMake(5 * borderRectX, borderRectY + 20)};
    CGPoint belowLeftPoints[] = {CGPointMake(borderRectX, borderRectY + _rectHeight), CGPointMake(borderRectX, borderRectY + _rectHeight - 20), CGPointMake(borderRectX, borderRectY + _rectHeight), CGPointMake(borderRectX +20, borderRectY + _rectHeight)};
    CGPoint belowRightPoints[] = {CGPointMake(5 * borderRectX, borderRectY + _rectHeight), CGPointMake(5 * borderRectX - 20, borderRectY + _rectHeight), CGPointMake(5 * borderRectX, borderRectY + _rectHeight), CGPointMake(5 * borderRectX, borderRectY + _rectHeight - 20)};
    CGContextStrokeLineSegments(ctx, upLeftPoints, 4);
    CGContextStrokeLineSegments(ctx, upRightPoints, 4);
    CGContextStrokeLineSegments(ctx, belowLeftPoints, 4);
    CGContextStrokeLineSegments(ctx, belowRightPoints, 4);
}

- (void)setWarningInfo:(NSString *)warningInfo {
    _warningLbl.text = warningInfo;

}
@end
