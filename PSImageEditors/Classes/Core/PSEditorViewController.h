//
//  PSEditorViewController.h
//  PSImageEditors
//
//  Created by rsf on 2018/8/29.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PSEditorMode) {
    
    PSEditorModeNone,
    PSEditorModeBrush,
    PSEditorModeText,
    PSEditorModeMosaic,
    PSEditorModeClipping
};

@interface PSEditorViewController : UIViewController

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithImage:(UIImage *)image;

@property (nonatomic, assign) PSEditorMode currentMode;

@end
