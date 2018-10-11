//
//  PSEditorViewController.m
//  PSImageEditors
//
//  Created by rsf on 2018/8/29.
//

#import "PSEditorViewController.h"
#import "PSPreviewImageView.h"
#import "PSDrawingBoard.h"
#import "PSTextBoard.h"
#import "PSMosaicBoard.h"
#import "PSTopToolBar.h"
#import "PSBottomToolBar.h"
#import "PSColorToolBar.h"
#import "PSMosaicToolBar.h"
#import "PSTextBoardItem.h"
#import "PSImageObject.h"
#import <TOCropViewController.h>
#import <UIImage+CropRotate.h>

static inline CGRect PSTextBoardItemDeleteCoordinate(void) {
	return CGRectMake(0, PS_SCREEN_H-PSBottomToolDeleteBarHeight, PS_SCREEN_W, PSBottomToolDeleteBarHeight);;
}

@interface PSEditorViewController ()
<PSTopToolBarDelegate,
PSBottomToolBarDelegate,
PSColorToolBarDelegate,
PSMosaicToolBarDelegate,
PSTextBoardItemDelegate,
TOCropViewControllerDelegate> {
	BOOL _navigationBarHidden;
}

@property (nonatomic, strong) UIImage *originImage;
@property (nonatomic, strong) PSPreviewImageView *previewImageView;

@property (nonatomic, strong) PSTopToolBar *topToolBar;
@property (nonatomic, strong) PSBottomToolBar *bottomToolBar;
@property (nonatomic, strong) PSColorToolBar *colorToolBar;
@property (nonatomic, strong) PSMosaicToolBar *mosaicToolBar;
@property (nonatomic, strong) PSBottomToolBar *deleteToolBar;

@property (nonatomic, strong) PSBaseDrawingBoard *currentBoard;
@property (nonatomic, strong) PSDrawingBoard *drawingBoard;
@property (nonatomic, strong) PSTextBoard *textBoard;
@property (nonatomic, strong) PSMosaicBoard *mosaicBoard;

@end

@implementation PSEditorViewController

