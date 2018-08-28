//
//  PSTopToolBar.m
//  PSImageEditors
//
//  Created by paintingStyle on 2018/8/25.
//

#import "PSTopToolBar.h"

#pragma mark - 色板

#define SPAP_COLOR_1  UIColorFromRGB(0x26242a)
#define SPAP_COLOR_2  UIColorFromRGB(0x666666)
#define SPAP_COLOR_3  UIColorFromRGB(0x999999)
#define SPAP_COLOR_4  UIColorFromRGB(0xbbbbbb)
#define SPAP_COLOR_5  UIColorFromRGB(0xcccccc)
#define SPAP_COLOR_6  UIColorFromRGB(0xe6e6e6)
#define SPAP_COLOR_7  UIColorFromRGB(0x4393f9)
#define SPAP_COLOR_8  UIColorFromRGBA(0x4393f9, 0.5)
#define SPAP_COLOR_9  UIColorFromRGB(0xf2f6f9)
#define SPAP_COLOR_10  UIColorFromRGB(0xffffff)
#define SPAP_COLOR_11  UIColorFromRGB(0x4ccfaf)
#define SPAP_COLOR_12  UIColorFromRGB(0xfe6972)
#define SPAP_COLOR_13  UIColorFromRGB(0xf5fafe)
#define SPAP_COLOR_14  UIColorFromRGB(0xfafafa)


#pragma mark - 字体

#define SPAP_FONT_SIZE_1  32
#define SPAP_FONT_SIZE_2  18
#define SPAP_FONT_SIZE_3  16
#define SPAP_FONT_SIZE_4  14
#define SPAP_FONT_SIZE_5  12
#define SPAP_FONT_SIZE_6  10
#define SPAP_FONT_SIZE_7  9

@interface PSTopToolBar()

@property (nonatomic, assign) PSTopToolType type;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *moreButton;

@end

@implementation PSTopToolBar

- (void)setTitle:(NSString *)title {
	
	_title = title;
	self.titleLabel.text = title;
}

- (instancetype)initWithType:(PSTopToolType)type {
    
    if (self = [super init]) {
		self.type = type;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6f];
        switch (type) {
            case PSTopToolTypeDefault:
                [self configDefaultUI];
                break;
            case PSTopToolTypePreview:
                [self configPreviewUI];
                break;
            case PSTopToolTypeCancelAndDoneText:
                [self configCancelAndDoneTextUI];
                break;
            case PSTopToolTypeCancelAndDoneIcon:
                [self configCancelAndDoneIconUI];
                break;
            default:
                break;
        }
    }
    return self;
}

- (void)buttonDidClickSender:(UIButton *)btn {
	
	PSTopToolEvent event;
	if (btn == self.backButton) {
		event = PSTopToolEventBack;
	}else if (btn == self.moreButton) {
		event = PSTopToolEventMore;
	}
	if (self.delegate && [self.delegate respondsToSelector:
						  @selector(topToolBarType:event:)]) {
		[self.delegate topToolBarType:self.type event:event];
	}
}

- (void)configDefaultUI {
    
    self.backButton = [[UIButton alloc] init];
    [self.backButton setFrame:CGRectMake(0, 0, 44, 44)];
    self.backButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.backButton setImage:[UIImage ps_imageNamed:@"btn_navBar_back"]
                     forState:UIControlStateNormal];
    [self.backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	[self.backButton addTarget:self action:@selector(buttonDidClickSender:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.backButton];
    
    self.moreButton = [[UIButton alloc] init];
    [self.moreButton setFrame:CGRectMake(0, 0, 44, 44)];
    self.moreButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.moreButton setImage:[UIImage ps_imageNamed:@"btn_previewView_more"]
                     forState:UIControlStateNormal];
    [self.moreButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
	[self.moreButton addTarget:self action:@selector(buttonDidClickSender:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.moreButton];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [self addSubview:self.titleLabel];
    
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(@44);
        make.left.equalTo(@15);
        make.centerY.equalTo(self).offset(PS_STATUS_BAR_H *0.5);
    }];
    
    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(@44);
        make.right.equalTo(@(-15));
        make.centerY.equalTo(self.backButton);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.backButton.mas_right).offset(15);
        make.right.equalTo(self.moreButton.mas_left).offset(-15);
        make.centerY.equalTo(self).offset(PS_STATUS_BAR_H *0.5);
    }];
   // DEBUG_VIEW(self);
}

- (void)setToolBarShow:(BOOL)show animation:(BOOL)animation {
	
	[UIView animateWithDuration:(animation ? 0.15:0) animations:^{
		if (show) {
			self.transform = CGAffineTransformIdentity;
		}else{
			self.transform = CGAffineTransformMakeTranslation(0, -PS_NAV_BAR_H);
		}
	}];
}

- (void)configPreviewUI {
    
    
}

- (void)configCancelAndDoneTextUI {
    
    
}

- (void)configCancelAndDoneIconUI {
    
    
}

@end


