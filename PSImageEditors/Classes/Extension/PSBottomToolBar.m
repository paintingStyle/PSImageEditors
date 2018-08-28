//
//  PSBottomToolBar.m
//  PSImageEditors
//
//  Created by paintingStyle on 2018/8/25.
//

#import "PSBottomToolBar.h"
#import "PSImageObject.h"

@interface PSBottomToolBar()

@property (nonatomic, strong) UILabel *titleLabel;

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
    }
    return self;
}

- (void)setToolBarShow:(BOOL)show animation:(BOOL)animation {
	
	[UIView animateWithDuration:(animation ? 0.15:0) animations:^{
		if (show) {
			self.transform = CGAffineTransformIdentity;
		}else{
			self.transform = CGAffineTransformMakeTranslation(0, 50);
		}
	}];
}

- (void)configDefaultUI {
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [self addSubview:self.titleLabel];
	
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
		make.height.equalTo(@20);
		make.left.equalTo(@15);
		make.right.equalTo(@(-15));
    }];
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
