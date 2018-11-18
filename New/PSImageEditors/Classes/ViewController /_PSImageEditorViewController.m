//
//  _PSImageEditorViewController.m
//  PSImageEditors
//
//  Created by paintingStyle on 2018/11/15.
//

#import "_PSImageEditorViewController.h"
#import "PSDrawTool.h"
#import "PSMosaicTool.h"
#import "PSTexTool.h"
#import "PSTexItem.h"
#import "PSClippingTool.h"

#import <TOCropViewController.h>


@interface _PSImageEditorViewController ()
<UIScrollViewDelegate,
PSTopToolBarDelegate,
PSBottomToolBarDelegate,
TOCropViewControllerDelegate> {
    BOOL _originalNavBarHidden;
    UIImage *_originalImage;
}

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) PSImageToolBase *currentTool;
@property (nonatomic, strong) PSDrawTool *drawTool;
@property (nonatomic, strong) PSMosaicTool *mosaicTool;
@property (nonatomic, strong) PSTexTool *texTool;
@property (nonatomic, strong) PSClippingTool *clippingTool;

@property (nonatomic, strong, readwrite) PSTopToolBar *topToolBar;
@property (nonatomic, strong, readwrite) PSBottomToolBar *bootomToolBar;

@end

@implementation _PSImageEditorViewController

- (instancetype)initWithImage:(UIImage *)image
                     delegate:(id<PSImageEditorDelegate>)delegate
                   dataSource:(id<PSImageEditorDataSource>)dataSource {
    
    if (self = [super init]) {
        _originalNavBarHidden = self.navigationController.navigationBar.hidden;
        _originalImage = image;
        self.delegate = self;
        self.dataSource = dataSource;
    }
    return self;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configUI];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:_originalNavBarHidden animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self.topToolBar setToolBarShow:YES animation:YES];
    [self.bottomToolBar setToolBarShow:YES animation:YES];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self refreshImageView];
    // 绘图画布的加载顺序：text >draw > mosaic，马赛克显示在页面最底层
    [self.mosaicTool initialize];
    [self.drawTool initialize];
    [self.texTool initialize];
}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Method

- (void)buildClipImageCallback:(void(^)(UIImage *clipedImage))clipedCallback {
    
    UIImageView *imageView =  self.imageView;
    UIImageView *drawingView =  self.drawTool->_drawingView;
    UIImage *mosaicImage = [self.mosaicTool mosaicImage];
    
    UIGraphicsBeginImageContextWithOptions(imageView.image.size, NO, imageView.image.scale);
    // 画笔
    [imageView.image drawAtPoint:CGPointZero];
    [mosaicImage drawAtPoint:CGPointZero];
    [drawingView.image drawInRect:CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height)];
    // text
    for (UIView *view in self.view.subviews) {
        if (![view isKindOfClass:[PSTexItem class]]) { continue; }
        
        PSTexItem *texItem = (PSTexItem *)view;
        [PSTexItem setInactiveTextView:texItem];
        
        CGFloat rotation = [[texItem.layer valueForKeyPath:@"transform.rotation.z"] doubleValue];
        CGFloat selfRw = imageView.bounds.size.width / imageView.image.size.width;
        CGFloat selfRh = imageView.bounds.size.height / imageView.image.size.height;
        
        CGRect texItemRect = [texItem.superview convertRect:texItem.frame toView:self.imageView.superview];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *textImg = [self screenshot:texItem];
            textImg = [textImg ps_imageRotatedByRadians:rotation];
            CGFloat sw = textImg.size.width / selfRw;
            CGFloat sh = textImg.size.height / selfRh;
            [textImg drawInRect:CGRectMake(texItemRect.origin.x/selfRw, texItemRect.origin.y/selfRh, sw, sh)];
        });
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *tmp = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImage *image = [UIImage imageWithCGImage:tmp.CGImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        clipedCallback(image);
    });
}

