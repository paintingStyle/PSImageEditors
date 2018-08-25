//
//  PSTopToolBar.h
//  PSImageEditors
//
//  Created by paintingStyle on 2018/8/25.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PSTopToolType) {
    
    PSTopToolTypeDefault = 0,          /**< 导航栏样式  */
    PSTopToolTypePreview,             /**< 相册图片预览样式  */
    PSTopToolTypeCancelAndDoneText,  /**< 取消与完成文字样式  */
    PSTopToolTypeCancelAndDoneIcon, /**< 取消与完成图标样式  */
};

@interface PSTopToolBar : UIView

- (instancetype)initWithType:(PSTopToolType)type;

@end
