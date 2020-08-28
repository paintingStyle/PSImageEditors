//
//  PSBrush.m
//  PSImageEditors
//
//  Created by rsf on 2020/8/24.
//

#import "PSBrush.h"

NSString *const PSBrushClassName = @"PSBrushClassName";
NSString *const PSBrushAllPoints = @"PSBrushAllPoints";
NSString *const PSBrushLineWidth = @"PSBrushLineWidth";
NSString *const PSBrushLevel = @"PSBrushLevel";
NSString *const PSBrushBundle = @"PSBrushBundle";

const CGPoint PSBrushPointNull = {INFINITY, INFINITY};

bool PSBrushPointIsNull(CGPoint point)
{
    return isinf(point.x) || isinf(point.y);
}

CGPoint PSBrushMidPoint(CGPoint p0, CGPoint p1) {
    if (PSBrushPointIsNull(p0) || PSBrushPointIsNull(p1)) {
        return CGPointZero;
    }
    return (CGPoint) {
        (p0.x + p1.x) / 2.0,
        (p0.y + p1.y) / 2.0
    };
}

CGFloat PSBrushDistancePoint(CGPoint p0, CGPoint p1) {
    if (PSBrushPointIsNull(p0) || PSBrushPointIsNull(p1)) {
        return 0;
    }
    return sqrt(pow(p0.x - p1.x, 2) + pow(p0.y - p1.y, 2));
}

CGFloat PSBrushAngleBetweenPoint(CGPoint p0, CGPoint p1) {
    
    if (PSBrushPointIsNull(p0) || PSBrushPointIsNull(p1)) {
        return 0;
    }
    
    CGPoint p = CGPointMake(p0.x, p0.y+100);
    
    CGFloat x1 = p.x - p0.x;
    CGFloat y1 = p.y - p0.y;
    CGFloat x2 = p1.x - p0.x;
    CGFloat y2 = p1.y - p0.y;
    
    CGFloat x = x1 * x2 + y1 * y2;
    CGFloat y = x1 * y2 - x2 * y1;
    
    CGFloat angle = acos(x/sqrt(x*x+y*y));
    
    if (p1.x < p0.x) {
        angle = M_PI*2 - angle;
    }
    
    return (180.0 * angle / M_PI);
}

@interface PSBrush ()

@property (nonatomic, strong) NSMutableArray <NSString /*CGPoint*/*>*allPoints;

/** NSBundle 资源 */
@property (nonatomic, strong) NSBundle *bundle;

@end

@implementation PSBrush

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lineWidth = 5.f;
        _level = 0;
    }
    return self;
}

- (void)addPoint:(CGPoint)point
{
    [self.allPoints addObject:NSStringFromCGPoint(point)];
}

- (CALayer *)createDrawLayerWithPoint:(CGPoint)point
{

	if (![self isMemberOfClass:[PSBrush class]]) {
		NSLog(@"Use subclasses of PSBrush.");
	}
	
    self.allPoints = [NSMutableArray array];
    if (PSBrushPointIsNull(point)) {
        return nil;
    }
    [self.allPoints addObject:NSStringFromCGPoint(point)];
    return nil;
}

- (CGPoint)currentPoint
{
    NSString *pointStr = self.allPoints.lastObject;
    if (pointStr) {
        return CGPointFromString(pointStr);
    }
    return PSBrushPointNull;
}

- (CGPoint)previousPoint
{
    if (self.allPoints.count > 1) {
        NSString *pointStr = [self.allPoints objectAtIndex:self.allPoints.count-2];
        return CGPointFromString(pointStr);
    }
    return PSBrushPointNull;
}

- (NSDictionary *)allTracks
{
    if (self.allPoints.count) {
        NSMutableDictionary *trackDict = [NSMutableDictionary dictionaryWithDictionary:@{
            PSBrushClassName:NSStringFromClass(self.class),
            PSBrushAllPoints:self.allPoints,
            PSBrushLineWidth:@(self.lineWidth),
            PSBrushLevel:@(self.level)
        }];
        if (self.bundle) {
            [trackDict setObject:self.bundle forKey:PSBrushBundle];
        }
        return trackDict;
    }
    return nil;
}

+ (CALayer *__nullable)drawLayerWithTrackDict:(NSDictionary *)trackDict
{
    NSString *className = trackDict[PSBrushClassName];
    NSInteger level = [trackDict[PSBrushLevel] integerValue];
    Class class = NSClassFromString(className);
    if (class && ![class isMemberOfClass:[self class]]) {
        CALayer *layer = [class drawLayerWithTrackDict:trackDict];
        layer.ps_level = level;
        return layer;
    }
    return nil;
}

@end
