//
//  PSPreviewImageView.m
//  PSImageEditors
//
//  Created by rsf on 2018/8/29.
//

#import "PSPreviewImageView.h"
#import "PSImageObject.h"

@interface PSPreviewImageView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *containerView;

@end

@implementation PSPreviewImageView

- (void)setImage:(UIImage *)image {
	
	_image = image;
	if ([image isKindOfClass:[FLAnimatedImage class]]) {
		self.imageView.animatedImage = (FLAnimatedImage *)image;
	}else {
		self.imageView.image = image;
	}
}

- (instancetype)init {
	
	if (self = [super init]) {
		
		_scrollView = [[UIScrollView alloc] init];
		_scrollView.delegate = self;
		_scrollView.minimumZoomScale = 1.0;
		_scrollView.maximumZoomScale = 3.0f;
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
		
		// 在UIViewContentModeScaleAspectFit之后，获取已经调整大小图像的宽度
		//imageView.clipsToBounds = true
		// TODO: 需要计算_imageView的大小，动态调整_containerView的高度
		_imageView = [[FLAnimatedImageView alloc] initWithFrame:CGRectZero];
		_imageView.contentMode = UIViewContentModeScaleAspectFit;
		[_containerView addSubview:_imageView];
		[_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
			
			make.left.top.right.equalTo(self.containerView);
			make.height.equalTo(@(PS_SCREEN_H));
		}];
		
		[_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
			make.bottom.equalTo(self.imageView);
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

- (void)longGestureDidClick:(UIGestureRecognizer *)gesture {
	
	if (gesture.state != UIGestureRecognizerStateBegan) { return; }
	if (self.longGestureDidClickBlock) {
		self.longGestureDidClickBlock();
	}
}
#pragma mark - 单击手势点击事件

- (void)singleGestureClicked {
	
	if (self.singleGestureDidClickBlock) {
		self.singleGestureDidClickBlock();
	}
}

- (CGFloat)maxScale {
	
	// TODO:此处计算有误
//	CGFloat imageHeight = self.imageObject.displayContentSize.height /self.imageObject.displayContentSize.width *CGRectGetWidth(self.contentView.frame);
//	CGFloat maxScale =  CGRectGetHeight(self.contentView.frame) / imageHeight;
//	//if (maxScale == 1) { maxScale = 3; }
	
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

@end
