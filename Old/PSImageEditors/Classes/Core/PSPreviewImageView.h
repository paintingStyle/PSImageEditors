//
//  PSPreviewImageView.h
//  PSImageEditors
//
//  Created by rsf on 2018/8/29.
//

#import <UIKit/UIKit.h>
@class PSImageObject;

typedef void(^CallbackBlock)(PSImageObject *imageObject);

@interface PSPreviewImageView : UIView

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) FLAnimatedImageView *imageView;
@property (nonatomic, strong) UIImageView *drawingView;

@property (nonatomic, strong) UITapGestureRecognizer *singleGesture;
@property (nonatomic, strong) UITapGestureRecognizer *doubleGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longGesture;

@property (nonatomic, strong) PSImageObject *imageObject;

@property (nonatomic, copy) CallbackBlock singleGestureBlock;
@property (nonatomic, copy) CallbackBlock longGestureBlock;

- (void)changeImage:(UIImage *)image;
- (void)reset;

@end
