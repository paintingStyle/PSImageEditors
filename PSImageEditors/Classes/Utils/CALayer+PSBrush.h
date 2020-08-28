//
//  CALayer+PSBrush.h
//  PSImageEditors
//
//  Created by rsf on 2020/8/24.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface CALayer (PSBrush)

/** 层级（区分不同的画笔所画的图层） */
@property (nonatomic, assign) NSInteger ps_level;

@end

NS_ASSUME_NONNULL_END
