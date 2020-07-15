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
	CAShapeLayer *_layer;
	CAShapeLayer *_layer2;
}

// 绘制需要获取到self.bounds
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, strong, readwrite) UIColor *color;

@end

@implementation PSColorFullButton

- (instancetype)initWithFrame:(CGRect)frame radius:(CGFloat)radius color:(UIColor *)color  {
	if (self = [super initWithFrame:frame]) {
		
		_radius = radius;
		_color = color;
		
		UIGraphicsBeginImageContext(self.bounds.size);
		CAShapeLayer *layer = [CAShapeLayer layer];
		layer.frame = self.bounds;
		UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width/2.f, self.bounds.size.height/2.f) radius:9 startAngle:0 endAngle:2*M_PI clockwise:YES];
		layer.fillColor = _color.CGColor;
		layer.allowsEdgeAntialiasing = YES;
		layer.backgroundColor = [UIColor clearColor].CGColor;
		layer.path = path.CGPath;
		[path fill];
		UIGraphicsEndImageContext();
		[self.layer addSublayer:layer];
		_layer = layer;
	}
	return self;
}


- (void)setIsUse:(BOOL)isUse {
	
	_isUse = isUse;
	[self drawCirle];
}

- (void)drawCirle {

	if (!_layer2 && self.isUse) {
		UIGraphicsBeginImageContext(self.bounds.size);
		CAShapeLayer *layer2 = [CAShapeLayer layer];
		layer2.frame = self.bounds;
		UIBezierPath *path2 = [UIBezierPath bezierPathWithArcCenter:CGPointMake((self.bounds.size.width/2.f), self.bounds.size.height/2.f) radius:_radius+8 startAngle:0 endAngle:2*M_PI clockwise:YES];
		layer2.fillColor = [UIColor clearColor].CGColor;
		layer2.allowsEdgeAntialiasing = YES;
		layer2.backgroundColor = [UIColor clearColor].CGColor;
		layer2.strokeColor = _color.CGColor;
		layer2.lineWidth = 4;
		layer2.path = path2.CGPath;
		[path2 stroke];
		UIGraphicsEndImageContext();
		[self.layer insertSublayer:layer2 below:_layer];
		_layer2 = layer2;
	}
	
	_layer2.hidden = !self.isUse;
}

@end
