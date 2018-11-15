//
//  PSBaseDrawingBoard.m
//  PSImageEditors
//
//  Created by paintingStyle on 2018/8/29.
//

#import "PSBaseDrawingBoard.h"

@interface PSBaseDrawingBoard()

@property (nonatomic, assign, readwrite, getter=isEditor) BOOL editor;
	
@end

@implementation PSBaseDrawingBoard

- (void)setup {
	self.editor = YES;
	self.previewView.imageView.userInteractionEnabled = YES;
    self.previewView.drawingView.userInteractionEnabled = YES;
}
	
- (void)cleanup {
	self.editor = NO;
	self.previewView.imageView.userInteractionEnabled = NO;
    self.previewView.drawingView.userInteractionEnabled = NO;
}

- (void)executeWithCompletionBlock:(void(^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock {
    
    //completionBlock(self.editor.imageView.image, nil, nil);
}

@end
