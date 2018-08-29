//
//  PSPreviewImageView.h
//  PSImageEditors
//
//  Created by rsf on 2018/8/29.
//

#import <UIKit/UIKit.h>
@class PSImageObject;

typedef void(^GestureDidClickCallback)(void);

@interface PSPreviewImageView : UIView

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, copy) GestureDidClickCallback singleGestureDidClickBlock;
@property (nonatomic, copy) GestureDidClickCallback longGestureDidClickBlock;

@end
