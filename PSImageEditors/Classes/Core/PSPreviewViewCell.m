//
//  PSPreviewViewCell.m
//  Pods-PSImageEditors
//
//  Created by rsf on 2018/8/24.
//

#import "PSPreviewViewCell.h"

@interface PSPreviewViewCell()<UIScrollViewDelegate>

@property (nonatomic, strong, readwrite) PSPreviewImageView *imageView;

@end

@implementation PSPreviewViewCell

- (void)setImageObject:(PSImageObject *)imageObject {
	
	_imageObject = imageObject;
	self.imageView.imageObject = imageObject;
}

- (void)prepareForReuse {
	
	[self.imageView reset];
}

- (instancetype)initWithFrame:(CGRect)frame {
	
	if (self = [super initWithFrame:frame]) {
		
		_imageView = [[PSPreviewImageView alloc] init];
		[self.contentView addSubview:_imageView];
		[_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(self.contentView);
		}];
	}
	return self;
}

@end
