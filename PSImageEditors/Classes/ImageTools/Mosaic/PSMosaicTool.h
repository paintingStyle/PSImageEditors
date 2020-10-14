//
//  PSMosaicTool.h
//  PSImageEditors
//
//  Created by rsf on 2018/11/16.
//

#import "PSImageToolBase.h"

@interface PSMosaicTool : PSImageToolBase


- (void)undo;
- (BOOL)canUndo;
- (void)changeRectangularMosaic;
- (void)changeGrindArenaceousMosaic;

- (UIImage *)mosaicImage;

@end


