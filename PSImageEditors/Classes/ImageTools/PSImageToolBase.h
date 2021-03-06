//
//  PSImageToolBase.h
//  PSImageEditors
//
//  Created by rsf on 2018/11/16.
//  Copyright © 2018年 paintingStyle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "_PSImageEditorViewController.h"

static const CGFloat kImageToolAnimationDuration = 0.3;
static const CGFloat kImageToolBaseFadeoutDuration = 0.2;

static NSString *kImageToolDrawLineWidthKey = @"drawLineWidth";
static NSString *kImageToolDrawLineColorKey = @"drawLineColor";

static NSString *kImageToolTextColorKey = @"textColor";
static NSString *kImageToolTextFontKey = @"textFont";

@interface PSImageToolBase : NSObject

@property (nonatomic, weak) _PSImageEditorViewController *editor;
@property (nonatomic, strong) NSDictionary *option;
@property (nonatomic, assign) BOOL produceChanges; // 是否使用过该工具,即图片产生了编辑操作

- (instancetype)initWithImageEditor:(_PSImageEditorViewController *)editor
						 withOption:(NSDictionary *)option;

- (void)initialize;
- (void)setup;
- (void)cleanup;
- (void)resetRect:(CGRect)rect;
- (void)executeWithCompletionBlock:(void(^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock;

- (void)hiddenToolBar:(BOOL)hidden animation:(BOOL)animation;

@end

