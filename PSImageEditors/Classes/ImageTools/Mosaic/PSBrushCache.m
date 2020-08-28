//
//  PSBrushCache.m
//  PSImageEditors
//
//  Created by rsf on 2020/8/24.
//

#import "PSBrushCache.h"

@interface PSBrushCache ()

@property (nonatomic, strong) NSMutableDictionary *forceCache;

@end

@implementation PSBrushCache

static PSBrushCache *ps_BrushCacheShare = nil;
+ (instancetype)share
{
    if (ps_BrushCacheShare == nil) {
        ps_BrushCacheShare = [[PSBrushCache alloc] init];
        ps_BrushCacheShare.name = @"BrushCache";
    }
    return ps_BrushCacheShare;
}

+ (void)free
{
    [ps_BrushCacheShare removeAllObjects];
    ps_BrushCacheShare = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _forceCache = [NSMutableDictionary dictionary];
        //收到系统内存警告后直接调用 removeAllObjects 删除所有缓存对象
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllObjects) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)setForceObject:(id)obj forKey:(id)key
{
    [self.forceCache setObject:obj forKey:key];
}

- (void)removeObjectForKey:(id)key
{
    [self.forceCache removeObjectForKey:key];
    [super removeObjectForKey:key];
}

- (id)objectForKey:(id)key
{
    id obj = [self.forceCache objectForKey:key];
    if (obj) {
        return obj;
    }
    return [super objectForKey:key];
}

- (void)removeAllObjects
{
    [self.forceCache removeAllObjects];
    [super removeAllObjects];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

@end
