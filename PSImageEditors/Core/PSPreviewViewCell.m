//
//  PSPreviewViewCell.m
//  Pods-PSImageEditors
//
//  Created by rsf on 2018/8/24.
//

#import "PSPreviewViewCell.h"
#import "PSImageEditorsDefine.h"
#import "PSImageEditorsHelper.h"

@interface PSPreviewViewCell()

@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) FLAnimatedImageView *imageView;

@end

@implementation PSPreviewViewCell

- (void)setImageObject:(PSImageObject *)imageObject {
	
	_imageObject = imageObject;
	
	if (imageObject.image) {
		 self.imageView.image = imageObject.image;
	}else if(imageObject.GIFImage) {
		self.imageView.animatedImage = imageObject.GIFImage;
	}else {
		[self.indicator startAnimating];
		[self.imageView sd_setImageWithURL:imageObject.url completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
			[self.indicator stopAnimating];
		}];
	}
}

- (instancetype)initWithFrame:(CGRect)frame {
	
	if (self = [super initWithFrame:frame]) {
		
		_indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		_indicator.hidesWhenStopped = YES;
		_indicator.center = self.contentView.center;
		[self.contentView addSubview:_indicator];
		
		_imageView = [[FLAnimatedImageView alloc] initWithFrame:self.contentView.bounds];
		_imageView.contentMode = UIViewContentModeScaleAspectFit;
		[self.contentView addSubview:_imageView];
	}
	return self;
}

@end
