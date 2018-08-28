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
	
	CGSize size = self.GIFImage ? self.GIFImage.size : self.image.size;
	
	CGFloat w = ceilf(size.width /[UIScreen mainScreen].scale);
	CGFloat h = ceilf(size.height /[UIScreen mainScreen].scale);
	if (h >PS_SCREEN_H) { // 超长图高度大于屏幕高度，将图片宽度置换为屏幕宽度，方便用户观看
		CGFloat fixW = PS_SCREEN_W;
		CGFloat fixH  = h / (w / fixW);
		w = fixW;
		h = fixH;
		self.scaling = YES;
	}else {
		h = PS_SCREEN_H;
	}
	CGSize result = CGSizeMake(w, h);
	self.displayContentSize = result;
}

@end
