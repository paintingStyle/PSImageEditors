//
//  PSImageEditorsDefine.h
//  Pods
//
//  Created by rsf on 2018/8/24.
//

#if __has_include(<FLAnimatedImage/FLAnimatedImageView.h>)
	#import <FLAnimatedImage/FLAnimatedImageView.h>
	#import <FLAnimatedImage/FLAnimatedImage.h>
#else
	#import "FLAnimatedImageView.h"
	#import "FLAnimatedImage.h"
#endif
#if __has_include(<SDWebImage/UIImageView+WebCache.h>)
	#import <SDWebImage/UIImageView+WebCache.h>
#else
	#import "UIImageView+WebCache.h"
#endif

#define PS_Is_GIFTypeWithData(data)\
({\
BOOL result = NO;\
if(!data) result = NO;\
uint8_t c;\
[data getBytes:&c length:1];\
if(c == 0x47) result = YES;\
(result);\
})

#define iPhone_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define PS_LAYOUT_W(v) ceil(((v)/375.0f * [UIScreen mainScreen].bounds.size.width))
#define PS_LAYOUT_H(v) (iPhone_X ? (ceil(((v)/667.0f * 736.0f))) : (ceil(((v)/667.0f * [UIScreen mainScreen].bounds.size.height))) )

#define PS_SCREEN_W [UIScreen mainScreen].bounds.size.width
#define PS_SCREEN_H [UIScreen mainScreen].bounds.size.height

/**
 兼容iPhone X，导航栏 状态栏 tabar高度
 */
#define PS_STATUS_BAR_H (iPhone_X ? 44.0f: 20.0f)
#define PS_NAV_BAR_H    (iPhone_X ? 88.0f: 64.0f)
#define PS_TAB_BAR_H    (iPhone_X ? 83.0f: 49.0f)
#define PS_COMMON_NUM   44.0f

#define PS_FONT(s) [UIFont fontWithName:@"PingFangSC-Regular" size:s] ? :[UIFont systemFontOfSize:s]
#define PS_HEX_COLOR(x) UIColorFromRGB(0x##x)
#define PS_PLACEHOLDER_COLOR PS_HEX_COLOR(F1F4F6)
#define PS_IMAGE(x) [UIImage PS_personalCardImageNamed:x]

#define PSColorFromRGBA(hexValue, alphaValue) [UIColor \
colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 \
green:((float)((hexValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(hexValue & 0x0000FF))/255.0 \
alpha:alphaValue]

#define PSColorFromRGB(rgbValue) PSColorFromRGBA(rgbValue, 1.0)

#ifndef weakify
#if __has_feature(objc_arc)
	#define weakify(x) autoreleasepool{} __weak __typeof__(x) __weak_##x##__ = x;
#else
	#define weakify(x) autoreleasepool{} __block __typeof__(x) __block_##x##__ = x;
#endif
#endif

#ifndef strongify
#if __has_feature(objc_arc)
	#define strongify(x) try{} @finally{} __typeof__(x)x = __weak_##x##__;
#else
	#define strongify(x) try{} @finally{} __typeof__(x)x = __block_##x##__;
#endif
#endif

/**
 关闭视图的自带间距
 */
#define PS_SCROLLVIEW_INSETS_NO(scrollView)\
if(@available(iOS 11.0, *)) {\
scrollView.contentInsetAdjustmentBehavior =\
UIScrollViewContentInsetAdjustmentNever;\
}else {\
self.automaticallyAdjustsScrollViewInsets = NO;\
}

/**
 解决在iOS11下 heightForHeaderInSection heightForFooterInSection 方法设置无效的情况及刷新抖动的情况
 */
#define PS_TABLEVIEW_FIX(tableView)\
if(@available(iOS 11.0, *)) {\
tableView.estimatedRowHeight = 0;\
tableView.estimatedSectionHeaderHeight = 0;\
tableView.estimatedSectionFooterHeight = 0;\
}

/**
 解决UIImageView的图片居中问题
 */
#define PS_IMAGEVIEW_CENTER_FIX(imageView)\
[imageView setContentScaleFactor:[[UIScreen mainScreen] scale]];\
imageView.contentMode =  UIViewContentModeScaleAPSectFill;\
imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;\
imageView.clipsToBounds  = YES;\

#define PS_RGBA_COLOR(r, g, b, a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

#define PS_RANDOM_COLOR PS_RGB_COLOR(arc4random_uniform(256.0),arc4random_uniform(256.0),arc4random_uniform(256.0))

#define PS_WINDOOW [UIApplication sharedApplication].delegate.window

#define PS_STROKE_PARAMETER(View, Radius, Width, Color)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES];\
[View.layer setBorderWidth:(Width)];\
[View.layer setBorderColor:[Color CGColor]]

#define PS_CIRCULAR_PARAMETER(View,Radius)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES]

#define USE_CIRCULAR_FORVIEW(View)\
\
[View.layer setCornerRadius:View.frame.size.width *0.5];\
[View.layer setMasksToBounds:YES]

#define LAZY_LOAD(object, assignment) (object = object ?: assignment)

#define diPSatch_async_main_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
diPSatch_async(diPSatch_get_main_queue(), block);\
}

#define FormatString(format,...) [NSString stringWithFormat:format,##__VA_ARGS__]

#define LOG_FRAME(f)   NSLog(@"%@",NSStringFromCGRect(f));
#define LOG_SIZE(s)    NSLog(@"%@",NSStringFromCGSize(s))
#define LOG_RANGE(r)   NSLog(@"%@",NSStringFromRange(r))
#define LOG_CGPOINT(p) NSLog(@"%@",NSStringFromCGPoint(p))
#define LOG_EDGEINSETS(e) NSLog(@"%@",NSStringFromUIEdgeInsets(e))
#define LOG_FUNC       NSLog(@"%s",__func__);

#define LOG_IsMainThread \
BOOL isMainThread = [NSThread isMainThread];\
NSLog(@"当前线程为%@线程!",isMainThread ? @"主":@"子");\

#define LOG_FONTFAMILY_NAMEES NSArray *familyNames = [UIFont familyNames];\
for(NSString *familyName in familyNames) {\
NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];\
for(NSString *fontName in fontNames){\
printf( "\tfontName: %s \n", [fontName UTF8String] );\
}\
}

#define DEBUG_VIEW(v)\
if ([v isKindOfClass:[UIView class]]) {\
[v.subviews enumerateObjectsUsingBlock:\
^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {\
if (![obj isKindOfClass:[UIView class]]) {\
return;\
}\
int r = arc4random() % 255;\
int g = arc4random() % 255;\
int b = arc4random() % 255;\
obj.backgroundColor = [UIColor colorWithRed:(r/255.0)\
green:(g/255.0)\
blue:(b/255.0)\
alpha:1.0];\
}];\
}\

