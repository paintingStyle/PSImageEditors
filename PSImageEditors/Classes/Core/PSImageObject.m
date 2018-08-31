//
//  PSImageObject.m
//  Pods-PSImageEditors
//
//  Created by rsf on 2018/8/24.
//

#import "PSImageObject.h"

@implementation PSImageObject

+ (instancetype)imageObjectWithIndex:(NSInteger)index
								 url:(NSURL *)url
							   image:(UIImage *)image
							GIFImage:(FLAnimatedImage *)GIFImage {
	
	PSImageObject *imageObject = [[PSImageObject alloc] init];
	imageObject.index = index;
	imageObject.url = url;
	imageObject.image = image;
	imageObject.GIFImage = GIFImage;
	imageObject.originSize = @"0KB";
	
	return imageObject;
}

- (void)calculateDisplayContentSize {
	
	if (!self.GIFImage && !self.image) {
		self.displayContentSize = CGSizeZero;
		return;
	}
	
	CGSize  size = self.GIFImage ? self.GIFImage.size : self.image.size;
	CGFloat imageScale  = size.height/size.width;
	CGFloat screenScale = PS_SCREEN_H/PS_SCREEN_W;
	
	CGFloat w = floorf(size.width /[UIScreen mainScreen].scale);
	CGFloat h = floorf(size.height /[UIScreen mainScreen].scale);
	
	if (h >PS_SCREEN_H) { // 超长图高度大于屏幕高度，将图片宽度置换为屏幕宽度，方便用户观看
		CGFloat fixW = PS_SCREEN_W;
		CGFloat fixH  = h / (w / fixW);
		w = fixW;
		h = fixH;
		self.scaling = YES;
	}else { // 计算与屏幕宽度等比例的屏幕高度
		w = PS_SCREEN_W;
		h = floorf(PS_SCREEN_W * imageScale);
	}
	CGSize result = CGSizeMake(w, h);
	self.displayContentSize = result;
}

@end
