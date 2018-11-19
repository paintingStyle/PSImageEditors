//
//  PSClippingTool.m
//  PSImageEditors
//
//  Created by rsf on 2018/11/16.
//

#import "PSClippingTool.h"
#import "TOCropViewController.h"

@interface PSClippingTool()<TOCropViewControllerDelegate>

@end

@implementation PSClippingTool

#pragma mark - Subclasses Override

- (void)setup {

	[self.editor buildClipImageCallback:^(UIImage *clipedImage) {
		[self clippingWithImage:clipedImage];
	}];
}

- (void)cleanup {
	
}

#pragma mark - Method

- (void)clippingWithImage:(UIImage *)image {
	
	TOCropViewController *cropController = [[TOCropViewController alloc] initWithCroppingStyle:
											TOCropViewCroppingStyleDefault image:image];
	cropController.aspectRatioPickerButtonHidden = YES;
	cropController.delegate = self;
	CGRect viewFrame = [self.editor.view convertRect:self.editor.imageView.frame
									   toView:self.editor.navigationController.view];
	[cropController presentAnimatedFromParentViewController:self.editor
												  fromImage:image
												   fromView:nil
												  fromFrame:viewFrame
													  angle:0
											   toImageFrame:CGRectZero
													  setup:nil
												 completion:nil];
}

#pragma mark - TOCropViewControllerDelegate


- (void)cropViewController:(TOCropViewController *)cropViewController
			didCropToImage:(UIImage *)image
				  withRect:(CGRect)cropRect
					 angle:(NSInteger)angle {
	
	UIImage *rectImage = [self.editor.imageView.image ps_imageAtRect:cropRect];
	if (self.clipedCompleteBlock) { self.clipedCompleteBlock(rectImage, cropRect); }
	
	if (cropViewController.croppingStyle != TOCropViewCroppingStyleCircular) {
		[cropViewController dismissAnimatedFromParentViewController:self.editor
												   withCroppedImage:image
															 toView:self.editor.imageView
															toFrame:CGRectZero
															  setup:nil
														 completion:nil];
	}else {
		[cropViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
	}
}

@end
