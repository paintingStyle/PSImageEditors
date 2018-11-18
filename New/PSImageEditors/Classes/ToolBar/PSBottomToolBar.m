//
//  PSBottomToolBar.m
//  PSImageEditors
//
//  Created by paintingStyle on 2018/11/17.
//

#import "PSBottomToolBar.h"

@interface PSBottomToolBar ()

@property (nonatomic, strong) UIImageView *maskImageView;
@property (nonatomic, strong) UIButton *drawButton;
@property (nonatomic, strong) UIButton *textButton;
@property (nonatomic, strong) UIButton *mosaicButton;
@property (nonatomic, strong) UIButton *clippingButton;

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

- (void)reset {
    
    self.drawButton.selected = NO;
    self.textButton.selected = NO;
    self.mosaicButton.selected = NO;
    self.clippingButton.selected = NO;
}

- (void)setToolBarShow:(BOOL)show animation:(BOOL)animation {
    
    self.show = show;
    [UIView animateWithDuration:(animation ? kEditorToolBarAnimationDuration:0)
                     animations:^{
                         if (show) {
                             self.transform = CGAffineTransformIdentity;
                         }else{
                             if (self.type == PSBottomToolTypeEditor) {
                                 self.transform = CGAffineTransformMakeTranslation(0, PSBottomToolBarHeight);
                             }else {
                                 self.transform = CGAffineTransformMakeTranslation(0, PSBottomToolDeleteBarHeight);
                             }
                         }
                     }];
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

- (void)setDeleteState:(PSBottomToolDeleteState)deleteState {
    
    _deleteState = deleteState;
    self.deleteButton.selected = (deleteState == PSBottomToolDeleteStateDid);
    self.deleteDescButton.selected = (deleteState == PSBottomToolDeleteStateDid);
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
