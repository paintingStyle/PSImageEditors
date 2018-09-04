//
//  PSEditorViewController.m
//  PSImageEditors
//
//  Created by rsf on 2018/8/29.
//

#import "PSEditorViewController.h"
#import "PSTopToolBar.h"
#import "PSBottomToolBar.h"
#import "PSColorToolBar.h"
#import "PSPreviewImageView.h"
#import "PSDrawingBoard.h"
#import "PSTextBoard.h"
#import "PSImageObject.h"

@interface PSEditorViewController ()
<PSTopToolBarDelegate,
PSBottomToolBarDelegate,
PSColorToolBarDelegate,
PSTextBoardItemDelegate> {
	BOOL _navigationBarHidden;
}

@property (nonatomic, strong) UIImage *originImage;
@property (nonatomic, strong) PSPreviewImageView *previewImageView;

@property (nonatomic, strong) PSTopToolBar *topToolBar;
@property (nonatomic, strong) PSBottomToolBar *bottomToolBar;
@property (nonatomic, strong) PSColorToolBar *colorToolBar;

@property (nonatomic, strong) PSBottomToolBar *deleteToolBar;

@property (nonatomic, strong) PSDrawingBoard *drawingBoard;
@property (nonatomic, strong) PSTextBoard *textBoard;

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
        self.colorToolBar.revocation = canPrev;
    };
    self.drawingBoard.drawingCallback = ^(BOOL isDrawing) {
        @strongify(self);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((isDrawing ? 0:0.5) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self toolBarShow:!isDrawing animation:NO];
        });
    };
    
    self.textBoard.dissmissTextTool = ^(NSString *currentText) {
        @strongify(self);
        [self.textBoard cleanup];
        if (self.bottomToolBar.isEditor) { // 判断待改进
            [self.colorToolBar setToolBarShow:YES animation:YES];
        }
        [self.bottomToolBar resetStateWithEvent:PSBottomToolEventText];
        self.currentMode = PSEditorModeNone;
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
	if (self.bottomToolBar.isEditor) {
		[self.colorToolBar setToolBarShow:show animation:animation];
	}
}

#pragma mark - Delegate

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
			[self.colorToolBar setToolBarShow:self.bottomToolBar.isEditor animation:YES];
			if (self.bottomToolBar.isEditor) {
				[self.drawingBoard setup];
			}else {
				[self.drawingBoard cleanup];
			}
            self.currentMode = PSEditorModeBrush;
			break;
		case PSBottomToolEventText:
            [self.colorToolBar setToolBarShow:NO animation:YES];
            if (self.bottomToolBar.isEditor) {
                [self.textBoard setup];
            }else {
                [self.textBoard cleanup];
            }
            self.currentMode = PSEditorModeText;
			break;
		case PSBottomToolEventMosaic:
            self.currentMode = PSEditorModeMosaic;
			break;
		case PSBottomToolEventClipping:
            self.currentMode = PSEditorModeClipping;
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
    
    self.deleteToolBar.hidden = !activation;
    PSTextBoardItem *textBoardItem = gesture.view;
    
    // https://www.jianshu.com/p/92e2d0200eb4
    CGRect rect = [self.view convertRect:textBoardItem.frame fromView:textBoardItem.superview];
    BOOL contains = CGRectIntersectsRect(rect, self.deleteToolBar.frame);
    if (contains) {
        self.deleteToolBar.deleteState = PSBottomToolDeleteStateDid;
        if (!activation) { [textBoardItem remove]; }
    }else {
        self.deleteToolBar.deleteState = PSBottomToolDeleteStateWill;
    }
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
    
    self.deleteToolBar = [[PSBottomToolBar alloc] initWithType:PSBottomToolTypeDelete];
    self.deleteToolBar.hidden = YES;
    [self.view addSubview:self.deleteToolBar];
    [self.deleteToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.bottom.right.equalTo(self.view);
        make.height.equalTo(@(PSBottomToolBarHeight));
    }];
	
	self.drawingBoard.previewView = self.previewImageView;
	self.drawingBoard.currentColor = self.colorToolBar.currentColor;;
	self.drawingBoard.pathWidth = 5.0f;
    
    self.textBoard.editorView = self.view;
    self.textBoard.previewView = self.previewImageView;
    self.textBoard.currentColor = self.colorToolBar.currentColor;
    
    // 默认开启交互
	self.previewImageView.imageView.userInteractionEnabled = YES;
    self.previewImageView.drawingView.userInteractionEnabled = YES;
}

#pragma mark - Getter/Setter

- (PSTextBoard *)textBoard {
    
    return LAZY_LOAD(_textBoard, ({
        
        _textBoard = [[PSTextBoard alloc] init];
        _textBoard.itemDelegate = self;
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
