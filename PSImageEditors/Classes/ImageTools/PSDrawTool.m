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
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, strong) PSColorToolBar *colorToolBar;
@property (nonatomic, strong) NSMutableArray<PSDrawPath *> *drawPaths;

@end

@implementation PSDrawTool {
	CGSize _originalImageSize;
}

- (instancetype)initWithImageEditor:(_PSImageEditorViewController *)editor
                         withOption:(NSDictionary *)option {
    
    if (self = [super initWithImageEditor:editor withOption:option]) {
        _drawPaths = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Subclasses Override

- (void)initialize {
    
    if (!_drawingView) {
		_originalImageSize = self.editor.imageView.image.size;
        _drawingView = [[UIImageView alloc] initWithFrame:self.editor.imageView.bounds];
		_drawingView.layer.shouldRasterize = YES;
		_drawingView.layer.minificationFilter = kCAFilterTrilinear;
        [self.editor.imageView addSubview:_drawingView];
    }
}

- (void)resetRect:(CGRect)rect {
	
	_drawingView.image = nil;
    _originalImageSize = self.editor.imageView.image.size;
    _drawingView.frame = self.editor.imageView.bounds;
	[_drawPaths removeAllObjects];
	[self refreshCanUndoButtonState];
}

- (void)setup {
	
	_originalImageSize = self.editor.imageView.image.size;
    _drawingView.frame = self.editor.imageView.bounds;
	
    _drawingView.userInteractionEnabled = YES;
	self.editor.imageView.userInteractionEnabled = YES;
	self.editor.scrollView.panGestureRecognizer.minimumNumberOfTouches = 2;
	self.editor.scrollView.panGestureRecognizer.delaysTouchesBegan = NO;
	self.editor.scrollView.pinchGestureRecognizer.delaysTouchesBegan = NO;
	
	if (!_drawLineColor) {
		_drawLineColor = self.option[kImageToolDrawLineColorKey];
	}
	_drawLineWidth = [self.option[kImageToolDrawLineWidthKey] floatValue];
	
    if (!self.panGesture) {
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drawingViewDidPan:)];
        self.panGesture.maximumNumberOfTouches = 1;
		[_drawingView addGestureRecognizer:self.panGesture];
    }
    if (!self.panGesture.isEnabled) {
        self.panGesture.enabled = YES;
    }
	
    if (!self.colorToolBar) {
        self.colorToolBar = [[PSColorToolBar alloc] initWithType:PSColorToolBarTypeColor];
        self.colorToolBar.delegate = self;
        [self.editor.view addSubview:self.colorToolBar];
        [self.colorToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.editor.bottomToolBar).offset(-64);
            make.left.right.equalTo(self.editor.view);
            make.height.equalTo(@(PSDrawColorToolBarHeight));
        }];
    }
	[self refreshCanUndoButtonState];
    [self.colorToolBar setToolBarShow:YES animation:YES];
}

- (void)cleanup {
	
    _drawingView.userInteractionEnabled = NO;
	self.editor.imageView.userInteractionEnabled = NO;
	self.editor.scrollView.panGestureRecognizer.minimumNumberOfTouches = 1;
    self.panGesture.enabled = NO;
	[self.colorToolBar setToolBarShow:NO animation:NO];
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

- (void)hiddenToolBar:(BOOL)hidden animation:(BOOL)animation {
    
    [self.colorToolBar setToolBarShow:!hidden animation:animation];
}

- (UIImage *)buildImageWithBackgroundImage:(UIImage*)backgroundImage
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
    
    self.colorToolBar.canUndo = _drawPaths.count;
	self.produceChanges = _drawPaths.count;
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
        // 初始化一个UIBezierPath对象, 把起始点存储到UIBezierPath对象中, 用来存储所有的轨迹点
        PSDrawPath *path = [PSDrawPath pathToPoint:currentDraggingPosition pathWidth:MAX(1, self.drawLineWidth)];
        path.pathColor         = self.drawLineColor;
        path.shape.strokeColor = self.drawLineColor.CGColor;
        [_drawPaths addObject:path];
		[self.editor hiddenToolBar:YES animation:YES];
	}
	
	if(sender.state == UIGestureRecognizerStateChanged){
        // 获得数组中的最后一个UIBezierPath对象(因为我们每次都把UIBezierPath存入到数组最后一个,因此获取时也取最后一个)
        PSDrawPath *path = [_drawPaths lastObject];
        [path pathLineToPoint:currentDraggingPosition];//添加点
        [self drawLine];
	}
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self refreshCanUndoButtonState];
		[self.editor hiddenToolBar:NO animation:YES];
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
