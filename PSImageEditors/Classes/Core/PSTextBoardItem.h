//
//  PSTextBoardItem.h
//  PSImageEditors
//
//  Created by paintingStyle on 2018/9/1.
//

#import <UIKit/UIKit.h>
@class PSTextBoard,PSTextBoardItem,PSTextBoardItemOverlapView;

@protocol PSTextBoardItemDelegate<NSObject>

@optional

- (void)textBoardItem:(PSTextBoardItem *)item
        hiddenToolBar:(BOOL)hidden
            animation:(BOOL)animation;

- (void)textBoardItemDidTapWithItem:(PSTextBoardItem *)item;

@end

@interface PSTextBoardItem : UIView

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign, getter=isActive) BOOL active;
@property (nonatomic, weak) id<PSTextBoardItemDelegate> delegate;
@property (nonatomic, strong) PSTextBoardItemOverlapView *archerBGView;

+ (void)setActiveTextView:(PSTextBoardItem *)view;
+ (void)setInactiveTextView:(PSTextBoardItem *)view;
- (instancetype)initWithTool:(PSTextBoard *)tool text:(NSString *)text font:(UIFont *)font orImage:(UIImage *)image;
- (void)setScale:(CGFloat)scale;
- (void)sizeToFitWithMaxWidth:(CGFloat)width lineHeight:(CGFloat)lineHeight;

@end

@interface PSTextBoardItemOverlapView : UIView 

@property (nonatomic, copy  ) NSString *text;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIImage *image;

@end

@interface PSTextLabel : UILabel

@property (nonatomic, strong) UIColor *outlineColor;
@property (nonatomic, assign) CGFloat outlineWidth;

@end
