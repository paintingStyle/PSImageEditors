//
//  PSSmearBrush.m
//  PSImageEditors
//
//  Created by rsf on 2020/8/24.
//

#import "PSSmearBrush.h"
#import "PSBrush+PSCreate.h"
#import "PSBrushCache.h"

NSString *const PSSmearBrushImage = @"PSSmearBrushImage";
NSString *const PSSmearBrushName = @"PSSmearBrushName";

NSString *const PSSmearBrushPoints = @"PSSmearBrushPoints";

// points sub data
NSString *const PSSmearBrushPoint = @"PSSmearBrushPoint";
NSString *const PSSmearBrushAngle = @"PSSmearBrushAngle";
NSString *const PSSmearBrushColor = @"PSSmearBrushColor";

@interface PSSmearBrush (color)

@end

@implementation PSSmearBrush (color)

#pragma mark - 获取屏幕的颜色块
- (UIColor *)colorOfPoint:(CGPoint)point
{
    UIImage *cacheImage = [[PSBrushCache share] objectForKey:PSSmearBrushImage];
    
	if (!cacheImage) {
		NSLog(@"call PSSmearBrush loadBrushImage:canvasSize:useCache:complete: method.");
	}
    
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, cacheImage.size.width, cacheImage.size.height), point)) {
        return nil;
    }
    UIColor *color = nil;
    @autoreleasepool {
        
        NSUInteger width = cacheImage.size.width;
        NSUInteger height = cacheImage.size.height;
        
        unsigned char pixel[4] = {0};
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(pixel,
                                                     1, 1, 8, 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        CGColorSpaceRelease(colorSpace);
        CGContextSetBlendMode(context, kCGBlendModeCopy);
        CGContextTranslateCTM(context, -point.x, point.y-(CGFloat)height);
        
//        [[[UIApplication sharedApplication] keyWindow].layer renderInContext:context];
        CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cacheImage.CGImage);
        
        CGContextRelease(context);
        color = [UIColor colorWithRed:pixel[0]/255.0
                                green:pixel[1]/255.0 blue:pixel[2]/255.0
                                alpha:pixel[3]/255.0];
    }
    
    return color;
}

@end

@interface PSSmearBrush ()

@property (nonatomic, copy) NSString *name;

@property (nonatomic, weak) CALayer *layer;

@property (nonatomic, strong) NSMutableArray <NSDictionary *>*points;

@end

@implementation PSSmearBrush

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.level = 5;
        self.lineWidth = 100;
    }
    return self;
}

- (instancetype)initWithImageName:(NSString *)name;
{
    self = [self init];
    if (self) {
        _name = name;
    }
    return self;
}

+ (void)loadBrushImage:(UIImage *)image canvasSize:(CGSize)canvasSize useCache:(BOOL)useCache complete:(void (^ _Nullable )(BOOL success))complete
{
    if (!useCache) {
        [[PSBrushCache share] removeObjectForKey:PSSmearBrushImage];
    }
    UIImage *cacheImage = [[PSBrushCache share] objectForKey:PSSmearBrushImage];
    if (cacheImage) {
        if (complete) {
            complete(YES);
        }
        return;
    }
    if (image) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            UIImage *patternImage = [image patternGaussianImageWithSize:canvasSize filterHandler:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (patternImage) {
                    [[PSBrushCache share] setForceObject:patternImage forKey:PSSmearBrushImage];
                }
                
                if (complete) {
                    complete((BOOL)patternImage);
                }
            });
        });
    } else {
        if (complete) {
            complete(NO);
        }
    }
}

+ (BOOL)smearBrushCache
{
    UIImage *cacheImage = [[PSBrushCache share] objectForKey:PSSmearBrushImage];
    return (BOOL)cacheImage;
}

- (void)addPoint:(CGPoint)point
{
    [super addPoint:point];
    
    UIImage *image = [[self class] cacheImageWithName:self.name bundle:self.bundle];
    
    CGFloat angle = PSBrushAngleBetweenPoint(self.previousPoint, point);
    // 调整角度，顺着绘画方向。
    angle = 360-angle;
    // 随机坐标
    point.x += floorf(arc4random()%((int)(image.size.width)+1)) - image.size.width/2;
    point.y += floorf(arc4random()%((int)(image.size.height)+1)) - image.size.width/2;
    
    //转换屏幕坐标，获取颜色块
    UIColor *color = nil;
    UIView *drawView = (UIView *)self.layer.superlayer.delegate;
    if ([drawView isKindOfClass:[UIView class]]) {
//        CGPoint screenPoint = [drawView convertPoint:point toView:[UIApplication sharedApplication].keyWindow];
        color = [self colorOfPoint:point];
    }

    CALayer *subLayer = [[self class] createSubLayerWithImage:image lineWidth:self.lineWidth point:point angle:angle color:color];
    
    [self.layer addSublayer:subLayer];
    
    // 记录坐标数据
    NSMutableDictionary *pointDict = [NSMutableDictionary dictionaryWithCapacity:2];
    [pointDict setObject:NSStringFromCGPoint(point) forKey:PSSmearBrushPoint];
    [pointDict setObject:@(angle) forKey:PSSmearBrushAngle];
    
    if (color) {
        [pointDict setObject:color forKey:PSSmearBrushColor];
    }
    [self.points addObject:pointDict];
}

