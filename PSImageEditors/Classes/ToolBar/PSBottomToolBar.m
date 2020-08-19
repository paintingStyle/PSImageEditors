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

@property (nonatomic, assign) PSBottomToolType type;

@end


@implementation PSBottomToolBar

- (void)buttonDidClickSender:(UIButton *)btn {
    
    for (UIButton *button in self.editorItemsView.subviews) {
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

- (void)selectIndex:(NSInteger)index {
	
	UIButton *sender = nil;
	switch (index) {
		case 0:
			sender = self.drawButton;
			break;
		case 1:
			sender = self.textButton;
			break;
		case 2:
			sender = self.mosaicButton;
			break;
		case 3:
			sender = self.clippingButton;
			break;
		default:
			break;
	}
	
	if (sender) {
		[self buttonDidClickSender:sender];
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
            default:
                break;
        }
    }
    return self;
}

- (void)configEditorUI {
    
	[self addSubview:self.editorItemsView];
    [self.editorItemsView addSubview:self.drawButton];
    [self.editorItemsView addSubview:self.textButton];
    [self.editorItemsView addSubview:self.mosaicButton];
    [self.editorItemsView addSubview:self.clippingButton];
	[self.editorItemsView addSubview:self.undoButton];
	[self.editorItemsView addSubview:self.doneButton];
	
    [self.editorItemsView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.right.bottom.equalTo(self);
		make.height.equalTo(@(44+PS_SAFEAREA_BOTTOM_DISTANCE));
    }];
	
	CGFloat leadItemMargin = PS_ELASTIC_LAYOUT(24);
	CGFloat leadItemWH = PS_ELASTIC_LAYOUT(16);
	CGFloat editorItemWH = leadItemWH;
	CGFloat editorItemMargin = PS_ELASTIC_LAYOUT(34);
	CGFloat editorItemLeadMargin = floor((PS_SCREEN_W  - (4 *editorItemWH) -(3 *editorItemMargin)) *0.5);
	
	[self.undoButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(@(leadItemMargin));
		make.size.equalTo(@(leadItemWH));
		make.top.equalTo(@14);
	}];
	
	[self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.right.equalTo(@(-leadItemMargin));
		make.size.equalTo(@(leadItemWH));
		make.top.equalTo(@14);
	}];
	
    NSMutableArray *editorItems = [NSMutableArray array];
    [editorItems addObject:self.drawButton];
    [editorItems addObject:self.textButton];
    [editorItems addObject:self.mosaicButton];
    [editorItems addObject:self.clippingButton];
	
	[editorItems mas_distributeViewsAlongAxis:MASAxisTypeHorizontal
						  withFixedItemLength:editorItemWH
								  leadSpacing:editorItemLeadMargin
								  tailSpacing:editorItemLeadMargin];

    [editorItems mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(self.undoButton);
		make.height.equalTo(@(editorItemWH));
    }];
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

- (UIView *)editorItemsView {
	
	return LAZY_LOAD(_editorItemsView, ({
		   
		   _editorItemsView = [[UIView alloc] init];
		   _editorItemsView.backgroundColor = [UIColor blackColor];
		   _editorItemsView;
	   }));
}

- (UIImageView *)maskImageView {
    
    return LAZY_LOAD(_maskImageView, ({
        
        _maskImageView = [[UIImageView alloc] initWithImage:[UIImage ps_imageNamed:@"icon_mask_bottom"]];
        _maskImageView;
    }));
}

@end