- (void)clippingWithImage:(UIImage *)image {
    
    TOCropViewController *cropController = [[TOCropViewController alloc] initWithCroppingStyle:
                                            TOCropViewCroppingStyleDefault image:image];
    cropController.aspectRatioPickerButtonHidden = YES;
    cropController.delegate = self;
    @weakify(self);
    CGRect viewFrame = [self.view convertRect:self.imageView.frame
                                       toView:self.navigationController.view];
    [cropController presentAnimatedFromParentViewController:self
                                                  fromImage:image
                                                   fromView:nil
                                                  fromFrame:viewFrame
                                                      angle:0
                                               toImageFrame:CGRectZero
                                                      setup:^{
                                                          @strongify(self);
                                                          //[self.colorToolBar setToolBarShow:NO animation:NO];
                                                         // self.currentMode = PSEditorModeClipping;
                                                          self.currentTool = nil;
                                                      }
                                                 completion:nil];
}

- (UIImage *)screenshot:(UIView *)view {
    
    CGSize targetSize = CGSizeZero;
    
    CGFloat transformScaleX = [[view.layer valueForKeyPath:@"transform.scale.x"] doubleValue];
    CGFloat transformScaleY = [[view.layer valueForKeyPath:@"transform.scale.y"] doubleValue];
    CGSize size = view.bounds.size;
    targetSize = CGSizeMake(size.width * transformScaleX, size.height *  transformScaleY);
    
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    [view drawViewHierarchyInRect:CGRectMake(0, 0, targetSize.width, targetSize.height) afterScreenUpdates:NO];
    CGContextRestoreGState(ctx);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)resetImageViewFrame {
    
    CGSize size = (_imageView.image) ? _imageView.image.size : _imageView.frame.size;
    CGFloat ratio = MIN(_scrollView.frame.size.width / size.width, _scrollView.frame.size.height / size.height);
    CGFloat W = ratio * size.width;
    CGFloat H = ratio * size.height;
    _imageView.frame = CGRectMake(0, 0, W, H);
    _imageView.superview.bounds = _imageView.bounds;
}


- (void)resetZoomScaleWithAnimate:(BOOL)animated {
    
    CGFloat Rw = _scrollView.frame.size.width / _imageView.frame.size.width;
    CGFloat Rh = _scrollView.frame.size.height / _imageView.frame.size.height;
    
    //CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat scale = 1;
    Rw = MAX(Rw, _imageView.image.size.width / (scale * _scrollView.frame.size.width));
    Rh = MAX(Rh, _imageView.image.size.height / (scale * _scrollView.frame.size.height));
    
    _scrollView.contentSize = _imageView.frame.size;
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = MAX(MAX(Rw, Rh), 1);
    
    [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:animated];
    [self scrollViewDidZoom:_scrollView];
}

- (void)refreshImageView {
    
    [self resetImageViewFrame];
    [self resetZoomScaleWithAnimate:NO];
}

- (NSDictionary *)drawToolOption {
    
    NSMutableDictionary *option = [NSMutableDictionary dictionary];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(imageEditorDefaultColor)]) {
        UIColor *defaultColor = [self.dataSource imageEditorDefaultColor];
        [option setObject:defaultColor ?:[UIColor redColor] forKey:kImageToolDrawLineColorKey];
    }
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(imageEditorDrawPathWidth)]) {
        CGFloat drawPathWidth = [self.dataSource imageEditorDrawPathWidth];
        [option setObject:@(MAX(1, drawPathWidth)) forKey:kImageToolDrawLineWidthKey];
    }
    
    return option;
}

- (NSDictionary *)textToolOption {
    
    NSMutableDictionary *option = [NSMutableDictionary dictionary];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(imageEditorDefaultColor)]) {
        UIColor *defaultColor = [self.dataSource imageEditorDefaultColor];
        [option setObject:defaultColor ?:[UIColor redColor] forKey:kImageToolTextColorKey];
    }
    if (self.dataSource && [self.dataSource respondsToSelector:
                            @selector(imageEditorTextFont)]) {
        UIFont *textFont = [self.dataSource imageEditorTextFont];
        [option setObject:(textFont ? :[UIFont systemFontOfSize:24.0f]) forKey:kImageToolTextFontKey];
    }
    
    return option;
}

