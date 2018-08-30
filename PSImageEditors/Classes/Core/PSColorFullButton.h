//
//  PSColorFullButton.h
//  PSImageEditors
//
//  Created by rsf on 2018/8/29.
//

#import <UIKit/UIKit.h>
#import "PSExpandClickAreaButton.h"

@interface PSColorFullButton : PSExpandClickAreaButton

// 绘制需要获取到self.bounds
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) BOOL isUse;

@end

