//
//  PSBootomToolBar.h
//  PSImageEditors
//
//  Created by rsf on 2018/11/16.
//

#import "PSEditorToolBar.h"
@class PSBootomToolBar;

@protocol PSBottomToolBarDelegate<NSObject>

- (void)bottomToolBar:(PSBootomToolBar *)toolBar
    didClickAtEditorMode:(PSImageEditorMode)mode;

@end

@interface PSBootomToolBar : PSEditorToolBar

@property (nonatomic, assign, getter=isEditor) BOOL editor;

@property (nonatomic, weak) id<PSBottomToolBarDelegate> delegate;

@end
