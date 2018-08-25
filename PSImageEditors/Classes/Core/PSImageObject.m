//
//  PSImageObject.m
//  Pods-PSImageEditors
//
//  Created by rsf on 2018/8/24.
//

#import "PSImageObject.h"

@interface PSImageObject()

@property (nonatomic, assign, readwrite) NSInteger index;
@property (nonatomic, copy, readwrite)   NSURL *url;

@property (nonatomic, strong, readwrite) UIImage *image;
@property (nonatomic, strong, nullable, readwrite) FLAnimatedImage *GIFImage;

@end

@implementation PSImageObject

+ (instancetype)imageObjectWithIndex:(NSInteger)index
								 url:(NSURL *)url
							   image:(UIImage *)image
							GIFImage:(FLAnimatedImage *)GIFImage {
	
	PSImageObject *imageObject = [[PSImageObject alloc] init];
	imageObject.index = index;
	imageObject.url = url;
	imageObject.image = image;
	imageObject.GIFImage = GIFImage;
	
	return imageObject;
}

- (void)updateImage:(id)image {
    
    if ([image isKindOfClass:[FLAnimatedImage class]]) {
        self.GIFImage = image;
    }else {
        self.image = image;
    }
}

@end
