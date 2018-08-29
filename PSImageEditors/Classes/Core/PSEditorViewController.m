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

@interface PSEditorViewController ()
<PSTopToolBarDelegate,
PSBottomToolBarDelegate> {
	BOOL _navigationBarHidden;
}

@property (nonatomic, strong) UIImage *originImage;
@property (nonatomic, strong) PSPreviewImageView *imageView;

@property (nonatomic, strong) PSTopToolBar *topToolBar;
@property (nonatomic, strong) PSBottomToolBar *bottomToolBar;
@property (nonatomic, strong) PSColorToolBar *colorToolBar;

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
	self.imageView.singleGestureDidClickBlock = ^{
		@strongify(self);
		BOOL show = !self.topToolBar.show;
		[self.topToolBar setToolBarShow:show animation:YES];
		[self.bottomToolBar setToolBarShow:show animation:YES];
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

#pragma mark - Method

#pragma mark - Delegate

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
			break;
		case PSBottomToolEventText:
			break;
		case PSBottomToolEventMosaic:
			break;
		case PSBottomToolEventClipping:
			break;
	}
}

#pragma mark - InitAndLayout

- (void)configUI {
	
	self.imageView = [[PSPreviewImageView alloc] init];
	self.imageView.image = self.originImage;
	[self.view addSubview:self.imageView];
	[self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
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
		make.height.equalTo(@PS_TAB_BAR_H);
	}];
	
	self.colorToolBar = [[PSColorToolBar alloc] initWithType:PSColorToolBarTypeColor];
	[self.colorToolBar setToolBarShow:NO animation:NO];
	[self.view addSubview:self.colorToolBar];
	[self.colorToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
		
		make.bottom.equalTo(self.bottomToolBar.mas_top);
		make.left.right.equalTo(self.bottomToolBar);
		make.height.equalTo(@55);
	}];
}

#pragma mark - Getter/Setter

@end