//
//  PSMosaicTool.h
//  PSImageEditors
//
//  Created by rsf on 2018/11/16.
//

#import "PSImageToolBase.h"

@interface PSMosaicTool : PSImageToolBase

//@property (nonatomic, copy) void (^canUndoBlock) (BOOL canUndo);

- (void)undo;
- (BOOL)canUndo;
- (void)changeRectangularMosaic;
- (void)changeGrindArenaceousMosaic;

- (UIImage *)mosaicImage;

@end