- (void)hiddenToolBar:(BOOL)hidden animation:(BOOL)animation {
    
    [self.topToolBar setToolBarShow:!hidden animation:animation];
    [self.bottomToolBar setToolBarShow:!hidden animation:animation];
    [self.drawTool hiddenToolBar:hidden animation:animation];
    [self.texTool hiddenToolBar:hidden animation:animation];
}

#pragma mark - TOCropViewControllerDelegate


- (void)cropViewController:(TOCropViewController *)cropViewController
            didCropToImage:(UIImage *)image
                  withRect:(CGRect)cropRect
                     angle:(NSInteger)angle {
    
    UIImage *rectImage = [self.imageView.image ps_imageAtRect:cropRect];
    self.imageView.image = rectImage;
    [self refreshImageView];
    [self.drawTool resetSize];
    [self.mosaicTool resetSize];
    
    if (cropViewController.croppingStyle != TOCropViewCroppingStyleCircular) {
        [cropViewController dismissAnimatedFromParentViewController:self
                                                   withCroppedImage:image
                                                             toView:self.imageView
                                                            toFrame:CGRectZero
                                                              setup:nil
                                                         completion:nil];
    }else {
        [cropViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - PSTopToolBarDelegate

- (void)topToolBar:(PSTopToolBar *)toolBar event:(PSTopToolBarEvent)event {
    
    switch (event) {
        case PSTopToolBarEventCancel: {
            if (toolBar.type == PSTopToolBarTypeCancelAndDoneText) {
                if (self.presentingViewController
                    && self.navigationController.viewControllers.count == 1) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                } else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }else {
                // text
               
            }
        }
        break;
        case PSTopToolBarEventDone: {
            if (toolBar.type == PSTopToolBarTypeCancelAndDoneText) {
                [self buildClipImageCallback:^(UIImage *clipedImage) {
                    UIImageWriteToSavedPhotosAlbum(clipedImage, nil, nil, nil);
                }];
            }else {
                // text
            }
        }
        break;
        default:
            break;
    }
}

#pragma mark - PSBottomToolBarDelegate

- (void)bottomToolBar:(PSBottomToolBar *)toolBar
 didClickAtEditorMode:(PSImageEditorMode)mode {
	
	//if (!toolBar.isEditor) { [self.currentTool cleanup]; }
	
	switch (mode) {
		case PSImageEditorModeDraw:
            self.currentTool = self.drawTool;
			break;
		case PSImageEditorModeText:
            self.currentTool = self.texTool;
			break;
		case PSImageEditorModeMosaic:
            self.currentTool = self.mosaicTool;
			break;
		case PSImageEditorModeClipping:
            //self.currentTool = self.clippingTool;
        {
            
            [self buildClipImageCallback:^(UIImage *clipedImage) {
               [self clippingWithImage:clipedImage];
                //UIImageWriteToSavedPhotosAlbum(clipedImage, nil, nil, nil);
            }];
        }
			break;
		default:
			break;
	}
}

#pragma mark- ScrollView

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return _imageView.superview;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    CGFloat Ws = _scrollView.frame.size.width - _scrollView.contentInset.left - _scrollView.contentInset.right;
    CGFloat Hs = _scrollView.frame.size.height - _scrollView.contentInset.top - _scrollView.contentInset.bottom;
    CGFloat W = _imageView.superview.frame.size.width;
    CGFloat H = _imageView.superview.frame.size.height;
    
    CGRect rct = _imageView.superview.frame;
    rct.origin.x = MAX((Ws-W)/2, 0);
    rct.origin.y = MAX((Hs-H)/2, 0);
    _imageView.superview.frame = rct;
}

#pragma mark - InitAndLayout

- (void)configUI {
    
    self.view.backgroundColor = [UIColor blackColor];
	[self.view addSubview:self.scrollView];
	[self.scrollView addSubview:self.contentView];
	[self.contentView addSubview:self.imageView];
	[self.view addSubview:self.topToolBar];
	[self.view addSubview:self.bottomToolBar];
	
	[self.topToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.left.right.equalTo(self.view);
		make.height.equalTo(@(PSTopToolBarHeight));
	}];
	[self.bottomToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.bottom.right.equalTo(self.view);
		make.height.equalTo(@(PSBottomToolBarHeight));
	}];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.view);
    }];
    
    [self.topToolBar setToolBarShow:NO animation:NO];
    [self.bottomToolBar setToolBarShow:NO animation:NO];
    
 
	
