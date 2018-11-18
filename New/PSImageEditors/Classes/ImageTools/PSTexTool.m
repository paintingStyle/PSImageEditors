//
//  PSTexTool.m
//  PSImageEditors
//
//  Created by rsf on 2018/11/16.
//

#import "PSTexTool.h"
#import "PSTopToolBar.h"
#import "PSBottomToolBar.h"
#import "PSColorToolBar.h"
#import "PSTexItem.h"

//static inline CGRect kTextItemDeleteCoordinate(void) {
//    return CGRectMake(0, PS_SCREEN_H-PSBottomToolDeleteBarHeight, PS_SCREEN_W, PSBottomToolDeleteBarHeight);;
//}
static const NSInteger kTextMaxLimitNumber = 100;

@interface PSTexTool()<PSTexItemDelegate>

@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) PSBottomToolBar *bottomToolBar;

@end

@implementation PSTexTool

#pragma mark - Subclasses Override

- (void)initialize {
    [super initialize];
}

- (void)setup {
    
    [super setup];
    
    [self.editor.topToolBar setToolBarShow:NO animation:NO];
    [self.editor.bottomToolBar setToolBarShow:NO animation:NO];
    
    if (!self.bottomToolBar) {
        self.bottomToolBar = [[PSBottomToolBar alloc] initWithType:PSBottomToolTypeDelete];
        [self.bottomToolBar setToolBarShow:NO animation:NO];
        [self.editor.view addSubview:self.bottomToolBar];
        [self.bottomToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self.editor.view);
            make.height.equalTo(@(PSBottomToolDeleteBarHeight));
        }];
    }
    
    self.textColor = self.option[kImageToolTextColorKey];
    self.textFont = self.option[kImageToolTextFontKey];
    
    // 关闭scrollView自带的缩放手势
    self.editor.scrollView.pinchGestureRecognizer.enabled = NO;
    
    __weak typeof(self)weakSelf = self;
    
    self.textView = [[PSTextView alloc] initWithFrame:self.editor.view.bounds];
    self.textView.inputView.textColor = self.textColor;
    self.textView.inputView.font = self.textFont;
    
    PSTexItem *activeTexItem  = self.activeItem;
    // 点击了激活的item，再次进入编辑模式
    if (activeTexItem && self.isEditAgain) {
        NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
        if (activeTexItem.fillColor) {
            [attrs setObject:activeTexItem.fillColor forKey:NSBackgroundColorAttributeName];
        }
        if (activeTexItem.strokeColor) {
            [attrs setObject:activeTexItem.strokeColor forKey:NSForegroundColorAttributeName];
        }
        if (activeTexItem.font) {
            [attrs setObject:activeTexItem.font forKey:NSFontAttributeName];
        }
        self.textView.inputView.text = activeTexItem.text;
        self.textView.attrs = attrs;
    }
    
    self.textView.dissmissBlock = ^(NSString *text, NSDictionary *attrs, BOOL use) {
        
        if (weakSelf.isEditAgain) { // 点击item
            if (weakSelf.editAgainCallback && use) {
                weakSelf.editAgainCallback(text, attrs);
            }
            weakSelf.isEditAgain = NO;
        } else {
            if (use) {
                [weakSelf addTextBoardItemWithText:text attrs:attrs];
            }
        }
        // 开启scrollView自带的缩放手势
        weakSelf.editor.scrollView.pinchGestureRecognizer.enabled = YES;
        //[weakSelf cleanup];
        if (weakSelf.dissmissCallback) {
             weakSelf.dissmissCallback(text);
        }
    };
 
    [self.editor.view addSubview:self.textView];
}

- (void)cleanup {
    [super cleanup];
    [self.textView removeFromSuperview];
    [self.editor.topToolBar setToolBarShow:YES animation:YES];
    [self.editor.bottomToolBar setToolBarShow:YES animation:YES];
}

- (void)executeWithCompletionBlock:(void (^)(UIImage *, NSError *, NSDictionary *))completionBlock {
    
}

- (void)hiddenToolBar:(BOOL)hidden animation:(BOOL)animation {
    
    [self.bottomToolBar setToolBarShow:!hidden animation:animation];
}

