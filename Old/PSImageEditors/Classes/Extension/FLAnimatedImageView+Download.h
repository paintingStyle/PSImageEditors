//
//  FLAnimatedImageView+Download.h
//  PSImageEditors
//
//  Created by rsf on 2018/8/31.
//

#import "FLAnimatedImageView.h"

typedef void(^PSDownloadCompletionBlock)(id _Nullable image, NSError * _Nullable error, NSURL * _Nullable imageURL);

@interface FLAnimatedImageView (Download)

- (void)ps_setImageWithURL:(NSURL *)url completed:(PSDownloadCompletionBlock)completed;

@end
