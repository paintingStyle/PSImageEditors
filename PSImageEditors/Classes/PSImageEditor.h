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

- (instancetype)initWithImage:(UIImage*)image;
- (instancetype)initWithImage:(UIImage*)image
                     delegate:(id<PSImageEditorDelegate>)delegate
                   dataSource:(id<PSImageEditorDataSource>)dataSource;

@end

@protocol PSImageEditorDelegate <NSObject>

@optional
- (void)imageEditorDidFinishEdittingWithImage:(UIImage *)image;
- (void)imageEditorDidCancel;

@end

@protocol PSImageEditorDataSource <NSObject>

@optional
- (UIColor *)imageEditorDefaultColor;
- (CGFloat)imageEditorDrawPathWidth;
- (UIFont *)imageEditorTextFont;

@end
