//
//  PSBrushCache.h
//  PSImageEditors
//
//  Created by rsf on 2020/8/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PSBrushCache : NSCache

+ (instancetype)share;
+ (void)free;

/** 强制缓存对象，不会因数量超出负荷而自动释放 */
- (void)setForceObject:(id)obj forKey:(id)key;

@end

NS_ASSUME_NONNULL_END
