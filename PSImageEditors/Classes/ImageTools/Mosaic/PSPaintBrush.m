//
//  PSPaintBrush.m
//  PSImageEditors
//
//  Created by rsf on 2020/8/24.
//

#import "PSPaintBrush.h"
#import "PSBrush+PSCreate.h"

NSString *const PSPaintBrushLineColor = @"PSPaintBrushLineColor";

@interface PSPaintBrush ()

@property (nonatomic, strong) UIBezierPath *path;

@property (nonatomic, weak) CAShapeLayer *layer;

@end

@implementation PSPaintBrush

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lineColor = [UIColor redColor];
    }
    return self;
}

- (void)addPoint:(CGPoint)point
{
    [super addPoint:point];
    if (self.path) {
        CGPoint midPoint = PSBrushMidPoint(self.previousPoint, point);
        // 使用二次曲线方程式
        [self.path addQuadCurveToPoint:midPoint controlPoint:self.previousPoint];
        self.layer.path = self.path.CGPath;
    }
}

- (CALayer *)createDrawLayerWithPoint:(CGPoint)point
{
    if (self.lineColor) {
        [super createDrawLayerWithPoint:point];
        /**
         首次创建UIBezierPath
         */
        self.path = [[self class] createBezierPathWithPoint:point];
        
        CAShapeLayer *layer = [[self class] createShapeLayerWithPath:self.path lineWidth:self.lineWidth strokeColor:self.lineColor];
        layer.ps_level = self.level;
        self.layer = layer;
        
        return layer;
    }
    return nil;
}
- (NSDictionary *)allTracks
{
    NSDictionary *superAllTracks = [super allTracks];
    
    NSMutableDictionary *myAllTracks = nil;
    if (superAllTracks && self.lineColor) {
        myAllTracks = [NSMutableDictionary dictionary];
        [myAllTracks addEntriesFromDictionary:superAllTracks];
        [myAllTracks addEntriesFromDictionary:@{PSPaintBrushLineColor:self.lineColor}];
    }
    return myAllTracks;
}

+ (CALayer *__nullable)drawLayerWithTrackDict:(NSDictionary *)trackDict
{
    CGFloat lineWidth = [trackDict[PSBrushLineWidth] floatValue];
    UIColor *lineColor = trackDict[PSPaintBrushLineColor];
    NSArray <NSString /*CGPoint*/*>*allPoints = trackDict[PSBrushAllPoints];
    
    if (allPoints) {
        CGPoint previousPoint = CGPointFromString(allPoints.firstObject);
        UIBezierPath *path = [[self class] createBezierPathWithPoint:previousPoint];
        
        for (NSInteger i=1; i<allPoints.count; i++) {
            
            CGPoint point = CGPointFromString(allPoints[i]);
            
            CGPoint midPoint = PSBrushMidPoint(previousPoint, point);
            // 使用二次曲线方程式
            [path addQuadCurveToPoint:midPoint controlPoint:previousPoint];
            previousPoint = point;
        }
        return [[self class] createShapeLayerWithPath:path lineWidth:lineWidth strokeColor:lineColor];
    }
    return nil;
}

@end
