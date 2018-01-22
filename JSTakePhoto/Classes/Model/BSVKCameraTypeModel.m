//
//  BSVKCameraTypeModel.m
//  JSTakePhoto
//
//  Created by Will on 2018/1/16.
//  Copyright © 2018年 Will. All rights reserved.
//

#import "BSVKCameraTypeModel.h"

@implementation BSVKCameraTypeModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.haveBg = NO;
        self.cameraDirection = @"2";
        self.bgType = @"0";
    }
    return self;
}

- (void)generateModelWithData:(id)data {
    if ([data isKindOfClass:[NSDictionary class]]) {
        NSString *showStr = data[@"iSShowBg"];
        if (showStr){
            if ([showStr isEqualToString:@"yes"]) {
                self.haveBg = YES;
            } else {
                self.haveBg = NO;
            }
        }
        NSString *direction = data[@"direction"];
        if (direction){
            self.cameraDirection = direction;
        }
        NSString *type = data[@"bgType"];
        if (type){
            self.bgType = type;
        }
    }
}

@end
