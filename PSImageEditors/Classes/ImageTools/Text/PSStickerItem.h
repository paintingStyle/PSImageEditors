//
//  PSStickerItem.h
//  PSImageEditors
//
//  Created by rsf on 2020/8/18.
//

#import <UIKit/UIKit.h>

static const NSInteger kLabelTag = 666666;

NS_ASSUME_NONNULL_BEGIN

@interface PSStickerItem : NSObject

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) NSAttributedString *attributedText;

@property (nonatomic, assign) CGRect imageRect;

+ (instancetype)mainWithAttributedText:(NSAttributedString *)text
							 imageRect:(CGRect)imageRect;

@end

@interface PSStickerItem (View)

- (UIView * __nullable)displayView;

@end

NS_ASSUME_NONNULL_END
