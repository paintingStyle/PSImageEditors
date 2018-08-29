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

@protocol PSColorToolBarDelegate<NSObject>

@optional

/// 选中颜色
- (void)colorToolBarDidSelectColor:(UIColor *)color;

@end

@interface PSColorToolBar : UIView

- (instancetype)initWithType:(PSColorToolBarType)type;

@property (nonatomic, weak) id<PSColorToolBarDelegate> delegate;

@property (nonatomic, strong) UIColor *currentColor;

/// 是否可以撤销
@property (nonatomic, assign, getter=isRevocation) BOOL revocation;

- (void)setToolBarShow:(BOOL)show animation:(BOOL)animation;

@end
