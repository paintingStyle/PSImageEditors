//
//  PSTopToolBar.m
//  PSImageEditors
//
//  Created by rsf on 2018/11/16.
//

#import "PSTopToolBar.h"

@interface PSTopToolBar ()

@property (nonatomic, strong) UIImageView *maskImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *doneButton;

@end

@implementation PSTopToolBar

- (void)buttonDidClickSender:(UIButton *)btn {
	
	SEL sel = (btn == self.backButton ?
			   @selector(topToolBarBackItemDidClick):
			   @selector(topToolBarDoneItemDidClick));
	if (self.delegate && [self.delegate respondsToSelector:sel]) {
		[self.delegate performSelector:sel];
	}
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

- (instancetype)init {
	
	if (self = [super init]) {
		
		[self addSubview:self.maskImageView];
		[self.maskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(self);
		}];
		
		[self.backButton setTitle:@"取消" forState:UIControlStateNormal];
		[self.backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[self addSubview:self.backButton];
		
		[self.doneButton setTitle:@"完成" forState:UIControlStateNormal];
		[self.doneButton setTitleColor:PSColorFromRGB(0x4393f9) forState:UIControlStateNormal];
		[self addSubview:self.doneButton];
		
		[self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
			make.size.equalTo(@44);
			make.left.equalTo(@18);
			make.top.equalTo(@(PSTopToolBarHeight *0.4));
		}];
		[self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
			make.size.equalTo(@44);
			make.right.equalTo(@(-18));
			make.centerY.equalTo(self.backButton);
		}];
	}
	return self;
}

#pragma mark - Getter/Setter

- (UIImageView *)maskImageView {
	
	return LAZY_LOAD(_maskImageView, ({
		
		_maskImageView = [[UIImageView alloc] initWithImage:[UIImage ps_imageNamed:@"icon_mask_top"]];
		_maskImageView;
	}));
}

- (UIButton *)backButton {
	
	return LAZY_LOAD(_backButton, ({
		
		_backButton = [[UIButton alloc] init];
		[_backButton setFrame:CGRectMake(0, 0, 44, 44)];
		_backButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
		[_backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
		[_backButton addTarget:self action:@selector(buttonDidClickSender:) forControlEvents:UIControlEventTouchUpInside];
		_backButton;
	}));
}

- (UIButton *)doneButton {
	
	return LAZY_LOAD(_doneButton, ({
		
		_doneButton = [[UIButton alloc] init];
		[_doneButton setFrame:CGRectMake(0, 0, 44, 44)];
		_doneButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
		[_doneButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
		[_doneButton addTarget:self action:@selector(buttonDidClickSender:) forControlEvents:UIControlEventTouchUpInside];
		_doneButton;
	}));
}

@end