- (void)changeColor:(NSNotification *)notification {
    UIColor *panColor = (UIColor *)notification.object;
    if (panColor && self.textView) {
        [self.textView.inputView setTextColor:panColor];
    }
}

- (void)addTextBoardItemWithText:(NSString *)text
                           attrs:(NSDictionary *)attrs {
    
    if (!text && !text.length) { return; }
    
    UIColor *fillColor = attrs[NSBackgroundColorAttributeName];
    UIColor *strokeColor = attrs[NSForegroundColorAttributeName];
    UIFont *font = attrs[NSFontAttributeName];
    
    PSTexItem *texItem = [[PSTexItem alloc] initWithTool:self text:text font:self.textView.inputView.font];

    CGPoint center = self.editor.view.center;
    // 修正超长图文字的显示位置
    if (CGRectGetHeight(self.editor.imageView.frame) >PS_SCREEN_H) {
        center.y = self.editor.scrollView.contentOffset.y + PS_SCREEN_H *0.5;
    }

    texItem.delegate = self;
    texItem.borderColor = [UIColor whiteColor];
    texItem.font = font;
    texItem.strokeColor = strokeColor;
    texItem.fillColor = fillColor;
    texItem.text = text;
    texItem.center = center;
    texItem.userInteractionEnabled = YES;
    [self.editor.view addSubview:texItem];
    [PSTexItem setActiveTextView:texItem];
}

- (PSTexItem *)activeItem {

    __block PSTexItem *activeItem;
    [self.editor.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[PSTexItem class]]) { return; }
        if (((PSTexItem *)obj).isActive) {
            activeItem = obj;
            *stop = YES;
        }
    }];
    return activeItem;
}

#pragma mark - PSTexItemDelegate

- (void)texItemDidClickWithItem:(PSTexItem *)item {
    
    [self setup];
}

- (BOOL)textItemRestrictedPanAreasWithTextItem:(PSTexItem *)item {
    
    BOOL hasDeleteCoordinate = CGRectIntersectsRect(self.bottomToolBar.frame, item.frame);
    CGRect rectCoordinate = [item.superview convertRect:item.frame toView:self.editor.imageView.superview];
    BOOL beyondBorder = !CGRectIntersectsRect(CGRectInset(self.editor.imageView.frame, 30, 30), rectCoordinate);
    
    return beyondBorder && !hasDeleteCoordinate;
}

- (void)texItem:(PSTexItem *)item
translationGesture:(UIPanGestureRecognizer *)gesture
     activation:(BOOL)activation {
    
    BOOL hasDeleteCoordinate = CGRectIntersectsRect(self.bottomToolBar.frame, item.frame);
    
    if (hasDeleteCoordinate) {
        self.bottomToolBar.deleteState = PSBottomToolDeleteStateDid;
        if (!activation) {
            [item remove];
        }
    }else {
        self.bottomToolBar.deleteState = PSBottomToolDeleteStateWill;
    }
    
    if (!self.bottomToolBar.isShow && activation) {
        [self.bottomToolBar setToolBarShow:YES animation:YES];
    }else if (self.bottomToolBar.isShow && !activation) {
        [self.bottomToolBar setToolBarShow:NO animation:YES];
    }
}



@end


#pragma mark - PSTextView

@interface PSTextView () <UITextViewDelegate,PSTopToolBarDelegate,PSColorToolBarDelegate>

@property (nonatomic, strong) PSTopToolBar *topToolBar;
@property (nonatomic, strong) PSColorToolBar *colorToolBar;
@property (nonatomic, strong) NSString *needReplaceString;
@property (nonatomic, assign) NSRange   needReplaceRange;

@end

@implementation PSTextView

