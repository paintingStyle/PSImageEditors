//
//  PSEditorToolBar.m
//  PSImageEditors
//
//  Created by rsf on 2018/11/16.
//

#import "PSEditorToolBar.h"

@interface PSEditorToolBar ()

@end

@implementation PSEditorToolBar

- (void)setToolBarShow:(BOOL)show animation:(BOOL)animation {
	
    self.wilShow = show;
    [UIView animateWithDuration:(animation ? kEditorToolBarAnimationDuration:0)
                     animations:^{
        if (show) {
			self.alpha = 1.0;
        }else{
            self.alpha = 0.0;
        }
	} completion:^(BOOL finished) {
		self.show = show;
	}];
}

@end




