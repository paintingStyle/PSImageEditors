//
//  PSBrush+PSCreate.h
//  PSImageEditors
//
//  Created by rsf on 2020/8/24.
//

#import "PSBrush.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSBrush (PSCreate)

+ (UIBezierPath *)createBezierPathWithPoint:(CGPoint)point;

+ (CAShapeLayer *)createShapeLayerWithPath:(UIBezierPath *)path lineWidth:(CGFloat)lineWidth strokeColor:(UIColor *)strokeColor;

@end

@interface UIImage (PSBlurryBrush)

/**
 创建图案
 */
- (UIImage *)patternGaussianImageWithSize:(CGSize)size filterHandler:(CIFilter *(^ _Nullable )(CIImage *ciimage))filterHandler;
/**
 创建图案颜色
 */
- (UIColor *)patternGaussianColorWithSize:(CGSize)size filterHandler:(CIFilter *(^ _Nullable )(CIImage *ciimage))filterHandler;

@end

NS_ASSUME_NONNULL_END
