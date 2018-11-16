//
//  PSDrawTool.m
//  PSImageEditors
//
//  Created by rsf on 2018/11/16.
//

#import "PSDrawTool.h"
#import "PSColorToolBar.h"

@interface PSDrawTool()

@property (nonatomic, assign) CGFloat drawLineWidth;
@property (nonatomic, strong) UIColor *drawLineColor;

@end

@implementation PSDrawTool {
	UIImageView *_drawingView;
	CGSize _originalImageSize;
	CGPoint _prevDraggingPosition;
	PSColorToolBar *_colorToolBar;
}

#pragma mark - Subclasses Override

- (void)setup {
	
	_originalImageSize = self.editor.imageView.image.size;
	_drawingView = [[UIImageView alloc] initWithFrame:self.editor.imageView.bounds];
	
	_drawLineColor = self.option[kImageToolDrawLineColorKey];
	_drawLineWidth = [self.option[kImageToolDrawLineWidthKey] floatValue];
	
	UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drawingViewDidPan:)];
	panGesture.maximumNumberOfTouches = 1;
	
	_drawingView.userInteractionEnabled = YES;
	[_drawingView addGestureRecognizer:panGesture];
	
	[self.editor.imageView addSubview:_drawingView];
	self.editor.imageView.userInteractionEnabled = YES;
	self.editor.scrollView.panGestureRecognizer.minimumNumberOfTouches = 2;
	self.editor.scrollView.panGestureRecognizer.delaysTouchesBegan = NO;
	self.editor.scrollView.pinchGestureRecognizer.delaysTouchesBegan = NO;
	
	_colorToolBar = [[PSColorToolBar alloc] initWithEditorMode:PSImageEditorModeDraw];
	_colorToolBar.viewController = self.editor;
	[self.editor.view addSubview:_colorToolBar];
	
	[_colorToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
		make.bottom.equalTo(self.editor.bootomToolBar.mas_top);
		make.left.right.equalTo(self.editor.view);
		make.height.equalTo(@(PSColorToolBarHeight));
	}];

	_colorToolBar.alpha = 0.2;
	[UIView animateWithDuration:kImageToolAnimationDuration
					 animations:^{
						 _colorToolBar.alpha = 1;
					 }
	 ];
}

- (void)cleanup {
	
	[_drawingView removeFromSuperview];
	[_colorToolBar removeFromSuperview];
	self.editor.imageView.userInteractionEnabled = NO;
	self.editor.scrollView.panGestureRecognizer.minimumNumberOfTouches = 1;
}

- (void)executeWithCompletionBlock:(void (^)(UIImage *, NSError *, NSDictionary *))completionBlock {
	
	UIImage *backgroundImage = self.editor.imageView.image;
	UIImage *foregroundImage = _drawingView.image;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		UIImage *image = [self buildImageWithBackgroundImage:backgroundImage foregroundImage:foregroundImage];
		dispatch_async(dispatch_get_main_queue(), ^{
			completionBlock(image, nil, nil);
		});
	});
}

- (UIImage*)buildImageWithBackgroundImage:(UIImage*)backgroundImage
						  foregroundImage:(UIImage*)foregroundImage {
	
	UIGraphicsBeginImageContextWithOptions(_originalImageSize, NO, backgroundImage.scale);
	[backgroundImage drawAtPoint:CGPointZero];
	[foregroundImage drawInRect:CGRectMake(0, 0, _originalImageSize.width, _originalImageSize.height)];
	UIImage *tmp = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return tmp;
}

#pragma mark - 根据手势路径画线

- (void)drawingViewDidPan:(UIPanGestureRecognizer*)sender {
	
	CGPoint currentDraggingPosition = [sender locationInView:_drawingView];
	
	if(sender.state == UIGestureRecognizerStateBegan){
		_prevDraggingPosition = currentDraggingPosition;
	}
	
	if(sender.state != UIGestureRecognizerStateEnded){
		[self drawLine:_prevDraggingPosition to:currentDraggingPosition];
	}
	_prevDraggingPosition = currentDraggingPosition;
}

-(void)drawLine:(CGPoint)from to:(CGPoint)to {
	
	CGSize size = _drawingView.frame.size;
	UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	[_drawingView.image drawAtPoint:CGPointZero];
	
	CGFloat strokeWidth = MAX(1, self.drawLineWidth);
	UIColor *strokeColor = self.drawLineColor;
	
	CGContextSetLineWidth(context, strokeWidth);
	CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextMoveToPoint(context, from.x, from.y);
	CGContextAddLineToPoint(context, to.x, to.y);
	CGContextStrokePath(context);
	
	_drawingView.image = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
}

@end
