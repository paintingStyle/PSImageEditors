//
//  _PSImageEditorViewController.m
//  PSImageEditors
//
//  Created by paintingStyle on 2018/11/15.
//

#import "_PSImageEditorViewController.h"
#import "PSImageEditorTopBar.h"

@interface _PSImageEditorViewController ()<UIScrollViewDelegate> {
    BOOL _originalNavBarHidden;
    UIImage *_originalImage;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong, readwrite) UIImageView *imageView;

@property (nonatomic, strong) PSImageEditorTopBar *topBar;
@property (nonatomic, strong, readwrite) PSBrushCanvasView *brushCanvasView;
@property (nonatomic, strong, readwrite) PSMosaicCanvasView *textCanvasView;
@property (nonatomic, strong, readwrite) PSTextCanvasView *mosaicCanvasView;

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

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self refreshImageView];
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
    [self.contentView addSubview:self.mosaicCanvasView];
    [self.contentView addSubview:self.brushCanvasView];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.equalTo(self.mas_topLayoutGuide);
        }
        make.left.right.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self.mas_bottomLayoutGuide);
        }
    }];
//    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.scrollView);
//        make.center.equalTo(self.scrollView);
//    }];
//    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.contentView);
//    }];
//    [self.mosaicCanvasView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.contentView);
//    }];
//    [self.brushCanvasView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.contentView);
//    }];
    
    self.mosaicCanvasView.backgroundColor = [UIColor redColor];
    self.textCanvasView.backgroundColor = [UIColor greenColor];
    self.brushCanvasView.backgroundColor = [UIColor blueColor];
}

#pragma mark - Getter/Setter

- (PSImageEditorTopBar *)topBar {
    
    return LAZY_LOAD(_topBar, ({
        
        _topBar = [[PSImageEditorTopBar alloc] init];
        _topBar;
    }));
}

- (PSTextCanvasView *)textCanvasView {
    
    return LAZY_LOAD(_textCanvasView, ({
        
        _textCanvasView = [[PSTextCanvasView alloc] init];
        _textCanvasView;
    }));
}

- (PSMosaicCanvasView *)mosaicCanvasView {
    
    return LAZY_LOAD(_mosaicCanvasView, ({
        
        _mosaicCanvasView = [[PSMosaicCanvasView alloc] init];
        _mosaicCanvasView;
    }));
}

- (PSBrushCanvasView *)brushCanvasView {
    
    return LAZY_LOAD(_brushCanvasView, ({
        
        _brushCanvasView = [[PSBrushCanvasView alloc] init];
        _brushCanvasView;
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
