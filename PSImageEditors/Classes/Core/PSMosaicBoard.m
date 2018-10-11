//
//  PSMosaicBoard.m
//  PSImageEditors
//
//  Created by rsf on 2018/9/11.
//

#import "PSMosaicBoard.h"

static const CGFloat kDrawLineWidth = 30.0f;

@interface PSMosaicBoard ()

@property (nonatomic, strong) PSMosaicView *mosaicView;
	
@end

@implementation PSMosaicBoard
	
- (void)setup {
	[super setup];
	
	self.previewView.scrollView.panGestureRecognizer.enabled = NO;
	
    if (!_mosaicView) {
        self.mosaicView = [[PSMosaicView alloc] initWithFrame:self.previewView.drawingView.bounds];
        self.mosaicView.originalImage = self.previewView.imageView.image;
        self.mosaicView.mosaicImage = [UIImage ps_mosaicImage:self.previewView.imageView.image level:20];;
        [self.previewView.drawingView addSubview:self.mosaicView];
		[self.previewView.drawingView sendSubviewToBack:self.mosaicView];
        self.mosaicView.drawEndBlock = self.drawEndBlock;
        // 获取初始值
        if (self.drawEndBlock) {
            self.drawEndBlock([self canUndo]);
        }
    }
}

- (void)changeRectangularMosaic {
	
	 self.mosaicView.mosaicImage = [UIImage ps_mosaicImage:self.previewView.imageView.image level:20];
}

- (void)changeGrindArenaceousMosaic {
	
    // 注意mosaicImage不能为带有alpha通道，否则画出的路径显示为黑色
	self.mosaicView.mosaicImage = [UIImage ps_imageNamed:@"icon_mosaic_mask"];
}

- (void)undo {
	
	[self.mosaicView undo];
}

- (BOOL)canUndo {
    
    return [self.mosaicView canUndo];
}
	
- (void)cleanup {
	[super cleanup];
	self.previewView.scrollView.panGestureRecognizer.enabled = YES;
	self.mosaicView.userInteractionEnabled = NO;
	//[self.mosaicView removeFromSuperview];
}

@end

@interface PSMosaicCache ()

@property (nonatomic, strong) NSMutableArray *cacheArray;
@property (nonatomic, strong) UIImage *originalImage;

@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation PSMosaicCache

- (instancetype)initWithOriginalImage:(UIImage*)image {
	if (!image) return nil;
	if (self = [super init]) {
		_currentIndex = 0;
		_cacheArray = [[NSMutableArray alloc]init];
		[_cacheArray addObject:image];
		_originalImage = image;
	}
	return self;
	
}
- (void)writeImageToCache:(UIImage *)image {
	if (!image) return;
	if (_currentIndex < _cacheArray.count -1) {
		[_cacheArray removeObjectsInRange:NSMakeRange(_currentIndex+1 , _cacheArray.count - 1 - _currentIndex)];
	}
	[_cacheArray addObject:image];
	_currentIndex++;
}

- (void)removeImageAtIndex:(NSInteger)index {
    
    if (index <= self.cacheArray.count-1) {
        [self.cacheArray removeObjectAtIndex:index];
    }
}

- (UIImage *)previousImage {
	if (_currentIndex - 1 >= 0) {
        _currentIndex--;
		return _cacheArray[_currentIndex];
	}
	return nil;
}

- (void)clear {
	[self.cacheArray removeAllObjects];
	_currentIndex = 0;
}

@end


@interface PSMosaicView ()
	
//存放顶层图片的UIImageView，图片为正常的图片
@property (nonatomic, strong) UIImageView *topImageView;

//展示马赛克图片的涂层
@property (nonatomic, strong) CALayer *mosaicImageLayer;

//遮罩层，用于设置形状路径
@property (nonatomic, strong) CAShapeLayer *shapeLayer;

//手指涂抹的路径
@property (nonatomic, assign) CGMutablePathRef path;

//当前绘制的信息
@property (nonatomic, strong) PSMosaicPath *currentPath;

//绘制路径
@property (nonatomic, strong) NSMutableArray *pathArray;

//每一次作图后的马赛克图
@property (nonatomic ,strong) UIImage *mosaiFinalImage;

@property (nonatomic,strong) PSMosaicCache *mosaicCache;

@end

@implementation PSMosaicView
	
- (void)dealloc{
	if (self.path) {
		CGPathRelease(self.path);
	}
	[self.mosaicCache clear];
}

- (instancetype)initWithFrame:(CGRect)frame{
	self = [super initWithFrame:frame];
	if (self) {
		
		_currentPath = [[PSMosaicPath alloc]init];
		_pathArray = [[NSMutableArray alloc]init];
		
		
		//初始化顶层图片视图
		self.topImageView = [[UIImageView alloc] initWithFrame:self.bounds];
		[self addSubview:self.topImageView];
		
	}
	return self;
}

- (void)setOriginalImage:(UIImage *)originalImage{
	_originalImage  = originalImage;//原始图片
	self.topImageView.image = originalImage;//顶层视图展示原始图片
	self.mosaiFinalImage = originalImage;
	self.mosaicCache = [[PSMosaicCache alloc] initWithOriginalImage:originalImage];
	
}

- (void)setMosaicImage:(UIImage *)mosaicImage{
	_mosaicImage = mosaicImage;//马赛克图片
	[self resetMosaiImage];
}

