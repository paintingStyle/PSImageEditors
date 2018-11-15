//
//  PSActionSheet.m
//  PSImageEditors
//
//  Created by paintingStyle on 2018/8/25.
//

#import "PSActionSheet.h"

#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define kRGBColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define kIsiPhoneX (kHeight == 812)

#define kActionButtonH 47
#define kActionCancelButtonH (kIsiPhoneX ? (kActionButtonH + 34): kActionButtonH)
#define kButtonDividerH 1
#define kCancelButtonDividerH 10
#define kAnimateDuration 0.25f

@implementation PSActionSheet

static PSActionSheetButton *_backgroundView;
static UIView *_sheetView;

+ (void)sheetWithActionTitles:(NSArray *)titles
                  actionBlock:(actionClickBlock)block {
    
    if (!titles.count) { return; }
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    _backgroundView = [[PSActionSheetButton alloc] init];
    _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    _backgroundView.center = CGPointMake(kWidth * 0.5, kHeight * 0.5);
    _backgroundView.bounds = CGRectMake(0, 0, kWidth, kHeight);
    [_backgroundView initWithClickBlock:^(id obj) {
        [self removeSheetView];
    } forControlEvents:UIControlEventTouchUpInside];
    [window addSubview:_backgroundView];
    
    CGFloat sheetViewH;
    if (titles.count == 1) {
        sheetViewH = (kActionCancelButtonH +kCancelButtonDividerH) +kActionButtonH;
    }else{
        sheetViewH = (kActionCancelButtonH +kCancelButtonDividerH) + titles.count * (kActionButtonH +kButtonDividerH) - kButtonDividerH;
    }
    _sheetView = [[UIView alloc] init];
    _sheetView.frame = CGRectMake(0, kHeight, kWidth, sheetViewH);
    _sheetView.backgroundColor = kRGBColor(242, 246, 249, 1);
    [_backgroundView addSubview:_sheetView];
    
    
    PSActionSheetButton *canclebutton = [[PSActionSheetButton alloc] init];
    canclebutton.backgroundColor = [UIColor whiteColor];
    [canclebutton setTitle:@"取消" forState:UIControlStateNormal];
    [canclebutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    canclebutton.titleLabel.font = [UIFont systemFontOfSize:16];
    canclebutton.frame = CGRectMake(0, CGRectGetHeight(_sheetView.frame) - kActionCancelButtonH, kWidth, kActionCancelButtonH);
    [canclebutton initWithClickBlock:^(id obj) {
        [self removeSheetView];
    } forControlEvents:UIControlEventTouchUpInside];
    if (kIsiPhoneX) { canclebutton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 20, 0); }
    [window addSubview:_backgroundView];
    [_sheetView addSubview:canclebutton];
    
    for (NSUInteger i = 0; i<titles.count; i++) {
        
        PSActionSheetButton *button = [[PSActionSheetButton alloc] init];
        button.backgroundColor = [UIColor whiteColor];
        button.tag = i;
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        if (titles.count == 1) {
            button.frame = CGRectMake(0, 0, kWidth,kActionButtonH);
        }else{
            button.frame = CGRectMake(0, i * (kActionButtonH + kButtonDividerH), kWidth,kActionButtonH);
        }
        [button initWithClickBlock:^(id obj) {
            if (block) { block(i); }
            [self removeSheetView];
        } forControlEvents:UIControlEventTouchUpInside];
        [window addSubview:_backgroundView];
        [_sheetView addSubview:button];
    }
    
    [UIView animateWithDuration:kAnimateDuration animations:^{
        
        CGRect sheetViewFrame = _sheetView.frame;
        sheetViewFrame.origin.y = kHeight - sheetViewH;
        _sheetView.frame = sheetViewFrame;
    }];
}

+ (void)removeSheetView {
    
    [UIView animateWithDuration:kAnimateDuration animations:^{

        CGRect sheetViewFrame = _sheetView.frame;
        sheetViewFrame.origin.y = kHeight;
        _sheetView.frame = sheetViewFrame;
    } completion:^(BOOL finished) {
        [_backgroundView removeFromSuperview];
        _backgroundView = nil;
        _sheetView = nil;
    }];
}

@end

@implementation PSActionSheetButton

- (void)initWithClickBlock:(buttonClickBlock)block forControlEvents:(UIControlEvents)event {
    
    [self addTarget:self action:@selector(buttonDidClick:) forControlEvents:event];
    self.clickBlock = block;
}

- (void)buttonDidClick:(UIButton *)btn {
    
    if (self.clickBlock) { self.clickBlock(btn); }
}

@end
