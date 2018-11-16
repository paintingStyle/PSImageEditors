//
//  PSDrawTool.m
//  PSImageEditors
//
//  Created by rsf on 2018/11/16.
//

#import "PSDrawTool.h"
#import "PSColorToolBar.h"

@interface PSDrawTool()<PSColorToolBarDelegate>

@property (nonatomic, assign) CGFloat drawLineWidth;
@property (nonatomic, strong) UIColor *drawLineColor;

@end

@implementation PSDrawTool {
	UIImageView *_drawingView;
	CGSize _originalImageSize;
	CGPoint _prevDraggingPosition;
	PSColorToolBar *_colorToolBar;
    NSMutableArray<PSDrawPath *> *_drawPaths;
}

- (instancetype)initWithImageEditor:(_PSImageEditorViewController *)editor
                         withOption:(NSDictionary *)option {
    
    if (self = [super initWithImageEditor:editor withOption:option]) {
        _drawPaths = [NSMutableArray array];
    }
    return self;
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
    _colorToolBar.delegate = self;
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

- (void)undoToLastDraw {
    
    if (!_drawPaths.count) { return; }
    [_drawPaths removeLastObject];
    [self drawLine];
    [self refreshCanUndoButtonState];
}

- (void)refreshCanUndoButtonState {
    
    _colorToolBar.canUndo = _drawPaths.count;
}

#pragma mark - PSColorToolBarDelegate

- (void)colorToolBar:(PSColorToolBar *)toolBar event:(PSColorToolBarEvent)event {
    
    switch (event) {
        case PSColorToolBarEventSelectColor:
            _drawLineColor = toolBar.currentColor;
            break;
        case PSColorToolBarEventUndo:
            [self undoToLastDraw];
            break;
        default:
            break;
    }
}

#pragma mark - 根据手势路径画线

- (void)drawingViewDidPan:(UIPanGestureRecognizer*)sender {
	
	CGPoint currentDraggingPosition = [sender locationInView:_drawingView];
	
	if(sender.state == UIGestureRecognizerStateBegan){
		_prevDraggingPosition = currentDraggingPosition;
        // 初始化一个UIBezierPath对象, 把起始点存储到UIBezierPath对象中, 用来存储所有的轨迹点
        PSDrawPath *path = [PSDrawPath pathToPoint:currentDraggingPosition pathWidth:MAX(1, self.drawLineWidth)];
        path.pathColor         = self.drawLineColor;
        path.shape.strokeColor = self.drawLineColor.CGColor;
        [_drawPaths addObject:path];
	}
	
	if(sender.state == UIGestureRecognizerStateChanged){
        // 获得数组中的最后一个UIBezierPath对象(因为我们每次都把UIBezierPath存入到数组最后一个,因此获取时也取最后一个)
        PSDrawPath *path = [_drawPaths lastObject];
        [path pathLineToPoint:currentDraggingPosition];//添加点
        [self drawLine];
	}
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self refreshCanUndoButtonState];
    }
}

- (void)drawLine {
    
    CGSize size = _drawingView.frame.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //去掉锯齿
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
    
    for (PSDrawPath *path in _drawPaths) {
        [path drawPath];
    }
    _drawingView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
}

@end

@interface PSDrawPath()

@property (nonatomic, strong) UIBezierPath *bezierPath;
@property (nonatomic, assign) CGPoint beginPoint;
@property (nonatomic, assign) CGFloat pathWidth;

@end

@implementation PSDrawPath

+ (instancetype)pathToPoint:(CGPoint)beginPoint pathWidth:(CGFloat)pathWidth {
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    bezierPath.lineWidth     = pathWidth;
    bezierPath.lineCapStyle  = kCGLineCapRound;
    bezierPath.lineJoinStyle = kCGLineJoinRound;
    [bezierPath moveToPoint:beginPoint];
    
    
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineWidth = pathWidth;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.path = bezierPath.CGPath;
    
    PSDrawPath *path   = [[PSDrawPath alloc] init];
    path.beginPoint = beginPoint;
    path.pathWidth  = pathWidth;
    path.bezierPath = bezierPath;
    path.shape      = shapeLayer;
    
    return path;
}

- (void)pathLineToPoint:(CGPoint)movePoint {
  
    [self.bezierPath addLineToPoint:movePoint];
    self.shape.path = self.bezierPath.CGPath;
}

- (void)drawPath {
    
    [self.pathColor set];
    [self.bezierPath stroke];
}

@end
