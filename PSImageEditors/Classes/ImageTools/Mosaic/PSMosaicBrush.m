//
//  PSMosaicBrush.m
//  PSImageEditors
//
//  Created by rsf on 2020/8/24.
//

#import "PSMosaicBrush.h"
#import "PSBrush+PSCreate.h"
#import "PSBrushCache.h"

NSString *const PSMosaicBrushImageColor = @"PSMosaicBrushImageColor";

@interface PSMosaicBrush ()

@end

@implementation PSMosaicBrush

@synthesize lineColor = _lineColor;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self->_lineColor = nil;
        self.level = 5;
        self.lineWidth = 25;
    }
    return self;
}

- (void)setLineColor:(UIColor *)lineColor
{
	NSLog(@"PSMosaicBrush cann't set line color.");
}

- (UIColor *)lineColor
{
    UIColor *color = [[PSBrushCache share] objectForKey:PSMosaicBrushImageColor];
	if (!color) {
		NSLog(@"call PSMosaicBrush loadBrushImage:scale:canvasSize:useCache:complete: method.");
	}
    return color;
}

+ (CALayer *__nullable)drawLayerWithTrackDict:(NSDictionary *)trackDict
{
    UIColor *lineColor = trackDict[PSPaintBrushLineColor];
    if (lineColor) {
        [[PSBrushCache share] setForceObject:lineColor forKey:PSMosaicBrushImageColor];
    }
    return [super drawLayerWithTrackDict:trackDict];
    
}

+ (void)loadBrushImage:(UIImage *)image scale:(CGFloat)scale canvasSize:(CGSize)canvasSize useCache:(BOOL)useCache complete:(void (^ _Nullable )(BOOL success))complete
{
    if (!useCache) {
        [[PSBrushCache share] removeObjectForKey:PSMosaicBrushImageColor];
    }
    UIColor *color = [[PSBrushCache share] objectForKey:PSMosaicBrushImageColor];
    if (color) {
        if (complete) {
            complete(YES);
        }
        return;
    }
    if (image) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            UIColor *patternColor = [image patternGaussianColorWithSize:canvasSize filterHandler:^CIFilter *(CIImage *ciimage) {
                //高斯模糊滤镜
                CIFilter *filter = [CIFilter filterWithName:@"CIPixellate"];
                [filter setDefaults];
                [filter setValue:ciimage forKey:kCIInputImageKey];
                //value 改变马赛克的大小
                [filter setValue:@(scale) forKey:kCIInputScaleKey];
                return filter;
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (patternColor) {
                    [[PSBrushCache share] setForceObject:patternColor forKey:PSMosaicBrushImageColor];
                }
                
                if (complete) {
                    complete((BOOL)patternColor);
                }
            });
        });
    } else {
        if (complete) {
            complete(NO);
        }
    }
}

+ (BOOL)mosaicBrushCache
{
    UIColor *color = [[PSBrushCache share] objectForKey:PSMosaicBrushImageColor];
    return (BOOL)color;
}

@end
