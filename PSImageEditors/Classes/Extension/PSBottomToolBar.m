//
//  PSBottomToolBar.m
//  PSImageEditors
//
//  Created by paintingStyle on 2018/8/25.
//

#import "PSBottomToolBar.h"

@interface PSBottomToolBar()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation PSBottomToolBar

- (instancetype)initWithType:(PSBottomToolType)type {
    
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6f];
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
            case PSBottomToolTypeCut:
                [self configCutUI];
                break;
            default:
                break;
        }
        DEBUG_VIEW(self);
    }
    return self;
}

- (void)configDefaultUI {
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [self addSubview:self.titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    self.titleLabel.text = @"原图(638KB)";
}

- (void)configPreviewUI {
    
    
}

- (void)configEditorUI {
    
    
}

- (void)configDeleteUI {
    
    
}

- (void)configCutUI {
    
    
}

@end
