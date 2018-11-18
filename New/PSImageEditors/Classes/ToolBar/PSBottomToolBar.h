//
//  PSBottomToolBar.h
//  PSImageEditors
//
//  Created by paintingStyle on 2018/11/17.
//

#import "PSEditorToolBar.h"
@class PSBottomToolBar;

typedef NS_ENUM(NSUInteger, PSBottomToolType) {
    
    PSBottomToolTypeEditor =0,    /**< 编辑样式  */
    PSBottomToolTypeDelete,   /**< 拖动删除标样式  */
};

typedef NS_ENUM(NSUInteger, PSBottomToolDeleteState) {
    
    PSBottomToolDeleteStateNormal = 0,/**< 默认样式，显示删除按钮  */
    PSBottomToolDeleteStateWill,     /**< 拖拽到删除区域，将要删除  */
    PSBottomToolDeleteStateDid,     /**< 拖拽到删除区域释放，删除 */
};

@protocol PSBottomToolBarDelegate<NSObject>

- (void)bottomToolBar:(PSBottomToolBar *)toolBar
 didClickAtEditorMode:(PSImageEditorMode)mode;

@end

@interface PSBottomToolBar : PSEditorToolBar

@property (nonatomic, assign, getter=isEditor) BOOL editor;

@property (nonatomic, assign, getter=isShow) BOOL show;

/// PSBottomToolTypeDelete模式下删除的样式
@property (nonatomic, assign) PSBottomToolDeleteState deleteState;

@property (nonatomic, weak) id<PSBottomToolBarDelegate> delegate;

- (instancetype)initWithType:(PSBottomToolType)type;
- (void)reset;

@end
