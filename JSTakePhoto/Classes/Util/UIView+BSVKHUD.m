//
//  UIView+BSVKHUD.m
//  JSTakePhoto
//
//  Created by Will on 2018/1/16.
//  Copyright © 2018年 Will. All rights reserved.
//

#import "UIView+BSVKHUD.h"

#import <objc/runtime.h>

#define KEY_CC_ALERT_VIEW "UIView.AlertController"

@implementation UIView (BSVKHUD)
@dynamic bsAlertController;

-(UIAlertController *)bsAlertController{
    NSObject * obj = objc_getAssociatedObject(self, KEY_CC_ALERT_VIEW);
    if (obj && [obj isKindOfClass:[UIAlertController class]]){
        return (UIAlertController *)obj;
    }
    return nil;
}

-(void)setCcAlertController:(UIAlertController *)bsAlertController
{
    if (nil == bsAlertController){
        return;
    }
    objc_setAssociatedObject(self, KEY_CC_ALERT_VIEW, bsAlertController, OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}

#pragma mark - 加载框
-(void)showHUD:(UIViewController *)vc message:(NSString *)message{
    [self showHUD:vc message:message isLoad:NO];
}

-(void)showLoadHUD:(UIViewController *)vc message:(NSString *)message{
    [self showHUD:vc message:message isLoad:YES];
}

-(void)showHUD:(UIViewController *)vc message:(NSString *)message isLoad:(BOOL)isLoad{
    if (!self.bsAlertController) {
        self.ccAlertController = [UIAlertController alertControllerWithTitle:nil
                                                                     message:[NSString stringWithFormat:@"\n\n\n%@",message]
                                                              preferredStyle:UIAlertControllerStyleAlert];
        if (isLoad) {
            [self findLabel:self.bsAlertController.view succ:^(UIView *label) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                    activityView.color = [UIColor lightGrayColor];
                    activityView.center = CGPointMake(label.frame.size.width/2, 25);
                    [label addSubview:activityView];
                    [activityView startAnimating];
                });
            }];
        }
    }
    [vc presentViewController:self.bsAlertController animated:YES completion:nil];
}

#pragma mark - 提示框
-(void)showAutoDismissHUD:(UIViewController *)vc message:(NSString *)message{
    [self showAutoDismissHUD:vc message:message delay:0.3];
}

-(void)showAutoDismissHUD:(UIViewController *)vc message:(NSString *)message delay:(NSTimeInterval)delay{
    if (!self.bsAlertController) {
        self.ccAlertController = [UIAlertController alertControllerWithTitle:nil
                                                                     message:message
                                                              preferredStyle:UIAlertControllerStyleAlert];
        
        UIView *view = [[UIView alloc]initWithFrame:self.bsAlertController.view.bounds];
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);
        [view addSubview:activityView];
        
    }
    [vc presentViewController:self.bsAlertController animated:YES completion:nil];
    [NSTimer scheduledTimerWithTimeInterval:delay
                                     target:self
                                   selector:@selector(hideHUD)
                                   userInfo:self.bsAlertController
                                    repeats:NO];
}

-(void)hideHUD{
    if (self.bsAlertController) {
        [self.bsAlertController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - 弹出框
-(void)showAlertView:(UIViewController *)vc message:(NSString *)message sure:(void(^)(UIAlertAction * act))sure cancel:(void(^)(UIAlertAction * act))cancel{
    [self showAlertView:vc title:@"提示" message:message sureTitle:@"确定" cancelTitle:@"取消" sure:sure cancel:cancel];
}

-(void)showAlertView:(UIViewController *)vc title:(NSString *)title message:(NSString *)message sureTitle:(NSString *)sureTitle cancelTitle:(NSString *)cancelTitle sure:(void(^)(UIAlertAction * act))sure cancel:(void(^)(UIAlertAction * act))cancel{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    if (cancelTitle) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (cancel) {
                cancel(action);
            }
        }];
        [alertController addAction:cancelAction];
    }
    
    if (sureTitle) {
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (sure) {
                sure(action);
            }
        }];
        [alertController addAction:okAction];
    }
    [vc presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Private methods
-(void)findLabel:(UIView*)view succ:(void(^)(UIView *label))succ
{
    for (UIView* subView in view.subviews)
    {
        if ([subView isKindOfClass:[UILabel class]]) {
            if (succ) {
                succ(subView);
            }
        }
        [self findLabel:subView succ:succ];
    }
}
@end
