//
//  PSStickerItem.h
//  PSImageEditors
//
//  Created by rsf on 2020/8/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PSStickerItem : NSObject

/** image/gif */
@property (nonatomic, strong) UIImage *image;

/** text */
@property (nonatomic, strong) NSAttributedString *attributedText;

/** display(image/text) */
- (UIImage * __nullable)displayImage;

/** main view */
+ (instancetype)mainWithAttributedText:(NSAttributedString *)text;

@end

@interface PSStickerItem (View)

- (UIView * __nullable)displayView;

@end

NS_ASSUME_NONNULL_END
