//
//  PSMosaicToolBar.m
//  PSImageEditors
//
//  Created by rsf on 2018/11/16.
//

#import "PSMosaicToolBar.h"
#import "PSExpandClickAreaButton.h"

@interface PSMosaicToolBar ()

/// 矩形马赛克
@property (nonatomic, strong) PSExpandClickAreaButton *rectangularMosaicStyleButton;
/// 磨砂马赛克
@property (nonatomic, strong) PSExpandClickAreaButton *grindArenaceousMosaicStyleButton;
/// 撤销
@property (nonatomic, strong) PSExpandClickAreaButton *undoButton;

@property (nonatomic, strong) UIView *bottomLineView;

@end

@implementation PSMosaicToolBar

- (void)setCanUndo:(BOOL)canUndo {
    
    _canUndo = canUndo;
    self.undoButton.enabled = canUndo;
}

- (instancetype)init {
    
    if (self = [super init]) {
        
        _rectangularMosaicStyleButton = [PSExpandClickAreaButton buttonWithType:UIButtonTypeCustom];
        [_rectangularMosaicStyleButton setImage:[UIImage ps_imageNamed:@"btn_mosaic_rectangular_normal"]
                                       forState:UIControlStateNormal];
        [_rectangularMosaicStyleButton setImage:[UIImage ps_imageNamed:@"btn_mosaic_rectangular_selected"]
                                       forState:UIControlStateSelected];
        [_rectangularMosaicStyleButton addTarget:self action:@selector(buttonDidClick:)
                                forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_rectangularMosaicStyleButton];
        
        _grindArenaceousMosaicStyleButton = [PSExpandClickAreaButton buttonWithType:UIButtonTypeCustom];
        [_grindArenaceousMosaicStyleButton setImage:[UIImage ps_imageNamed:@"btn_mosaic_grindArenaceous_normal"]
                                           forState:UIControlStateNormal];
        [_grindArenaceousMosaicStyleButton setImage:[UIImage ps_imageNamed:@"btn_mosaic_grindArenaceous_selected"]
                                           forState:UIControlStateSelected];
        [_grindArenaceousMosaicStyleButton addTarget:self action:@selector(buttonDidClick:)
                                    forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_grindArenaceousMosaicStyleButton];
        
        _undoButton = [PSExpandClickAreaButton buttonWithType:UIButtonTypeCustom];
        [_undoButton setImage:[UIImage ps_imageNamed:@"btn_revocation_normal"]
                     forState:UIControlStateNormal];
        [_undoButton setImage:[UIImage ps_imageNamed:@"btn_revocation_disabled"]
                     forState:UIControlStateDisabled];
        [_undoButton addTarget:self action:@selector(buttonDidClick:)
              forControlEvents:UIControlEventTouchUpInside];
        _undoButton.enabled = NO;
        [self addSubview:_undoButton];
        
        NSArray *views = @[_rectangularMosaicStyleButton,
                           _grindArenaceousMosaicStyleButton,
                           _undoButton];
        
        [views mas_distributeViewsAlongAxis:MASAxisTypeHorizontal
                           withFixedSpacing:28
                                leadSpacing:48
                                tailSpacing:48];
        [views mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.height.equalTo(@28);
        }];
		
		_bottomLineView = [[UIView alloc] init];
		_bottomLineView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
		[self addSubview:_bottomLineView];
		
		[_bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
			
			make.left.equalTo(@15);
			make.right.equalTo(@(-15));
			make.bottom.equalTo(self);
			make.height.equalTo(@0.5);
		}];
		
        // 默认选中
        _rectangularMosaicStyleButton.selected = YES;
        [self buttonDidClick:_rectangularMosaicStyleButton];
    }
    return self;
}

- (void)buttonDidClick:(UIButton *)sender {
    
    PSMosaicToolBarEvent event;
    if (sender == self.rectangularMosaicStyleButton) {
        event = PSMosaicToolBarEventRectangular;
        self.mosaicType = PSMosaicTypeRectangular;
        self.rectangularMosaicStyleButton.selected = YES;
        self.grindArenaceousMosaicStyleButton.selected = NO;
    }else if (sender == self.grindArenaceousMosaicStyleButton) {
        event = PSMosaicToolBarEventGrindArenaceous;
        self.mosaicType = PSMosaicTypeGrindArenaceous;
        self.grindArenaceousMosaicStyleButton.selected = YES;
        self.rectangularMosaicStyleButton.selected = NO;
    }else {
        event = PSMosaicToolBarEventUndo;
    }
    
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(mosaicToolBarType:event:)]) {
        [self.delegate mosaicToolBarType:self.mosaicType event:event];
    }
}

- (void)setToolBarShow:(BOOL)show animation:(BOOL)animation {
    
    [UIView animateWithDuration:(animation ? kEditorToolBarAnimationDuration:0.0f) animations:^{
        self.alpha = (show ? 1.0f:0.0f);
    }];
}

@end