- (instancetype)initWithImage:(UIImage *)image {
	
	if (self = [super init]) {
		_originImage = image;
	}
	return self;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
	
	[super viewDidLoad];
	[self configUI];
	
	@weakify(self);
	self.previewImageView.singleGestureBlock = ^(PSImageObject *imageObject) {
		@strongify(self);
		BOOL show = !self.topToolBar.isShow;
		[self toolBarShow:show animation:YES];
	};
	
    self.drawingBoard.drawToolStatus = ^(BOOL canPrev) {
        @strongify(self);
        self.colorToolBar.canUndo = canPrev;
    };
    self.drawingBoard.drawingCallback = ^(BOOL isDrawing) {
        @strongify(self);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((isDrawing ? 0:0.5) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self toolBarShow:!isDrawing animation:NO];
        });
    };
    

}

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	_navigationBarHidden = self.navigationController.navigationBar.hidden;
	[self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
	
	[super viewDidAppear:animated];
	[self.topToolBar setToolBarShow:YES animation:YES];
	[self.bottomToolBar setToolBarShow:YES animation:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
	
	[super viewWillDisappear:animated];
	[self.navigationController setNavigationBarHidden:_navigationBarHidden animated:NO];
}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

#pragma mark - Method

- (void)toolBarShow:(BOOL)show animation:(BOOL)animation {
	
	[self.topToolBar setToolBarShow:show animation:animation];
	[self.bottomToolBar setToolBarShow:show animation:animation];
	if (self.currentMode == PSEditorModeBrush && self.bottomToolBar.isEditor) {
		[self.colorToolBar setToolBarShow:show animation:animation];
	}
    if (self.currentMode == PSEditorModeMosaic && self.bottomToolBar.isEditor) {
        [self.mosaicToolBar setToolBarShow:show animation:animation];
    }
}

- (void)clippingWithImage:(UIImage *)image {
	
	TOCropViewController *cropController = [[TOCropViewController alloc] initWithCroppingStyle:
											TOCropViewCroppingStyleDefault image:image];
	cropController.delegate = self;
	@weakify(self);
	CGRect viewFrame = [self.view convertRect:self.previewImageView.imageView.frame
									   toView:self.navigationController.view];
	[cropController presentAnimatedFromParentViewController:self
												  fromImage:image
												   fromView:nil
												  fromFrame:viewFrame
													  angle:0
											   toImageFrame:CGRectZero
													  setup:^{
														  @strongify(self);
														  [self.colorToolBar setToolBarShow:NO animation:NO];
														  self.currentMode = PSEditorModeClipping;
														  self.currentBoard = nil;
													  }
												 completion:nil];
}


- (void)buildClipImageCallback:(void(^)(UIImage *clipedImage))clipedCallback {
	
	UIImageView *imageView =  self.previewImageView.imageView;
	UIImageView *drawingView =  self.previewImageView.drawingView;
	
	UIGraphicsBeginImageContextWithOptions(imageView.image.size, NO, imageView.image.scale);
	// 画笔
	[imageView.image drawAtPoint:CGPointZero];
	[drawingView.image drawInRect:CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height)];
	// text
	for (UIView *view in self.view.subviews) {
		if (![view isKindOfClass:[PSTextBoardItem class]]) { return; }
		
		PSTextBoardItem *textLabel = (PSTextBoardItem *)view;
		[PSTextBoardItem setInactiveTextView:textLabel];
		
		CGFloat rotation = [[textLabel.layer valueForKeyPath:@"transform.rotation.z"] doubleValue];
		CGFloat selfRw = imageView.bounds.size.width / imageView.image.size.width;
		CGFloat selfRh = imageView.bounds.size.height / imageView.image.size.height;
		
		dispatch_async(dispatch_get_main_queue(), ^{
			UIImage *textImg = [self screenshot:textLabel];
			textImg = [textImg ps_imageRotatedByRadians:rotation];
			CGFloat sw = textImg.size.width / selfRw;
			CGFloat sh = textImg.size.height / selfRh;
			[textImg drawInRect:CGRectMake(textLabel.frame.origin.x/selfRw, textLabel.frame.origin.y/selfRh, sw, sh)];
		});
	}

	dispatch_async(dispatch_get_main_queue(), ^{
		UIImage *tmp = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		UIImage *image = [UIImage imageWithCGImage:tmp.CGImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
		clipedCallback(image);
	});
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

#pragma mark - Delegate

#pragma mark - TOCropViewControllerDelegate


- (void)cropViewController:(TOCropViewController *)cropViewController
			didCropToImage:(UIImage *)image
				  withRect:(CGRect)cropRect
					 angle:(NSInteger)angle {
	
	UIImage *rectImage = [self.previewImageView.imageView.image ps_imageAtRect:cropRect];
	[self.previewImageView changeImage:rectImage];
	
	if (cropViewController.croppingStyle != TOCropViewCroppingStyleCircular) {
		[cropViewController dismissAnimatedFromParentViewController:self
												   withCroppedImage:image
															 toView:self.previewImageView.imageView
															toFrame:CGRectZero
															  setup:nil
														 completion:nil];
	}else {
		[cropViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
	}
}

#pragma mark - PSColorToolBarDelegate

- (void)colorToolBar:(PSColorToolBar *)toolBar event:(PSColorToolBarEvent)event {

	switch (event) {
	case PSColorToolBarEventSelectColor:
		self.drawingBoard.currentColor = toolBar.currentColor;
		break;
	case PSColorToolBarEventRevocation:
		[self.drawingBoard revocation];
		break;
	default:
		break;
	}
}

#pragma mark - PSTopToolBarDelegate

- (void)topToolBarType:(PSTopToolType)type event:(PSTopToolEvent)event {
	
	if (event == PSTopToolEventCancel) {
		/**
		 增加self.navigationController.viewControllers.count == 1判断
		 解决第一个界面present的，之后都push。在后面的界面也会误判成presen的问题
		 */
		if (self.presentingViewController
			&& self.navigationController.viewControllers.count == 1) {
			[self dismissViewControllerAnimated:YES completion:nil];
		} else {
			[self.navigationController popViewControllerAnimated:YES];
		}
	}else if(event == PSTopToolEventDone) {
		
	}
}

#pragma mark - PSBottomToolBarDelegate

- (void)bottomToolBarType:(PSBottomToolType)type event:(PSBottomToolEvent)event {
	
	switch (event) {
		case PSBottomToolEventBrush:
		self.currentMode = self.bottomToolBar.isEditor ?
					  PSEditorModeBrush:PSEditorModeNone;
		self.currentBoard = self.drawingBoard;
		break;
		case PSBottomToolEventText:
		self.currentMode = self.bottomToolBar.isEditor ?
				      PSEditorModeText:PSEditorModeNone;
		self.currentBoard = self.textBoard;
		break;
		case PSBottomToolEventMosaic:
		self.currentMode = self.bottomToolBar.isEditor ?
					 PSEditorModeMosaic:PSEditorModeNone;
		self.currentBoard = self.mosaicBoard;
		break;
		case PSBottomToolEventClipping:
		self.currentMode = self.bottomToolBar.isEditor ?
					  PSEditorModeClipping:PSEditorModeNone;
		[self buildClipImageCallback:^(UIImage *clipedImage) {
			[self clippingWithImage:clipedImage];
		}];
		break;
	}
}

#pragma mark - PSMosaicToolBarDelegate

- (void)mosaicToolBarType:(PSMosaicType)type event:(PSMosaicToolBarEvent)event {
	
	switch (event) {
		case PSMosaicToolBarEventRectangular:
			[self.mosaicBoard changeRectangularMosaic];
			break;
		case PSMosaicToolBarEventGrindArenaceous:
			[self.mosaicBoard changeGrindArenaceousMosaic];
			break;
		case PSMosaicToolBarEventUndo:
			[self.mosaicBoard undo];
            self.mosaicToolBar.canUndo = [self.mosaicBoard canUndo];
			break;
		default:
			break;
	}
}

#pragma mark - PSTextBoardItemDelegate

- (void)textBoardItem:(PSTextBoardItem *)item
        hiddenToolBar:(BOOL)hidden
            animation:(BOOL)animation {
    
    [self toolBarShow:!hidden animation:animation];
}

- (void)textBoardItem:(PSTextBoardItem *)item
   translationGesture:(UIPanGestureRecognizer *)gesture
           activation:(BOOL)activation {
	
	if (!self.deleteToolBar.isShow && activation) {
		[self.deleteToolBar setToolBarShow:YES animation:YES];
	}else if (self.deleteToolBar.isShow && !activation) {
		[self.deleteToolBar setToolBarShow:NO animation:YES];
	}
    PSTextBoardItem *textBoardItem = gesture.view;
	
    // https://www.jianshu.com/p/92e2d0200eb4
    CGRect rect = [self.view convertRect:textBoardItem.frame fromView:textBoardItem.superview];
    BOOL contains = CGRectIntersectsRect(rect, PSTextBoardItemDeleteCoordinate());
    if (contains) {
        self.deleteToolBar.deleteState = PSBottomToolDeleteStateDid;
        if (!activation) {
			[textBoardItem remove];
		}
    }else {
        self.deleteToolBar.deleteState = PSBottomToolDeleteStateWill;
    }
}

- (BOOL)textBoardItem:(PSTextBoardItem *)item
   restrictedPanAreasAtTextBoard:(PSTextBoard *)textBoard {
	
	CGRect rectCoordinate = [item.superview convertRect:item.frame toView:textBoard.previewView.imageView.superview];
	BOOL hasDeleteCoordinate = CGRectIntersectsRect(PSTextBoardItemDeleteCoordinate(), rectCoordinate);
	BOOL beyondBorder = !CGRectIntersectsRect(CGRectInset(textBoard.previewView.imageView.frame, 30, 30), rectCoordinate);
	
	return beyondBorder && !hasDeleteCoordinate;
}
    
- (void)textBoardItemDidClickItem:(PSTextBoardItem *)item {
    
    [self.colorToolBar setToolBarShow:NO animation:YES];
     [self.textBoard setup];
}

#pragma mark - InitAndLayout

- (void)configUI {
	
	@weakify(self);
	
	PSImageObject *imageObject = [PSImageObject imageObjectWithIndex:0
																url:nil
															  image:self.originImage
														   GIFImage:nil];
	imageObject.editor = YES;
	self.previewImageView = [[PSPreviewImageView alloc] init];
	self.previewImageView.imageObject = imageObject;
	[self.view addSubview:self.previewImageView];
	[self.previewImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.view);
	}];
	
	self.topToolBar = [[PSTopToolBar alloc] initWithType:PSTopToolTypeCancelAndDoneText];
	self.topToolBar.delegate = self;
	[self.topToolBar setToolBarShow:NO animation:NO];
	[self.view addSubview:self.topToolBar];
	[self.topToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
		
		make.left.top.right.equalTo(self.view);
		make.height.equalTo(@PS_NAV_BAR_H);
	}];
	
	self.bottomToolBar = [[PSBottomToolBar alloc] initWithType:PSBottomToolTypeEditor];
	self.bottomToolBar.delegate = self;
	[self.bottomToolBar setToolBarShow:NO animation:NO];
	[self.view addSubview:self.bottomToolBar];
	[self.bottomToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
		
		make.left.bottom.right.equalTo(self.view);
		make.height.equalTo(@(PSBottomToolBarHeight));
	}];
	
	self.colorToolBar = [[PSColorToolBar alloc] initWithType:PSColorToolBarTypeColor];
    self.colorToolBar.delegate = self;
	[self.colorToolBar setToolBarShow:NO animation:NO];
	[self.view addSubview:self.colorToolBar];
	[self.colorToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
		
		make.bottom.equalTo(self.bottomToolBar.mas_top);
		make.left.right.equalTo(self.bottomToolBar);
		make.height.equalTo(@55);
	}];
	
	[self.view addSubview:self.mosaicToolBar];
	[self.mosaicToolBar setToolBarShow:NO animation:NO];
	[self.mosaicToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
		make.bottom.equalTo(self.bottomToolBar.mas_top);
		make.left.right.equalTo(self.bottomToolBar);
		make.height.equalTo(@44);
	}];
    
    self.deleteToolBar = [[PSBottomToolBar alloc] initWithType:PSBottomToolTypeDelete];
	[self.deleteToolBar setToolBarShow:NO animation:NO];
    [self.view addSubview:self.deleteToolBar];
    [self.deleteToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.bottom.right.equalTo(self.view);
        make.height.equalTo(@(PSBottomToolDeleteBarHeight));
    }];
	
