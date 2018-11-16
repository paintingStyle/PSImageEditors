//
//  PSTopToolBar.h
//  PSImageEditors
//
//  Created by rsf on 2018/11/16.
//

#import "PSEditorToolBar.h"

@protocol PSTopToolBarDelegate<NSObject>

- (void)topToolBarBackItemDidClick;
- (void)topToolBarDoneItemDidClick;

@end

@interface PSTopToolBar : PSEditorToolBar

@property (nonatomic, weak) id<PSTopToolBarDelegate> delegate;

@end
