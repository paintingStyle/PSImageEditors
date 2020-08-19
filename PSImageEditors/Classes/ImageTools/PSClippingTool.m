//
//  PSClippingTool.m
//  PSImageEditors
//
//  Created by rsf on 2018/11/16.
//

#import "PSClippingTool.h"
#import "TOCropViewController.h"
#import "UIImage+CropRotate.h"

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
	
	
	TOCropToolbar *toolbar = cropController.toolbar;
	
	[toolbar.doneTextButton setImage:[self doneImage] forState:UIControlStateNormal];
	[toolbar.cancelTextButton setImage:[self cancelImage] forState:UIControlStateNormal];
	[toolbar.doneTextButton setTitle:nil forState:UIControlStateNormal];
	[toolbar.cancelTextButton setTitle:nil forState:UIControlStateNormal];
	[toolbar.doneTextButton setTintColor:[UIColor whiteColor]];
	[toolbar.cancelTextButton setTintColor:[UIColor whiteColor]];
	
	
	cropController.aspectRatioPickerButtonHidden = YES;
	cropController.delegate = self;
	CGRect viewFrame = [self.editor.view convertRect:self.editor.imageView.frame
									   toView:self.editor.navigationController.view];
	[cropController presentAnimatedFromParentViewController:self.editor
												  fromImage:image
												   fromView:self.editor.imageView
												  fromFrame:viewFrame
													  angle:0
											   toImageFrame:CGRectZero
													  setup:^{
												 [UIApplication sharedApplication].statusBarHidden = YES;
													  } completion:nil];
}

- (UIImage *)doneImage
{
    UIImage *doneImage = nil;
    
    UIGraphicsBeginImageContextWithOptions((CGSize){17,14}, NO, 0.0f);
    {
        //// Rectangle Drawing
        UIBezierPath* rectanglePath = UIBezierPath.bezierPath;
        [rectanglePath moveToPoint: CGPointMake(1, 7)];
        [rectanglePath addLineToPoint: CGPointMake(6, 12)];
        [rectanglePath addLineToPoint: CGPointMake(16, 1)];
        [UIColor.whiteColor setStroke];
        rectanglePath.lineWidth = 2;
        [rectanglePath stroke];
        
        
        doneImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return doneImage;
}

- (UIImage *)cancelImage
{
    UIImage *cancelImage = nil;
    
    UIGraphicsBeginImageContextWithOptions((CGSize){16,16}, NO, 0.0f);
    {
        UIBezierPath* bezierPath = UIBezierPath.bezierPath;
        [bezierPath moveToPoint: CGPointMake(15, 15)];
        [bezierPath addLineToPoint: CGPointMake(1, 1)];
        [UIColor.whiteColor setStroke];
        bezierPath.lineWidth = 2;
        [bezierPath stroke];
        
        
        //// Bezier 2 Drawing
        UIBezierPath* bezier2Path = UIBezierPath.bezierPath;
        [bezier2Path moveToPoint: CGPointMake(1, 15)];
        [bezier2Path addLineToPoint: CGPointMake(15, 1)];
        [UIColor.whiteColor setStroke];
        bezier2Path.lineWidth = 2;
        [bezier2Path stroke];
        
        cancelImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return cancelImage;
}


#pragma mark - TOCropViewControllerDelegate


- (void)cropViewController:(TOCropViewController *)cropViewController
			didCropToImage:(UIImage *)image
				  withRect:(CGRect)cropRect
					 angle:(NSInteger)angle {
	
	UIImage *rectImage = image;//[self.editor.imageView.image ps_imageAtRect:cropRect];
	self.produceChanges = YES;
	if (self.clipedCompleteBlock) { self.clipedCompleteBlock(rectImage, cropRect); }
	
	if (cropViewController.croppingStyle != TOCropViewCroppingStyleCircular) {
		[cropViewController dismissAnimatedFromParentViewController:self.editor
												   withCroppedImage:image
															 toView:self.editor.imageView
															toFrame:CGRectZero
															  setup:^{
														[UIApplication sharedApplication].statusBarHidden = NO;
															  } completion:nil];
	}else {
		[cropViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
	}
}

@end
