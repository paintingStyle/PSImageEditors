//
//  PSBrush+PSCreate.m
//  PSImageEditors
//
//  Created by rsf on 2020/8/24.
//

#import "PSBrush+PSCreate.h"

@implementation PSBrush (create)

#pragma mark - private
+ (UIBezierPath *)createBezierPathWithPoint:(CGPoint)point
{
    UIBezierPath *path = [UIBezierPath new];
    path.lineCapStyle = kCGLineCapRound; //线条拐角
    path.lineJoinStyle = kCGLineJoinRound; //终点处理
    [path moveToPoint:point];
    return path;
}

+ (CAShapeLayer *)createShapeLayerWithPath:(UIBezierPath *)path lineWidth:(CGFloat)lineWidth strokeColor:(UIColor *)strokeColor
{
    /**
     1、渲染快速。CAShapeLayer使用了硬件加速，绘制同一图形会比用Core Graphics快很多。
     2、高效使用内存。一个CAShapeLayer不需要像普通CALayer一样创建一个寄宿图形，所以无论有多大，都不会占用太多的内存。
     3、不会被图层边界剪裁掉。
     4、不会出现像素化。
     */
    CAShapeLayer *slayer = nil;
    if (path) {
        slayer = [CAShapeLayer layer];
        slayer.path = path.CGPath;
        slayer.backgroundColor = [UIColor clearColor].CGColor;
        slayer.fillColor = [UIColor clearColor].CGColor;
        slayer.lineCap = kCALineCapRound;
        slayer.lineJoin = kCALineJoinRound;
        slayer.strokeColor = strokeColor.CGColor;
        slayer.lineWidth = lineWidth;
    }
    
    return slayer;
}

@end

@interface PSBrush (CIContext)

@end

static CIContext *PSBrush_CIContext = nil;
@implementation PSBrush (CIContext)

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PSBrush_CIContext = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer: @(NO)}];
    });
}

@end

@implementation UIImage (PSBlurryBrush)

/**
 创建图案
 */
- (UIImage *)patternGaussianImageWithSize:(CGSize)size filterHandler:(CIFilter *(^ _Nullable )(CIImage *ciimage))filterHandler
{
    return [self patternGaussianImageWithSize:size orientation:0 filterHandler:filterHandler];
}
/**
 创建图案颜色
 */
- (UIColor *)patternGaussianColorWithSize:(CGSize)size filterHandler:(CIFilter *(^ _Nullable )(CIImage *ciimage))filterHandler
{
    //翻转图片（因为图片转换成图像颜色后在layer上使用，layer的画布是反转的，这里需要翻转方向。理应这里不应该调整方向，为了提高效率，这里的方法私有化，仅为PSBlurryBrush/PSMosaicBrush提供。）
    UIImage *image = [self patternGaussianImageWithSize:size orientation:kCGImagePropertyOrientationDownMirrored filterHandler:filterHandler];
    return [UIColor colorWithPatternImage:image];
}

- (UIImage *)patternGaussianImageWithSize:(CGSize)size orientation:(CGImagePropertyOrientation)orientation filterHandler:(CIFilter *(^ _Nullable )(CIImage *ciimage))filterHandler
{
    CIContext *context = PSBrush_CIContext;
	if (!context) {
		NSLog(@"This method must be called using the PSBrush class.");
	}
    CIImage *midImage = [CIImage imageWithCGImage:self.CGImage];
    midImage = [midImage imageByApplyingTransform:[self preferredTransform]];
    midImage = [midImage imageByApplyingTransform:CGAffineTransformMakeScale(size.width/midImage.extent.size.width, size.height/midImage.extent.size.height)];
    
    if (orientation > 0 && orientation < 9) {
        midImage = [midImage imageByApplyingOrientation:orientation];
    }
    //图片开始处理
    CIImage *result = midImage;
    if (filterHandler) {
        CIFilter *filter = filterHandler(midImage);
        if (filter) {
            result = filter.outputImage;
        }
    }
    
    CGImageRef outImage = [context createCGImage:result fromRect:[midImage extent]];
    UIImage *image = [UIImage imageWithCGImage:outImage];
    CGImageRelease(outImage);
    
    return image;
}

- (CGAffineTransform)preferredTransform {
    if (self.imageOrientation == UIImageOrientationUp) {
        return CGAffineTransformIdentity;
    }
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGSize imageSize = CGSizeMake(self.size.width*self.scale, self.size.height*self.scale);
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, imageSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, imageSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, imageSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, imageSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    return transform;
}

@end