- (CALayer *)createDrawLayerWithPoint:(CGPoint)point
{
    [super createDrawLayerWithPoint:point];
    _points = [NSMutableArray array];
    
    CALayer *layer = [[self class] createLayer];
    layer.ps_level = self.level;
    self.layer = layer;
    return layer;
}

- (NSDictionary *)allTracks
{
    NSDictionary *superAllTracks = [super allTracks];
    
    NSMutableDictionary *myAllTracks = nil;
    if (superAllTracks && self.points.count) {
        myAllTracks = [NSMutableDictionary dictionary];
        [myAllTracks addEntriesFromDictionary:superAllTracks];
        [myAllTracks addEntriesFromDictionary:@{
                                                PSSmearBrushPoints:self.points,
                                                PSSmearBrushName:self.name
                                                }];
    }
    return myAllTracks;
}

+ (CALayer *__nullable)drawLayerWithTrackDict:(NSDictionary *)trackDict
{
    CGFloat lineWidth = [trackDict[PSBrushLineWidth] floatValue];
//    NSArray <NSString /*CGPoint*/*>*allPoints = trackDict[PSBrushAllPoints];
    NSArray <NSDictionary *>*points = trackDict[PSSmearBrushPoints];
    NSString *name = trackDict[PSSmearBrushName];
    NSBundle *bundle = trackDict[PSBrushBundle];
    
    if (points.count > 0) {
        CALayer *layer = [[self class] createLayer];
        UIImage *image = [[self class] cacheImageWithName:name bundle:bundle];
        NSDictionary *pointDict = nil;
        for (NSInteger i=0; i<points.count; i++) {
            
            pointDict = points[i];
            
            CGPoint point = CGPointFromString(pointDict[PSSmearBrushPoint]);
            
            CGFloat angle = [pointDict[PSSmearBrushAngle] floatValue];
            
            UIColor *color = pointDict[PSSmearBrushColor];
            
            CALayer *subLayer = [[self class] createSubLayerWithImage:image lineWidth:lineWidth point:point angle:angle color:color];
            
            [layer addSublayer:subLayer];
        }
        return layer;
    }
    return nil;
}

#pragma mark - private
+ (UIImage *)cacheImageWithName:(NSString *)name bundle:(NSBundle *)bundle
{
    if (0==name.length) return nil;
    
    PSBrushCache *imageCache = [PSBrushCache share];
    UIImage *image = [imageCache objectForKey:name];
    if (image) {
        return image;
    }
    
    if (image == nil) {
		if (!name) {
			NSLog(@"PSSmearBrush name is nil.");
		}
		
        if (bundle) {
            /**
             framework内部加载
             */
            image = [UIImage imageWithContentsOfFile:[bundle pathForResource:name ofType:nil]];
        } else {
            /**
             framework外部加载
             */
            image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:nil]];
        }
    }
    
    if (image) {
        @autoreleasepool {
            //redraw image using device context
            UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
            [image drawAtPoint:CGPointZero];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        [imageCache setObject:image forKey:name];
    }
    
    return image;
}

+ (CALayer *)createLayer
{
    CALayer *layer = [CALayer layer];
    layer.contentsScale = [UIScreen mainScreen].scale;
    return layer;
}

+ (CALayer *)createSubLayerWithImage:(UIImage *)image lineWidth:(CGFloat)lineWidth point:(CGPoint)point angle:(CGFloat)angle color:(UIColor *)color
{
    if (image == nil) return nil;
    
    CGFloat height = lineWidth;
    CGSize size = CGSizeMake(image.size.width*height/image.size.height, height);
    CGRect rect = CGRectMake(point.x-size.width/2, point.y-size.height/2, size.width, size.height);
    
    CALayer *subLayer = [CALayer layer];
    subLayer.frame = rect;
    subLayer.contentsScale = [UIScreen mainScreen].scale;
    subLayer.contentsGravity = kCAGravityResizeAspect;
    subLayer.contents = (__bridge id _Nullable)(image.CGImage);
    
    if (color) {
        CALayer *markLayer = [CALayer layer];
        markLayer.frame = rect;
        markLayer.contentsScale = [UIScreen mainScreen].scale;
        markLayer.backgroundColor = color.CGColor;
        subLayer.frame = markLayer.bounds;
        
        markLayer.transform = CATransform3DMakeRotation((angle * M_PI / 180.0), 0, 0, 1);
        markLayer.mask = subLayer;
        markLayer.masksToBounds = YES;
        
        return markLayer;
    }
    subLayer.transform = CATransform3DMakeRotation((angle * M_PI / 180.0), 0, 0, 1);
    
    return subLayer;
}

@end

