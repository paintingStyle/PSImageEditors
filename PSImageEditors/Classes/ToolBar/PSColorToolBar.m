//
//  PSColorToolBar.m
//  PSImageEditors
//
//  Created by rsf on 2018/11/16.
//

#import "PSColorToolBar.h"
#import "PSColorFullButton.h"
#import "PSExpandClickAreaButton.h"

static const CGFloat kItemLength = 44;
static const CGFloat kItemRadius= 9;

@interface PSColorToolBar ()

@property (nonatomic, strong) PSColorFullButton *redButton;
@property (nonatomic, strong) PSColorFullButton *blackButton;
@property (nonatomic, strong) PSColorFullButton *whiteButton;
@property (nonatomic, strong) PSColorFullButton *yellowButton;
@property (nonatomic, strong) PSColorFullButton *greenButton;
@property (nonatomic, strong) PSColorFullButton *lightBlueButton;
@property (nonatomic, strong) PSColorFullButton *blueButton;

@property (nonatomic, strong) UIView *colorFullButtonViews;
@property (nonatomic, strong) UIButton *undoButton;
@property (nonatomic, strong) UIView *bottomLineView;

@property (nonatomic, strong) UIButton *changeBgColorButton;

@end

@implementation PSColorToolBar

- (instancetype)initWithType:(PSColorToolBarType)type {
	
    if (self = [super init]) {
        switch (type) {
            case PSColorToolBarTypeColor:
                [self configDrawUI];
                break;
            case PSColorToolBarTypeText:
                [self configTextUI];
                break;
        }
    }
    return self;
}

- (void)configDrawUI {
	
	_colorFullButtonViews = [[UIView alloc] init];
	[self addSubview:_colorFullButtonViews];
	
	[_colorFullButtonViews addSubview:self.redButton];
	[_colorFullButtonViews addSubview:self.blackButton];
	[_colorFullButtonViews addSubview:self.whiteButton];
	[_colorFullButtonViews addSubview:self.yellowButton];
	[_colorFullButtonViews addSubview:self.greenButton];
	[_colorFullButtonViews addSubview:self.lightBlueButton];
	[_colorFullButtonViews addSubview:self.blueButton];
	// 使用手势识别，关闭自带交互
	for (PSColorFullButton *button in _colorFullButtonViews.subviews) {
		button.userInteractionEnabled = NO;
	}
	
	_bottomLineView = [[UIView alloc] init];
	_bottomLineView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
	[self addSubview:_bottomLineView];

	[_colorFullButtonViews.subviews mas_distributeViewsAlongAxis:MASAxisTypeHorizontal
											 withFixedItemLength:kItemLength
													 leadSpacing:0
													 tailSpacing:0];
	[_colorFullButtonViews mas_makeConstraints:^(MASConstraintMaker *make) {
		CGFloat s = 20 * [UIScreen mainScreen].scale;
		make.left.equalTo(@(s));
		make.right.equalTo(@(-s));
		make.bottom.equalTo(@(-30));
	}];
	
	[_colorFullButtonViews.subviews mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(_colorFullButtonViews);
		make.height.equalTo(@(kItemLength));
	}];
	
	[_bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
		
		make.left.equalTo(@15);
		make.right.equalTo(@(-15));
		make.bottom.equalTo(self);
		make.height.equalTo(@0.5);
	}];

	// 设置默认选中颜色
	self.redButton.isUse = YES;
	self.currentColor = self.redButton.color;
}

- (void)configTextUI {
	
	_changeBgColorButton = [PSExpandClickAreaButton buttonWithType:UIButtonTypeCustom];
	[_changeBgColorButton setImage:[UIImage ps_imageNamed:@"btn_changeTextBgColor_normal"]
						  forState:UIControlStateNormal];
	[_changeBgColorButton setImage:[UIImage ps_imageNamed:@"btn_changeTextBgColor_selected"]
						  forState:UIControlStateSelected];
	[_changeBgColorButton addTarget:self action:@selector(changeBgColorButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_changeBgColorButton];
	
	_colorFullButtonViews = [[UIView alloc] init];
	[self addSubview:_colorFullButtonViews];
	
	[_colorFullButtonViews addSubview:self.whiteButton];
	[_colorFullButtonViews addSubview:self.blackButton];
	[_colorFullButtonViews addSubview:self.redButton];
	[_colorFullButtonViews addSubview:self.yellowButton];
	[_colorFullButtonViews addSubview:self.greenButton];
	[_colorFullButtonViews addSubview:self.lightBlueButton];
	[_colorFullButtonViews addSubview:self.blueButton];
	// 使用手势识别，关闭自带交互
	for (PSColorFullButton *button in _colorFullButtonViews.subviews) {
		button.userInteractionEnabled = NO;
	}
	
	[_changeBgColorButton mas_makeConstraints:^(MASConstraintMaker *make) {
		
		make.centerY.equalTo(self);
		make.left.equalTo(@17);
		make.width.equalTo(@(kItemLength+12)); // 与选中按钮大小一致
		make.height.equalTo(@(kItemLength+12));
	}];
	
	[_colorFullButtonViews mas_makeConstraints:^(MASConstraintMaker *make) {
		
		make.centerY.equalTo(self);
		make.left.equalTo(_changeBgColorButton.mas_right).offset(25);
		make.height.equalTo(@(kItemLength));
		make.right.equalTo(@(-17));
	}];
	
	[_colorFullButtonViews.subviews mas_distributeViewsAlongAxis:MASAxisTypeHorizontal
											 withFixedItemLength:kItemLength
													 leadSpacing:0
													 tailSpacing:0];
	
	[_colorFullButtonViews.subviews mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(_colorFullButtonViews);
		make.height.equalTo(@(kItemLength));
	}];
	
	// 设置默认选中颜色
	self.whiteButton.isUse = YES;
	self.currentColor = self.whiteButton.color;
}

