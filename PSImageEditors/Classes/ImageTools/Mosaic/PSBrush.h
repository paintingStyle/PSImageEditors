//
//  PSBrush.h
//  PSImageEditors
//
//  Created by rsf on 2020/8/24.
//

#import <Foundation/Foundation.h>
#import "CALayer+PSBrush.h"

NS_ASSUME_NONNULL_BEGIN

OBJC_EXTERN NSString *const PSBrushClassName;
OBJC_EXTERN NSString *const PSBrushAllPoints;
OBJC_EXTERN NSString *const PSBrushLineWidth;
OBJC_EXTERN NSString *const PSBrushBundle;

// 为CGPoint{inf, inf}
OBJC_EXTERN const CGPoint PSBrushPointNull;
// 点是否为CGPoint{inf, inf}
OBJC_EXTERN bool PSBrushPointIsNull(CGPoint point);
// 2点的中点
OBJC_EXTERN CGPoint PSBrushMidPoint(CGPoint p0, CGPoint p1);
// 2点的距离
OBJC_EXTERN CGFloat PSBrushDistancePoint(CGPoint p0, CGPoint p1);
// 2点的角度
OBJC_EXTERN CGFloat PSBrushAngleBetweenPoint(CGPoint p0, CGPoint p1);

@interface PSBrush : NSObject

/** 线粗 默认5 */
@property (nonatomic, assign) CGFloat lineWidth;
/** 绘画图层的层级 默认0, 层级越大, 图层越低 */
@property (nonatomic, assign) NSInteger level;

/**
 1、创建点与画笔结合的绘画层(意味着重新绘画，重置轨迹数据)；应在手势开始时调用，例如：touchesBegan，若需要忽略轨迹坐标，入参修改为CGPoint{inf, inf}
 */
- (CALayer * __nullable)createDrawLayerWithPoint:(CGPoint)point;
/**
 2、结合手势的坐标（手势移动时产生的坐标）；应在手势移动时调用，例如：touchesMoved
 */
- (void)addPoint:(CGPoint)point;

/**
 当前点。如果没值，回调CGPoint{inf, inf}
 */
@property (nonatomic, readonly) CGPoint currentPoint;
/**
 上一个点。如果没值，回调CGPoint{inf, inf}
 */
@property (nonatomic, readonly) CGPoint previousPoint;

/**
 所有轨迹数据；应在手势结束时调用，例如：touchesEnded、touchesCancelled
 */
@property (nonatomic, readonly, nullable) NSDictionary *allTracks;

/**
 使用轨迹数据恢复绘画层，持有所有轨迹数据，轻松实现undo、redo操作。
 */
+ (CALayer *__nullable)drawLayerWithTrackDict:(NSDictionary *)trackDict;

@end

@interface PSBrush (NSBundle)

/** NSBundle 资源 */
@property (nonatomic, strong) NSBundle *bundle;

@end

NS_ASSUME_NONNULL_END
