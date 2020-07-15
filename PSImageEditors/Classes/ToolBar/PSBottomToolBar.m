//
//  PSBottomToolBar.m
//  PSImageEditors
//
//  Created by paintingStyle on 2018/11/17.
//

#import "PSBottomToolBar.h"
#import "PSExpandClickAreaButton.h"

@interface PSBottomToolBar ()

@property (nonatomic, strong) UIImageView *maskImageView;

@property (nonatomic, strong) PSExpandClickAreaButton *drawButton;
@property (nonatomic, strong) PSExpandClickAreaButton *textButton;
@property (nonatomic, strong) PSExpandClickAreaButton *mosaicButton;
@property (nonatomic, strong) PSExpandClickAreaButton *clippingButton;

@property (nonatomic, strong) PSExpandClickAreaButton *undoButton;
@property (nonatomic, strong) PSExpandClickAreaButton *doneButton;

@property (nonatomic, strong) UIView *deleteContainerView;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *deleteDescButton;

@property (nonatomic, assign) PSBottomToolType type;

@end


@implementation PSBottomToolBar

- (void)buttonDidClickSender:(UIButton *)btn {
    
    for (UIButton *button in self.subviews) {
        if ([button isKindOfClass:[UIButton class]] && (button !=btn))
        { button.selected = NO; }
    }
	
	PSBottomToolBarEvent event;
    if (btn == self.drawButton) {
        event = PSBottomToolBarEventDraw;
    }else if (btn == self.textButton) {
        event = PSBottomToolBarEventText;
    }else if (btn == self.mosaicButton) {
        event = PSBottomToolBarEventMosaic;
    }else if (btn == self.clippingButton) {
        event = PSBottomToolBarEventClipping;
    }
    btn.selected = !btn.isSelected;
    self.editor = btn.selected;
    
    if (self.delegate && [self.delegate respondsToSelector:
                          @selector(bottomToolBar:didClickEvent:)]) {
        [self.delegate bottomToolBar:self didClickEvent:event];
    }
}

- (void)undoButtonDidClick {
	
	if (self.delegate && [self.delegate respondsToSelector:
                          @selector(bottomToolBar:didClickEvent:)]) {
        [self.delegate bottomToolBar:self didClickEvent:PSBottomToolBarEventUndo];
    }
}

- (void)doneButtonDidClick {
	
	if (self.delegate && [self.delegate respondsToSelector:
                          @selector(bottomToolBar:didClickEvent:)]) {
        [self.delegate bottomToolBar:self didClickEvent:PSBottomToolBarEventDone];
    }
}

- (void)reset {
    
    self.drawButton.selected = NO;
    self.textButton.selected = NO;
    self.mosaicButton.selected = NO;
    self.clippingButton.selected = NO;
}


- (instancetype)initWithType:(PSBottomToolType)type {
    
    if (self = [super init]) {
        self.type = type;
        switch (type) {
            case PSBottomToolTypeEditor:
                [self configEditorUI];
                break;
            case PSBottomToolTypeDelete:
                [self configDeleteUI];
                break;
            default:
                break;
        }
    }
    return self;
}

- (void)configEditorUI {
    
    [self addSubview:self.maskImageView];
    [self addSubview:self.drawButton];
    [self addSubview:self.textButton];
    [self addSubview:self.mosaicButton];
    [self addSubview:self.clippingButton];
	[self addSubview:self.undoButton];
	[self addSubview:self.doneButton];
	
    [self.maskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
	[self.undoButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(@24);
		if (@available(iOS 11.0, *)) {
			make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-14);
		} else {
			make.bottom.equalTo(@(-14));
		}
		make.size.equalTo(@34);
	}];
	[self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.right.equalTo(@(-24));
		make.bottom.equalTo(self.undoButton);
		make.size.equalTo(@34);
	}];
	
    NSMutableArray *editorItems = [NSMutableArray array];
    [editorItems addObject:self.drawButton];
    [editorItems addObject:self.textButton];
    [editorItems addObject:self.mosaicButton];
    [editorItems addObject:self.clippingButton];
	
	[editorItems mas_distributeViewsAlongAxis:MASAxisTypeHorizontal
							 withFixedSpacing:34
								  leadSpacing:100
								  tailSpacing:100];
    [editorItems mas_makeConstraints:^(MASConstraintMaker *make) {
		
		if (@available(iOS 11.0, *)) {
			make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-14);
		} else {
			make.bottom.equalTo(@(-14));
		}
        make.height.equalTo(@34);
    }];
	self.tempEditorItem = editorItems.firstObject;
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
		
        make.centerX.equalTo(self.deleteContainerView);
		make.bottom.equalTo(self.deleteDescButton.mas_top).offset(-12);
    }];
    
    [self.deleteDescButton mas_makeConstraints:^(MASConstraintMaker *make) {
		
        make.centerX.equalTo(self.deleteButton);
		if (@available(iOS 11.0, *)) {
			make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-20);
		} else {
			make.bottom.equalTo(@(-20));
		}
    }];
}

