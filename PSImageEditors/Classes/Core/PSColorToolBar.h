//
//  PSColorToolBar.h
//  PSImageEditors
//
//  Created by rsf on 2018/8/29.
//

#import <UIKit/UIKit.h>
#import "PSColorFullButton.h"

typedef NS_ENUM(NSInteger, PSColorToolBarType) {
	
	PSColorToolBarTypeColor =0,
	PSColorToolBarTypeText
};

@interface PSColorToolBar : UIView

- (instancetype)initWithType:(PSColorToolBarType)type;

@property (nonatomic, strong) UIColor *currentColor;

- (void)setToolBarShow:(BOOL)show animation:(BOOL)animation;

@end
