//
//  PSImageEditorsHelper.m
//  Pods-PSImageEditors
//
//  Created by rsf on 2018/8/24.
//

#import "PSImageEditorsHelper.h"
#import <Photos/Photos.h>
#import <SDWebImageManager.h>

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

- (void)rgbComponents:(CGFloat [4])components color:(UIColor *)color {
    
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat alpha = 0.0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    components[0] = red;
    components[1] = green;
    components[2] = blue;
    components[3] = alpha;
}

+ (BOOL)checkAlbumIsAvailableViewController:(UIViewController *)controller {
    
    // 判断相册是否可以打开
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"相册不可用" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        
        [controller presentViewController:alertController animated:YES completion:nil];
        return NO;
    }
    
    // 判断相册权限
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted ||
        status == PHAuthorizationStatusDenied) {
        //无权限 引导去开启
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"相册权限受限 请在设备的\"设置-隐私-相册\"中允许访问相册" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication]canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url options:@{}  completionHandler:nil];
            }
        }]];
        [controller presentViewController:alertController animated:YES completion:nil];
        return NO;
    }
    return YES;
}

+ (void)saveToPhotosAlbumWithImageData:(NSData *)data completionHandler:(void(^)(BOOL success))handler {
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        if (@available(iOS 9.0, *)) {
            PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
            [request addResourceWithType:PHAssetResourceTypePhoto data:data options:nil];
        }
        else {
            NSString *temporaryFileName = [NSProcessInfo processInfo].globallyUniqueString;
            NSString *temporaryFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:temporaryFileName];
            NSURL *temporaryFileURL = [NSURL fileURLWithPath:temporaryFilePath];
            NSError *error = nil;
            [data writeToURL:temporaryFileURL options:NSDataWritingAtomic error:&error];
            
            [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:temporaryFileURL];
            [[NSFileManager defaultManager] removeItemAtURL:temporaryFileURL error:nil];
        }
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handler) { handler(!error); }
        });
    }];
}

+ (void)imageDataWithImageURL:(NSURL *)url completion:(void(^)(NSData *data))completion {
    
    NSData *imageData = nil;
    [[SDWebImageManager sharedManager] diskImageExistsForURL:url completion:^(BOOL isInCache) {
        
        NSData *imageData = nil;
        if(isInCache) {
            NSString *cacheImageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:url];
            if(cacheImageKey.length) {
                NSString*cacheImagePath = [[SDImageCache sharedImageCache] defaultCachePathForKey:cacheImageKey];
                if(cacheImagePath.length) {
                    imageData = [NSData dataWithContentsOfFile:cacheImagePath];
                }
            }
        }
        if (completion) { completion(imageData); }
    }];
}

@end
