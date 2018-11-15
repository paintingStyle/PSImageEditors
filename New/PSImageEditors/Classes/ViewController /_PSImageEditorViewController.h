//
//  _PSImageEditorViewController.h
//  PSImageEditors
//
//  Created by paintingStyle on 2018/11/15.
//

#import "PSImageEditor.h"
#import "PSBrushCanvasView.h"
#import "PSMosaicCanvasView.h"
#import "PSTextCanvasView.h"


@interface _PSImageEditorViewController : PSImageEditor

/// 最底层负责显示的图片
@property (nonatomic, strong, readonly) UIImageView *imageView;
/// 画笔画布
@property (nonatomic, strong, readonly) PSBrushCanvasView *brushCanvasView;
/// 文字画布
@property (nonatomic, strong, readonly) PSMosaicCanvasView *textCanvasView;
/// 马赛克画布
@property (nonatomic, strong, readonly) PSTextCanvasView *mosaicCanvasView;

- (void)fixZoomScaleWithAnimated:(BOOL)animated;
- (void)resetZoomScaleWithAnimated:(BOOL)animated;

@end
