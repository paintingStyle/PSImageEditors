//
//  PSDrawingBoard.m
//  PSImageEditors
//
//  Created by rsf on 2018/8/29.
//

#import "PSDrawingBoard.h"
#import "PSImageEditorGestureManager.h"

@interface PSDrawingBoard () {
    __weak UIImageView        *_drawingView;
    CGSize                     _originalImageSize;
}

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation PSDrawingBoard

- (instancetype)init {
    
    if (self = [super init]) {
        _allLineMutableArray = [NSMutableArray new];
    }
    return self;
}


- (void)backToLastDraw {
    
    [_allLineMutableArray removeLastObject];
    [self drawLine];
    if (self.drawToolStatus) {
        self.drawToolStatus(_allLineMutableArray.count > 0 ? : NO);
    }
}

#pragma mark - Gesture
//tap
- (void)drawingViewDidTap:(UITapGestureRecognizer *)sender {
    if (self.drawingDidTap) {
        self.drawingDidTap();
    }
}

//draw
- (void)drawingViewDidPan:(UIPanGestureRecognizer*)sender
{
    CGPoint currentDraggingPosition = [sender locationInView:_drawingView];
    
    if(sender.state == UIGestureRecognizerStateBegan) {
        //取消所有加入文字激活状态
//        for (UIView *subView in self.editor.drawingView.subviews) {
//            if ([subView isKindOfClass:[WBGTextToolView class]]) {
//                [WBGTextToolView setInactiveTextView:(WBGTextToolView *)subView];
//            }
//        }
        
        // 初始化一个UIBezierPath对象, 把起始点存储到UIBezierPath对象中, 用来存储所有的轨迹点
        PSDrawingPath *path = [PSDrawingPath pathToPoint:currentDraggingPosition pathWidth:MAX(1, self.pathWidth)];
        path.pathColor         = self.currentColor;
        path.shape.strokeColor = self.currentColor.CGColor;
        [_allLineMutableArray addObject:path];
        
    }
    
    if(sender.state == UIGestureRecognizerStateChanged) {
        // 获得数组中的最后一个UIBezierPath对象(因为我们每次都把UIBezierPath存入到数组最后一个,因此获取时也取最后一个)
        PSDrawingPath *path = [_allLineMutableArray lastObject];
        [path pathLineToPoint:currentDraggingPosition];//添加点
        [self drawLine];
        
        if (self.drawingCallback) {
            self.drawingCallback(YES);
        }
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.drawToolStatus) {
            self.drawToolStatus(_allLineMutableArray.count > 0 ? : NO);
        }
        
        if (self.drawingCallback) {
            self.drawingCallback(NO);
        }
    }
}

- (void)drawLine {
    CGSize size = _drawingView.frame.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //去掉锯齿
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
    
    for (PSDrawingPath *path in _allLineMutableArray) {
        [path drawPath];
    }
    
    _drawingView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
}

- (UIImage *)buildImage {
    UIGraphicsBeginImageContextWithOptions(_originalImageSize, NO, self.imageView.image.scale);
    [self.imageView.image drawAtPoint:CGPointZero];
    [_drawingView.image drawInRect:CGRectMake(0, 0, _originalImageSize.width, _originalImageSize.height)];
    UIImage *tmp = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tmp;
}

#pragma mark - implementation 重写父方法
- (void)setup {
    //初始化一些东西
    _originalImageSize   = self.imageView.image.size;
    _drawingView         = self.drawingView;
    
    //滑动手势
    if (!self.panGesture) {
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drawingViewDidPan:)];
        self.panGesture.delegate = [PSImageEditorGestureManager instance];
        self.panGesture.maximumNumberOfTouches = 1;
    }
    if (!self.panGesture.isEnabled) {
        self.panGesture.enabled = YES;
    }
    
    //点击手势
    if (!self.tapGesture) {
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(drawingViewDidTap:)];
        self.tapGesture.delegate = [PSImageEditorGestureManager instance];
        self.tapGesture.numberOfTouchesRequired = 1;
        self.tapGesture.numberOfTapsRequired = 1;
        
    }
    
    [_drawingView addGestureRecognizer:self.panGesture];
    [_drawingView addGestureRecognizer:self.tapGesture];
    _drawingView.userInteractionEnabled = YES;
    _drawingView.layer.shouldRasterize = YES;
    _drawingView.layer.minificationFilter = kCAFilterTrilinear;
    
    _drawingView.userInteractionEnabled = YES;
    
//    self.editor.imageView.userInteractionEnabled = YES;
//    self.editor.scrollView.panGestureRecognizer.minimumNumberOfTouches = 2;
//    self.editor.scrollView.panGestureRecognizer.delaysTouchesBegan = NO;
//    self.editor.scrollView.pinchGestureRecognizer.delaysTouchesBegan = NO;
//
    //TODO: todo?
    
}

- (void)cleanup {
//    self.editor.imageView.userInteractionEnabled = NO;
//    self.editor.scrollView.panGestureRecognizer.minimumNumberOfTouches = 1;
    self.panGesture.enabled = NO;
    //TODO: todo?
}

- (void)executeWithCompletionBlock:(void (^)(UIImage *, NSError *, NSDictionary *))completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self buildImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(image, nil, nil);
        });
    });
}



@end


@interface PSDrawingPath()

@property (nonatomic, strong) UIBezierPath *bezierPath;
@property (nonatomic, assign) CGPoint beginPoint;
@property (nonatomic, assign) CGFloat pathWidth;

@end

@implementation PSDrawingPath

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
    
    PSDrawingPath *path   = [[PSDrawingPath alloc] init];
    path.beginPoint = beginPoint;
    path.pathWidth  = pathWidth;
    path.bezierPath = bezierPath;
    path.shape      = shapeLayer;
    
    return path;
}

//曲线
- (void)pathLineToPoint:(CGPoint)movePoint;
{
    //判断绘图类型
    [self.bezierPath addLineToPoint:movePoint];
    self.shape.path = self.bezierPath.CGPath;
}

- (void)drawPath {
    [self.pathColor set];
    [self.bezierPath stroke];
}

@end
