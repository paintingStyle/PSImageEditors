//
//  PSPreviewImageView.m
//  PSImageEditors
//
//  Created by rsf on 2018/8/29.
//

#import "PSPreviewImageView.h"
#import "PSImageObject.h"
#import "PSImageEditorsHelper.h"
#import "PSImageLoadFailedView.h"

@interface PSPreviewImageView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) PSImageLoadFailedView *loadFailedView;

@property (nonatomic, strong) UITapGestureRecognizer *singleGesture;
@property (nonatomic, strong) UITapGestureRecognizer *doubleGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longGesture;

@end

@implementation PSPreviewImageView

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
	self.drawingView.hidden = !self.imageObject.isEditor;
	self.doubleGesture.enabled = self.imageObject.isDoubleClickZoom;
}

- (void)processingImageDisplay {
	
	id image = self.imageObject.GIFImage ? :self.imageObject.image;
	BOOL isAnimation = [image isKindOfClass:[FLAnimatedImage class]];
	
	if (isAnimation) { // GIF图片暂时不缩放
		self.imageView.animatedImage = image;
	}else {
		[self.imageObject calculateDisplayContentSize];
		[_imageView mas_updateConstraints:^(MASConstraintMaker *make) {
			make.height.equalTo(@(self.imageObject.displayContentSize.height));
		}];
		[self layoutIfNeeded];
		if (self.imageObject.isScaling) {
			self.imageView.image = [PSImageEditorsHelper imageByScalingToSize:self.imageObject.displayContentSize
																  sourceImage:image];
		}else {
			self.imageView.image = image;
			//[self alignCenterImage];
		}
	}
}

- (void)alignCenterImage {
	
	CGPoint offest = CGPointMake(0, (self.imageObject.displayContentSize.height -PS_SCREEN_H) *0.5);
	[self.scrollView setContentOffset:offest animated:NO];
}

- (void)hiddenLoadFailedImageView:(BOOL)hidden {
	
	self.loadFailedView.hidden = hidden;
	if (hidden) {
		[self sendSubviewToBack:self.loadFailedView];
		self.imageView.image = nil;
		self.imageView.animatedImage = nil;
	}else{
		[self bringSubviewToFront:self.loadFailedView];
		[self processingImageDisplay];
	}
}

- (instancetype)init {
	
	if (self = [super init]) {
		
		_scrollView = [[UIScrollView alloc] init];
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_scrollView.delegate = self;
		_scrollView.minimumZoomScale = 1.0;
		_scrollView.maximumZoomScale = 3.0f;
		_scrollView.multipleTouchEnabled = YES;
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.delaysContentTouches = NO;
		_scrollView.scrollsToTop = NO;
		_scrollView.clipsToBounds = NO;
		if(@available(iOS 11.0, *)) {
			_scrollView.contentInsetAdjustmentBehavior =
			UIScrollViewContentInsetAdjustmentNever;
		}
		[self addSubview:_scrollView];
		[_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(self);
		}];
		
		_containerView = [[UIView alloc] init];
		[_scrollView addSubview:_containerView];
		[_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
			
			make.edges.equalTo(self.scrollView);
			make.width.equalTo(self.scrollView);
		}];
		
		_imageView = [[FLAnimatedImageView alloc] init];
		[_containerView addSubview:_imageView];
		[_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
			make.left.right.equalTo(_containerView);
			make.height.equalTo(@(PS_SCREEN_H));
			make.centerY.equalTo(_containerView);
		}];
		
		_drawingView = [[UIImageView alloc] init];
		_drawingView.contentMode = UIViewContentModeCenter;
		_drawingView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
		[_imageView addSubview:_drawingView];
		[_drawingView mas_makeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(self.imageView);
		}];
		
		_loadFailedView = [[PSImageLoadFailedView alloc] init];
		_loadFailedView.hidden = YES;
		[self sendSubviewToBack:_loadFailedView];
		[self addSubview:_loadFailedView];
		[_loadFailedView mas_makeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(self);
		}];
		
		_indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		_indicator.hidesWhenStopped = YES;
		[_containerView addSubview:_indicator];
		[_containerView bringSubviewToFront:_indicator];
		[_indicator mas_makeConstraints:^(MASConstraintMaker *make) {
			make.center.equalTo(self.containerView);
		}];
		
		[_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
			make.height.equalTo(self.imageView).priorityLow();
			make.height.equalTo(@(PS_SCREEN_H));
		}];
		
		_singleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleGestureClicked)];
		[_scrollView addGestureRecognizer:_singleGesture];
		
		_doubleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleGestureClicked:)];
		_doubleGesture.numberOfTapsRequired = 2;
		[_scrollView addGestureRecognizer:_doubleGesture];
		[_singleGesture requireGestureRecognizerToFail:_doubleGesture];
		
		_longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:
		 @selector(longGestureDidClick:)];
		_longGesture.minimumPressDuration = .5;
		[_scrollView addGestureRecognizer:_longGesture];
	}
	return self;
}

- (void)reset {
	
	[self.scrollView setZoomScale:1.0 animated:NO];
	[self hiddenLoadFailedImageView:YES];
	[self.indicator stopAnimating];
}

- (void)longGestureDidClick:(UIGestureRecognizer *)gesture {
	
	if (gesture.state != UIGestureRecognizerStateBegan) { return; }
	if (self.longGestureBlock) {
		self.longGestureBlock(self.imageObject);
	}
}
#pragma mark - 单击手势点击事件

- (void)singleGestureClicked {
	
	if (self.singleGestureBlock) {
		self.singleGestureBlock(self.imageObject);
	}
}

#pragma mark - 双击点击事件

- (void)doubleGestureClicked:(UITapGestureRecognizer *)gesture {
	
	UIScrollView *scrollView = self.scrollView;
	
	CGFloat scale = 1;
	if (scrollView.zoomScale != 3.0) {
		scale = 3;
	} else {
		scale = 1;
	}
	CGRect zoomRect = [self zoomRectForScale:scale withCenter:[gesture locationInView:gesture.view]];
	[scrollView zoomToRect:zoomRect animated:YES];
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
	
	CGRect zoomRect;
	zoomRect.size.height = self.scrollView.frame.size.height / scale;
	zoomRect.size.width  = self.scrollView.frame.size.width  / scale;
	zoomRect.origin.x    = center.x - (zoomRect.size.width  /2.0);
	zoomRect.origin.y    = center.y - (zoomRect.size.height /2.0);
	return zoomRect;
}

#pragma mark - UIScrollViewDelegate

#pragma mark - 使用捏合手势时，这个方法返回的控件就是需要进行缩放的控件

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	
	return self.containerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
	
	CGFloat offsetX = (CGRectGetWidth(scrollView.frame) > scrollView.contentSize.width) ? (CGRectGetWidth(scrollView.frame) - scrollView.contentSize.width) * 0.5 : 0.0;
	CGFloat offsetY = (CGRectGetHeight(scrollView.frame) > scrollView.contentSize.height) ? (CGRectGetHeight(scrollView.frame) - scrollView.contentSize.height) * 0.5 : 0.0;
	self.containerView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

@end
