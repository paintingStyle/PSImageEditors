//
//  PSViewController.m
//  PSImageEditors
//
//  Created by rsf on 2018/8/24.
//  Copyright © 2018年 paintingStyle. All rights reserved.
//

#import "PSViewController.h"
#import <PSImageEditor.h>

@interface PSViewController ()<PSImageEditorDelegate,PSImageEditorDataSource>

@property (nonatomic, copy) NSArray *images;
@property (nonatomic, copy) NSArray *urls;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation PSViewController

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (IBAction)imageEditorsDidClicked {

	UIImage *image = [UIImage imageNamed:@"localImage_06@2x.jpg"];
	PSImageEditor *imageEditor = [[PSImageEditor alloc] initWithImage:image
															 delegate:self
														   dataSource:self];
	[self.navigationController pushViewController:imageEditor animated:YES];
}

#pragma mark - PSImageEditorDelegate

- (void)imageEditor:(PSImageEditor *)editor didFinishEdittingWithImage:(UIImage *)image {
	
	self.imageView.image = image;
	[editor dismiss];
	
	NSLog(@"%s",__func__);
}

- (void)imageEditorDidCancel {
	
	NSLog(@"%s",__func__);
}

#pragma mark - PSImageEditorDelegate

- (UIColor *)imageEditorDefaultColor {
    
    return [UIColor redColor];
}

- (CGFloat)imageEditorDrawPathWidth {
	
    return 5;
}

- (UIFont *)imageEditorTextFont {
    
	return [UIFont boldSystemFontOfSize:24];
}

@end
