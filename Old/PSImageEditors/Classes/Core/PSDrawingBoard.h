//
//  PSDrawingBoard.h
//  PSImageEditors
//
//  Created by rsf on 2018/8/29.
//

#import "PSBaseDrawingBoard.h"
@class PSDrawingPath;

@interface PSDrawingBoard : PSBaseDrawingBoard

@property (nonatomic, copy) void (^drawToolStatus)(BOOL canPrev);
@property (nonatomic, copy) void (^drawingCallback)(BOOL isDrawing);
@property (nonatomic, copy) void (^drawingDidTap)(void);

@property (nonatomic, strong, readonly) NSMutableArray<PSDrawingPath *> *drawingPaths;
@property (nonatomic, assign) CGFloat pathWidth;

/// 撤销
- (void)revocation;

@end

@interface PSDrawingPath : NSObject

@property (nonatomic, strong) CAShapeLayer *shape;

/// 画笔颜色
@property (nonatomic, strong) UIColor *pathColor;

+ (instancetype)pathToPoint:(CGPoint)beginPoint pathWidth:(CGFloat)pathWidth;

/// 画
- (void)pathLineToPoint:(CGPoint)movePoint;
/// 绘制
- (void)drawPath;

@end


