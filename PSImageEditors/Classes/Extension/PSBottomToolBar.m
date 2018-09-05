//
//  PSBottomToolBar.m
//  PSImageEditors
//
//  Created by paintingStyle on 2018/8/25.
//

#import "PSBottomToolBar.h"
#import "PSImageObject.h"

@interface PSBottomToolBar()

@property (nonatomic, assign) PSBottomToolType type;

// PSBottomToolTypeDefault
@property (nonatomic, strong) UILabel *titleLabel;

// PSBottomToolTypeEditor
@property (nonatomic, strong) UIImageView *maskImageView;
@property (nonatomic, strong) UIButton *brushButton;
@property (nonatomic, strong) UIButton *textButton;
@property (nonatomic, strong) UIButton *mosaicButton;
@property (nonatomic, strong) UIButton *clippingButton;

// PSBottomToolTypeDelete
@property (nonatomic, strong) UIView *deleteContainerView;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *deleteDescButton;

@end

@implementation PSBottomToolBar

- (void)setImageObject:(PSImageObject *)imageObject {
	
	_imageObject = imageObject;
	
	self.titleLabel.text = [NSString stringWithFormat:@"原图(%@)",
							imageObject.originSize];
	
	@weakify(self);
	_imageObject.fetchOriginSizeBlock = ^(NSString * _Nonnull originSize) {
		@strongify(self);
		self.titleLabel.text = [NSString stringWithFormat:@"原图(%@)",
								imageObject.originSize];
	};
}

- (void)setDeleteState:(PSBottomToolDeleteState)deleteState {
    
    _deleteState = deleteState;
    self.deleteDescButton.selected = (deleteState == PSBottomToolDeleteStateDid);
    self.deleteDescButton.selected = (deleteState == PSBottomToolDeleteStateDid);
}

- (instancetype)initWithType:(PSBottomToolType)type {
    
    if (self = [super init]) {
		self.type = type;
        switch (type) {
            case PSBottomToolTypeDefault:
                [self configDefaultUI];
                break;
            case PSBottomToolTypePreview:
                [self configPreviewUI];
                break;
            case PSBottomToolTypeEditor:
                [self configEditorUI];
                break;
            case PSBottomToolTypeDelete:
                [self configDeleteUI];
                break;
            case PSBottomToolTypeClipping:
                [self configClippingUI];
                break;
            default:
                break;
        }
    }
    return self;
}

- (void)setToolBarShow:(BOOL)show animation:(BOOL)animation {
	
	CGFloat offestY;
	if (self.type == PSBottomToolTypeDelete) {
		offestY = PSBottomToolDeleteBarHeight;
	}else {
		offestY = PSBottomToolBarHeight;
	}
	
	[UIView animateWithDuration:(animation ? 0.15:0) animations:^{
		if (show) {
			self.transform = CGAffineTransformIdentity;
		}else{
			self.transform = CGAffineTransformMakeTranslation(0, offestY);
		}
	} completion:^(BOOL finished) {
		self.show = show;
	}];
}

- (void)configDefaultUI {
	
	self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6f];
	[self addSubview:self.titleLabel];
	
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
		make.height.equalTo(@20);
		make.left.equalTo(@15);
		make.right.equalTo(@(-15));
    }];
}

- (void)configPreviewUI {
    
	self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6f];
}

- (void)configEditorUI {
    
    [self addSubview:self.maskImageView];
    [self.maskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
	
	[self addSubview:self.brushButton];
	[self addSubview:self.textButton];
	[self addSubview:self.mosaicButton];
	[self addSubview:self.clippingButton];
	
	NSMutableArray *editorItems = [NSMutableArray array];
	[editorItems addObject:self.brushButton];
	[editorItems addObject:self.textButton];
	[editorItems addObject:self.mosaicButton];
	[editorItems addObject:self.clippingButton];
	[editorItems mas_distributeViewsAlongAxis:MASAxisTypeHorizontal
						  withFixedItemLength:28
								  leadSpacing:48
								  tailSpacing:48];
	[editorItems mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(self);
		make.height.equalTo(@28);
	}];
}

- (void)configDeleteUI {
    
    [self addSubview:self.maskImageView];
    [self.maskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    self.deleteContainerView = [[UIView alloc] init];
    [self addSubview:self.deleteContainerView];
    
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.deleteButton setImage:[UIImage ps_imageNamed:@"btn_delete_normal"] forState:UIControlStateNormal];
    [self.deleteButton setImage:[UIImage ps_imageNamed:@"btn_delete_selected"] forState:UIControlStateSelected];
    [self.deleteContainerView addSubview:self.deleteButton];
    
    self.deleteDescButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.deleteDescButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.deleteDescButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.deleteDescButton setTitle:@"拖动到此处删除" forState:UIControlStateNormal];
    [self.deleteDescButton setTitle:@"松手即可删除" forState:UIControlStateSelected];
    [self.deleteContainerView addSubview:self.deleteDescButton];
    
    
    [self.deleteContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(self.deleteContainerView);
        make.centerX.equalTo(self.deleteContainerView);
    }];
    
    [self.deleteDescButton mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(self.deleteButton.mas_bottom).offset(6);
        make.centerX.equalTo(self.deleteButton);
    }];
}

