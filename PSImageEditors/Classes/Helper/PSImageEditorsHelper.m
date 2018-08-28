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

+ (UIImage *)imageByScalingToSize:(CGSize)targetSize
					  sourceImage:(UIImage *)image {
	
	UIImage *newImage = nil;
	
	CGFloat targetWidth = ceilf(targetSize.width);
	CGFloat targetHeight = ceilf(targetSize.height);
	
	CGFloat scaledWidth = targetWidth;
	CGFloat scaledHeight = targetHeight;
	
	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	
	UIGraphicsBeginImageContextWithOptions(targetSize, NO, [[UIScreen mainScreen] scale]);
	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width = scaledWidth;
	thumbnailRect.size.height = scaledHeight;
	[image drawInRect:thumbnailRect];
	newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	if (newImage == nil) {
		NSLog(@"Could not scale image");
	}
	
	return newImage;
}

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

+ (NSString *)fileSizeWithByteSize:(NSInteger)byteSize {
	
	if (byteSize <=0) { return @"0KB"; }
	
	NSDecimalNumber *decimalNumber = [[NSDecimalNumber alloc] initWithString:[NSString stringWithFormat:@"%ld",byteSize]];
	CGFloat byteSizeFloatValue = [decimalNumber floatValue];
	
	// 注意iOS中的字节之间的换算是1000不是1024
	CGFloat ratio = 1000.00;
	
	if (byteSizeFloatValue < ratio) {
		
		// 小于1k
		return [NSString stringWithFormat:@"%ldB",(long)byteSize];
		
	}else if (byteSizeFloatValue < ratio * ratio){
		
		// 小于1m
		CGFloat aFloat = byteSize/ratio;
		return [NSString stringWithFormat:@"%.0fKB",aFloat];
		
	}else if (byteSizeFloatValue < ratio * ratio * ratio){
		
		// 小于1G
		CGFloat aFloat = byteSize/(ratio * ratio);
		return [NSString stringWithFormat:@"%.1fM",aFloat];
		
	}else{
		
		CGFloat aFloat = byteSize/(ratio*ratio*ratio);
		return [NSString stringWithFormat:@"%.1fG",aFloat];
	}
}

+ (void)checkAlbumAvailableWithViewController:(UIViewController *)controller
									  handler:(void(^)(BOOL available))handler {
    
    // 判断相册是否可以打开
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"相册不可用" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [controller presentViewController:alertController animated:YES completion:nil];
		if (handler) { handler(NO); }
    }
    // 判断相册权限
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
	
	if (status == PHAuthorizationStatusAuthorized) { // 有权限
		 if (handler) { handler(YES); }
	}else if (status == PHAuthorizationStatusNotDetermined) { // 还没有申请权限
		[PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
			if (status == PHAuthorizationStatusAuthorized) { // 有权限
				if (handler) { handler(YES); }
			}else if(status == PHAuthorizationStatusRestricted || // 无权限 引导去开启
					 status == PHAuthorizationStatusDenied) {
				[self showPhotoLibraryLimitedAlertWithController:controller];
				if (handler) { handler(NO); }
			}
		}];
	}else if (status == PHAuthorizationStatusRestricted || // 无权限 引导去开启
        	  status == PHAuthorizationStatusDenied) {
        [self showPhotoLibraryLimitedAlertWithController:controller];
		if (handler) { handler(NO); }
    }
}

+ (void)showPhotoLibraryLimitedAlertWithController:(UIViewController *)controller {
	
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"相册权限受限 请在设备的\"设置-隐私-相册\"中允许访问相册" preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
		if ([[UIApplication sharedApplication]canOpenURL:url]) {
			[[UIApplication sharedApplication] openURL:url options:@{}  completionHandler:nil];
		}
	}]];
	[controller presentViewController:alertController animated:YES completion:nil];
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
