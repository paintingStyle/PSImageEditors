//
//  PSImageEditorsHelper.h
//  Pods-PSImageEditors
//
//  Created by rsf on 2018/8/24.
//

#import <UIKit/UIKit.h>

@interface PSImageEditorsHelper : NSObject

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)imageSpecifyWidthScalingWithImage:(UIImage *)image
								  scalingWidth:(CGFloat)width;

@end
