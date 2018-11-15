//
//  PSImageEditorTopBar.m
//  PSImageEditors
//
//  Created by rsf on 2018/11/14.
//  Copyright © 2018年 paintingStyle. All rights reserved.
//

#import "PSImageEditorTopBar.h"

@interface PSImageEditorTopBar ()

@property (nonatomic, strong) UIImageView *maskImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;

@end

@implementation PSImageEditorTopBar

- (instancetype)init {
	
	if (self = [super init]) {
		
		[self addSubview:self.maskImageView];
		[self.maskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(self);
		}];
		
		[self.leftButton setTitle:@"取消" forState:UIControlStateNormal];
		[self.leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[self addSubview:self.leftButton];
		
		[self.rightButton setTitle:@"完成" forState:UIControlStateNormal];
		[self.rightButton setTitleColor:PSColorFromRGB(0x4393f9) forState:UIControlStateNormal];
		[self addSubview:self.rightButton];
		
		[self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
			make.size.equalTo(@44);
			make.left.equalTo(@15);
			make.top.equalTo(@(PSImageEditorTopBarHeight *0.5));
		}];
		[self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
			make.size.equalTo(@44);
			make.right.equalTo(@(-15));
			make.centerY.equalTo(self.leftButton);
		}];
	}
	return self;
}

- (void)setTabBarShow:(BOOL)show animation:(BOOL)animation {
	
	[UIView animateWithDuration:(animation ? 0.15:0) animations:^{
		if (show) {
			self.transform = CGAffineTransformIdentity;
		}else{
			self.transform = CGAffineTransformMakeTranslation(0, -PS_NAV_BAR_H);
		}
	} completion:^(BOOL finished) {
		//self.show = show;
	}];
}

#pragma mark - Getter/Setter

- (UIImageView *)maskImageView {
	
	return LAZY_LOAD(_maskImageView, ({
		
		_maskImageView = [[UIImageView alloc] initWithImage:[UIImage ps_imageNamed:@"icon_mask_top"]];
		_maskImageView;
	}));
}

- (UIButton *)leftButton {
	
	return LAZY_LOAD(_leftButton, ({
		
		_leftButton = [[UIButton alloc] init];
		[_leftButton setFrame:CGRectMake(0, 0, 44, 44)];
		_leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
		[_leftButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
		[_leftButton addTarget:self action:@selector(buttonDidClickSender:) forControlEvents:UIControlEventTouchUpInside];
		_leftButton;
	}));
}

- (UIButton *)rightButton {
	
	return LAZY_LOAD(_rightButton, ({
		
		_rightButton = [[UIButton alloc] init];
		[_rightButton setFrame:CGRectMake(0, 0, 44, 44)];
		_rightButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
		[_rightButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
		[_rightButton addTarget:self action:@selector(buttonDidClickSender:) forControlEvents:UIControlEventTouchUpInside];
		_rightButton;
	}));
}

@end
