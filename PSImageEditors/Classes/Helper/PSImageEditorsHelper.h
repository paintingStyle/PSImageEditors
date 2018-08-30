//
//  PSImageEditorsHelper.h
//  Pods-PSImageEditors
//
//  Created by rsf on 2018/8/24.
//

#import <UIKit/UIKit.h>

@interface PSImageEditorsHelper : NSObject

+ (UIImage *)imageByScalingToSize:(CGSize)targetSize
					  sourceImage:(UIImage *)image;

+ (UIImage *)imageCompressForWidth:(UIImage *)image
					   targetWidth:(CGFloat)width;

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (NSString *)fileSizeWithByteSize:(NSInteger)byteSize;

+ (void)rgbComponents:(CGFloat [4])components color:(UIColor *)color;

+ (void)checkAlbumAvailableWithViewController:(UIViewController *)controller
									  handler:(void(^)(BOOL available))handler;

+ (void)saveToPhotosAlbumWithImageData:(NSData *)data completionHandler:(void(^)(BOOL success))handler;

+ (void)imageDataWithImageURL:(NSURL *)url completion:(void(^)(NSData *data))completion;

@end
