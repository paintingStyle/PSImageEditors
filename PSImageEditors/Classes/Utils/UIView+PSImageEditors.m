//
//  UIView+PSImageEditors.m
//  PSImageEditors
//
//  Created by rsf on 2020/8/24.
//

#import "UIView+PSImageEditors.h"

@implementation UIView (PSImageEditors)

- (UIImage *)captureImageAtFrame:(CGRect)rect
{
    
    UIImage* image = nil;
    
    if (/* DISABLES CODE */ (YES)) {
        CGSize size = self.bounds.size;
        CGPoint point = self.bounds.origin;
        if (!CGRectEqualToRect(CGRectZero, rect)) {
            size = rect.size;
            point = CGPointMake(-rect.origin.x, -rect.origin.y);
        }
        @autoreleasepool {
            UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
            [self drawViewHierarchyInRect:(CGRect){point, self.bounds.size} afterScreenUpdates:YES];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        
    } else {
        
            BOOL translateCTM = !CGRectEqualToRect(CGRectZero, rect);
        
            if (!translateCTM) {
                rect = self.frame;
            }
        
            /** 参数取整，否则可能会出现1像素偏差 */
            /** 有小数部分才调整差值 */
#define lfme_fixDecimal(d) ((fmod(d, (int)d)) > 0.59f ? ((int)(d+0.5)*1.f) : (((fmod(d, (int)d)) < 0.59f && (fmod(d, (int)d)) > 0.1f) ? ((int)(d)*1.f+0.5f) : (int)(d)*1.f))
            rect.origin.x = lfme_fixDecimal(rect.origin.x);
            rect.origin.y = lfme_fixDecimal(rect.origin.y);
            rect.size.width = lfme_fixDecimal(rect.size.width);
            rect.size.height = lfme_fixDecimal(rect.size.height);
#undef lfme_fixDecimal
            CGSize size = rect.size;
        
        @autoreleasepool {
            //1.开启上下文
            UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
            
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            if (translateCTM) {
                /** 移动上下文 */
                CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
            }
            //2.绘制图层
            [self.layer renderInContext: context];
            
            //3.从上下文中获取新图片
            image = UIGraphicsGetImageFromCurrentImageContext();
            
            //4.关闭图形上下文
            UIGraphicsEndImageContext();
            
            //    if (translateCTM) {
            //        UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
            //        [image drawAtPoint:CGPointMake(-rect.origin.x, -rect.origin.y)];
            //        image = UIGraphicsGetImageFromCurrentImageContext();
            //        UIGraphicsEndImageContext();
            //    }
        }
        
    }
    
    
    return image;
}


@end
