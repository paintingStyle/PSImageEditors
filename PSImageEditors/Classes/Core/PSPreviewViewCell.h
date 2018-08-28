//
//  PSPreviewViewCell.h
//  Pods-PSImageEditors
//
//  Created by rsf on 2018/8/24.
//

#import <UIKit/UIKit.h>
#import "PSImageObject.h"

typedef void(^GestureDidClickCallback)(PSImageObject *imageObject);

@interface PSPreviewViewCell : UICollectionViewCell

@property (nonatomic, strong) PSImageObject *imageObject;

@property (nonatomic, copy) GestureDidClickCallback singleGestureDidClickBlock;

@property (nonatomic, copy) GestureDidClickCallback longGestureDidClickBlock;

@end