- (void)configClippingUI {
    
    
}

- (void)buttonDidClickSender:(UIButton *)btn {
	
	PSBottomToolEvent event;
	if (btn == self.brushButton) {
		event = PSBottomToolEventBrush;
		self.brushButton.selected = !self.brushButton.selected;
		self.editor = self.brushButton.selected;
	}else if (btn == self.textButton) {
		event = PSBottomToolEventText;
		self.textButton.selected = !self.textButton.selected;
		self.editor = self.textButton.selected;
	}else if (btn == self.mosaicButton) {
		event = PSBottomToolEventMosaic;
		self.mosaicButton.selected = !self.mosaicButton.selected;
		self.editor = self.mosaicButton.selected;
	}else if (btn == self.clippingButton) {
		event = PSBottomToolEventClipping;
		self.clippingButton.selected = !self.clippingButton.selected;
		self.editor = self.clippingButton.selected;
	}
	
	if (self.delegate && [self.delegate respondsToSelector:
						  @selector(bottomToolBarType:event:)]) {
		[self.delegate bottomToolBarType:self.type event:event];
	}
}

- (void)resetStateWithEvent:(PSBottomToolEvent)event {
    
    switch (event) {
        case PSBottomToolEventBrush:
            self.brushButton.selected = NO;
            break;
        case PSBottomToolEventText:
            self.textButton.selected = NO;
            break;
        case PSBottomToolEventMosaic:
            self.mosaicButton.selected = NO;
            break;
        case PSBottomToolEventClipping:
            self.clippingButton.selected = NO;
            break;
    }
    
    if (!self.brushButton.isSelected
        && !self.textButton.isSelected
        && !self.mosaicButton.isSelected
        && !self.clippingButton.isSelected) {
        self.editor = NO;
    }
}

- (void)resetButtons {
	
	if (self.type == PSBottomToolTypeEditor) {
		for (UIView *view in self.subviews) {
			if ([view isKindOfClass:[UIButton class]]) {
				((UIButton *)view).selected = NO;
			}
		}
	}
}

- (UIButton *)clippingButton {
	
	return LAZY_LOAD(_clippingButton, ({
		
		_clippingButton = [[UIButton alloc] init];
		[_clippingButton setImage:[UIImage ps_imageNamed:@"btn_clipping_normal"]
					  forState:UIControlStateNormal];
		[_clippingButton addTarget:self action:@selector(buttonDidClickSender:) forControlEvents:UIControlEventTouchUpInside];
		_clippingButton;
	}));
}

- (UIButton *)mosaicButton {
	
	return LAZY_LOAD(_mosaicButton, ({
		
		_mosaicButton = [[UIButton alloc] init];
		[_mosaicButton setImage:[UIImage ps_imageNamed:@"btn_mosaic_normal"]
					  forState:UIControlStateNormal];
		[_mosaicButton setImage:[UIImage ps_imageNamed:@"btn_mosaic_selected"]
					  forState:UIControlStateSelected];
		[_mosaicButton addTarget:self action:@selector(buttonDidClickSender:) forControlEvents:UIControlEventTouchUpInside];
		_mosaicButton;
	}));
}

- (UIButton *)textButton {
	
	return LAZY_LOAD(_textButton, ({
		
		_textButton = [[UIButton alloc] init];
		[_textButton setImage:[UIImage ps_imageNamed:@"btn_text_normal"]
					  forState:UIControlStateNormal];
		[_textButton setImage:[UIImage ps_imageNamed:@"btn_text_selected"]
					  forState:UIControlStateSelected];
		[_textButton addTarget:self action:@selector(buttonDidClickSender:) forControlEvents:UIControlEventTouchUpInside];
		_textButton;
	}));
}

- (UIButton *)brushButton {
	
	return LAZY_LOAD(_brushButton, ({
		
		_brushButton = [[UIButton alloc] init];
		[_brushButton setImage:[UIImage ps_imageNamed:@"btn_brush_normal"]
					  forState:UIControlStateNormal];
		[_brushButton setImage:[UIImage ps_imageNamed:@"btn_brush_selected"]
					  forState:UIControlStateSelected];
		[_brushButton addTarget:self action:@selector(buttonDidClickSender:) forControlEvents:UIControlEventTouchUpInside];
		_brushButton;
	}));
}

- (UIImageView *)maskImageView {
	
	return LAZY_LOAD(_maskImageView, ({
		
		_maskImageView = [[UIImageView alloc] initWithImage:[UIImage ps_imageNamed:@"icon_mask_bottom"]];
		_maskImageView;
	}));
}

- (UILabel *)titleLabel {
	
	return LAZY_LOAD(_titleLabel, ({
		
		_titleLabel = [[UILabel alloc] init];
		_titleLabel.textColor = [UIColor whiteColor];
		_titleLabel.textAlignment = NSTextAlignmentCenter;
		_titleLabel.font = [UIFont systemFontOfSize:17.0f];
		_titleLabel;
	}));
}

@end
