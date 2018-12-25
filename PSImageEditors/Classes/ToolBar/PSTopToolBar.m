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
	
    
    PSTopToolBarEvent event = (btn == self.backButton ? PSTopToolBarEventCancel:PSTopToolBarEventDone);
    if (self.delegate && [self.delegate respondsToSelector:@selector(topToolBar:event:)]) {
        [self.delegate topToolBar:self event:event];
    }
}

- (void)setToolBarShow:(BOOL)show animation:(BOOL)animation {

    [UIView animateWithDuration:(animation ? kEditorToolBarAnimationDuration:0)
                     animations:^{
        if (show) {
            self.transform = CGAffineTransformIdentity;
        }else{
            self.transform = CGAffineTransformMakeTranslation(0, -PSTopToolBarHeight);
        }
	 } completion:^(BOOL finished) {
		 self.show = show;
	 }];
}

- (instancetype)initWithType:(PSTopToolBarType)type {
    
    if (self = [super init]) {
        _type = type;
        switch (type) {
            case PSTopToolBarTypeCancelAndDoneText:
                [self configCancelAndDoneTextUI];
                break;
            case PSTopToolBarTypeCancelAndDoneIcon:
                [self configCancelAndDoneIconUI];
                break;
            default:
                break;
        }
    }
    return self;
}

- (void)configCancelAndDoneTextUI {
	
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
		if (@available(iOS 11.0, *)) {
			make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(20);
		} else {
			make.top.equalTo(@20);
		}
    }];
    [self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@44);
        make.right.equalTo(@(-18));
        make.centerY.equalTo(self.backButton);
    }];
}

- (void)configCancelAndDoneIconUI {
    
    
    [self.backButton setImage:[UIImage ps_imageNamed:@"btn_cancel"]
                     forState:UIControlStateNormal];
    [self addSubview:self.backButton];
    
    [self.doneButton setImage:[UIImage ps_imageNamed:@"btn_done"]
                      forState:UIControlStateNormal];
    [self addSubview:self.doneButton];
    
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(@44);
        make.left.equalTo(@15);
        make.centerY.equalTo(self);
    }];
    
    [self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(@44);
        make.right.equalTo(@(-15));
        make.centerY.equalTo(self.backButton);
    }];
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