//	self.topToolBar.backgroundColor = [UIColor yellowColor];
//	self.bottomToolBar.backgroundColor = [UIColor greenColor];
	
	//DEBUG_VIEW(self.view);
}

#pragma mark - Getter/Setter

- (void)setCurrentTool:(PSImageToolBase *)currentTool {
	
	if (currentTool != _currentTool){
		[_currentTool cleanup];
		_currentTool = currentTool;
		[_currentTool setup];
        NSLog(@"_currentTool:%@",_currentTool);
	}
}

- (PSClippingTool *)clippingTool {
    
    return LAZY_LOAD(_clippingTool, ({
        
        _clippingTool = [[PSClippingTool alloc] initWithImageEditor:self withOption:nil];
        _clippingTool;
    }));
}

- (PSMosaicTool *)mosaicTool {
    
    return LAZY_LOAD(_mosaicTool, ({
        
        _mosaicTool = [[PSMosaicTool alloc] initWithImageEditor:self withOption:nil];
        _mosaicTool;
    }));
}

- (PSTexTool *)texTool {
    
    return LAZY_LOAD(_texTool, ({
        
        _texTool = [[PSTexTool alloc] initWithImageEditor:self withOption:[self textToolOption]];
        @weakify(self);
        _texTool.dissmissCallback = ^(NSString *currentText) {
            @strongify(self);
            self.currentTool = nil;
            [self.bottomToolBar reset];
        };
        _texTool;
    }));
}

- (PSDrawTool *)drawTool {
    
    return LAZY_LOAD(_drawTool, ({
        
        _drawTool = [[PSDrawTool alloc] initWithImageEditor:self withOption:[self drawToolOption]];
        _drawTool;
    }));
}

- (PSBottomToolBar *)bottomToolBar {
	
	return LAZY_LOAD(_bootomToolBar, ({
		
		_bootomToolBar = [[PSBottomToolBar alloc] initWithType:PSBottomToolTypeEditor];
		_bootomToolBar.delegate = self;
		_bootomToolBar;
	}));
}

- (PSTopToolBar *)topToolBar {
    
    return LAZY_LOAD(_topToolBar, ({
        
        _topToolBar = [[PSTopToolBar alloc] initWithType:PSTopToolBarTypeCancelAndDoneText];
		_topToolBar.delegate = self;
        _topToolBar;
    }));
}

- (UIImageView *)imageView {
    
    return LAZY_LOAD(_imageView, ({
        
        _imageView = [[UIImageView alloc] initWithImage:_originalImage];
        _imageView;
    }));
}

- (UIView *)contentView {
    
    return LAZY_LOAD(_contentView, ({
        
        _contentView = [[UIView alloc] init];
        _contentView;
    }));
}

- (UIScrollView *)scrollView {
    
    return LAZY_LOAD(_scrollView, ({
        
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delegate = self;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delaysContentTouches = NO;
        _scrollView.scrollsToTop = NO;
        _scrollView.clipsToBounds = NO;
        if(@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior =
            UIScrollViewContentInsetAdjustmentNever;
        }
        _scrollView;
    }));
}

@end
