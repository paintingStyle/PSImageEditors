//
//  PSTexItem.h
//  PSImageEditors
//
//  Created by paintingStyle on 2018/11/17.
//

#import <UIKit/UIKit.h>
@class PSTexTool,PSTexItem;

@protocol PSTexItemDelegate<NSObject>

@optional

- (BOOL)textItemRestrictedPanAreasWithTextItem:(PSTexItem *)item;

- (void)texItem:(PSTexItem *)item
translationGesture:(UIPanGestureRecognizer *)gesture
           activation:(BOOL)activation;

- (void)texItemDidClickWithItem:(PSTexItem *)item;

@end

@interface PSTexItem : UIView

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, assign) NSTextAlignment textAlignment;

//@property (nonatomic, strong) UIView *containerView;

/// item处于激活状态
@property (nonatomic, assign, getter=isActive) BOOL active;
@property (nonatomic, weak) id<PSTexItemDelegate> delegate;

+ (void)setActiveTextView:(PSTexItem *)view;
+ (void)setInactiveTextView:(PSTexItem *)view;
- (instancetype)initWithTool:(PSTexTool *)tool
                        text:(NSString *)text
                        font:(UIFont *)font;
- (void)setScale:(CGFloat)scale;
- (void)sizeToFitWithMaxWidth:(CGFloat)width lineHeight:(CGFloat)lineHeight;
- (void)remove;

@end
