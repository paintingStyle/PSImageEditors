//
//  PSBottomToolBar.h
//  PSImageEditors
//
//  Created by paintingStyle on 2018/8/25.
//

#import <UIKit/UIKit.h>
@class PSImageObject;

typedef NS_ENUM(NSUInteger, PSBottomToolType) {
    
    PSBottomToolTypeDefault = 0, /**< 原图样式  */
    PSBottomToolTypePreview,    /**< 相册图片预览样式  */
    PSBottomToolTypeEditor,    /**< 编辑样式  */
    PSBottomToolTypeDelete,   /**< 拖动删除标样式  */
    PSBottomToolTypeClipping /**< 裁剪样式  */
};

typedef NS_ENUM(NSUInteger, PSBottomToolEvent) {
	
	PSBottomToolEventBrush = 0,
	PSBottomToolEventText,
	PSBottomToolEventMosaic,
	PSBottomToolEventClipping,
};

typedef NS_ENUM(NSUInteger, PSBottomToolDeleteState) {
    
    PSBottomToolDeleteStateNormal = 0,/**< 默认样式，显示删除按钮  */
    PSBottomToolDeleteStateWill,     /**< 拖拽到删除区域，将要删除  */
    PSBottomToolDeleteStateDid,     /**< 拖拽到删除区域释放，删除 */
};

@protocol PSBottomToolBarDelegate<NSObject>

@optional

- (void)bottomToolBarType:(PSBottomToolType)type event:(PSBottomToolEvent)event;

@end

@interface PSBottomToolBar : UIView

@property (nonatomic, weak) id<PSBottomToolBarDelegate> delegate;

@property (nonatomic, strong) PSImageObject *imageObject;

/// 是否处于编辑模式
@property (nonatomic, assign, getter=isEditor) BOOL editor;

/// PSBottomToolTypeDelete模式下删除的样式
@property (nonatomic, assign) PSBottomToolDeleteState deleteState;

- (instancetype)initWithType:(PSBottomToolType)type;

- (void)setToolBarShow:(BOOL)show animation:(BOOL)animation;

- (void)resetStateWithEvent:(PSBottomToolEvent)event;

@end