//	self.drawingBoard.previewView = self.previewImageView;
//	self.drawingBoard.currentColor = self.colorToolBar.currentColor;;
//	self.drawingBoard.pathWidth = 5.0f;
//
//    self.textBoard.editorView = self.view;
//    self.textBoard.previewView = self.previewImageView;
//    self.textBoard.currentColor = self.colorToolBar.currentColor;
	
    // 默认开启交互
//	self.previewImageView.imageView.userInteractionEnabled = YES;
//    self.previewImageView.drawingView.userInteractionEnabled = YES;
}

#pragma mark - Getter/Setter
	
- (void)setCurrentBoard:(PSBaseDrawingBoard *)currentBoard {
	
	if (_currentBoard != currentBoard) {
		[_currentBoard cleanup];
		_currentBoard = currentBoard;
		_currentBoard.previewView = self.previewImageView;
		_currentBoard.currentColor = self.colorToolBar.currentColor;
		_currentBoard.editorView = self.view;
		[_currentBoard setup];
	}
	
	switch (self.currentMode) {
		case PSEditorModeNone:
		[self.colorToolBar setToolBarShow:NO animation:NO];
		[self.mosaicToolBar setToolBarShow:NO animation:NO];
		[self.bottomToolBar reset];
		[_currentBoard cleanup]; 
		break;
		case PSEditorModeBrush:
        self.drawingBoard.pathWidth = 5.0f;
		[self.mosaicToolBar setToolBarShow:NO animation:NO];
		[self.colorToolBar setToolBarShow:YES animation:YES];
		break;
		case PSEditorModeText:
		[self.colorToolBar setToolBarShow:NO animation:NO];
		[self.mosaicToolBar setToolBarShow:NO animation:NO];
		break;
		case PSEditorModeMosaic:
		[self.colorToolBar setToolBarShow:NO animation:NO];
		[self.mosaicToolBar setToolBarShow:YES animation:YES];
		break;
		case PSEditorModeClipping:
		break;
	}
}
	
