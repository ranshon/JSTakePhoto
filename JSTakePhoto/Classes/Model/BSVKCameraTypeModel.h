//
//  BSVKCameraTypeModel.h
//  JSTakePhoto
//
//  Created by Will on 2018/1/16.
//  Copyright © 2018年 Will. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BSVKCameraTypeModel : NSObject

@property (nonatomic, assign) BOOL haveBg; //是否含有背景图 有、无

@property (nonatomic, copy) NSString *cameraDirection; //摄像头方向 "1"前、"2"后

@property (nonatomic, copy) NSString *bgType; //背景图类型 "0":无 "1"：头像、"2"：身份证正面、"3"：身份证反面

//数据转换
- (void)generateModelWithData:(id)data;

@end
