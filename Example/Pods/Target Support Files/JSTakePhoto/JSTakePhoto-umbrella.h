#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "BSVKCameraController.h"
#import "BSVKWebController.h"
#import "IMYWebView.h"
#import "IMY_NJKWebViewProgress.h"
#import "BSVKCameraTypeModel.h"
#import "UIView+BSVKAdditions.h"
#import "UIView+BSVKHUD.h"
#import "BSVKBackGroundView.h"
#import "BSVKCameraPreview.h"
#import "BSVKCameraView.h"
#import "WebViewJavascriptBridge.h"
#import "WebViewJavascriptBridgeBase.h"
#import "WebViewJavascriptBridge_JS.h"
#import "WKWebViewJavascriptBridge.h"

FOUNDATION_EXPORT double JSTakePhotoVersionNumber;
FOUNDATION_EXPORT const unsigned char JSTakePhotoVersionString[];

