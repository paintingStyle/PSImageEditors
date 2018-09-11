//
//  PSImageEditors.h
//  PSImageEditors
//
//  Created by rsf on 2018/8/29.
//

#import "PSPreviewViewController.h"
#import "PSCoolPreviewsViewController.h"

@interface PSImageEditors : NSObject

+ (void)defaultEditors;

/// 编辑默认颜色，例如画笔预设颜色
@property (nonatomic, strong) UIColor *editorDefaultColor;

/// 画笔宽度
@property (nonatomic, assign) CGFloat drawPathWidth;

@end

/**
待解决：
 1，旋转文字显示问题
 */
 
