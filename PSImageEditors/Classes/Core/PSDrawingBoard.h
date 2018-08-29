//
//  PSDrawingBoard.h
//  PSImageEditors
//
//  Created by rsf on 2018/8/29.
//

#import <Foundation/Foundation.h>

@interface PSDrawingBoard : NSObject

- (void)setup;
- (void)cleanup;

- (void)executeWithCompletionBlock:(void(^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock;

@end


