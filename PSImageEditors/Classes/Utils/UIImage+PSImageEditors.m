//
//  UIImage+PSImageEditors.m
//  PSImageEditors
//
//  Created by paintingStyle on 2018/8/25.
//

#import "UIImage+PSImageEditors.h"
#import "PSMovingView.h"
#import <AVFoundation/AVFoundation.h>

#define kBitsPerComponent (8)
#define kPixelChannelCount (4)
#define kBitsPerPixel (32)

@implementation UIImage (PSImageEditors)

+ (UIImage *)ps_imageNamed:(NSString *)name {
    
    NSString *bundleName = @"PSImageEditors.bundle";
    UIImage *image = [self imageWithName:name
                        withBundleClass:NSClassFromString(@"_PSImageEditorViewController")
                             bundleName:bundleName];
    return image;
}

+ (UIImage *)imageWithName:(NSString *)name
           withBundleClass:(Class)class
                bundleName:(NSString *)bundleName {
    
    NSBundle *bundle = [self bundleForClass:class withBundleName:bundleName];
    UIImage *image = [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    return image;
}

+ (NSBundle *)bundleForClass:(Class)class withBundleName:(NSString *)name {
    
    NSBundle *frameworkBundle = [NSBundle bundleForClass:class];
    NSURL *kitBundleUrl = [frameworkBundle.resourceURL URLByAppendingPathComponent:name];
    NSBundle *bundle = [NSBundle bundleWithURL:kitBundleUrl];
    return bundle;
}
	
+ (UIImage *)ps_mosaicImage:(UIImage *)image level:(NSInteger)level {
	
	//1、这一部分是为了把原始图片转成位图，位图再转成可操作的数据
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();//颜色通道
	CGImageRef imageRef = image.CGImage;//位图
	CGFloat width = CGImageGetWidth(imageRef);//位图宽
	CGFloat height = CGImageGetHeight(imageRef);//位图高
	CGContextRef context = CGBitmapContextCreate(nil, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast);//生成上下午
	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, width, height), imageRef);//绘制图片到上下文中
	unsigned char *bitmapData = CGBitmapContextGetData(context);//获取位图的数据
	
	
	//2、这一部分是往右往下填充色值
	NSUInteger index,preIndex;
	unsigned char pixel[4] = {0};
	for (int i = 0; i < height; i++) {//表示高，也可以说是行
		for (int j = 0; j < width; j++) {//表示宽，也可以说是列
			index = i * width + j;
			if (i % level == 0) {
				if (j % level == 0) {
					//把当前的色值数据保存一份，开始为i=0，j=0，所以一开始会保留一份
					memcpy(pixel, bitmapData + index * 4, 4);
				}else{
					//把上一次保留的色值数据填充到当前的内存区域，这样就起到把前面数据往后挪的作用，也是往右填充
					memcpy(bitmapData +index * 4, pixel, 4);
				}
			}else{
				//这里是把上一行的往下填充
				preIndex = (i - 1) * width + j;
				memcpy(bitmapData + index * 4, bitmapData + preIndex * 4, 4);
			}
		}
	}
	
	//把数据转回位图，再从位图转回UIImage
	NSUInteger dataLength = width * height * 4;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, bitmapData, dataLength, NULL);
	
	CGImageRef mosaicImageRef = CGImageCreate(width, height,
											  8,
											  32,
											  width*4 ,
											  colorSpace,
											  kCGBitmapByteOrderDefault,
											  provider,
											  NULL, NO,
											  kCGRenderingIntentDefault);
	CGContextRef outputContext = CGBitmapContextCreate(nil,
													   width,
													   height,
													   8,
													   width*4,
													   colorSpace,
													   kCGImageAlphaPremultipliedLast);
	CGContextDrawImage(outputContext, CGRectMake(0.0f, 0.0f, width, height), mosaicImageRef);
	CGImageRef resultImageRef = CGBitmapContextCreateImage(outputContext);
	UIImage *resultImage = nil;
	if([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
		float scale = [[UIScreen mainScreen] scale];
		resultImage = [UIImage imageWithCGImage:resultImageRef scale:scale orientation:UIImageOrientationUp];
	} else {
		resultImage = [UIImage imageWithCGImage:resultImageRef];
	}
	CFRelease(resultImageRef);
	CFRelease(mosaicImageRef);
	CFRelease(colorSpace);
	CFRelease(provider);
	CFRelease(context);
	CFRelease(outputContext);
	return resultImage;
}