- (PSMosaicToolBar *)mosaicToolBar {
	
	return LAZY_LOAD(_mosaicToolBar, ({
		
		_mosaicToolBar = [[PSMosaicToolBar alloc] init];
		_mosaicToolBar.delegate = self;
		_mosaicToolBar.mosaicType = PSMosaicToolBarEventGrindArenaceous;
		_mosaicToolBar;
	}));
}
- (PSMosaicBoard *)mosaicBoard {
	
	return LAZY_LOAD(_mosaicBoard, ({
		@weakify(self);
		_mosaicBoard = [[PSMosaicBoard alloc] init];
		_mosaicBoard.drawEndBlock = ^(BOOL canUndo) {
			@weakify(self);
			self.mosaicToolBar.canUndo = canUndo;
		};
		_mosaicBoard;
	}));
}
	
- (PSTextBoard *)textBoard {
    
    return LAZY_LOAD(_textBoard, ({
		
		@weakify(self);
        _textBoard = [[PSTextBoard alloc] init];
        _textBoard.itemDelegate = self;
		_textBoard.dissmissTextTool = ^(NSString *currentText) {
			@strongify(self);
			self.currentMode = PSEditorModeNone;
			self.currentBoard = nil;
		};
        _textBoard;
    }));
}

- (PSDrawingBoard *)drawingBoard {
    
    return LAZY_LOAD(_drawingBoard, ({
        
        _drawingBoard = [[PSDrawingBoard alloc] init];
        _drawingBoard;
    }));
}

@end
