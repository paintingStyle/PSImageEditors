//
//  NSAttributedString+PSCoreText.m
//  PSImageEditors
//
//  Created by rsf on 2020/8/18.
//

#import "NSAttributedString+PSCoreText.h"
#import <CoreText/CoreText.h>


@implementation NSAttributedString (PSCoreText)

- (CGSize)sizeWithConstrainedToSize:(CGSize)size
{
    if (self.length == 0) return CGSizeZero;
    
    CFAttributedStringRef attributedString = (__bridge CFAttributedStringRef)self;
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CGSize result = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [self length]), NULL, size, NULL);
    CFRelease(framesetter);
	
    return CGSizeMake(ceilf(result.width), ceilf(result.height));
}

- (void)drawInContext:(CGContextRef)context withPosition:(CGPoint)p andHeight:(float)height andWidth:(float)width
{
    CGSize size = CGSizeMake(width, height);
    // 翻转坐标系
    CGContextSetTextMatrix(context,CGAffineTransformIdentity);
    CGContextTranslateCTM(context,0,height);
    CGContextScaleCTM(context,1.0,-1.0);
    
    // 创建绘制区域（路径）
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path,NULL,CGRectMake(p.x, height-p.y-size.height,(size.width),(size.height)));
    
    // 创建CFAttributedStringRef
    CFAttributedStringRef attributedString = (__bridge CFAttributedStringRef)self;
    
    // 绘制frame
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CTFrameRef ctframe = CTFramesetterCreateFrame(framesetter, CFRangeMake(0,0),path,NULL);
    CTFrameDraw(ctframe,context);
    CGPathRelease(path);
    CFRelease(framesetter);
    CFRelease(ctframe);
    
    CGContextSetTextMatrix(context,CGAffineTransformIdentity);
    CGContextTranslateCTM(context,0, height);
    CGContextScaleCTM(context,1.0,-1.0);
}

@end
