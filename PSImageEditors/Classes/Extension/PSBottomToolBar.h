//
//  PSBottomToolBar.h
//  PSImageEditors
//
//  Created by paintingStyle on 2018/8/25.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PSBottomToolType) {
    
    PSBottomToolTypeDefault = 0, /**< 原图样式  */
    PSBottomToolTypePreview,    /**< 相册图片预览样式  */
    PSBottomToolTypeEditor,    /**< 编辑样式  */
    PSBottomToolTypeDelete,   /**< 拖动删除标样式  */
    PSBottomToolTypeCut      /**< 裁剪样式  */
};

@interface PSBottomToolBar : UIView

- (instancetype)initWithType:(PSBottomToolType)type;

@end
