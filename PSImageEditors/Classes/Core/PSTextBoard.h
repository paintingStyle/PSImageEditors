//
//  PSTextBoard.h
//  PSImageEditors
//
//  Created by paintingStyle on 2018/8/29.
//

#import "PSBaseDrawingBoard.h"
#import "PSTextBoardItem.h"
@class PSTextView;

@interface PSTextBoard : PSBaseDrawingBoard

@property (nonatomic, strong) PSTextView *textView;
@property (nonatomic, strong) PSTextBoardItem *activeItem;
@property (nonatomic, assign) BOOL isEditAgain;

@property (nonatomic, copy) void(^dissmissTextTool)(NSString *currentText);//, BOOL isEditAgain);
/// 再次编辑回调
@property (nonatomic, copy)   void(^editAgainCallback)(NSString *text, NSDictionary *attrs);

@property (nonatomic, weak) id<PSTextBoardItemDelegate> itemDelegate;

@end

@interface PSTextView : UIView

@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, strong) UITextView *textView;
/// 预设属性
@property (nonatomic, strong) NSDictionary *attrs;

@property (nonatomic, copy) void(^dissmissBlock) (NSString *text, NSDictionary *attrs, BOOL use);

@end

