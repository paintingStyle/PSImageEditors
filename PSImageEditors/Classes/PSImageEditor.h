//
//  PSImageEditor.h
//  PSImageEditors
//
//  Created by paintingStyle on 2018/11/15.
//

#import <UIKit/UIKit.h>

@protocol PSImageEditorDelegate,PSImageEditorDataSource;

typedef NS_ENUM(NSInteger, PSImageEditorMode) {
	
	PSImageEditorModeNone =-1,
	PSImageEditorModeDraw,
	PSImageEditorModeText,
	PSImageEditorModeMosaic,
	PSImageEditorModeClipping
};

@interface PSImageEditor : UIViewController

@property (nonatomic, weak) id<PSImageEditorDelegate> delegate;
@property (nonatomic, weak) id<PSImageEditorDataSource> dataSource;
@property (nonatomic, assign) PSImageEditorMode editorMode;
@property (nonatomic, assign) BOOL produceChanges; // 是否使用过该工具,即图片产生了编辑操作

- (instancetype)initWithImage:(UIImage*)image;
- (instancetype)initWithImage:(UIImage*)image
                     delegate:(id<PSImageEditorDelegate>)delegate
                   dataSource:(id<PSImageEditorDataSource>)dataSource;
- (void)dismiss;

@end

@protocol PSImageEditorDelegate <NSObject>

@optional
- (void)imageEditor:(PSImageEditor *)editor didFinishEdittingWithImage:(UIImage *)image;
- (void)imageEditorDidCancel;

@end

@protocol PSImageEditorDataSource <NSObject>

@optional
- (UIColor *)imageEditorDefaultColor;
- (PSImageEditorMode)imageEditorDefalutEditorMode;
- (CGFloat)imageEditorDrawPathWidth;
- (UIFont *)imageEditorTextFont;

@end
