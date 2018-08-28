//
//  PSPreviewViewCell.m
//  Pods-PSImageEditors
//
//  Created by rsf on 2018/8/24.
//

#import "PSPreviewViewCell.h"
#import "PSImageLoadFailedView.h"
#import "PSImageEditorsHelper.h"

@interface PSPreviewViewCell()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) FLAnimatedImageView *imageView;
@property (nonatomic, strong) PSImageLoadFailedView *loadFailedView;

@end

@implementation PSPreviewViewCell

- (void)setImageObject:(PSImageObject *)imageObject {
	
	_imageObject = imageObject;
	
	if (imageObject.image || imageObject.GIFImage) {
		NSInteger length = imageObject.GIFImage ? imageObject.GIFImage.data.length
							   :UIImageJPEGRepresentation(imageObject.image, 1.0f).length;
		self.imageObject.originSize = [PSImageEditorsHelper fileSizeWithByteSize:length];
		if (imageObject.fetchOriginSizeBlock) {
			imageObject.fetchOriginSizeBlock(self.imageObject.originSize);
		}
		[self processingImageDisplay];
	}else {
		[self.indicator startAnimating];
		[self.imageView sd_setImageWithURL:imageObject.url completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
			
			if (error) {
				[self hiddenLoadFailedImageView:NO];
				[self.indicator stopAnimating];
				return;
			}
			[PSImageEditorsHelper imageDataWithImageURL:imageURL completion:^(NSData *data) {
				if (PS_Is_GIFTypeWithData(data)) {
					imageObject.GIFImage = [FLAnimatedImage animatedImageWithGIFData:data];
				}else {
					imageObject.image = image;
				}
				self.imageObject.originSize = [PSImageEditorsHelper fileSizeWithByteSize:data.length];
				if (imageObject.fetchOriginSizeBlock) {
					imageObject.fetchOriginSizeBlock(self.imageObject.originSize);
				}
				[self processingImageDisplay];
			}];
			[self.indicator stopAnimating];
		}];
	}
}

- (void)prepareForReuse {
	
	[self.scrollView setZoomScale:1.0 animated:NO];
	[self hiddenLoadFailedImageView:YES];
	[self.indicator stopAnimating];
}

- (void)hiddenLoadFailedImageView:(BOOL)hidden {
	
	self.loadFailedView.hidden = hidden;
	if (hidden) {
		[self.contentView sendSubviewToBack:self.loadFailedView];
	}else{
		[self.contentView bringSubviewToFront:self.loadFailedView];
	}
}

- (void)processingImageDisplay {
	
	id image = self.imageObject.GIFImage ? :self.imageObject.image;
	BOOL isAnimation = [image isKindOfClass:[FLAnimatedImage class]];
	
	if (isAnimation) { // GIF图片暂时不缩放
		self.imageView.animatedImage = image;
		return;
	}else {
		[self.imageObject calculateDisplayContentSize];
		[_imageView mas_updateConstraints:^(MASConstraintMaker *make) {
			make.height.equalTo(@(self.imageObject.displayContentSize.height));
		}];
		[self.contentView layoutIfNeeded];
		if (self.imageObject.isScaling) {
			self.imageView.image = [PSImageEditorsHelper imageByScalingToSize:self.imageObject.displayContentSize
																  sourceImage:image];
		}else {
			self.imageView.image = image;
		}
	}
}

- (void)longGestureDidClick:(UIGestureRecognizer *)gesture {
	
	if (gesture.state != UIGestureRecognizerStateBegan) { return; }
	if (self.longGestureDidClickBlock) {
		self.longGestureDidClickBlock(self.imageObject);
	}
}
#pragma mark - 单击手势点击事件

- (void)singleGestureClicked {
	
	if (self.singleGestureDidClickBlock) {
		self.singleGestureDidClickBlock(self.imageObject);
	}
}

- (CGFloat)maxScale {
	
	// TODO:此处计算有误
	CGFloat imageHeight = self.imageObject.displayContentSize.height /self.imageObject.displayContentSize.width *CGRectGetWidth(self.contentView.frame);
	CGFloat maxScale =  CGRectGetHeight(self.contentView.frame) / imageHeight;
	//if (maxScale == 1) { maxScale = 3; }
	
	return 3;
}

#pragma mark - 双击点击事件

- (void)doubleGestureClicked:(UITapGestureRecognizer *)gesture {

	CGFloat scale = 1.0;
	if (self.scrollView.zoomScale >1.0) {
		scale = 1.0;
	}else {
		scale = [self maxScale];
	}
	[self.scrollView setZoomScale:scale animated:YES];
}

#pragma mark - UIScrollViewDelegate

#pragma mark - 使用捏合手势时，这个方法返回的控件就是需要进行缩放的控件

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	
	return self.imageView;
}

- (instancetype)initWithFrame:(CGRect)frame {
	
	if (self = [super initWithFrame:frame]) {
		
		_scrollView = [[UIScrollView alloc] init];
		_scrollView.delegate = self;
		_scrollView.minimumZoomScale = 1.0;
		_scrollView.maximumZoomScale = [self maxScale];
		_scrollView.multipleTouchEnabled = YES;
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.showsVerticalScrollIndicator = NO;
//		_scrollView.alwaysBounceVertical = YES;
//		_scrollView.alwaysBounceHorizontal = YES;
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_scrollView.delaysContentTouches = NO;
		_scrollView.scrollsToTop = NO;
		if(@available(iOS 11.0, *)) {
			_scrollView.contentInsetAdjustmentBehavior =
			UIScrollViewContentInsetAdjustmentNever;
		}
		[self.contentView addSubview:_scrollView];
		[_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(self.contentView);
		}];
		
		_containerView = [[UIView alloc] init];
		[_scrollView addSubview:_containerView];
		[_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
			
			make.edges.equalTo(_scrollView);
			make.width.equalTo(_scrollView);
		}];
		
		// TODO: 需要计算_imageView的大小，动态调整_containerView的高度
		_imageView = [[FLAnimatedImageView alloc] initWithFrame:CGRectZero];
		_imageView.contentMode = UIViewContentModeScaleAspectFit;
		[_containerView addSubview:_imageView];
		[_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
			
			make.left.top.right.equalTo(_containerView);
			make.height.equalTo(@(PS_SCREEN_H));
		}];
		
		_loadFailedView = [[PSImageLoadFailedView alloc] init];
		_loadFailedView.hidden = YES;
		[self.contentView sendSubviewToBack:_loadFailedView];
		[self.contentView addSubview:_loadFailedView];
		[_loadFailedView mas_makeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(self.contentView);
		}];
		
		_indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		_indicator.hidesWhenStopped = YES;
		[_containerView addSubview:_indicator];
		[_containerView bringSubviewToFront:_indicator];
		[_indicator mas_makeConstraints:^(MASConstraintMaker *make) {
			make.center.equalTo(_containerView);
		}];
	
		[_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
			make.bottom.equalTo(_imageView);
		}];

		UITapGestureRecognizer *singleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleGestureClicked)];
		[_scrollView addGestureRecognizer:singleGesture];
		
		UITapGestureRecognizer *doubleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleGestureClicked:)];
		doubleGesture.numberOfTapsRequired = 2;
		[_scrollView addGestureRecognizer:doubleGesture];
		[singleGesture requireGestureRecognizerToFail:doubleGesture];

		UILongPressGestureRecognizer *longGesture =
		[[UILongPressGestureRecognizer alloc] initWithTarget:self action:
		 @selector(longGestureDidClick:)];
		[_scrollView addGestureRecognizer:longGesture];
	}
	return self;
}

@end
