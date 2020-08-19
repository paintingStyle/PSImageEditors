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

typedef NS_ENUM(NSInteger, PSBottomToolBarEvent) {
	
	PSBottomToolBarEventDraw = 0,
	PSBottomToolBarEventText,
	PSBottomToolBarEventMosaic,
	PSBottomToolBarEventClipping,
	PSBottomToolBarEventUndo,
	PSBottomToolBarEventDone,
};

@protocol PSBottomToolBarDelegate<NSObject>

- (void)bottomToolBar:(PSBottomToolBar *)toolBar
		didClickEvent:(PSBottomToolBarEvent)event;

@end

@interface PSBottomToolBar : PSEditorToolBar

@property (nonatomic, assign, getter=isEditor) BOOL editor;

/// 用于参照布局
@property (nonatomic, strong) UIView *editorItemsView;

/// 是否可以撤销
@property (nonatomic, assign) BOOL canUndo;

@property (nonatomic, weak) id<PSBottomToolBarDelegate> delegate;

- (instancetype)initWithType:(PSBottomToolType)type;

- (void)selectIndex:(NSInteger)index;
- (void)reset;

@end
