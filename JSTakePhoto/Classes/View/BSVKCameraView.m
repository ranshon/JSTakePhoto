//
//  BSVKCameraView.m
//  JSTakePhoto
//
//  Created by Will on 2018/1/16.
//  Copyright © 2018年 Will. All rights reserved.
//

#import "BSVKCameraView.h"

#import "BSVKCameraTypeModel.h"

#import "BSVKBackGroundView.h"
#import "BSVKCameraPreview.h"

#import "UIView+BSVKAdditions.h"
#import "UIView+BSVKHUD.h"
@interface BSVKCameraView()
@property(nonatomic, strong) UIView *topView;      // 上面的bar
@property(nonatomic, strong) UIImageView *headerView; // 头像背景
@property(nonatomic, strong) BSVKBackGroundView *backView; // 背景View
@property(nonatomic, strong) BSVKCameraPreview *previewView;

@property(nonatomic, strong) UIButton *cancleBtn;  //返回
@property(nonatomic, strong) UIButton *lightBtn;   //补光 (打开灯光)
@property(nonatomic, strong) UIButton *flashBtn;   //闪光灯(打开闪光灯)
@property(nonatomic, strong) UIButton *switchCameraBtn;   //转换摄像头方向
@property(nonatomic, strong) UIButton *photoBtn;   //拍照

@end

@implementation BSVKCameraView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
    }
    return self;
}

#pragma mark - Get Set
//头视图
-(UIView *)topView{
    if (_topView == nil) {
        _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, 50)];
        _topView.backgroundColor = [UIColor blackColor];
    }
    return _topView;
}

//头像背景图
- (UIImageView *)headerView {
    if (!_headerView) {
        _headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, self.width, self.height-50)];
        _headerView.contentMode = UIViewContentModeScaleAspectFill;
        [_headerView setImage:[UIImage imageNamed:@"person_header_bg"]];
        [self addSubview:_headerView];
        _headerView.hidden = YES;
    }
    return _headerView;
}

//身份证背景图
- (BSVKBackGroundView *)backView {
    if (!_backView) {
        _backView = [[BSVKBackGroundView alloc] initWithFrame:CGRectMake(0, 50, self.width, self.height - 50)];
        [self addSubview:_backView];
        _backView.hidden = YES;
    }
    return _backView;
}

- (void)setIsOpenFlush:(BOOL)isOpenFlush {
    _isOpenFlush = isOpenFlush;
    if (isOpenFlush) {
        [self.flashBtn setTitle:@"关闭闪光灯" forState:UIControlStateNormal];
    } else {
       [self.flashBtn setTitle:@"打开闪光灯" forState:UIControlStateNormal];
    }
}

- (void)setTypeModel:(BSVKCameraTypeModel *)typeModel {
    _typeModel = typeModel;
    self.headerView.hidden = YES;
    self.backView.hidden = YES;
    if (typeModel.haveBg) {
        if ([typeModel.bgType isEqualToString:@"1"]) {
            self.headerView.hidden = NO;
            
        } else if ([typeModel.bgType isEqualToString:@"2"]) {
            self.backView.warningInfo = @"请拍摄身份证正面";
            self.backView.hidden = NO;
            
        } else {
            self.backView.warningInfo = @"请拍摄身份证反面";
            self.backView.hidden = NO;
        }
    }
    [self bringSubviewToFront:self.photoBtn];
}

