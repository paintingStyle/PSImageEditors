//
//  PSFilePreviewsViewController.m
//  PSImageEditors
//
//  Created by paintingStyle on 2018/8/25.
//

#import "PSFilePreviewsViewController.h"
#import "PSEditorViewController.h"
#import "PSTopToolBar.h"
#import "PSBottomToolBar.h"
#import "PSActionSheet.h"
#import "PSImageObject.h"

@interface PSFilePreviewsViewController ()
<PSPreviewViewControllerDelegate,
PSTopToolBarDelegate>

@property (nonatomic, strong) PSTopToolBar *topToolBar;
@property (nonatomic, strong) PSBottomToolBar *bottomToolBar;

@property (nonatomic, assign, getter=isShowToolBar) BOOL showToolBar;

@end

@implementation PSFilePreviewsViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
	
	self.delegate = self;
	self.clickShowNavigationBar = NO;
	self.showToolBar = YES;
	
	self.topToolBar = [[PSTopToolBar alloc] initWithType:PSTopToolTypeDefault];
	self.topToolBar.delegate = self;
	[self.view addSubview:self.topToolBar];
	[self.topToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
		
		make.left.top.right.equalTo(self.view);
		make.height.equalTo(@(PS_NAV_BAR_H));
	}];
	
	self.bottomToolBar = [[PSBottomToolBar alloc] initWithType:PSBottomToolTypeDefault];
	[self.view addSubview:self.bottomToolBar];
	[self.bottomToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
		
		make.left.bottom.right.equalTo(self.view);
		make.height.equalTo(@(PSBottomToolBarHeight));
	}];
}

- (void)viewDidAppear:(BOOL)animated {
	
	[super viewDidAppear:animated];
	[self.topToolBar setToolBarShow:YES animation:YES];
	[self.bottomToolBar setToolBarShow:YES animation:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
	
	[super viewWillDisappear:animated];
	[self.topToolBar setToolBarShow:NO animation:YES];
	[self.bottomToolBar setToolBarShow:NO animation:YES];
}

#pragma mark - Method

- (void)showMoreActionSheet {
    
    [PSActionSheet sheetWithActionTitles:@[@"发给送朋友",
                                           @"保存到手机",
                                           @"编辑"
                                           ]
                             actionBlock:^(NSInteger index) {
                                 
                                 switch (index) {
                                         case 0:
                                         break;
                                         case 1:
                                         [self saveCurrentImageToPhotosAlbum];
                                         break;
                                         case 2:
										 [self jumpEditorViewController];
                                         break;
                                     default:
                                         break;
                                 }
                             }];
    
}

- (void)jumpEditorViewController {
	
	UIImage *image = self.currentImageObject.GIFImage ? self.currentImageObject.GIFImage.posterImage:self.currentImageObject.image;
	PSEditorViewController *controller = [[PSEditorViewController alloc] initWithImage:image];
	[self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Delegate

#pragma mark - PSPreviewViewDelegate

- (void)previewViewController:(PSPreviewViewController *)controller
     didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
	
	self.showToolBar = !self.showToolBar;

	[self.topToolBar setToolBarShow:self.showToolBar animation:YES];
	[self.bottomToolBar setToolBarShow:self.showToolBar animation:YES];
}

- (void)previewViewController:(PSPreviewViewController *)controller
	   didScrollAtImageObject:(PSImageObject *)object {
	
	self.topToolBar.title = self.navigationItem.title;
	self.topToolBar.imageObject = object;
	self.bottomToolBar.imageObject = object;
}

#pragma mark - PSTopToolBarDelegate

- (void)topToolBarType:(PSTopToolType)type event:(PSTopToolEvent)event {
	
	switch (event) {
		case PSTopToolEventBack:
			[self.navigationController popViewControllerAnimated:YES];
			break;
		case PSTopToolEventMore:
			[self showMoreActionSheet];
			break;
		default:
			break;
	}
}

#pragma mark - InitAndLayout

- (void)configUI {
	
	
}

#pragma mark - Getter/Setter

@end
