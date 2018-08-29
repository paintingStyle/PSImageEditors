//
//  PSBaseDrawingBoard.m
//  PSImageEditors
//
//  Created by paintingStyle on 2018/8/29.
//

#import "PSBaseDrawingBoard.h"

@implementation PSBaseDrawingBoard

- (void)setup {}
- (void)cleanup {}

- (void)executeWithCompletionBlock:(void(^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock {
    
    //completionBlock(self.editor.imageView.image, nil, nil);
}

@end
