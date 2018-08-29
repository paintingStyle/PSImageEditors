//
//  UIColor+PSImageEditors.h
//  PSImageEditors
//
//  Created by rsf on 2018/8/29.
//

#import <UIKit/UIKit.h>

//#define PS_HEX_COLOR(c) [UIColor hex:c]

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (PSImageEditors)

/**
 *  根据指定的HEX字符串创建一种颜色
 *  HEX支持下面的格式:
 *  - #RGB
 *  - #ARGB
 *  - #RRGGBB
 *  - #AARRGGBB
 *
 *  @param hexString HEX字符串
 *
 *  @return 返回创建的UIColor实例
 */
+ (UIColor *)hex:(NSString *)hexString;

@end

NS_ASSUME_NONNULL_END
