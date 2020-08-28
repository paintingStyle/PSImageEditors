//
//  PSDrawView.h
//  PSImageEditors
//
//  Created by rsf on 2020/8/24.
//

#import <UIKit/UIKit.h>
#import "PSBrush.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSDrawView : UIView

/** 画笔 */
@property (nonatomic, strong) PSBrush *brush;
/** 正在绘画 */
@property (nonatomic, readonly) BOOL isDrawing;
/** 图层数量 */
@property (nonatomic, readonly) NSUInteger count;

@property (nonatomic, copy) void(^drawBegan)(void);
@property (nonatomic, copy) void(^drawEnded)(void);

/** 数据 */
@property (nonatomic, strong) NSDictionary *data;

/** 是否可撤销 */
- (BOOL)canUndo;
//撤销
- (void)undo;

- (void)removeAllObjects;

@end

NS_ASSUME_NONNULL_END
