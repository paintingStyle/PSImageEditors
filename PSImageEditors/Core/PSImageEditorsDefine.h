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

#define PSIsGIFTypeWithData(data)\
({\
BOOL result = NO;\
if(!data) result = NO;\
uint8_t c;\
[data getBytes:&c length:1];\
if(c == 0x47) result = YES;\
(result);\
})

#define PS_SCROLLVIEWINSETS_NO(scrollView)\
if(@available(iOS 11.0, *)) {\
scrollView.contentInsetAdjustmentBehavior =\
UIScrollViewContentInsetAdjustmentNever;\
}else {\
self.automaticallyAdjustsScrollViewInsets = NO;\
}
