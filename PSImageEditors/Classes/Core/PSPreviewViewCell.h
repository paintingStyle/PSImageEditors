//
//  PSPreviewViewCell.h
//  Pods-PSImageEditors
//
//  Created by rsf on 2018/8/24.
//

#import <UIKit/UIKit.h>
#import "PSPreviewImageView.h"
#import "PSImageObject.h"

typedef void(^GestureCallbackBlock)(PSImageObject *imageObject);

@interface PSPreviewViewCell : UICollectionViewCell

@property (nonatomic, strong, readonly) PSPreviewImageView *imageView;
@property (nonatomic, strong) PSImageObject *imageObject;

@end

