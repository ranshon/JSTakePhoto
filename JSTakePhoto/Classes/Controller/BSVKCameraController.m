//
//  BSVKCameraController.m
//  JSTakePhoto
//
//  Created by Will on 2018/1/16.
//  Copyright © 2018年 Will. All rights reserved.
//

#import "BSVKCameraController.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <CoreMedia/CMMetadata.h>

#import "BSVKCameraView.h"
#import "BSVKCameraPreview.h"

#import "UIView+BSVKHUD.h"


#define ISIOS9 __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0

@interface BSVKCameraController () <AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate,BSVKCameraViewDelegate> {
    AVCaptureSession          *_captureSession;
    
    // 输入
    AVCaptureDeviceInput      *_deviceInput;
    
    // 输出
    AVCaptureStillImageOutput *_imageOutput;
    AVCaptureFlashMode         _currentflashMode; // 当前闪光灯的模式

}

@property(nonatomic, strong) BSVKCameraView *cameraView;

@property(nonatomic, strong) AVCaptureDevice *activeCamera;     // 当前输入设备
@property(nonatomic, strong) AVCaptureDevice *inactiveCamera;   // 不活跃的设备(这里指前摄像头或后摄像头，不包括外接输入设备)

@end

@implementation BSVKCameraController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.cameraView];
    self.cameraView.typeModel = self.typeModel;
    self.cameraView.isOpenFlush = ([[self activeCamera] flashMode] == AVCaptureFlashModeOn);
    
    NSError *error;
    [self setupSession:&error];
    if (!error) {
        [self.cameraView.previewView setCaptureSessionsion:_captureSession];
        if (!_captureSession.isRunning){
            [_captureSession startRunning];
        }
    } else {
        [self showError:error];
    }
    
    //根据数据设置摄像头方向
    if ([self.typeModel.cameraDirection isEqualToString:@"1"]) {
        [self switchCameras];
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Init
// 配置会话
- (void)setupSession:(NSError **)error {
    _captureSession = [[AVCaptureSession alloc]init];
    [_captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    
    [self setupSessionInputs:error];
    [self setupSessionOutputs:error];
}

// 添加输入
- (void)setupSessionInputs:(NSError **)error {
    // 图片或视频输入
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //设置为自动曝光
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
    BOOL canResetFocus = [videoDevice isFocusPointOfInterestSupported] && [videoDevice isFocusModeSupported:focusMode];
    BOOL canResetExposure = [videoDevice isExposurePointOfInterestSupported] && [videoDevice isExposureModeSupported:exposureMode];
    CGPoint centerPoint = CGPointMake(0.5f, 0.5f);
    NSError *deviceeError;
    if ([videoDevice lockForConfiguration:&deviceeError]) {
        if (canResetFocus) {
            videoDevice.focusMode = focusMode;
            videoDevice.focusPointOfInterest = centerPoint;
        }
        if (canResetExposure) {
            videoDevice.exposureMode = exposureMode;
            videoDevice.exposurePointOfInterest = centerPoint;
        }
        [videoDevice unlockForConfiguration];
    }
    
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:error];
    
    if (videoInput) {
        if ([_captureSession canAddInput:videoInput]){
            [_captureSession addInput:videoInput];
            _deviceInput = videoInput;
        }
    }
}

// 添加输出
- (void)setupSessionOutputs:(NSError **)error {
    // 静态图片输出
    AVCaptureStillImageOutput *imageOutput = [[AVCaptureStillImageOutput alloc] init];
    imageOutput.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    if ([_captureSession canAddOutput:imageOutput]) {
        [_captureSession addOutput:imageOutput];
        _imageOutput = imageOutput;
    }
}

#pragma mark - Get Set
- (void)setTypeModel:(BSVKCameraTypeModel *)typeModel {
    _typeModel = typeModel;
    self.cameraView.typeModel = typeModel;
}

- (BSVKCameraView *)cameraView {
    if (!_cameraView) {
        self.cameraView = [[BSVKCameraView alloc] initWithFrame:self.view.bounds];
        self.cameraView.delegate = self;
    }
    return _cameraView;
}

- (AVCaptureDevice *)activeCamera {
    return _deviceInput.device;
}

- (AVCaptureDevice *)inactiveCamera {
    AVCaptureDevice *device = nil;
    if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1) {
        if ([self activeCamera].position == AVCaptureDevicePositionBack) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else {
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}

#pragma mark - Private Method
//输入设备(摄像头)
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}
// 展示错误
- (void)showError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view showAlertView:self title:error.localizedDescription message:error.localizedFailureReason sureTitle:@"确定" cancelTitle:nil sure:nil cancel:nil];
    });
}

