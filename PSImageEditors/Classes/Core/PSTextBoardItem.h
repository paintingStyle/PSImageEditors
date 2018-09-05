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

- (void)textBoardItem:(PSTextBoardItem *)item
   translationGesture:(UIPanGestureRecognizer *)gesture
           activation:(BOOL)activation;

- (void)textBoardItemDidClickItem:(PSTextBoardItem *)item;

@end

@interface PSTextBoardItem : UIView

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) NSTextAlignment textAlignment;

@property (nonatomic, assign, getter=isActive) BOOL active;
@property (nonatomic, weak) id<PSTextBoardItemDelegate> delegate;
@property (nonatomic, strong) PSTextBoardItemOverlapView *archerBGView;

+ (void)setActiveTextView:(PSTextBoardItem *)view;
+ (void)setInactiveTextView:(PSTextBoardItem *)view;
- (instancetype)initWithTool:(PSTextBoard *)tool text:(NSString *)text font:(UIFont *)font orImage:(UIImage *)image;
- (void)setScale:(CGFloat)scale;
- (void)sizeToFitWithMaxWidth:(CGFloat)width lineHeight:(CGFloat)lineHeight;
- (void)remove;

@end

@interface PSTextBoardItemOverlapView : UIView

@property (nonatomic, copy  ) NSString *text;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) UIColor *textColor;

@end
