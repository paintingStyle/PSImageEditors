//
//  PSColorFullButton.h
//  PSImageEditors
//
//  Created by rsf on 2018/8/29.
//

#import <UIKit/UIKit.h>

@interface PSColorFullButton : UIButton

// 绘制需要获取到self.bounds
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) BOOL isUse;

@end