+ (UIImage *)ps_screenshot:(UIView *)view imageRect:(CGRect)imageRect {
	
	CGSize targetSize = CGSizeZero;
	
	CGFloat transformScaleX = [[view.layer valueForKeyPath:@"transform.scale.x"] doubleValue];
	CGFloat transformScaleY = [[view.layer valueForKeyPath:@"transform.scale.y"] doubleValue];
	
	if ([view isKindOfClass:[PSMovingView class]]) {
		transformScaleX = ((PSMovingView *)view).transformScaleX;
		transformScaleY = ((PSMovingView *)view).transformScaleY;
	}

	CGSize size = view.bounds.size;
	targetSize = CGSizeMake(size.width * transformScaleX, size.height * transformScaleY);
	
	UIGraphicsBeginImageContext(targetSize);
	//UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0); // 统一为0，方便PC端查看
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSaveGState(ctx);
	[view drawViewHierarchyInRect:CGRectMake(0, 0, targetSize.width, targetSize.height) afterScreenUpdates:NO];
	CGContextRestoreGState(ctx);
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}

- (UIImage *)ps_imageRotatedByRadians:(CGFloat)radians {
	
	//定义一个执行旋转的CGAffineTransform结构体
	CGAffineTransform t = CGAffineTransformMakeRotation(radians);
	//对图片的原始区域执行旋转，获取旋转后的区域
	CGRect rotateRect = CGRectApplyAffineTransform(CGRectMake(0, 0, self.size.width, self.size.height), t);
	//获取图片旋转后的大小
	CGSize rotatedSize = rotateRect.size;
	//创建绘制位图的上下文
	UIGraphicsBeginImageContextWithOptions(rotatedSize, NO, [UIScreen mainScreen].scale);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	//指定坐标变换，将坐标中心平移到图片中心
	CGContextTranslateCTM(ctx, rotatedSize.width/2.0, rotatedSize.height/2.0);
	//执行坐标变换，旋转过radians弧度
	CGContextRotateCTM(ctx, radians);
	CALayer *layer = [CALayer layer];
	
	//执行坐标变换，执行缩放
	CGContextScaleCTM(ctx, 1.0, -1.0);
	//绘制图片
	CGContextDrawImage(ctx, CGRectMake(-self.size.width/2.0, -self.size.height/2.0, self.size.width, self.size.height), self.CGImage);
	//获取绘制后生成的新图片
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

- (UIImage *)ps_decode {
	
	if(!self){  return nil; }
	
	UIImage *decodeImage = nil;
	UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
	[self drawAtPoint:CGPointMake(0, 0)];
	decodeImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return decodeImage;
}

- (UIImage *)ps_imageAtRect:(CGRect)rect {
	
	//把像 素rect 转化为 点rect（如无转化则按原图像素取部分图片）
	CGFloat scale = [UIScreen mainScreen].scale;
	CGFloat x= rect.origin.x*scale,y=rect.origin.y*scale,w=rect.size.width*scale,h=rect.size.height*scale;
	CGRect dianRect = CGRectMake(x, y, w, h);
	
	//截取部分图片并生成新图片
	CGImageRef newImageRef = CGImageCreateWithImageInRect([self CGImage], dianRect);
	UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:scale orientation:self.imageOrientation];
	CGImageRelease(newImageRef);
	return newImage;
}

- (UIImage *)ps_imageCompress {
	
	UIImage *image = self;
	CGFloat imageWidth = image.size.width; // 2268
	CGFloat imageHeight = image.size.height; // 4032
	CGFloat boundary = 1280;
	
	// width, height <= 1280, Size remains the same
	if (imageWidth <= boundary && imageHeight <= boundary) {
		UIImage *reImage = [self resizedImage:imageWidth withHeight:imageHeight withImage:image];
		return reImage;
	}
	
	// aspect ratio
	CGFloat s = MAX(imageWidth, imageHeight) / MIN(imageWidth, imageHeight);
	
	if (s <= 2) {
		// Set the larger value to the boundary, the smaller the value of the compression
		CGFloat x = MAX(imageWidth, imageHeight) / boundary;
		if (imageWidth > imageHeight) {
			imageWidth = boundary ;
			imageHeight = imageHeight / x;
		}else{
			imageHeight = boundary;
			imageWidth = imageWidth / x;
		}
	}else{
		// width, height > 1280
		if (MIN(imageWidth, imageHeight) >= boundary) {
			//- parameter type: session image boundary is 800, timeline is 1280
			// boundary = type == .session ? 800 : 1280
			CGFloat x = MIN(imageWidth, imageHeight) / boundary;
			if (imageWidth < imageHeight) {
				imageWidth = boundary;
				imageHeight = imageHeight / x;
			} else {
				imageHeight = boundary;
				imageWidth = imageWidth / x;
			}
		}
	}
	
	UIImage *reImage = [self resizedImage:imageWidth withHeight:imageHeight withImage:image];
	return reImage;
}

- (UIImage *)resizedImage:(CGFloat)imageWidth
			   withHeight:(CGFloat)imageHeight
				withImage:(UIImage *)image {
	
	CGRect newRect = CGRectMake(0, 0, imageWidth, imageHeight);
	UIImage *newImage;
	UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageWidth, imageHeight), NO, image.scale);
	newImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:image.imageOrientation];
	[newImage drawInRect:newRect];
	newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

@end
