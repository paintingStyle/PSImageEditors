//
//  UIImage+PSImageEditors.m
//  PSImageEditors
//
//  Created by paintingStyle on 2018/8/25.
//

#import "UIImage+PSImageEditors.h"

@implementation UIImage (PSImageEditors)

+ (UIImage *)ps_imageNamed:(NSString *)name {
    
    NSString *bundleName = @"PSImageEditors.bundle";
    UIImage *image = [self imageWithName:name
                        withBundleClass:NSClassFromString(@"PSPreviewViewController")
                             bundleName:bundleName];
    return image;
}

+ (UIImage *)imageWithName:(NSString *)name
           withBundleClass:(Class)class
                bundleName:(NSString *)bundleName {
    
    NSBundle *bundle = [self bundleForClass:class withBundleName:bundleName];
    UIImage *image = [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    return image;
}

+ (NSBundle *)bundleForClass:(Class)class withBundleName:(NSString *)name {
    
    NSBundle *frameworkBundle = [NSBundle bundleForClass:class];
    NSURL *kitBundleUrl = [frameworkBundle.resourceURL URLByAppendingPathComponent:name];
    NSBundle *bundle = [NSBundle bundleWithURL:kitBundleUrl];
    return bundle;
}

@end
