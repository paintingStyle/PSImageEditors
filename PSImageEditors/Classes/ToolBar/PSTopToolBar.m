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

- (instancetype)initWithType:(PSTopToolBarType)type {
    
    if (self = [super init]) {
        _type = type;
        switch (type) {
            case PSTopToolBarTypeClose:
                [self configCloseUI];
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

- (void)configCloseUI {
	
	[self.backButton setBackgroundImage:[UIImage ps_imageNamed:@"btn_close"]  forState:UIControlStateNormal];
	[self addSubview:self.backButton];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@40);
        make.left.equalTo(@18);
		make.top.equalTo(@(18+PS_SAFEAREA_TOP_DISTANCE));
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
