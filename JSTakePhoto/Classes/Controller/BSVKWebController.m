//
//  BSVKWebController.m
//  JSTakePhoto
//
//  Created by Will on 2018/1/15.
//  Copyright © 2018年 Will. All rights reserved.
//

#import "BSVKWebController.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

#import <IMYWebView.h>
#import <WebViewJavascriptBridge.h>

#import "UIView+BSVKAdditions.h"

#import "BSVKCameraTypeModel.h"

#import "BSVKCameraController.h"



@interface BSVKWebController ()<IMYWebViewDelegate,BSVKCameraControllerDelegate> {
    WVJBResponseCallback _responseCallback;
}

@property (nonatomic, strong) IMYWebView *webShowView;

@property (nonatomic) WebViewJavascriptBridge *bridge;

@property (nonatomic, strong) UIAlertController *alertCon;
@end

@implementation BSVKWebController
- (void)loadView {
    [super loadView];
    
    [self generateJsBridge];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (_strUrl.length <= 0) {
        _strUrl = @"https://testpm.haiercash.com:9002/hf/#!/test/webview.html";
    }
    
    //设置请求头
    NSURL *url = [[NSURL alloc]initWithString:_strUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    NSMutableURLRequest *muRequest = [request mutableCopy];
    [muRequest addValue:@"iOSApp" forHTTPHeaderField:@"webview"];
    request = [muRequest copy];
    [self.webShowView loadRequest:request];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (@available(iOS 11, *)) {
        self.webShowView.frame = CGRectMake(0, 20, self.view.width, self.view.height - 20 - self.view.safeAreaInsets.bottom);
    } else {
        self.webShowView.frame = CGRectMake(0, 20, self.view.width, self.view.height - 20);
    }
}

#pragma mark - Init
//初始化JS交互实体
- (void)generateJsBridge {
    if (DEBUG) {
        [WebViewJavascriptBridge enableLogging];
    }
    
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.webShowView.realWebView];
    if (self.bridge) {
        typeof(self) __weak weakSelf = self;

        //注册JS交互方法 chooseImage
        [_bridge registerHandler:@"chooseImage" handler:^(id data, WVJBResponseCallback responseCallback) {
            typeof(weakSelf) __strong strongSelf = weakSelf;
            _responseCallback = responseCallback;
            if([strongSelf isGetCameraPermission]) {
                [strongSelf toNewCamareControllerWithData:data];
            } else {
                strongSelf.alertCon.message = @"请到设置中开启照相权限";
                [strongSelf presentViewController:strongSelf.alertCon animated:YES completion:nil];
            }
            
        }];
    }
}

#pragma mark - Get Set
//网页
- (IMYWebView *)webShowView {
    if (!_webShowView) {
        _webShowView = [[IMYWebView alloc] initWithFrame:CGRectMake(0, 20, self.view.width, self.view.height - 20)];
        _webShowView.delegate = self;
        [self.view addSubview:_webShowView];
    }
    return _webShowView;
}

//弹出框
- (UIAlertController *)alertCon {
    if (!_alertCon) {
        _alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        [_alertCon addAction:sureAction];
    }
    return _alertCon;
}

- (void)setConTitle:(NSString *)conTitle {
    _conTitle = conTitle;
    self.title = _conTitle;
}

#pragma mark - 私有方法
//弹出自定义照相页面
- (void)toNewCamareControllerWithData:(id)data {
    BSVKCameraTypeModel *model = [BSVKCameraTypeModel new];
    [model generateModelWithData:data];
    BSVKCameraController *cameraCon = [BSVKCameraController new];
    cameraCon.cameraConDelegate = self;
    cameraCon.typeModel = model;
    [self presentViewController:cameraCon animated:YES completion:nil];
}

#pragma mark - 权限判断
//判读拍照权限
-(BOOL)isGetCameraPermission{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
    {
        return NO;
        
    }else{
        return YES;
    }
}

#pragma mark - BSVKCameraControllerDelegate
//拍照完成后回调的方法，会将照片数据传到网页端
-(void)returnImage:(UIImage *)image {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        NSData *data = UIImageJPEGRepresentation(image, 1);
        
        if(data.length > 1024 * 1024 * 2) {
            CGFloat compressionQuality = (1024 * 1024 * 2) / ((CGFloat)data.length);
            data = nil;
            data = UIImageJPEGRepresentation(image, compressionQuality);
        }
        
        NSString *string = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        string = [string stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        if(_responseCallback){
            _responseCallback(@{@"photoBase64":string});
        }
    });
    
}

@end
