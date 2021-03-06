//
//  _PSImageEditorViewController.h
//  PSImageEditors
//
//  Created by paintingStyle on 2018/11/15.
//

#import "PSImageEditor.h"
#import "PSTopToolBar.h"
#import "PSBottomToolBar.h"

@interface _PSImageEditorViewController : PSImageEditor

/// 缩放容器
@property (nonatomic, strong) UIScrollView *scrollView;
/// 最底层负责显示的图片
@property (nonatomic, strong) UIImageView *imageView;

/// 用于布局参照
@property (nonatomic, strong, readonly) PSTopToolBar *topToolBar;
@property (nonatomic, strong, readonly) PSBottomToolBar *bottomToolBar;

@property (nonatomic, copy) void(^scrollViewDidZoomBlock) (CGFloat zoomScale);

- (void)buildClipImageCallback:(void(^)(UIImage *clipedImage))callback;
- (void)hiddenToolBar:(BOOL)hidden animation:(BOOL)animation;
- (void)hiddenBottomToolBar:(BOOL)hidden animation:(BOOL)animation;
- (void)refreshImageView;

- (void)addTrajectoryName:(NSString *)name;
- (void)removeLastTrajectory;
- (void)removeLastTrajectoryName:(NSString *)name;
- (void)removeAllTrajectory;

@end
