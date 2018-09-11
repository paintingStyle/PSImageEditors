//
//  PSMosaicBoard.h
//  PSImageEditors
//
//  Created by rsf on 2018/9/11.
//

#import "PSBaseDrawingBoard.h"

@interface PSMosaicBoard : PSBaseDrawingBoard

@property (nonatomic, copy) void(^drawEndBlock)(BOOL canUndo);

- (void)undo;
- (void)changeRectangularMosaic;
- (void)changeGrindArenaceousMosaic;

@end

@interface PSMosaicView : UIView
	
//底图为马赛克图
@property (nonatomic, strong) UIImage *mosaicImage;
//表图为正常图片
@property (nonatomic, strong) UIImage *originalImage;

@property (nonatomic, copy) void(^drawEndBlock)(BOOL canUndo);

- (void)undo;
- (BOOL)canUndo;

@end

@interface PSMosaicCache : NSObject

- (instancetype)initWithOriginalImage:(UIImage*)image;
- (void)writeImageToCache:(UIImage *)image;
- (UIImage *)undo;
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
