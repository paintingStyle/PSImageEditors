//
//  PSCropViewController.m
//  PSImageEditors
//
//  Created by rsf on 2020/9/14.
//

#import "PSCropViewController.h"

@interface PSCropViewController ()

@property (nonatomic, strong) UIButton *closeButton;

@end

@implementation PSCropViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	TOCropToolbar *toolbar = self.toolbar;

	[toolbar.doneTextButton setImage:[UIImage ps_imageNamed:@"btn_done"] forState:UIControlStateNormal];
	[toolbar.cancelTextButton setImage:[UIImage ps_imageNamed:@"btn_revocation_normal"] forState:UIControlStateNormal];
	[toolbar.doneTextButton setTitle:nil forState:UIControlStateNormal];
	[toolbar.cancelTextButton setTitle:nil forState:UIControlStateNormal];
	[toolbar.doneTextButton setTintColor:[UIColor whiteColor]];
	[toolbar.cancelTextButton setTintColor:[UIColor whiteColor]];
	[toolbar.cancelTextButton addTarget:self action:@selector(undoButtonClick) forControlEvents:UIControlEventTouchUpInside];
	toolbar.cancelTextButton.enabled = NO;
	
	self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.closeButton setImage:[self cancelImage] forState:UIControlStateNormal];
	[self.closeButton addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:self.closeButton];
	
	[self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(@(10));
		make.left.equalTo(@10);
		make.size.equalTo(@44);
	}];
	
	
	__weak typeof(self) weakSelf = self;
   self.toolbar.cancelButtonTapped = ^{
	   [weakSelf undoButtonClick];
   };
	
	/*
	 TOCropView
	 - (void)checkForCanReset
	 [[NSNotificationCenter defaultCenter] postNotificationName:@"TOCheckForCanReset" object:@(canReset)];
	 */
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(checkForCanReset:)
												 name:@"TOCheckForCanReset"
											   object:nil];
	
	
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)checkForCanReset:(NSNotification *)noti {
	
	BOOL canBeReset = [noti.object boolValue];
	self.toolbar.cancelTextButton.enabled = canBeReset;
}

- (void)undoButtonClick {
	[self performSelector:@selector(resetCropViewLayout)];
}

- (void)closeButtonClick {
	[self performSelector:@selector(cancelButtonTapped)];
}

- (void)viewDidLayoutSubviews {
	
	[super viewDidLayoutSubviews];
}

#pragma mark - Method

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

#pragma mark - Delegate

#pragma mark - InitAndLayout

#pragma mark - Getter/Setter

@end
