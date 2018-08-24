//
//  PSPreviewViewController.h
//  PSImageEditors
//
//  Created by rsf on 2018/8/24.
//  Copyright © 2018年 paintingStyle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSPreviewViewController : UIViewController

@property (nonatomic, strong, readonly) NSArray<NSURL *> *urls;
@property (nonatomic, strong, readonly) NSArray<UIImage *> *images;
@property (nonatomic, assign, readonly) NSInteger currentIndex;

- (instancetype)init NS_UNAVAILABLE;

/**
 初始化图片预览

 @param urls 图片(兼容URL,NSString)
 @param index 当前显示索引
 @return PSPreviewViewController
 */
- (instancetype)initWithURLs:(NSArray *)urls
				currentIndex:(NSInteger)index;

/**
 初始化图片预览
 
 @param images 图片数组(兼容UIImage,FLAnimatedImage)
 @param index  当前显示索引
 @return PSPreviewViewController
 */
- (instancetype)initWithImages:(NSArray *)images
				  currentIndex:(NSInteger)index;

@end

