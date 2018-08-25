//
//  PSFilePreviewsViewController.m
//  PSImageEditors
//
//  Created by paintingStyle on 2018/8/25.
//

#import "PSFilePreviewsViewController.h"
#import "PSTopToolBar.h"
#import "PSBottomToolBar.h"
#import "PSActionSheet.h"

@interface PSFilePreviewsViewController ()<PSPreviewViewControllerDelegate>

@property (nonatomic, strong) PSTopToolBar *topToolBar;
@property (nonatomic, strong) PSBottomToolBar *bottomToolBar;

@end

@implementation PSFilePreviewsViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configUI];
    [self configData];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
}

#pragma mark - Method

- (void)configData {
    
    [super configData];
}

- (void)morebuttonDidClick {
    
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
                                         break;
                                     default:
                                         break;
                                 }
                             }];
    
}

#pragma mark - Delegate

#pragma mark - PSPreviewViewDelegate

- (void)previewViewController:(PSPreviewViewController *)controller
     didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    BOOL hidden = !self.topToolBar.hidden;
    
    [self.topToolBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(hidden ? -PS_NAV_BAR_H:0);
    }];
    [self.bottomToolBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(hidden ? 50:0);
    }];
    
    [UIView animateWithDuration:0.25f
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.topToolBar.hidden = hidden;
                         self.bottomToolBar.hidden = hidden;
                         [self.view layoutIfNeeded];
                     } completion:nil];
}

#pragma mark - InitAndLayout

- (void)configUI {
    
    [super configUI];
    self.delegate = self;
    self.clickShowNavigationBar = NO;
   
    self.topToolBar = [[PSTopToolBar alloc] initWithType:PSTopToolTypeDefault];
    [self.view addSubview:self.topToolBar];
    [self.topToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.top.right.equalTo(self.view);
        make.height.equalTo(@(PS_NAV_BAR_H));
    }];
    
    self.bottomToolBar = [[PSBottomToolBar alloc] initWithType:PSBottomToolTypeDefault];
    [self.view addSubview:self.bottomToolBar];
    [self.bottomToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.bottom.right.equalTo(self.view);
        make.height.equalTo(@(50));
    }];
}

#pragma mark - Getter/Setter

@end
