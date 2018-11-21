//
//  PSClippingTool.h
//  PSImageEditors
//
//  Created by rsf on 2018/11/16.
//

#import "PSImageToolBase.h"

@interface PSClippingTool : PSImageToolBase

@property (nonatomic, copy) void (^clipedCompleteBlock) (UIImage *image, CGRect cropRect);
@property (nonatomic, assign) BOOL presentCropViewController;

@end
