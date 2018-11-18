//
//  PSEditorToolBar.h
//  PSImageEditors
//
//  Created by rsf on 2018/11/16.
//

#import <UIKit/UIKit.h>

static const CGFloat kEditorToolBarAnimationDuration = 0.2;

@interface PSEditorToolBar : UIView

- (void)setToolBarShow:(BOOL)show animation:(BOOL)animation;

@end
