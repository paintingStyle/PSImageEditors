//
//  PSDrawView.m
//  PSImageEditors
//
//  Created by rsf on 2020/8/24.
//

#import "PSDrawView.h"

NSString *const kPSDrawViewData = @"PSDrawViewData";

@interface PSDrawView ()
{
    BOOL _isWork;
    BOOL _isBegan;
}
/** 画笔数据 */
@property (nonatomic, strong) NSMutableArray <NSDictionary *>*brushData;
/** 图层 */
@property (nonatomic, strong) NSMutableArray <CALayer *>*layerArray;

@end

@implementation PSDrawView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    _layerArray = [@[] mutableCopy];
    _brushData = [@[] mutableCopy];
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
    self.exclusiveTouch = YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if ([event allTouches].count == 1 && self.brush) {
        _isWork = NO;
        _isBegan = YES;

        // 画笔落点
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        // 1.创建画布
        CALayer *layer = [self.brush createDrawLayerWithPoint:point];
        
        if (layer) {
            /** 使用画笔的图层层级，层级越大，图层越低 */
            [self.layer.sublayers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                /** 图层层级<=，放在该图层上方 */
                if (layer.ps_level <= obj.ps_level) {
                    [self.layer insertSublayer:layer above:obj];
                    *stop = YES;
                }
            }];
            /** 没有被加入到显示图层，直接放到最低 */
            if (layer.superlayer == nil) {
                [self.layer insertSublayer:layer atIndex:0];
            }
            [self.layerArray addObject:layer];
        } else {
            _isBegan = NO;
        }
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if (_isBegan || _isWork) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        
        if (!CGPointEqualToPoint(self.brush.currentPoint, point)) {
            if (_isBegan && self.drawBegan) self.drawBegan();
            _isBegan = NO;
            _isWork = YES;
            // 2.添加画笔路径坐标
            [self.brush addPoint:point];
        }
    }
    
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
    
    if (_isWork) {
        // 3.1.添加画笔数据
        id data = self.brush.allTracks;
        if (data) {
            [self.brushData addObject:data];
        }
        if (self.drawEnded) self.drawEnded();
    } else if (_isBegan) {
        // 3.2.移除开始时添加的图层
        [self.layerArray.lastObject removeFromSuperlayer];
        [self.layerArray removeLastObject];
    }
    _isBegan = NO;
    _isWork = NO;
    
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_isWork) {
        // 3.1.添加画笔数据
        id data = self.brush.allTracks;
        if (data) {
            [self.brushData addObject:data];
        }
        if (self.drawEnded) self.drawEnded();
    } else if (_isBegan) {
        // 3.2.移除开始时添加的图层
        [self.layerArray.lastObject removeFromSuperlayer];
        [self.layerArray removeLastObject];
    }
    _isBegan = NO;
    _isWork = NO;
    
    [super touchesCancelled:touches withEvent:event];
}

- (BOOL)isDrawing
{
    return _isWork;
}

/** 图层数量 */
- (NSUInteger)count
{
    return self.brushData.count;
}

/** 是否可撤销 */
- (BOOL)canUndo
{
    return self.count > 0;
}

//撤销
- (void)undo
{
    CALayer *layer = self.layerArray.lastObject;
    [layer removeFromSuperlayer];
    [self.layerArray removeLastObject];
    [self.brushData removeLastObject];
    layer = nil;
}

- (void)removeAllObjects {
	
	for (CALayer *layer in self.layerArray) {
		 [layer removeFromSuperlayer];
	}
	
	[self.layerArray removeAllObjects];
	[self.brushData removeAllObjects];
}

#pragma mark  - 数据
- (NSDictionary *)data
{
    if (self.brushData.count) {
        return @{kPSDrawViewData:[self.brushData copy]};
    }
    return nil;
}

- (void)setData:(NSDictionary *)data
{
    NSArray *brushData = data[kPSDrawViewData];
    if (brushData.count) {
        for (NSDictionary *allTracks in brushData) {
            CALayer *layer = [PSBrush drawLayerWithTrackDict:allTracks];
            if (layer) {
                /** 使用画笔的图层层级，层级越大，图层越低 */
                [self.layer.sublayers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    /** 图层层级<=，放在该图层上方 */
                    if (layer.ps_level <= obj.ps_level) {
                        [self.layer insertSublayer:layer above:obj];
                        *stop = YES;
                    }
                }];
                /** 没有被加入到显示图层，直接放到最低 */
                if (layer.superlayer == nil) {
                    [self.layer insertSublayer:layer atIndex:0];
                }
                [self.layerArray addObject:layer];
            }
        }
        [self.brushData addObjectsFromArray:brushData];
    }
}

@end

