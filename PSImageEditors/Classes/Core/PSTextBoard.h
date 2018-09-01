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

@property (nonatomic, copy) void(^dissmissTextTool)(NSString *currentText);//, BOOL isEditAgain);
@property (nonatomic, strong) PSTextView *textView;
@property (nonatomic, assign) BOOL isEditAgain;
@property (nonatomic, copy)   void(^editAgainCallback)(NSString *text);

@property (nonatomic, weak) id<PSTextBoardItemDelegate> itemDelegate;

@end

@interface PSTextView : UIView

@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, copy) void(^dissmissTextTool)(NSString *currentText, BOOL isUse);//, BOOL isEditAgain);
@property (nonatomic, strong) UITextView *textView;

@end

