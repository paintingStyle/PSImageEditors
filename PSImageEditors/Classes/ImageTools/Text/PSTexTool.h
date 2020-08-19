//
//  PSTexTool.h
//  PSImageEditors
//
//  Created by rsf on 2018/11/16.
//

#import "PSImageToolBase.h"
@class PSTexTool, PSTextView, PSTexToolItem;

@interface PSTexTool : PSImageToolBase

@property (nonatomic, strong) PSTextView *textView;

@end

@interface PSTextView : UIView

@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, strong) UITextView *inputView;
@property (nonatomic, strong) NSDictionary *attrs; /// 预设属性


- (void)addTextItemWithText:(NSString *)text
				  withAttrs:(NSDictionary *)attrs
				  withPoint:(CGPoint)point;

@property (nonatomic, copy) void (^dissmissBlock) (NSString *text, NSDictionary *attrs, BOOL done);

@end