- (void)setAttrs:(NSDictionary *)attrs {
    
    _attrs = attrs;
    if (!attrs.allValues.count) { return; }
    
    UIColor *fillColor = attrs[NSBackgroundColorAttributeName];
    UIColor *strokeColor = attrs[NSForegroundColorAttributeName];
    
    self.colorToolBar.changeBgColor = !CGColorEqualToColor(fillColor.CGColor, [UIColor clearColor].CGColor);
    self.colorToolBar.currentColor = self.colorToolBar.changeBgColor ? fillColor:strokeColor;
    
    [self refreshTextViewDisplay];
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        __weak typeof(self)weakSelf = self;
        
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
        self.effectView.frame = frame;
        [self addSubview:self.effectView];
        
        self.topToolBar = [[PSTopToolBar alloc] initWithType:PSTopToolBarTypeCancelAndDoneIcon];
        self.topToolBar.delegate = self;
        self.topToolBar.frame = CGRectMake(0, 0, PS_SCREEN_W, PSTopToolBarHeight);
        [self addSubview:self.topToolBar];
        
        self.inputView = [[UITextView alloc] init];
        CGRect frame = CGRectInset(self.bounds, 15, 0);
        frame.origin.y = CGRectGetMaxY(self.topToolBar.frame);
        frame.size.height -= CGRectGetMaxY(self.topToolBar.frame);
        self.inputView.frame = frame;
        self.inputView.scrollEnabled = YES;
        self.inputView.returnKeyType = UIReturnKeyDone;
        self.inputView.backgroundColor = [UIColor clearColor];
        self.inputView.delegate = self;
        [self addSubview:self.inputView];
        
        self.colorToolBar = [[PSColorToolBar alloc] initWithType:PSColorToolBarTypeText];
        self.colorToolBar.delegate = self;
        self.colorToolBar.frame = CGRectMake(0, 0, PS_SCREEN_W, PSTextColorToolBarHeight);
        self.inputView.inputAccessoryView = self.colorToolBar;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - PSTopToolBarDelegate

- (void)topToolBar:(PSTopToolBar *)toolBar event:(PSTopToolBarEvent)event {
    
    if (event == PSTopToolBarEventCancel) {
        [self dismissTextEditing:NO];
    }else {
        [self dismissTextEditing:YES];
    }
}

#pragma makr - PSColorToolBarDelegate

- (void)colorToolBar:(PSColorToolBar *)toolBar event:(PSColorToolBarEvent)event {
    
    if (event == PSColorToolBarEventSelectColor ||
        event == PSColorToolBarEventChangeBgColor) {
        [self refreshTextViewDisplay];
    }
}

- (void)refreshTextViewDisplay {
    
    NSDictionary *attributes = nil;
    UIColor *bgcolor = self.colorToolBar.currentColor ? :[UIColor redColor];
    UIColor *textColor = self.colorToolBar.currentColor ? :[UIColor whiteColor];
    UIFont *font = self.inputView.font ? :[UIFont systemFontOfSize:24.f weight:UIFontWeightRegular];
    
    if (self.colorToolBar.isChangeBgColor) {
        // 当处于改变文字背景的模式，背景颜色为白色，文字为黑色，其他情况统一为白色
        if ([self.colorToolBar isWhiteColor]) {
            textColor = [UIColor blackColor];
        }else {
            textColor = [UIColor whiteColor];
        }
        attributes = @{
                       NSFontAttributeName:font,
                       NSForegroundColorAttributeName:textColor,
                       NSBackgroundColorAttributeName:bgcolor
                       };
    }else {
        attributes = @{
                       NSFontAttributeName:font,
                       NSForegroundColorAttributeName:textColor,
                       NSBackgroundColorAttributeName:[UIColor clearColor]
                       };
    }
    self.inputView.attributedText = [[NSAttributedString alloc] initWithString:self.inputView.text
                                                                   attributes:attributes];
}

- (void)keyboardWillShow:(NSNotification *)notification {
   
    NSDictionary *userinfo = notification.userInfo;
    CGRect  keyboardRect              = [[userinfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardAnimationDuration = [[userinfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions keyboardAnimationCurve = [[userinfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    self.hidden = YES;
    [UIView animateWithDuration:keyboardAnimationDuration delay:keyboardAnimationDuration options:keyboardAnimationCurve animations:^{
        
        CGRect frame = self.inputView.frame;
        frame.size.height = [UIScreen mainScreen].bounds.size.height - keyboardRect.size.height;
        self.inputView.frame = frame;
        
        CGRect frame2 = self.frame;
        frame2.origin.y = 0;
        self.frame = frame2;
        
    } completion:^(BOOL finished) {}];
    
    [UIView animateWithDuration:3 animations:^{
        self.hidden = NO;
    }];
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary *userinfo = notification.userInfo;
    CGFloat keyboardAnimationDuration = [[userinfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions keyboardAnimationCurve = [[userinfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:keyboardAnimationDuration delay:0.f options:keyboardAnimationCurve animations:^{
        
        CGRect frame = self.frame;
        frame.origin.y = CGRectGetHeight(self.effectView.frame);
        self.frame = frame;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismissTextEditing:(BOOL)done {
    
    [self.inputView resignFirstResponder];
    
    NSDictionary *attrs = nil;
    if (self.inputView.text.length) {
        NSRange range = NSMakeRange(0, self.inputView.text.length);
        attrs = [self.inputView.attributedText attributesAtIndex:0 effectiveRange:&range];
    }
    if (self.dissmissBlock) {
        self.dissmissBlock(self.inputView.text, attrs, done);
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.inputView becomeFirstResponder];
            [self.inputView scrollRangeToVisible:NSMakeRange(self.inputView.text.length-1, 0)];
        });
    } else {
        
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    
    // 选中范围的标记
    UITextRange *textSelectedRange = [textView markedTextRange];
    // 获取高亮部分
    UITextPosition *textPosition = [textView positionFromPosition:textSelectedRange.start offset:0];
    // 如果在变化中是高亮部分在变, 就不要计算字符了
    if (textSelectedRange && textPosition) {
        return;
    }
    // 文本内容
    NSString *textContentStr = textView.text;
    NSLog(@"text = %@",textView.text);
    NSInteger existTextNumber = textContentStr.length;
    
    if (existTextNumber > kTextMaxLimitNumber) {
        // 截取到最大位置的字符(由于超出截取部分在should时被处理了,所以在这里为了提高效率不在判断)
        NSString *str = [textContentStr substringToIndex:kTextMaxLimitNumber];
        [textView setText:str];
        //[AlertBox showMessage:@"输入字符不能超过100\n多余部分已截断" hideAfter:3];
    }
    [self refreshTextViewDisplay];
}

- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    
    NSLog(@"%@", text);
    if ([text isEqualToString:@"\n"]) {
        [self dismissTextEditing:YES];
        return NO;
    }
    
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    
    //如果有高亮且当前字数开始位置小于最大限制时允许输入
    if (selectedRange && pos) {
        NSInteger startOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.start];
        NSInteger endOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.end];
        NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
        
        if (offsetRange.location < kTextMaxLimitNumber && textView.text.length - offsetRange.length <= kTextMaxLimitNumber) {
            self.needReplaceRange = offsetRange;
            self.needReplaceString = text;
            return YES;
        }
        else
        {
            return NO;
        }
    }
    
    
    NSString *comcatstr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    NSInteger caninputlen = kTextMaxLimitNumber - comcatstr.length;
    
    if (caninputlen >= 0)
    {
        return YES;
    }
    else
    {
        NSInteger len = text.length + caninputlen;
        //防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
        NSRange rg = {0,MAX(len,0)};
        
        if (rg.length > 0)
        {
            NSString *s = @"";
            //判断是否只普通的字符或asc码(对于中文和表情返回NO)
            BOOL asc = [text canBeConvertedToEncoding:NSASCIIStringEncoding];
            if (asc) {
                s = [text substringWithRange:rg];//因为是ascii码直接取就可以了不会错
            }
            else
            {
                __block NSInteger idx = 0;
                __block NSString  *trimString = @"";//截取出的字串
                //使用字符串遍历，这个方法能准确知道每个emoji是占一个unicode还是两个
                [text enumerateSubstringsInRange:NSMakeRange(0, [text length])
                                         options:NSStringEnumerationByComposedCharacterSequences
                                      usingBlock: ^(NSString* substring, NSRange substringRange, NSRange enclosingRange, BOOL* stop) {
                                          
                                          NSInteger steplen = substring.length;
                                          if (idx >= rg.length) {
                                              *stop = YES; //取出所需要就break，提高效率
                                              return ;
                                          }
                                          
                                          trimString = [trimString stringByAppendingString:substring];
                                          
                                          idx = idx + steplen;//这里变化了，使用了字串占的长度来作为步长
                                      }];
                
                s = trimString;
            }
            //rang是指从当前光标处进行替换处理(注意如果执行此句后面返回的是YES会触发didchange事件)
            [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
        }
        return NO;
    }
}

@end

