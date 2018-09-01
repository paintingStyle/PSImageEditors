//
//  PSColorToolBar.h
//  PSImageEditors
//
//  Created by rsf on 2018/8/29.
//

#import <UIKit/UIKit.h>
#import "PSColorFullButton.h"
@class PSColorToolBar;

typedef NS_ENUM(NSInteger, PSColorToolBarType) {
	
	PSColorToolBarTypeColor =0,
	PSColorToolBarTypeText
};

typedef NS_ENUM(NSUInteger, PSColorToolBarEvent) {
	
	PSColorToolBarEventSelectColor = 0,
	PSColorToolBarEventRevocation,
	PSColorToolBarEventChangeBgColor
};

@protocol PSColorToolBarDelegate<NSObject>

@optional

- (void)colorToolBar:(PSColorToolBar *)toolBar event:(PSColorToolBarEvent)event;

@end

@interface PSColorToolBar : UIView

- (instancetype)initWithType:(PSColorToolBarType)type;

@property (nonatomic, weak) id<PSColorToolBarDelegate> delegate;

/// 当前颜色
@property (nonatomic, strong) UIColor *currentColor;

/// 是否可以撤销
@property (nonatomic, assign, getter=isRevocation) BOOL revocation;

/// 是否可以改变文字颜色
@property (nonatomic, assign, getter=isChangeBgColor) BOOL changeBgColor;

- (void)setToolBarShow:(BOOL)show animation:(BOOL)animation;

- (BOOL)isWhiteColor;

@end
