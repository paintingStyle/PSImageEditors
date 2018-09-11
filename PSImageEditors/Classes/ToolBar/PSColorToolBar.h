//
//  PSColorToolBar.h
//  PSImageEditors
//
//  Created by rsf on 2018/8/29.
//

#import "PSToolBar.h"
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
 
@interface PSColorToolBar : PSToolBar

- (instancetype)initWithType:(PSColorToolBarType)type;

@property (nonatomic, weak) id<PSColorToolBarDelegate> delegate;

/// 当前颜色
@property (nonatomic, strong) UIColor *currentColor;

/// 是否可以撤销
@property (nonatomic, assign) BOOL canUndo;

/// 是否可以改变文字颜色
@property (nonatomic, assign, getter=isChangeBgColor) BOOL changeBgColor;

- (BOOL)isWhiteColor;

@end
