//
//  UIImage+PSImageEditors.m
//  PSImageEditors
//
//  Created by paintingStyle on 2018/8/25.
//

#import "UIImage+PSImageEditors.h"

@implementation UIImage (PSImageEditors)

+ (UIImage *)ps_imageNamed:(NSString *)name {
    
    NSString *bundleName = @"PSImageEditors.bundle";
    UIImage *image = [self imageWithName:name
                        withBundleClass:NSClassFromString(@"PSPreviewViewController")
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
	
//	CGImageRef imageRef = image.CGImage;
//	NSUInteger imageW = CGImageGetWidth(imageRef);
//	NSUInteger imageH = CGImageGetHeight(imageRef);
//	//创建颜色空间
//	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//	unsigned char *rawData = (unsigned char *)calloc(imageH*imageW*4, sizeof(unsigned char));
//	CGContextRef contextRef = CGBitmapContextCreate(rawData, imageW, imageH, 8, imageW*4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
//	CGContextDrawImage(contextRef, CGRectMake(0, 0, imageW, imageH), imageRef);
//
//	unsigned char *bitMapData = CGBitmapContextGetData(contextRef);
//	NSUInteger currentIndex,preCurrentIndex;
//	NSUInteger sizeLevel = level == 0 ? MIN(imageW, imageH)/40.0 : level;
//	//像素点默认是4个通道
//	unsigned char *pixels[4] = {0};
//	for (int i = 0; i < imageH; i++) {
//		for (int j = 0; j < imageW; j++) {
//			currentIndex = imageW*i + j;
//			NSUInteger red = rawData[currentIndex*4];
//			NSUInteger green = rawData[currentIndex*4+1];
//			NSUInteger blue = rawData[currentIndex*4+2];
//			NSUInteger alpha = rawData[currentIndex*4+3];
//			if (red+green+blue == 0 && (alpha/255.0 <= 0.5)) {
//				rawData[currentIndex*4] = 255;
//				rawData[currentIndex*4+1] = 255;
//				rawData[currentIndex*4+2] = 255;
//				rawData[currentIndex*4+3] = 0;
//				continue;
//			}
//			/*
//			 memcpy指的是c和c++使用的内存拷贝函数，memcpy函数的功能是从源src所指的内存地址的起始位置开始拷贝n个字节到目标dest所指的内存地址的起始位置中。
//			 strcpy和memcpy主要有以下3方面的区别。
//			 1、复制的内容不同。strcpy只能复制字符串，而memcpy可以复制任意内容，例如字符数组、整型、结构体、类等。
//			 2、复制的方法不同。strcpy不需要指定长度，它遇到被复制字符的串结束符"\0"才结束，所以容易溢出。memcpy则是根据其第3个参数决定复制的长度。
//			 3、用途不同。通常在复制字符串时用strcpy，而需要复制其他类型数据时则一般用memcpy
//			 */
//			if (i % sizeLevel == 0) {
//				if (j % sizeLevel == 0) {
//					memcpy(pixels, bitMapData+4*currentIndex, 4);
//				}else{
//					//将上一个像素点的值赋给第二个
//					memcpy(bitMapData+4*currentIndex, pixels, 4);
//				}
//			}else{
//				preCurrentIndex = (i-1)*imageW+j;
//				memcpy(bitMapData+4*currentIndex, bitMapData+4*preCurrentIndex, 4);
//			}
//		}
//	}
//	//获取图片数据集合
//	NSUInteger size = imageW*imageH*4;
//	CGDataProviderRef providerRef = CGDataProviderCreateWithData(NULL, bitMapData, size, NULL);
//	//创建马赛克图片，根据变换过的bitMapData像素来创建图片
//	CGImageRef mosaicImageRef = CGImageCreate(imageW, imageH, 8, 4*8, imageW*4, colorSpace, kCGBitmapByteOrderDefault, providerRef, NULL, NO, kCGRenderingIntentDefault);//Creates a bitmap image from data supplied by a data provider.
//	//创建输出马赛克图片
//	CGContextRef outContextRef = CGBitmapContextCreate(bitMapData, imageW, imageH, 8, imageW*4, colorSpace, kCGImageAlphaPremultipliedLast);
//	//绘制图片
//	CGContextDrawImage(outContextRef, CGRectMake(0, 0, imageW, imageH), mosaicImageRef);
//
//	CGImageRef resultImageRef = CGBitmapContextCreateImage(contextRef);
//	UIImage *mosaicImage = [UIImage imageWithCGImage:resultImageRef];
//	//释放内存
//	CGImageRelease(resultImageRef);
//	CGImageRelease(mosaicImageRef);
//	CGColorSpaceRelease(colorSpace);
//	CGDataProviderRelease(providerRef);
//	CGContextRelease(outContextRef);
//
//	return mosaicImage;
}

@end
