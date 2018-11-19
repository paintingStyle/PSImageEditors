//
//  PSImageEditorDefine.h
//  Pods
//
//  Created by paintingStyle on 2018/11/15.
//

#ifndef PSImageEditorDefine_h
#define PSImageEditorDefine_h

#define PSTopToolBarHeight PS_NAV_BAR_H
#define PSBottomToolBarHeight PS_TAB_BAR_H +6
#define PSBottomToolDeleteBarHeight PS_TAB_BAR_H +16
#define PSDrawColorToolBarHeight 55
#define PSTextColorToolBarHeight 48

#define PS_SCREEN_W [UIScreen mainScreen].bounds.size.width
#define PS_SCREEN_H [UIScreen mainScreen].bounds.size.height
/// 手机机型为iPhoneX或以后的系列机型
#define PS_IPHONE_X_FUTURE_MODELS (PS_SCREEN_H >= 812.0f)

///  兼容iPhone X,状态栏 tabar高度
#define PS_STATUS_BAR_H [[UIApplication sharedApplication] statusBarFrame].size.height
#define PS_NAV_BAR_H    (PS_IPHONE_X_FUTURE_MODELS ? 88.0f: 64.0f)
#define PS_TAB_BAR_H     (PS_IPHONE_X_FUTURE_MODELS ? 83.0f: 49.0f)
#define PS_COMMON_NUM     44.0f

/// iPhoneX顶部安全距离
#define PS_SAFEAREA_TOP_DISTANCE (PS_IPHONE_X_FUTURE_MODELS ? 24 : 0)
/// iPhoneX底部安全距离
#define PS_SAFEAREA_BOTTOM_DISTANCE (PS_IPHONE_X_FUTURE_MODELS ? 34 : 0)

#define LAZY_LOAD(object, assignment) (object = object ?: assignment)
#define PSColorFromRGB(rgbValue) PSColorFromRGBA(rgbValue, 1.0)
#define PSColorFromRGBA(hexValue, alphaValue) [UIColor \
colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 \
green:((float)((hexValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(hexValue & 0x0000FF))/255.0 \
alpha:alphaValue]

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


#define LOG_FRAME(f)   NSLog(@"%@",NSStringFromCGRect(f));
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

#endif /* PSImageEditorDefine_h */
