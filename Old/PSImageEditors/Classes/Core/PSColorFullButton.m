//
//  PSColorFullButton.m
//  PSImageEditors
//
//  Created by rsf on 2018/8/29.
//

#import "PSColorFullButton.h"

@interface PSColorFullButton () {
	UIColor *_color;
	CGFloat _radius;
}

@end

@implementation PSColorFullButton

- (void)setRadius:(CGFloat)radius {
	
	_radius = radius;
	[self drawCirle];
}

- (void)setColor:(UIColor *)color {
	
	_color = color;
	[self drawCirle];
}

- (void)setIsUse:(BOOL)isUse {
	
	_isUse = isUse;
	[self drawCirle];
}

- (void)drawCirle {
	
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
	
    // 保持同步，等待删除图层完毕添加图层
    dispatch_async(dispatch_get_main_queue(), ^{
        UIGraphicsBeginImageContext(self.bounds.size);
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.frame = self.bounds;
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width/2.f, self.bounds.size.height/2.f) radius:_isUse ? _radius+5: _radius startAngle:0 endAngle:2*M_PI clockwise:YES];
        layer.fillColor = _color.CGColor;
        layer.allowsEdgeAntialiasing = YES;
        layer.backgroundColor = [UIColor clearColor].CGColor;
        layer.strokeColor = [UIColor whiteColor].CGColor;
        layer.lineWidth = _isUse ? 2.f:1.0f;
        layer.path = path.CGPath;
        [path fill];
        UIGraphicsEndImageContext();
        [self.layer addSublayer:layer];
    });
}

@end
