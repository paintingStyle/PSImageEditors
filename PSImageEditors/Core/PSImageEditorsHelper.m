//
//  PSImageEditorsHelper.m
//  Pods-PSImageEditors
//
//  Created by rsf on 2018/8/24.
//

#import "PSImageEditorsHelper.h"

@implementation PSImageEditorsHelper

+ (UIImage *)imageWithColor:(UIColor *)color {
	
	CGRect rect = CGRectMake(0, 0, 1, 1);
	UIGraphicsBeginImageContextWithOptions(rect.size, NO, [[UIScreen mainScreen] scale]);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, [color CGColor]);
	
	CGContextFillRect(context, rect);
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}

+ (UIImage *)imageSpecifyWidthScalingWithImage:(UIImage *)image
								  scalingWidth:(CGFloat)width {
	
	UIImage *newImage = nil;
	CGSize imageSize = image.size;
	CGFloat height = imageSize.height;
	
	CGFloat targetHeight = height / (width / width);
	CGSize size = CGSizeMake(width, targetHeight);
	
	CGFloat scaleFactor = 0.0;
	CGFloat scaledWidth = width;
	CGFloat scaledHeight = targetHeight;
	CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
	
	if(CGSizeEqualToSize(imageSize, size) == NO){
		
		CGFloat widthFactor = width / width;
		CGFloat heightFactor = targetHeight / height;
		if(widthFactor > heightFactor){
			scaleFactor = widthFactor;
		}else{
			scaleFactor = heightFactor;
		}
		
		scaledWidth = width * scaleFactor;
		scaledHeight = height * scaleFactor;
		
		if(widthFactor > heightFactor){
			thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
		}else if(widthFactor < heightFactor){
			thumbnailPoint.x = (width - scaledWidth) * 0.5;
		}
	}
	UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width = scaledWidth;
	thumbnailRect.size.height = scaledHeight;
	[image drawInRect:thumbnailRect];
	newImage = UIGraphicsGetImageFromCurrentImageContext();
	if(newImage == nil){
		NSLog(@"scale image fail");
	}
	UIGraphicsEndImageContext();
	
	return newImage;
}

@end
