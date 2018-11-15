//
//  PSImageEditor.m
//  PSImageEditors
//
//  Created by paintingStyle on 2018/11/15.
//

#import "PSImageEditor.h"
#import "_PSImageEditorViewController.h"

@interface PSImageEditor ()

@end

@implementation PSImageEditor

- (instancetype)initWithImage:(UIImage *)image {
    return [self initWithImage:image delegate:nil dataSource:nil];
}

- (instancetype)initWithImage:(UIImage*)image
                     delegate:(id<PSImageEditorDelegate>)delegate
                   dataSource:(id<PSImageEditorDataSource>)dataSource {
    
    return [[_PSImageEditorViewController alloc] initWithImage:image delegate:delegate dataSource:dataSource];
}

- (void)refreshToolSettings {
    
}

@end