//重新设置马赛克
-(void)resetMosaiImage{
	//重新设置Layer与Path
	if (self.path) {
		CGPathRelease(self.path);
		self.path = nil;
	}
	self.path = CGPathCreateMutable();
	self.topImageView.image = _mosaiFinalImage;
	
	//移除轨迹
	[self.pathArray removeAllObjects];
	[_currentPath resetStatus];
	
	[self.shapeLayer removeFromSuperlayer];
	self.shapeLayer = nil;
	
	[self.mosaicImageLayer removeFromSuperlayer];
	self.mosaicImageLayer = nil;
	
	
	self.mosaicImageLayer = [CALayer layer];
	self.mosaicImageLayer.frame  = self.bounds;
	[self.layer addSublayer:self.mosaicImageLayer];
	self.mosaicImageLayer.contents = (__bridge id _Nullable)([self.mosaicImage CGImage]);//将马赛克图层内容设置为马赛克图片内容
	
	
	//初始化遮罩图层
	self.shapeLayer = [CAShapeLayer layer];
	self.shapeLayer.frame = self.bounds;
	self.shapeLayer.lineCap = kCALineCapRound;
	self.shapeLayer.lineJoin = kCALineJoinRound;
	self.shapeLayer.lineWidth = kDrawLineWidth;
	self.shapeLayer.strokeColor = [[UIColor blueColor] CGColor];
	self.shapeLayer.fillColor = nil;
	[self.layer addSublayer:self.shapeLayer];
	self.mosaicImageLayer.mask = self.shapeLayer;
	
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	CGPathMoveToPoint(self.path, NULL, point.x, point.y);
	CGMutablePathRef path = CGPathCreateMutableCopy(self.path);
	self.shapeLayer.path = path;
	CGPathRelease(path);
	
	
	CGSize size = self.topImageView.image.size;
	CGFloat rate = size.width/self.topImageView.bounds.size.width;
	_currentPath.startPoint = CGPointMake(point.x * rate, point.y * rate);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event];
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	CGPathAddLineToPoint(self.path, NULL, point.x, point.y);
	CGMutablePathRef path = CGPathCreateMutableCopy(self.path);
	self.shapeLayer.path = path;
	CGPathRelease(path);
	
	
	CGSize size = self.topImageView.image.size;
	CGFloat rate = size.width/self.topImageView.bounds.size.width;
	PSMosaicPathPoint *pointPath = [[PSMosaicPathPoint alloc]init];
	pointPath.xPoint = point.x * rate;
	pointPath.yPoint = point.y * rate;
	[_currentPath.pathPointArray addObject:pointPath];
}


-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
	[super touchesMoved:touches withEvent:event];
	
	//画完之后需要保存一张原图,因为做多层马赛克的话，就是在上一次马赛克画笔之后的图作为原图，后面再叠加一层
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	CGSize size = self.topImageView.image.size;
	CGFloat rate = size.width/self.topImageView.bounds.size.width;
	_currentPath.endPoint = CGPointMake(point.x * rate, point.y * rate);
	
	
	PSMosaicPath *path = [_currentPath copy];
	[_pathArray addObject:path];
	[_currentPath resetStatus];
	
	UIGraphicsBeginImageContext(size);
	[self.topImageView.image drawInRect:CGRectMake(0, 0, size.width, size.height)];
	for (PSMosaicPath *path in _pathArray) {
		
		CGContextMoveToPoint(UIGraphicsGetCurrentContext(), path.startPoint.x, path.startPoint.y);
		CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), path.startPoint.x, path.startPoint.y);
		
		for (PSMosaicPathPoint *point in path.pathPointArray) {
			CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), point.xPoint, point.yPoint);
		}
		
	}
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, true); //去掉锯齿
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetLineWidth(context, kDrawLineWidth * rate);
	CGContextSetBlendMode(context, kCGBlendModeClear);
	CGContextStrokePath(context);
    
	UIImage *finalPath = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	UIGraphicsBeginImageContextWithOptions(size, YES, 1.0);

	[self.mosaicImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
	[finalPath drawInRect:CGRectMake(0, 0, size.width, size.height)];
	_mosaiFinalImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	//写入缓存
	[self.mosaicCache writeImageToCache:_mosaiFinalImage];
	
	if (self.drawEndBlock) {
		self.drawEndBlock([self canUndo]);
	}
}

- (void)undo {
    
	UIImage *image = [self.mosaicCache previousImage];
    if (!image) { return; }
	self.mosaiFinalImage = image;
	[self resetMosaiImage];
    [self.mosaicCache removeImageAtIndex:self.mosaicCache.cacheArray.count-1];
}

- (BOOL)canUndo{
	if (self.mosaicCache.currentIndex > 0) {
		return YES;
	}
	return NO;
}

@end


@implementation PSMosaicPath

- (instancetype)init
{
	self = [super init];
	if (self) {
		_startPoint = CGPointZero;
		_endPoint = CGPointZero;
		_pathPointArray = [[NSMutableArray alloc]init];
	}
	return self;
}


-(void)resetStatus{
	_startPoint = CGPointZero;
	_endPoint = CGPointZero;
	[_pathPointArray removeAllObjects];
}


- (id)copyWithZone:(NSZone *)zone
{
	PSMosaicPath *obj = [[[self class] allocWithZone:zone] init];
	obj.pathPointArray = [self.pathPointArray copyWithZone:zone];
	obj.startPoint = self.startPoint;
	obj.endPoint = self.endPoint;
	
	return obj;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
	PSMosaicPath *obj = [[[self class] allocWithZone:zone] init];
	obj.pathPointArray = [self.pathPointArray copyWithZone:zone];
	obj.startPoint = self.startPoint;
	obj.endPoint = self.endPoint;
	return obj;
}

@end


@implementation PSMosaicPathPoint

- (instancetype)init {
	self = [super init];
	if (self) {
		_xPoint = _yPoint = 0;
	}
	return self;
}

@end

