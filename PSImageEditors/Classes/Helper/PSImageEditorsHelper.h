//
//  PSImageEditorsHelper.h
//  Pods-PSImageEditors
//
//  Created by rsf on 2018/8/24.
//

#import <UIKit/UIKit.h>

@interface PSImageEditorsHelper : NSObject

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (void)rgbComponents:(CGFloat [4])components color:(UIColor *)color;

+ (BOOL)checkAlbumIsAvailableViewController:(UIViewController *)controller;

+ (void)saveToPhotosAlbumWithImageData:(NSData *)data completionHandler:(void(^)(BOOL success))handler;

+ (void)imageDataWithImageURL:(NSURL *)url completion:(void(^)(NSData *data))completion;

@end
