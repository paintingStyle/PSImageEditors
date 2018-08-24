//
//  PSImageObject.h
//  Pods-PSImageEditors
//
//  Created by rsf on 2018/8/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PSImageObject : NSObject

@property (nonatomic, assign, readonly) NSInteger index;
@property (nonatomic, copy, readonly)   NSURL *url;

@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, strong, nullable, readonly) FLAnimatedImage *GIFImage;

+ (instancetype)imageObjectWithIndex:(NSInteger)index
								 url:(NSURL *)url
							   image:(UIImage *)image
							GIFImage:(FLAnimatedImage *)GIFImage;

@end

NS_ASSUME_NONNULL_END
