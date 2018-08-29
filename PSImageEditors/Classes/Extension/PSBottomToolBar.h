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

@protocol PSBottomToolBarDelegate<NSObject>

@optional

- (void)bottomToolBarType:(PSBottomToolType)type event:(PSBottomToolEvent)event;

@end

@interface PSBottomToolBar : UIView

@property (nonatomic, weak) id<PSBottomToolBarDelegate> delegate;

@property (nonatomic, strong) PSImageObject *imageObject;

/// 是否处于编辑模式
@property (nonatomic, assign, getter=isEditor) BOOL editor;

- (instancetype)initWithType:(PSBottomToolType)type;

- (void)setToolBarShow:(BOOL)show animation:(BOOL)animation;

@end
