//
//  PSEditorToolBar.h
//  PSImageEditors
//
//  Created by rsf on 2018/11/16.
//

#import <UIKit/UIKit.h>

static const CGFloat kEditorToolBarAnimationDuration = 0.25;

@interface PSEditorToolBar : UIView

@property (nonatomic, assign, getter=isWilShow) BOOL wilShow;
@property (nonatomic, assign, getter=isShow) BOOL show;

- (void)setToolBarShow:(BOOL)show animation:(BOOL)animation;

@end
