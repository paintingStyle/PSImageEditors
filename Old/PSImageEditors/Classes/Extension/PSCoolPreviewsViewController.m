//
//  PSCoolPreviewsViewController.m
//  PSImageEditors
//
//  Created by paintingStyle on 2018/8/25.
//  Copyright © 2018年 paintingStyle. All rights reserved.
//

#import "PSCoolPreviewsViewController.h"
#import "PSImageObject.h"
#import "PSImageEditorsHelper.h"
#import "PSActionSheet.h"
#import "UIAlertController+PSExtension.h"

@interface PSCoolPreviewsViewController ()<PSPreviewViewControllerDelegate>

@end

@implementation PSCoolPreviewsViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
	
	self.delegate = self;
	self.clickShowNavigationBar = NO;
	
	/***
	 https://www.cnblogs.com/CodingMann/p/5511869.html
	 用来将约束添加到view。在添加时唯一要注意的是添加的目标view要遵循以下规则：
	 对于两个同层级view之间的约束关系，添加到他们的父view上
	 对于两个不同层级view之间的约束关系，添加到他们最近的共同父view上
	 对于有层次关系的两个view之间的约束关系，添加到层次较高的父view上
	 */
	
	UIButton *morebutton = [[UIButton alloc] init];
	morebutton.translatesAutoresizingMaskIntoConstraints = NO;
	morebutton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
	[morebutton setImage:[UIImage ps_imageNamed:@"btn_coolPreviews_more"] forState:UIControlStateNormal];
	[morebutton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
	[morebutton addTarget:self action:@selector(morebuttonDidClick) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:morebutton];
	
	NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:morebutton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:18+PS_STATUS_BAR_H];
	NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:morebutton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-18];
	[self.view addConstraints:@[topConstraint, rightConstraint]];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
}

#pragma mark - Method

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
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - InitAndLayout

#pragma mark - Getter/Setter

@end
