//
//  PSBootomToolBar.m
//  PSImageEditors
//
//  Created by rsf on 2018/11/16.
//

#import "PSBootomToolBar.h"

@interface PSBootomToolBar ()

@property (nonatomic, strong) UIImageView *maskImageView;
@property (nonatomic, strong) UIButton *drawButton;
@property (nonatomic, strong) UIButton *textButton;
@property (nonatomic, strong) UIButton *mosaicButton;
@property (nonatomic, strong) UIButton *clippingButton;

@end

@implementation PSBootomToolBar

- (void)buttonDidClickSender:(UIButton *)btn {
	
	for (UIButton *button in self.subviews) {
		if ([button isKindOfClass:[UIButton class]] && (button !=btn))
		{ button.selected = NO; }
	}
	
	PSImageEditorMode editorMode;
	if (btn == self.drawButton) {
		editorMode = PSImageEditorModeDraw;
	}else if (btn == self.textButton) {
		editorMode = PSImageEditorModeText;
	}else if (btn == self.mosaicButton) {
		editorMode = PSImageEditorModeMosaic;
	}else if (btn == self.clippingButton) {
		editorMode = PSImageEditorModeClipping;
	}
	btn.selected = !btn.isSelected;
	self.editor = btn.selected;
	
	if (self.delegate && [self.delegate respondsToSelector:
						  @selector(bottomToolBar:didClickAtEditorMode:)]) {
		[self.delegate bottomToolBar:self didClickAtEditorMode:editorMode];
	}
}

- (instancetype)init {
	
	if (self = [super init]) {
		
		[self addSubview:self.maskImageView];
		[self addSubview:self.drawButton];
		[self addSubview:self.textButton];
		[self addSubview:self.mosaicButton];
		[self addSubview:self.clippingButton];
		
		[self.maskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(self);
		}];
		NSMutableArray *editorItems = [NSMutableArray array];
		[editorItems addObject:self.drawButton];
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
	return self;
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

- (UIButton *)drawButton {
	
	return LAZY_LOAD(_drawButton, ({
		
		_drawButton = [[UIButton alloc] init];
		[_drawButton setImage:[UIImage ps_imageNamed:@"btn_brush_normal"]
					  forState:UIControlStateNormal];
		[_drawButton setImage:[UIImage ps_imageNamed:@"btn_brush_selected"]
					  forState:UIControlStateSelected];
		[_drawButton addTarget:self action:@selector(buttonDidClickSender:) forControlEvents:UIControlEventTouchUpInside];
		_drawButton;
	}));
}

- (UIImageView *)maskImageView {
	
	return LAZY_LOAD(_maskImageView, ({
		
		_maskImageView = [[UIImageView alloc] initWithImage:[UIImage ps_imageNamed:@"icon_mask_bottom"]];
		_maskImageView;
	}));
}

@end
