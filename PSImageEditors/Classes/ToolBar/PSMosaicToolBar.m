//
//  PSMosaicToolBar.m
//  PSImageEditors
//
//  Created by rsf on 2018/11/16.
//

#import "PSMosaicToolBar.h"
#import "PSExpandClickAreaButton.h"

@interface PSMosaicToolBar ()

@property (nonatomic, strong) UIImageView *maskImageView;

/// 矩形马赛克
@property (nonatomic, strong) PSExpandClickAreaButton *rectangularMosaicStyleButton;
/// 磨砂马赛克
@property (nonatomic, strong) PSExpandClickAreaButton *grindArenaceousMosaicStyleButton;

@end

@implementation PSMosaicToolBar


- (instancetype)init {
    
    if (self = [super init]) {
        
		[self addSubview:self.maskImageView];
		[self.maskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		   make.edges.equalTo(self);
		}];
		
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
        
        
        NSArray *views = @[_rectangularMosaicStyleButton,
                           _grindArenaceousMosaicStyleButton];
        
        [views mas_distributeViewsAlongAxis:MASAxisTypeHorizontal
                           withFixedSpacing:28
                                leadSpacing:48
                                tailSpacing:48];
        [views mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(@(-10));
            make.height.equalTo(@30);
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
    }
    
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(mosaicToolBarType:event:)]) {
        [self.delegate mosaicToolBarType:self.mosaicType event:event];
    }
}

- (UIImageView *)maskImageView {
    
    return LAZY_LOAD(_maskImageView, ({
        
        _maskImageView = [[UIImageView alloc] initWithImage:[UIImage ps_imageNamed:@"icon_mask_bottom"]];
        _maskImageView;
    }));
}

@end
