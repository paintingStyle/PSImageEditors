//
//  PSTexTool.h
//  PSImageEditors
//
//  Created by rsf on 2018/11/16.
//

#import "PSImageToolBase.h"
@class PSTexTool, PSTextView, PSTexToolItem;

@interface PSTexTool : PSImageToolBase

@property (nonatomic, strong) PSTextView *textView;

/// 再次编辑PSTexToolItem
@property (nonatomic, assign) BOOL isEditAgain;
/// 关闭页面
@property (nonatomic, copy) void (^dissmissCallback) (NSString *currentText);
/// 再次编辑回调
@property (nonatomic, copy) void (^editAgainCallback) (NSString *text, NSDictionary *attrs);

@end

@interface PSTextView : UIView

@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, strong) UITextView *inputView;
@property (nonatomic, strong) NSDictionary *attrs; /// 预设属性

@property (nonatomic, copy) void (^dissmissBlock) (NSString *text, NSDictionary *attrs, BOOL use);

@end