- (void)setDeleteState:(PSBottomToolDeleteState)deleteState {
    
    _deleteState = deleteState;

	if (deleteState == PSBottomToolDeleteStateDid) {
		self.deleteButton.selected = YES;
		self.deleteDescButton.selected = YES;
	}else {
		self.deleteButton.selected = NO;
		self.deleteDescButton.selected = NO;
	}
}

- (void)setCanUndo:(BOOL)canUndo {
	
	_canUndo = canUndo;
	self.undoButton.enabled = canUndo;
}

- (PSExpandClickAreaButton *)clippingButton {
    
    return LAZY_LOAD(_clippingButton, ({
        
        _clippingButton = [[PSExpandClickAreaButton alloc] init];
        [_clippingButton setImage:[UIImage ps_imageNamed:@"btn_clipping_normal"]
                         forState:UIControlStateNormal];
        [_clippingButton addTarget:self action:@selector(buttonDidClickSender:) forControlEvents:UIControlEventTouchUpInside];
        _clippingButton;
    }));
}

- (PSExpandClickAreaButton *)mosaicButton {
    
    return LAZY_LOAD(_mosaicButton, ({
        
        _mosaicButton = [[PSExpandClickAreaButton alloc] init];
        [_mosaicButton setImage:[UIImage ps_imageNamed:@"btn_mosaic_normal"]
                       forState:UIControlStateNormal];
        [_mosaicButton setImage:[UIImage ps_imageNamed:@"btn_mosaic_selected"]
                       forState:UIControlStateSelected];
        [_mosaicButton addTarget:self action:@selector(buttonDidClickSender:) forControlEvents:UIControlEventTouchUpInside];
        _mosaicButton;
    }));
}

- (PSExpandClickAreaButton *)textButton {
    
    return LAZY_LOAD(_textButton, ({
        
        _textButton = [[PSExpandClickAreaButton alloc] init];
        [_textButton setImage:[UIImage ps_imageNamed:@"btn_text_normal"]
                     forState:UIControlStateNormal];
        [_textButton setImage:[UIImage ps_imageNamed:@"btn_text_selected"]
                     forState:UIControlStateSelected];
        [_textButton addTarget:self action:@selector(buttonDidClickSender:) forControlEvents:UIControlEventTouchUpInside];
        _textButton;
    }));
}

- (PSExpandClickAreaButton *)drawButton {
    
    return LAZY_LOAD(_drawButton, ({
        
        _drawButton = [[PSExpandClickAreaButton alloc] init];
        [_drawButton setImage:[UIImage ps_imageNamed:@"btn_brush_normal"]
                     forState:UIControlStateNormal];
        [_drawButton setImage:[UIImage ps_imageNamed:@"btn_brush_selected"]
                     forState:UIControlStateSelected];
        [_drawButton addTarget:self action:@selector(buttonDidClickSender:) forControlEvents:UIControlEventTouchUpInside];
        _drawButton;
    }));
}

- (PSExpandClickAreaButton *)undoButton {
	
	return LAZY_LOAD(_undoButton, ({
		
		_undoButton = [PSExpandClickAreaButton buttonWithType:UIButtonTypeCustom];
		[_undoButton setImage:[UIImage ps_imageNamed:@"btn_revocation_normal"]
					 forState:UIControlStateNormal];
		_undoButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
		_undoButton.enabled = NO;
		[_undoButton addTarget:self action:@selector(undoButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
		_undoButton;
	}));
}

- (PSExpandClickAreaButton *)doneButton {
	
	return LAZY_LOAD(_doneButton, ({
		
		_doneButton = [PSExpandClickAreaButton buttonWithType:UIButtonTypeCustom];
		[_doneButton setImage:[UIImage ps_imageNamed:@"btn_done"]
					 forState:UIControlStateNormal];
		_doneButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
		[_doneButton addTarget:self action:@selector(doneButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
		_doneButton;
	}));
}

- (UIImageView *)maskImageView {
    
    return LAZY_LOAD(_maskImageView, ({
        
        _maskImageView = [[UIImageView alloc] initWithImage:[UIImage ps_imageNamed:@"icon_mask_bottom"]];
        _maskImageView;
    }));
}

@end
