//
//  PSMosaicTool.h
//  PSImageEditors
//
//  Created by rsf on 2018/11/16.
//

#import "PSImageToolBase.h"
@class PSMosaicCache;

@interface PSMosaicTool : PSImageToolBase

@property (nonatomic, copy) void (^canUndoBlock) (BOOL canUndo);

- (void)undo;
- (BOOL)canUndo;
- (void)changeRectangularMosaic;
- (void)changeGrindArenaceousMosaic;

- (UIImage *)mosaicImage;

@end

@interface PSMosaicView : UIView

//底图为马赛克图
@property (nonatomic, strong) UIImage *mosaicImage;
//表图为正常图片
@property (nonatomic, strong) UIImage *originalImage;

@property (nonatomic,strong) PSMosaicCache *mosaicCache;

@property (nonatomic, copy) void(^drawBeganBlock)(void);
@property (nonatomic, copy) void(^drawEndBlock)(BOOL canUndo);

- (void)undo;
- (BOOL)canUndo;
- (void)reset;

@end

@interface PSMosaicCache : NSObject

- (instancetype)initWithOriginalImage:(UIImage*)image;
- (UIImage *)previousImage;

- (void)writeImageToCache:(UIImage *)image;
- (void)removeImageAtIndex:(NSInteger)index;
- (UIImage *)lastImage;
- (void)clear;

@end

@interface PSMosaicPath : NSObject<NSCopying,NSMutableCopying>

@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint endPoint;
@property (nonatomic, strong) NSMutableArray *pathPointArray;

-(void)resetStatus;

@end

@interface PSMosaicPathPoint : NSObject

@property (nonatomic, assign) CGFloat xPoint;
@property (nonatomic, assign) CGFloat yPoint;

@end
