//
//  PSNavigationController.m
//  PSImageEditors
//
//  Created by paintingStyle on 2018/8/25.
//  Copyright © 2018年 paintingStyle. All rights reserved.
//

#import "PSNavigationController.h"
//#import <UIImage+PSImageEditors.h>

#define UIColorFromRGBA(rgbValue, alphaValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:alphaValue]

@interface PSNavigationController ()

@end

@implementation PSNavigationController

+ (void)initialize {
    
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    [navigationBarAppearance setTitleTextAttributes:@{
                                                      NSForegroundColorAttributeName:[UIColor whiteColor],
                                                      NSFontAttributeName:[UIFont systemFontOfSize:17.0f]
                                                      }];
    navigationBarAppearance.tintColor = UIColorFromRGBA(0x000000, 1.0f);
    navigationBarAppearance.barTintColor =  UIColorFromRGBA(0x000000, 1.0f);
	
}

#pragma mark - 拦截控制器跳转

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
        UIButton *btn = [[UIButton alloc] init];
        [btn setFrame:CGRectMake(0, 0, 44, 44)];
        btn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        //[btn setImage:[UIImage ps_imageNamed:@"btn_navBar_back"] forState:UIControlStateNormal];
        [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [btn addTarget:self action:@selector(backButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
    [self.viewControllers.lastObject.view endEditing:YES];
    
    CGRect frame = self.tabBarController.tabBar.frame;
    frame.origin.y = [UIScreen mainScreen].bounds.size.height - frame.size.height;
    self.tabBarController.tabBar.frame = frame;
    
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    
    return [super popViewControllerAnimated:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return [self.topViewController preferredStatusBarStyle];
}

- (BOOL)prefersStatusBarHidden {
    
    return [self.topViewController prefersStatusBarHidden];;
}

- (void)backButtonDidClick {
    
    [self popViewControllerAnimated:YES];
}

@end
