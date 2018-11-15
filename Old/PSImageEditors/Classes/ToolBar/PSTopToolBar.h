//
//  PSTopToolBar.h
//  PSImageEditors
//
//  Created by paintingStyle on 2018/8/25.
//

#import "PSToolBar.h"
@class PSImageObject;

typedef NS_ENUM(NSUInteger, PSTopToolType) {
    
    PSTopToolTypeDefault = 0,          /**< 导航栏样式  */
    PSTopToolTypePreview,             /**< 相册图片预览样式  */
    PSTopToolTypeCancelAndDoneText,  /**< 取消与完成文字样式  */
    PSTopToolTypeCancelAndDoneIcon, /**< 取消与完成图标样式  */
};

typedef NS_ENUM(NSUInteger, PSTopToolEvent) {
	
	PSTopToolEventBack = 0,
	PSTopToolEventMore,
	PSTopToolEventCancel,
	PSTopToolEventDone,
	
};

@protocol PSTopToolBarDelegate<NSObject>

@optional

- (void)topToolBarType:(PSTopToolType)type event:(PSTopToolEvent)event;

@end

@interface PSTopToolBar : PSToolBar

@property (nonatomic, weak) id<PSTopToolBarDelegate> delegate;

@property (nonatomic, assign, getter=isShow) BOOL show;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) PSImageObject *imageObject;

- (instancetype)initWithType:(PSTopToolType)type;

@end
