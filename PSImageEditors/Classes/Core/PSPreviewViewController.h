//
//  PSPreviewViewController.h
//  PSImageEditors
//
//  Created by rsf on 2018/8/24.
//  Copyright © 2018年 paintingStyle. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PSPreviewViewController,PSImageObject;

@protocol PSPreviewViewControllerDelegate<NSObject>

@optional

/// 点击图片
- (void)previewViewController:(PSPreviewViewController *)controller
     didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

/// 滚动视图
- (void)previewViewController:(PSPreviewViewController *)controller
	   didScrollAtImageObject:(PSImageObject *)object;

@end

@interface PSPreviewViewController : UIViewController

@property (nonatomic, strong, readonly) NSArray *urls;
@property (nonatomic, strong, readonly) NSArray *images;
@property (nonatomic, assign, readonly) NSInteger currentIndex;

@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, strong, readonly) NSMutableArray<PSImageObject *> *dataSources;
@property (nonatomic, assign, readonly) PSImageObject *currentImageObject;

@property (nonatomic, weak) id<PSPreviewViewControllerDelegate> delegate;

/// 显示导航栏，default is NO
@property (nonatomic, assign, getter=isShowNavigationBar) BOOL showNavigationBar;

/// 点击cell显示导航栏，default is YES
@property (nonatomic, assign, getter=isClickShowNavigationBar) BOOL clickShowNavigationBar;

- (instancetype)init NS_UNAVAILABLE;
- (void)configUI;
- (void)configData;

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

/**
 保存当前图片到相册
 */
- (void)saveCurrentImageToPhotosAlbum;

@end

