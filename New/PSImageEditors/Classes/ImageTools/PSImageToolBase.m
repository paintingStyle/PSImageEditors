//
//  PSImageToolBase.m
//  PSImageEditors
//
//  Created by rsf on 2018/11/16.
//  Copyright © 2018年 paintingStyle. All rights reserved.
//

#import "PSImageToolBase.h"

@implementation PSImageToolBase

- (instancetype)initWithImageEditor:(_PSImageEditorViewController *)editor
						 withOption:(NSDictionary *)option {
	if(self =  [super init]){
		self.editor = editor;
		self.option = option;
	}
	return self;
}

- (void)initialize {}

- (void)setup {}

- (void)cleanup {}

- (void)resetRect:(CGRect)rect {};

- (void)executeWithCompletionBlock:(void(^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock {
	completionBlock(self.editor.imageView.image, nil, nil);
}

@end
