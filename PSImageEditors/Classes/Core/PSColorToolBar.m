//
//  PSColorToolBar.m
//  PSImageEditors
//
//  Created by rsf on 2018/8/29.
//

#import "PSColorToolBar.h"
#import "PSColorFullButton.h"

#define kColorFullButtonSize CGSizeMake(30, 30)

@interface PSColorToolBar ()

@property (nonatomic, assign) PSColorToolBarType *type;

@property (nonatomic, strong) PSColorFullButton *redButton;
@property (nonatomic, strong) PSColorFullButton *blackButton;
@property (nonatomic, strong) PSColorFullButton *whiteButton;
@property (nonatomic, strong) PSColorFullButton *yellowButton;
@property (nonatomic, strong) PSColorFullButton *greenButton;
@property (nonatomic, strong) PSColorFullButton *lightBlueButton;
@property (nonatomic, strong) PSColorFullButton *blueButton;

@property (nonatomic, strong) UIView *colorFullButtonViews;
@property (nonatomic, strong) UIButton *revocationButton;
@property (nonatomic, strong) UIView *bottomLineView;

@end

@implementation PSColorToolBar

- (instancetype)initWithType:(PSColorToolBarType)type {
	
	if (self = [super init]) {
		
		_colorFullButtonViews = [[UIView alloc] init];
		[self addSubview:_colorFullButtonViews];
		
		[_colorFullButtonViews addSubview:self.redButton];
		[_colorFullButtonViews addSubview:self.blackButton];
		[_colorFullButtonViews addSubview:self.whiteButton];
		[_colorFullButtonViews addSubview:self.yellowButton];
		[_colorFullButtonViews addSubview:self.lightBlueButton];
		[_colorFullButtonViews addSubview:self.blueButton];
		
		_revocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_revocationButton setImage:[UIImage ps_imageNamed:@"btn_revocation_normal"]
						   forState:UIControlStateNormal];
		[_revocationButton setImage:[UIImage ps_imageNamed:@"btn_revocation_disabled"]
						   forState:UIControlStateDisabled];
		_revocationButton.enabled = NO;
		[self addSubview:_revocationButton];
		
		_bottomLineView = [[UIView alloc] init];
		_bottomLineView.backgroundColor = PSColorFromRGB(0x999999);
		[self addSubview:_bottomLineView];

		
		[_revocationButton mas_makeConstraints:^(MASConstraintMaker *make) {
			
			make.right.equalTo(@(-15));
			make.bottom.equalTo(@(-30));
		}];
		
		[_colorFullButtonViews mas_makeConstraints:^(MASConstraintMaker *make) {
			
			make.top.equalTo(self);
			make.left.equalTo(@15);
			make.height.equalTo(@(kColorFullButtonSize.height));
			make.right.equalTo(_revocationButton.mas_left).offset(-5);
			make.centerY.equalTo(_revocationButton);
		}];
		
		[_colorFullButtonViews.subviews mas_distributeViewsAlongAxis:MASAxisTypeHorizontal
												 withFixedItemLength:kColorFullButtonSize.width
														 leadSpacing:15
														 tailSpacing:15];
		
		[_colorFullButtonViews.subviews mas_makeConstraints:^(MASConstraintMaker *make) {
			make.centerY.equalTo(_colorFullButtonViews);
			make.height.equalTo(@(kColorFullButtonSize.height));
		}];
		
		[_bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
			
			make.left.equalTo(@15);
			make.right.equalTo(@(-15));
			make.bottom.equalTo(self);
			make.height.equalTo(@1);
		}];
	}
	return self;
}

- (void)setToolBarShow:(BOOL)show animation:(BOOL)animation {
	
	[UIView animateWithDuration:(animation ? 0.15:0) animations:^{
		self.alpha = (show ? 1.0f:0.0f);
	}];
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
}

- (PSColorFullButton *)blueButton {
	
	return LAZY_LOAD(_blueButton, ({
		
		_blueButton = [[PSColorFullButton alloc] initWithFrame:
					   CGRectMake(0, 0, kColorFullButtonSize.width, kColorFullButtonSize.height)];
		_blueButton.radius = 9;
		_blueButton.color = PSColorFromRGB(0x8c06ff);
		[_blueButton addTarget:self action:@selector(colorFullButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
		_blueButton;
	}));
}

- (PSColorFullButton *)lightBlueButton {
	
	return LAZY_LOAD(_lightBlueButton, ({
		
		_lightBlueButton = [[PSColorFullButton alloc] initWithFrame:
							CGRectMake(0, 0, kColorFullButtonSize.width, kColorFullButtonSize.height)];
		_lightBlueButton.radius = 9;
		_lightBlueButton.color = PSColorFromRGB(0x199bff);
		[_lightBlueButton addTarget:self action:@selector(colorFullButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
		_lightBlueButton;
	}));
}

- (PSColorFullButton *)yellowButton {
	
	return LAZY_LOAD(_yellowButton, ({
		
		_yellowButton = [[PSColorFullButton alloc] initWithFrame:
						 CGRectMake(0, 0, kColorFullButtonSize.width, kColorFullButtonSize.height)];
		_yellowButton.radius = 9;
		_yellowButton.color = PSColorFromRGB(0x14e213);
		[_yellowButton addTarget:self action:@selector(colorFullButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
		_yellowButton;
	}));
}

- (PSColorFullButton *)whiteButton {
	
	return LAZY_LOAD(_whiteButton, ({
		
		_whiteButton = [[PSColorFullButton alloc] initWithFrame:
						CGRectMake(0, 0, kColorFullButtonSize.width, kColorFullButtonSize.height)];
		_whiteButton.radius = 9;
		_whiteButton.color = PSColorFromRGB(0xf9f9f9);
		[_whiteButton addTarget:self action:@selector(colorFullButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
		_whiteButton;
	}));
}

- (PSColorFullButton *)blackButton {
	
	return LAZY_LOAD(_blackButton, ({
		
		_blackButton = [[PSColorFullButton alloc] initWithFrame:
						CGRectMake(0, 0, kColorFullButtonSize.width, kColorFullButtonSize.height)];
		_blackButton.radius = 9;
		_blackButton.color = PSColorFromRGB(0x26252a);
		[_blackButton addTarget:self action:@selector(colorFullButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
		_blackButton;
	}));
}

- (PSColorFullButton *)redButton {
	
	return LAZY_LOAD(_redButton, ({
		
		_redButton = [[PSColorFullButton alloc] initWithFrame:
					  CGRectMake(0, 0, kColorFullButtonSize.width, kColorFullButtonSize.height)];
		_redButton.radius = 9;
		_redButton.color = PSColorFromRGB(0xff1d12);
		[_redButton addTarget:self action:@selector(colorFullButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
		_redButton;
	}));
}

@end
