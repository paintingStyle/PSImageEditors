//
//  _PSImageEditorViewController.m
//  PSImageEditors
//
//  Created by paintingStyle on 2018/11/15.
//

#import "_PSImageEditorViewController.h"
#import "PSImageToolBase.h"

static inline NSDictionary *PSImageToolMappings (void) {
	
	return @{
			@(PSImageEditorModeDraw):@"PSDrawTool",
			@(PSImageEditorModeText):@"PSTexTool",
			@(PSImageEditorModeMosaic):@"PSMosaicTool",
			@(PSImageEditorModeClipping):@"PSClippingTool",
			};
}


@interface _PSImageEditorViewController ()
<UIScrollViewDelegate,PSTopToolBarDelegate,PSBottomToolBarDelegate> {
    BOOL _originalNavBarHidden;
    UIImage *_originalImage;
}

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) PSImageToolBase *currentTool;
@property (nonatomic, strong) NSMutableDictionary *option;
@property (nonatomic, strong, readwrite) PSTopToolBar *topToolBar;
@property (nonatomic, strong, readwrite) PSBootomToolBar *bootomToolBar;

@end

@implementation _PSImageEditorViewController

- (NSMutableDictionary *)option  {
	
	return LAZY_LOAD(_option, ({
		
		_option = [NSMutableDictionary dictionary];
		_option;
	}));
}

- (instancetype)initWithImage:(UIImage *)image
                     delegate:(id<PSImageEditorDelegate>)delegate
                   dataSource:(id<PSImageEditorDataSource>)dataSource {
    
    if (self = [super init]) {
        _originalNavBarHidden = self.navigationController.navigationBar.hidden;
        _originalImage = image;
        self.delegate = self;
        self.dataSource = dataSource;
		if (self.dataSource && [self.dataSource respondsToSelector:@selector(imageEditorDefaultColor)]) {
			UIColor *defaultColor = [self.dataSource imageEditorDefaultColor];
			[self.option setObject:defaultColor ?:[UIColor redColor] forKey:kImageToolDrawLineColorKey];
		}
		if (self.dataSource && [self.dataSource respondsToSelector:@selector(imageEditorDrawPathWidth)]) {
			CGFloat drawPathWidth = [self.dataSource imageEditorDrawPathWidth];
			[self.option setObject:@(MAX(1, drawPathWidth)) forKey:kImageToolDrawLineWidthKey];
		}
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

- (void)setupToolWithEditorMode:(PSImageEditorMode)mode {
	
	NSString *className = PSImageToolMappings()[@(mode)];
	if (!className) { return; }
	Class toolClass = NSClassFromString(className);
	if(toolClass){
		id instance = [toolClass alloc];
		if (instance && [instance isKindOfClass:[PSImageToolBase class]]){
			instance = [instance initWithImageEditor:self withOption:self.option];
			if (![self.currentTool isKindOfClass:toolClass]) {
				self.currentTool = instance;
			}
		}
	}
	
	
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

#pragma mark - PSTopToolBarDelegate

- (void)topToolBarBackItemDidClick {
	
	if (self.presentingViewController
		&& self.navigationController.viewControllers.count == 1) {
		[self dismissViewControllerAnimated:YES completion:nil];
	} else {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (void)topToolBarDoneItemDidClick {
	
	[self.currentTool executeWithCompletionBlock:^(UIImage *image, NSError *error, NSDictionary *userInfo) {
		UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
	}];
}

#pragma mark - PSBottomToolBarDelegate

- (void)bottomToolBar:(PSBootomToolBar *)toolBar
 didClickAtEditorMode:(PSImageEditorMode)mode {
	
	if (toolBar.isEditor) {
		[self setupToolWithEditorMode:mode];
	}else {
		[self.currentTool cleanup];
	}
	
	switch (mode) {
		case PSImageEditorModeDraw:
			break;
		case PSImageEditorModeText:
			break;
		case PSImageEditorModeMosaic:
			break;
		case PSImageEditorModeClipping:
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
	[self.view addSubview:self.bootomToolBar];
	
	[self.topToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.left.right.equalTo(self.view);
		make.height.equalTo(@(PSTopToolBarHeight));
	}];
	[self.bootomToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.bottom.right.equalTo(self.view);
		make.height.equalTo(@(PSBottomToolBarHeight));
	}];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.view);
    }];
	
//	self.topToolBar.backgroundColor = [UIColor yellowColor];
//	self.bootomToolBar.backgroundColor = [UIColor greenColor];
	
	//DEBUG_VIEW(self.view);
}

#pragma mark - Getter/Setter

- (void)setCurrentTool:(PSImageToolBase *)currentTool {
	
	if (currentTool != _currentTool){
		[_currentTool cleanup];
		_currentTool = currentTool;
		[_currentTool setup];
	}
}

- (PSBootomToolBar *)bootomToolBar {
	
	return LAZY_LOAD(_bootomToolBar, ({
		
		_bootomToolBar = [[PSBootomToolBar alloc] init];
		_bootomToolBar.delegate = self;
		_bootomToolBar;
	}));
}

- (PSTopToolBar *)topToolBar {
    
    return LAZY_LOAD(_topToolBar, ({
        
        _topToolBar = [[PSTopToolBar alloc] init];
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