- (BOOL)isWhiteColor {
	
	return CGColorEqualToColor(self.currentColor.CGColor,
							   self.whiteButton.color.CGColor);
}

- (void)setCurrentColor:(UIColor *)currentColor {
	
	_currentColor = currentColor;
	for (PSColorFullButton *button in self.colorFullButtonViews.subviews) {
		button.isUse = CGColorEqualToColor(button.color.CGColor, currentColor.CGColor);
	}
}

- (void)changeBgColorButtonDidClick {
	
	self.changeBgColorButton.selected = !self.changeBgColorButton.selected;
	self.changeBgColor = self.changeBgColorButton.isSelected;
	
	if (self.delegate && [self.delegate respondsToSelector:
						  @selector(colorToolBar:event:)]) {
		[self.delegate colorToolBar:self event:PSColorToolBarEventChangeBgColor];
	}
}

- (void)colorFullButtonDidClick:(PSColorFullButton *)sender {
	
	for (PSColorFullButton *button in self.colorFullButtonViews.subviews) {
		if (button == sender) {
			button.isUse = YES;
			self.currentColor = sender.color;
		} else {
			button.isUse = NO;
		}
	}
	
	if (self.delegate && [self.delegate respondsToSelector:
						  @selector(colorToolBar:event:)]) {
		[self.delegate colorToolBar:self event:PSColorToolBarEventSelectColor];
	}
}

#pragma mark - 手动手势识别，兼容滑动选择

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [touch locationInView:self];
	for (PSColorFullButton *button in self.colorFullButtonViews.subviews) {
		CGRect rect = [button convertRect:button.bounds toView:self];
		if (CGRectContainsPoint(rect, touchPoint) && button.isUse == NO) {
			[self colorFullButtonDidClick:button];
		}
	}
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [touch locationInView:self];
	for (PSColorFullButton *button in self.colorFullButtonViews.subviews) {
		CGRect rect = [button convertRect:button.bounds toView:self];
		if (CGRectContainsPoint(rect, touchPoint) && button.isUse == NO) {
			[self colorFullButtonDidClick:button];
		}
	}
}

#pragma mark - Getter/Setter

- (PSColorFullButton *)blueButton {
	
	return LAZY_LOAD(_blueButton, ({
		
		_blueButton = [[PSColorFullButton alloc] initWithFrame:CGRectMake(0, 0, kItemLength, kItemLength) radius:kItemRadius color:PSColorFromRGB(0x8c06ff)];
		_blueButton;
	}));
}

- (PSColorFullButton *)lightBlueButton {
	
	return LAZY_LOAD(_lightBlueButton, ({
		
		_lightBlueButton = [[PSColorFullButton alloc] initWithFrame:CGRectMake(0, 0, kItemLength, kItemLength) radius:kItemRadius color:PSColorFromRGB(0x199bff)];
		_lightBlueButton;
	}));
}

- (PSColorFullButton *)greenButton {
	
	return LAZY_LOAD(_greenButton, ({
		
		_greenButton = [[PSColorFullButton alloc] initWithFrame:CGRectMake(0, 0, kItemLength, kItemLength) radius:kItemRadius color:PSColorFromRGB(0x14e213)];
		_greenButton;
	}));
}

- (PSColorFullButton *)yellowButton {
	
	return LAZY_LOAD(_yellowButton, ({
		
		_yellowButton = [[PSColorFullButton alloc] initWithFrame:CGRectMake(0, 0, kItemLength, kItemLength) radius:kItemRadius color:PSColorFromRGB(0xfbf60f)];
		_yellowButton;
	}));
}

- (PSColorFullButton *)whiteButton {
	
	return LAZY_LOAD(_whiteButton, ({
		
		_whiteButton = [[PSColorFullButton alloc] initWithFrame:CGRectMake(0, 0, kItemLength, kItemLength) radius:kItemRadius color:PSColorFromRGB(0xf9f9f9)];
		_whiteButton;
	}));
}

- (PSColorFullButton *)blackButton {
	
	return LAZY_LOAD(_blackButton, ({
		
		_blackButton = [[PSColorFullButton alloc] initWithFrame:CGRectMake(0, 0, kItemLength, kItemLength) radius:kItemRadius color:PSColorFromRGB(0x26252a)];
		_blackButton;
	}));
}

- (PSColorFullButton *)redButton {
	
	return LAZY_LOAD(_redButton, ({
		
		_redButton = [[PSColorFullButton alloc] initWithFrame:CGRectMake(0, 0, kItemLength, kItemLength) radius:kItemRadius color:PSColorFromRGB(0xff1d12)];
		_redButton;
	}));
}

@end
