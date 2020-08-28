//
//  NSAttributedString+PSCoreText.h
//  PSImageEditors
//
//  Created by rsf on 2020/8/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSAttributedString (PSCoreText)

/**
 *  计算文字大小
 *
 *  @param size          最大范围 文字长度、文字高度
 *
 *  @return 文字大小
 */
- (CGSize)sizeWithConstrainedToSize:(CGSize)size;


/**
 *  绘制文字
 *
 *  @param context       画布
 *  @param p             坐标
 *  @param height        高度
 *  @param width         宽度
 */
- (void)drawInContext:(CGContextRef)context withPosition:(CGPoint)p andHeight:(float)height andWidth:(float)width;

@end

NS_ASSUME_NONNULL_END
