//
//  UIImage+PSImageEditors.h
//  PSImageEditors
//
//  Created by paintingStyle on 2018/8/25.
//

#import <UIKit/UIKit.h>

@interface UIImage (PSImageEditors)

+ (UIImage *)ps_imageNamed:(NSString *)name;
	
/** 通过遍历像素点实现马赛克效果,level越大,马赛克颗粒越大,若level为0则默认为图片1/20 */
+ (UIImage *)ps_mosaicImage:(UIImage *)image level:(NSInteger)level;

@end
