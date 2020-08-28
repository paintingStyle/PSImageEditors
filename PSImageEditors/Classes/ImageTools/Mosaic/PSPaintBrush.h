//
//  PSPaintBrush.h
//  PSImageEditors
//
//  Created by rsf on 2020/8/24.
//

#import "PSBrush.h"

NS_ASSUME_NONNULL_BEGIN

OBJC_EXTERN NSString *const PSPaintBrushLineColor;

@interface PSPaintBrush : PSBrush

/** 线颜色 默认红色 */
@property (nonatomic, strong, nullable) UIColor *lineColor;

@end

NS_ASSUME_NONNULL_END