#pragma mark - 摄像头属性设置
- (id)setFlashMode:(AVCaptureFlashMode)flashMode{
    AVCaptureDevice *device = [self activeCamera];
    if ([device isFlashModeSupported:flashMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
            _currentflashMode = flashMode;
        }
        return error;
    }
    return nil;
}

- (id)setTorchMode:(AVCaptureTorchMode)torchMode{
    AVCaptureDevice *device = [self activeCamera];
    if ([device isTorchModeSupported:torchMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        }
        return error;
    }
    return nil;
}

#pragma mark - BSVKCameraViewDelegate
/// 取消
-(void)cancelAction:(BSVKCameraView *)cameraView {
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self.navigationController popViewControllerAnimated:YES];
}
/// 补光按钮
-(void)torchLightAction:(BSVKCameraView *)cameraView succ:(void(^)(void))succ fail:(void(^)(NSError *error))fail {
    id error =  [self changeTorch:[[self activeCamera] torchMode] == AVCaptureTorchModeOn?AVCaptureTorchModeOff:AVCaptureTorchModeOn];
    error?!fail?:fail(error):!succ?:succ();
}

- (id)changeTorch:(AVCaptureTorchMode)torchMode{
    if (![[self activeCamera] hasTorch]) {
        NSDictionary *desc = @{NSLocalizedDescriptionKey:@"不支持手电筒"};
        NSError *error = [NSError errorWithDomain:@"com.cc.camera" code:403 userInfo:desc];
        return error;
    }
    // 如果闪光灯打开，先关闭闪光灯
    if ([[self activeCamera] flashMode] == AVCaptureFlashModeOn) {
        [self setFlashMode:AVCaptureFlashModeOff];
    }
    return [self setTorchMode:torchMode];
}

/// 闪光灯按钮
-(void)flashLightAction:(BSVKCameraView *)cameraView succ:(void(^)(void))succ fail:(void(^)(NSError *error))fail {
    id error = [self changeFlash:[[self activeCamera] flashMode] == AVCaptureFlashModeOn?AVCaptureFlashModeOff:AVCaptureFlashModeOn];
    error?!fail?:fail(error):!succ?:succ();
}

- (id)changeFlash:(AVCaptureFlashMode)flashMode{
    if (![[self activeCamera] hasFlash]) {
        NSDictionary *desc = @{NSLocalizedDescriptionKey:@"不支持闪光灯"};
        NSError *error = [NSError errorWithDomain:@"com.cc.camera" code:401 userInfo:desc];
        return error;
    }
    // 如果手电筒打开，先关闭手电筒
    if ([[self activeCamera] torchMode] == AVCaptureTorchModeOn) {
        [self setTorchMode:AVCaptureTorchModeOff];
    }
    return [self setFlashMode:flashMode];
}
/// 转换摄像头
-(void)swicthCameraAction:(BSVKCameraView *)cameraView succ:(void(^)(void))succ fail:(void(^)(NSError *error))fail {
    id error = [self switchCameras];
    error?!fail?:fail(error):!succ?:succ();
}

- (id)switchCameras
{
    if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] <= 1) return nil;
    NSError *error;
    AVCaptureDevice *videoDevice = [self inactiveCamera];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if (videoInput) {
        [_captureSession beginConfiguration];
        [_captureSession removeInput:_deviceInput];
        if ([_captureSession canAddInput:videoInput]) {
            [_captureSession addInput:videoInput];
            _deviceInput = videoInput;
        }
        [_captureSession commitConfiguration];
        
        // 如果从后置转前置，会关闭手电筒，如果之前打开的，需要通知camera更新UI
        if (videoDevice.position == AVCaptureDevicePositionFront) {
            [self.cameraView changeLight:NO];
        }
        // 闪关灯，前后摄像头的闪光灯是不一样的，所以在转换摄像头后需要重新设置闪光灯
        [self changeFlash:_currentflashMode];
        return nil;
    }
    return error;
}

/// 拍照
-(void)takePhotoAction:(BSVKCameraView *)cameraView {
    AVCaptureConnection *connection = [_imageOutput connectionWithMediaType:AVMediaTypeVideo];
    id takePictureSuccess = ^(CMSampleBufferRef sampleBuffer,NSError *error){
        if (sampleBuffer == NULL) {
            [self showError:error];
            return ;
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
        UIImage *image = [[UIImage alloc]initWithData:imageData];
        if (self.cameraConDelegate && [self.cameraConDelegate respondsToSelector:@selector(returnImage:)]) {
            [self.cameraConDelegate returnImage:image];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    [_imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:takePictureSuccess];
}

@end
