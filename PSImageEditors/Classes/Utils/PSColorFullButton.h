//
//  PSColorFullButton.h
//  PSImageEditors
//
//  Created by rsf on 2018/8/29.
//

#import <UIKit/UIKit.h>

@interface PSColorFullButton : UIButton

@property (nonatomic, assign) BOOL isUse;
@property (nonatomic, strong, readonly) UIColor *color;

- (instancetype)initWithFrame:(CGRect)frame radius:(CGFloat)radius color:(UIColor *)color;

@end

