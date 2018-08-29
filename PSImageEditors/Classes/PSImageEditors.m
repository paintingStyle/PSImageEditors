//
//  PSImageEditors.m
//  PSImageEditors
//
//  Created by rsf on 2018/8/29.
//

#import "PSImageEditors.h"

@implementation PSImageEditors

+ (void)defaultEditors {
	
	static PSImageEditors *_instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_instance = [[PSImageEditors alloc] init];
		_instance.drawPathWidth = 2;
	});
}

@end
