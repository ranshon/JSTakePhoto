//
//  BSVKCameraController.h
//  JSTakePhoto
//
//  Created by Will on 2018/1/16.
//  Copyright © 2018年 Will. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BSVKCameraTypeModel.h"

@protocol BSVKCameraControllerDelegate <NSObject>

- (void)returnImage:(UIImage *)image;

@end

@interface BSVKCameraController : UIViewController

@property (nonatomic, strong) BSVKCameraTypeModel *typeModel;

@property (nonatomic,weak) id<BSVKCameraControllerDelegate> cameraConDelegate;

@end
