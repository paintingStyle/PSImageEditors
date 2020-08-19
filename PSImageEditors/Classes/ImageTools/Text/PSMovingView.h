//
//  PSMovingView.h
//  PSImageEditors
//
//  Created by rsf on 2020/8/18.
//

#import <UIKit/UIKit.h>
#import "PSStickerItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSMovingView : UIView

/** active sticker view */
+ (void)setActiveEmoticonView:(PSMovingView * __nullable)view;

/** 初始化 */
- (instancetype)initWithItem:(PSStickerItem *)item;

/** 缩放率 0.2~3.0 */
- (void)setScale:(CGFloat)scale;
- (void)setScale:(CGFloat)scale rotation:(CGFloat)rotation;

/** 最小缩放率 默认0.2 */
@property (nonatomic, assign) CGFloat minScale;
/** 最大缩放率 默认3.0 */
@property (nonatomic, assign) CGFloat maxScale;

/** 显示界面的缩放率，例如在UIScrollView上显示，scrollView放大了5倍，movingView的视图控件会显得较大，这个属性是适配当前屏幕的比例调整控件大小 */
@property (nonatomic, assign) CGFloat screenScale;

/** Delayed deactivated time */
@property (nonatomic, assign) CGFloat deactivatedDelay;


@property (nonatomic, readonly) UIView *view;
@property (nonatomic, strong) 	PSStickerItem *item;
@property (nonatomic, readonly) CGFloat scale;
@property (nonatomic, readonly) CGFloat rotation;
@property (nonatomic, readonly) BOOL isActive;


@property (nonatomic, copy, nullable) void(^tapEnded)(PSMovingView *view);

@property (nonatomic, copy, nullable) void(^moveCenter)(UIGestureRecognizerState state);

@end

NS_ASSUME_NONNULL_END
