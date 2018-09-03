//
//  PSBaseDrawingBoard.h
//  PSImageEditors
//
//  Created by paintingStyle on 2018/8/29.
//

#import <Foundation/Foundation.h>
#import "PSPreviewImageView.h"

@interface PSBaseDrawingBoard : NSObject

@property (nonatomic, strong) UIColor *currentColor;
@property (nonatomic, strong) PSPreviewImageView *previewView;
@property (nonatomic, weak)   UIView *editorView;

- (void)setup;
- (void)cleanup;

- (void)executeWithCompletionBlock:(void(^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock;

@end
