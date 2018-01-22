//
//  BSVKCameraView.h
//  JSTakePhoto
//
//  Created by Will on 2018/1/16.
//  Copyright © 2018年 Will. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BSVKCameraTypeModel,BSVKCameraView,BSVKCameraPreview;
@protocol BSVKCameraViewDelegate <NSObject>
/// 取消
-(void)cancelAction:(BSVKCameraView *)cameraView;
/// 补光按钮
-(void)torchLightAction:(BSVKCameraView *)cameraView succ:(void(^)(void))succ fail:(void(^)(NSError *error))fail;
/// 闪光灯按钮
-(void)flashLightAction:(BSVKCameraView *)cameraView succ:(void(^)(void))succ fail:(void(^)(NSError *error))fail;
/// 转换摄像头
-(void)swicthCameraAction:(BSVKCameraView *)cameraView succ:(void(^)(void))succ fail:(void(^)(NSError *error))fail;
/// 拍照
-(void)takePhotoAction:(BSVKCameraView *)cameraView;
@end

@interface BSVKCameraView : UIView

@property (nonatomic, strong) BSVKCameraTypeModel *typeModel;

@property(nonatomic, weak) id <BSVKCameraViewDelegate> delegate;

@property (nonatomic, assign) BOOL isOpenFlush;


@property(nonatomic, strong, readonly) BSVKCameraPreview *previewView;

- (void)changeLight:(BOOL)on;
@end
