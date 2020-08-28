//
//  CALayer+PSBrush.m
//  PSImageEditors
//
//  Created by rsf on 2020/8/24.
//

#import "CALayer+PSBrush.h"
#import <objc/runtime.h>

static const char * PSBrushLayerLevelKey = "PSBrushLayerLevelKey";

@implementation CALayer (PSBrush)

- (void)setPs_level:(NSInteger)ps_level
{
    objc_setAssociatedObject(self, PSBrushLayerLevelKey, @(ps_level), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)ps_level
{
    NSNumber *num = objc_getAssociatedObject(self, PSBrushLayerLevelKey);
    if (num != nil) {
        return [num integerValue];
    }
    return 0;
}

@end
