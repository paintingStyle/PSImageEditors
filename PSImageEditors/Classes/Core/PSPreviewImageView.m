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
#import "FLAnimatedImageView+Download.h"

static const NSInteger kMinimumZoomScale = 1.0;
static const NSInteger kMaximumZoomScale = 3.0f;
static const CGFloat   kHorizontalSpacing = 5.0f;

@interface PSPreviewImageView ()<UIScrollViewDelegate>

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
		if (imageObject.GIFImage) {
			self.imageView.animatedImage = imageObject.GIFImage;
		}else {
			self.imageView.image = imageObject.image;
		}
		[self processingImageDisplay];
	}else {
		[self.indicator startAnimating];
		[self.imageView ps_setImageWithURL:imageObject.url completed:^(id  _Nullable image, NSError * _Nullable error, NSURL * _Nullable imageURL) {
			[self.indicator stopAnimating];
			[self hiddenLoadFailedImageView:(error ? NO:YES)];
			if (!error) { [self processingImageDisplay]; }
		}];
	}
	self.drawingView.hidden = !self.imageObject.isEditor;
	self.doubleGesture.enabled = self.imageObject.isDoubleClickZoom;
}

- (void)processingImageDisplay {
	
	FLAnimatedImage *animatedImage = self.imageView.animatedImage;
	UIImage *image = self.imageView.image;
	BOOL isAnimation = animatedImage;
	
	self.imageObject.GIFImage = animatedImage;
	self.imageObject.image = image;
	
	NSInteger length = isAnimation ? animatedImage.data.length : UIImageJPEGRepresentation(image, 1.0f).length;
	self.imageObject.originSize = [PSImageEditorsHelper fileSizeWithByteSize:length];
	if (self.imageObject.fetchOriginSizeBlock) {
		self.imageObject.fetchOriginSizeBlock(self.imageObject.originSize);
	}
	
	[self.imageObject calculateDisplayContentSize];
	
	if (!isAnimation && self.imageObject.isScaling) {
	   self.imageView.image = [PSImageEditorsHelper imageByScalingToSize:self.imageObject.displayContentSize
													         sourceImage:image];
	}
	
	
	CGRect frame = CGRectMake(0,
							  0,
							  self.imageObject.displayContentSize.width,
							  self.imageObject.displayContentSize.height);
	frame.size.width -= kHorizontalSpacing *0.5;
	frame.origin.x = kHorizontalSpacing;
	
	if (self.imageObject.displayContentSize.height <PS_SCREEN_H) {
		CGFloat offestY = (PS_SCREEN_H - self.imageObject.displayContentSize.height) *0.5;
		frame.origin.y = offestY;
	}
	_imageView.frame = frame;
	_drawingView.frame = _imageView.bounds;
	_scrollView.contentSize = frame.size;
}

- (void)hiddenLoadFailedImageView:(BOOL)hidden {
	
	self.loadFailedView.hidden = hidden;
	if (hidden) {
		[self sendSubviewToBack:self.loadFailedView];
	}else{
		[self bringSubviewToFront:self.loadFailedView];
		self.imageView.image = nil;
		self.imageView.animatedImage = nil;
	}
}

- (void)layoutSubviews {
	
	[super layoutSubviews];
	_scrollView.frame = self.bounds;
	_loadFailedView.frame = self.bounds;
	_indicator.center  = _scrollView.center;
}

- (instancetype)init {
	
	if (self = [super init]) {
		
		_scrollView = [[UIScrollView alloc] init];
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_scrollView.delegate = self;
		_scrollView.minimumZoomScale = kMinimumZoomScale;
		_scrollView.maximumZoomScale = kMaximumZoomScale;
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
		
		_imageView = [[FLAnimatedImageView alloc] init];
		[_scrollView addSubview:_imageView];
		
		_drawingView = [[UIImageView alloc] init];
		_drawingView.contentMode = UIViewContentModeCenter;
		_drawingView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
		[_scrollView addSubview:_drawingView];
		
		_loadFailedView = [[PSImageLoadFailedView alloc] init];
		_loadFailedView.hidden = YES;
		[self sendSubviewToBack:_loadFailedView];
		[self addSubview:_loadFailedView];
		
		_indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		_indicator.hidesWhenStopped = YES;
		[_scrollView addSubview:_indicator];
		[_scrollView bringSubviewToFront:_indicator];
		
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
	
	self.imageView.image = nil;
	self.imageView.animatedImage = nil;
	[self.indicator stopAnimating];
	[self.scrollView setZoomScale:kMinimumZoomScale animated:NO];
	[self hiddenLoadFailedImageView:YES];
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
	
	if (scrollView.zoomScale > kMinimumZoomScale) {
		[scrollView setZoomScale:kMinimumZoomScale animated:YES];
	} else {
		CGPoint touchPoint = [gesture locationInView:self.imageView];
		CGFloat newZoomScale = scrollView.maximumZoomScale;
		CGFloat xsize = scrollView.frame.size.width/newZoomScale;
		CGFloat ysize = scrollView.frame.size.height/newZoomScale;
		[scrollView zoomToRect:CGRectMake(touchPoint.x-xsize/2, touchPoint.y-ysize/2, xsize, ysize) animated:YES];
	}
}

#pragma mark - UIScrollViewDelegate

#pragma mark - 使用捏合手势时，这个方法返回的控件就是需要进行缩放的控件

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	
	return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
	
	CGFloat offsetX = (scrollView.bounds.size.width >scrollView.contentSize.width) ?
			  (scrollView.bounds.size.width -scrollView.contentSize.width)*0.5 : 0.0;
	CGFloat offsetY = (scrollView.bounds.size.height >scrollView.contentSize.height) ?
		        (scrollView.bounds.size.height-scrollView.contentSize.height)*0.5:0.0;
	self.imageView.center = CGPointMake(scrollView.contentSize.width*0.5+offsetX, scrollView.contentSize.height*0.5+offsetY);
}

@end
