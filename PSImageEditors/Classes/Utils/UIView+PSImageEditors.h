//
//  UIView+PSImageEditors.h
//  PSImageEditors
//
//  Created by rsf on 2020/8/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (PSImageEditors)

- (UIImage *)captureImageAtFrame:(CGRect)rect;

@end

NS_ASSUME_NONNULL_END
