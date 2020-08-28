//
//  PSDrawTool.h
//  PSImageEditors
//
//  Created by rsf on 2018/11/16.
//

#import "PSImageToolBase.h"

@interface PSDrawTool : PSImageToolBase {
    @public UIImageView *_drawingView;
}

//@property (nonatomic, copy) void (^canUndoBlock) (BOOL canUndo);

- (BOOL)canUndo;
- (void)undo;

@end

@interface PSDrawPath : UIBezierPath

@property (nonatomic, strong) CAShapeLayer *shape;

/// 画笔颜色
@property (nonatomic, strong) UIColor *pathColor;

+ (instancetype)pathToPoint:(CGPoint)beginPoint
				  pathWidth:(CGFloat)pathWidth;

/// 画
- (void)pathLineToPoint:(CGPoint)movePoint;
/// 绘制
- (void)drawPath;

@end