#pragma mark - Init
- (void)setUpUI {
    self.previewView = [[BSVKCameraPreview alloc]initWithFrame:CGRectMake(0, 50, self.width, self.height - 50)];
    [self addSubview:self.previewView];
    
    [self addSubview:self.topView];
    
    CGFloat margerWidth = (self.width - 30 - 70 - 180) / 3;
    self.cancleBtn = [self generateButtonWithTitle:@"取消" andAction:@selector(cancel)];
    self.cancleBtn.frame = CGRectMake(15,25,35, 20);
    [self.topView addSubview:self.cancleBtn];
    
    self.lightBtn = [self generateButtonWithTitle:@"补光" andAction:@selector(lightBtnClick)];
    self.lightBtn.selected = NO;
    self.lightBtn.frame = CGRectMake(self.cancleBtn.right + margerWidth, self.cancleBtn.top, 35, 20);
    [self.topView addSubview:self.lightBtn];
    
    self.flashBtn = [self generateButtonWithTitle:@"打开闪光灯" andAction:@selector(flashBtnClick)];
    self.flashBtn.selected = NO;
    self.flashBtn.frame = CGRectMake(self.lightBtn.right + margerWidth, self.cancleBtn.top, 90, 20);
    [self.topView addSubview:self.flashBtn];
    
    self.switchCameraBtn = [self generateButtonWithTitle:@"转换摄像头" andAction:@selector(switchCameraClick)];
    self.switchCameraBtn.frame = CGRectMake(self.flashBtn.right + margerWidth, self.cancleBtn.top, 90, 20);
    [self.topView addSubview:self.switchCameraBtn];
    
    self.photoBtn = [self generateButtonWithTitle:@"拍" andAction:@selector(takePicture)];
    self.photoBtn.frame = CGRectMake((self.width - 80) / 2, self.height - 100, 80, 80);
    self.photoBtn.layer.masksToBounds = YES;
    self.photoBtn.layer.cornerRadius = 40;
    self.photoBtn.backgroundColor = [UIColor whiteColor];
    [self.photoBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.photoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.photoBtn.titleLabel.font = [UIFont systemFontOfSize:20];

    [self addSubview:self.photoBtn];
}

- (UIButton *)generateButtonWithTitle:(NSString *)title andAction:(SEL)action {
    UIButton *normalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [normalBtn setTitle:title forState:UIControlStateNormal];
    normalBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [normalBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [normalBtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [normalBtn sizeToFit];
    
    return normalBtn;
}

#pragma mark - Public Method
- (void)changeLight:(BOOL)on {
    _lightBtn.selected = on;
    if (_lightBtn.isSelected) {
        [_lightBtn setTitle:@"关灯" forState:UIControlStateNormal];
    } else {
        [_lightBtn setTitle:@"补光" forState:UIControlStateNormal];
    }
}

#pragma mark - Button Event
- (void)cancel {
    if ([_delegate respondsToSelector:@selector(cancelAction:)]) {
        [_delegate cancelAction:self];
    }
}

//补光
- (void)lightBtnClick {
    if ([_delegate respondsToSelector:@selector(torchLightAction:succ:fail:)]) {
        [_delegate torchLightAction:self succ:^{
            _lightBtn.selected = !_lightBtn.selected;
            if (_lightBtn.isSelected) {
                [_lightBtn setTitle:@"关灯" forState:UIControlStateNormal];
            } else {
                [_lightBtn setTitle:@"补光" forState:UIControlStateNormal];
            }
            if (_flashBtn.isSelected) {
                _flashBtn.selected = NO;
                [_flashBtn setTitle:@"打开闪光灯" forState:UIControlStateNormal];
            }
            
        } fail:^(NSError *error) {
            [self showError:error];
        }];
    }
}

//闪光灯设置
- (void)flashBtnClick {
    if ([_delegate respondsToSelector:@selector(flashLightAction:succ:fail:)]) {
        [_delegate flashLightAction:self succ:^{
            _flashBtn.selected = !_flashBtn.selected;
            if (_flashBtn.isSelected) {
                [_flashBtn setTitle:@"关闭闪关灯" forState:UIControlStateNormal];
            } else {
                [_flashBtn setTitle:@"打开闪光灯" forState:UIControlStateNormal];
            }
            if (_lightBtn.isSelected) {
                _lightBtn.selected = NO;
                [_lightBtn setTitle:@"补光" forState:UIControlStateNormal];
            }
        } fail:^(NSError *error) {
            [self showError:error];
        }];
    }
}

//变更摄像头方向
- (void)switchCameraClick {
    if ([_delegate respondsToSelector:@selector(swicthCameraAction:succ:fail:)]) {
        [_delegate swicthCameraAction:self succ:nil fail:^(NSError *error) {
            [self showError:error];
        }];
    }
}

//拍照
- (void)takePicture {
    if ([_delegate respondsToSelector:@selector(takePhotoAction:)]) {
        [_delegate takePhotoAction:self];
    }
}

- (void)showError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showAlertView:[self viewController] title:error.localizedDescription message:error.localizedFailureReason sureTitle:@"确定" cancelTitle:nil sure:nil cancel:nil];
    });
}
@end
