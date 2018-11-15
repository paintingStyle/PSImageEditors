//
//  FLAnimatedImageView+Download.m
//  PSImageEditors
//
//  Created by rsf on 2018/8/31.
//

#import "FLAnimatedImageView+Download.h"
#import <UIView+WebCache.h>
#import <NSData+ImageContentType.h>
#import <FLAnimatedImageView+WebCache.h>
#import "UIImage+MultiFormat.h"

#define kFetchImageError [[NSError alloc] initWithDomain:@"PSImageEditorsErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"获取图片失败"}]

static inline FLAnimatedImage * SDWebImageCreateFLAnimatedImage(FLAnimatedImageView *imageView, NSData *imageData) {
	if ([NSData sd_imageFormatForImageData:imageData] != SDImageFormatGIF) {
		return nil;
	}
	FLAnimatedImage *animatedImage;
	// Compatibility in 4.x for lower version FLAnimatedImage.
	if ([FLAnimatedImage respondsToSelector:@selector(initWithAnimatedGIFData:optimalFrameCacheSize:predrawingEnabled:)]) {
		animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:imageData optimalFrameCacheSize:imageView.sd_optimalFrameCacheSize predrawingEnabled:imageView.sd_predrawingEnabled];
	} else {
		animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:imageData];
	}
	return animatedImage;
}

@implementation FLAnimatedImageView (Download)

//typedef void(^SDExternalCompletionBlock)(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL);

- (void)ps_setImageWithURL:(NSURL *)url completed:(PSDownloadCompletionBlock)completed {
	
	__weak typeof(self)weakSelf = self;
	[self sd_internalSetImageWithURL:url
					placeholderImage:nil
							 options:0
						operationKey:nil
					   setImageBlock:^(UIImage * _Nullable image, NSData * _Nullable imageData) {
						  
						   __strong typeof(weakSelf)strongSelf = weakSelf;
						   if (!strongSelf || (!image && !imageData)) {
							   return;
						   }
						   
						   // 1,取出二进制数据
						   if (!imageData) {
							   NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:url];
							   imageData = [[SDImageCache sharedImageCache] diskImageDataForKey:key];
						   }
						   SDImageFormat imageFormat = [NSData sd_imageFormatForImageData:imageData];
						   if (imageFormat == SDImageFormatGIF) {
							   // 2,检测GIF内存缓存
							   FLAnimatedImage *associatedAnimatedImage = image.sd_FLAnimatedImage;
							   if (associatedAnimatedImage) {
								   strongSelf.animatedImage = associatedAnimatedImage;
								   strongSelf.image = nil;
								   if (completed) {
									   completed(associatedAnimatedImage, nil, url);
								   }
								   return;
							   }
							   // 3,创建GIF
							   dispatch_async(dispatch_get_global_queue(0, 0), ^{
								   FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:imageData];
								   dispatch_main_async_safe(^{
									   strongSelf.animatedImage = animatedImage;
									   strongSelf.image = nil;
									   if (completed) {
										   completed(animatedImage, nil, url);
									   }
								   });
							   });
						   }else {
							   strongSelf.image = image;
							   strongSelf.animatedImage = nil;
							   if (completed) {
								   completed(image, nil, url);
							   }
						   }
					   } progress:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
						   if (completed && error) {
							   completed(nil, error, imageURL);
						   }
					   }];
	
}

@end
