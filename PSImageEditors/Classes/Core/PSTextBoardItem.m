//
//  PSTextBoardItem.m
//  PSImageEditors
//
//  Created by paintingStyle on 2018/9/1.
//

#import "PSTextBoardItem.h"
#import "PSTextBoard.h"
#import "PSImageEditorGestureManager.h"

static const CGFloat MAX_FONT_SIZE = 50.0f;
static const CGFloat MIN_TEXT_SCAL = 0.614f;
static const CGFloat MAX_TEXT_SCAL = 4.0f;
static const CGFloat LABEL_OFFSET  = 0.f;

@interface PSTextBoardItemOverlapContentView : UIView

@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) CGFloat defaultFont;
@property (nonatomic, strong) UIImage *image;

@end

@implementation PSTextBoardItemOverlapContentView

- (void)setText:(NSString *)text {
    if (_text != text) {
        _text = text;
        [self setNeedsDisplay];
    }
}

- (void)setTextColor:(UIColor *)textColor {
    if (_textColor != textColor) {
        _textColor = textColor;
        [self setNeedsDisplay];
    }
}

- (void)setTextFont:(UIFont *)textFont {
    if (_textFont != textFont) {
        _textFont = textFont;
        _defaultFont = textFont.pointSize;
        [self setNeedsDisplay];
    }
}

- (void)setImage:(UIImage *)image {
    if (_image != image) {
        _image = image;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect {
    if (self.image) {
        [self.image drawInRect:CGRectInset(rect, 21, 25)];
        return;
    }
    
    rect.origin = CGPointMake(1, 2);
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:self.text
                                                                 attributes:@{NSForegroundColorAttributeName : self.textColor,
																			  NSFontAttributeName : self.textFont}];
    [string drawInRect:CGRectInset(rect, 21, 25)];
    
}

@end

@interface PSTextBoardItemOverlapView ()
@property (nonatomic, strong) PSTextBoardItemOverlapContentView *contentView;
@end
@implementation PSTextBoardItemOverlapView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _contentView = [[PSTextBoardItemOverlapContentView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _contentView.backgroundColor = [UIColor clearColor];
        [self addSubview:_contentView];
    }
    return self;
}

- (void)setText:(NSString *)text {
    if (_text != text) {
        _text = text;
        [_contentView setText:_text];
    }
}

- (void)setTextColor:(UIColor *)textColor {
    if (_textColor != textColor) {
        _textColor = textColor;
        [_contentView setTextColor:_textColor];
    }
}

- (void)setTextFont:(UIFont *)textFont {
    if (_textFont != textFont) {
        _textFont = textFont;
        _contentView.defaultFont = textFont.pointSize;
        [_contentView setTextFont:_textFont];
    }
}

- (void)setImage:(UIImage *)image {
    if (_image != image) {
        _image = image;
        [_contentView setImage:image];
    }
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    _contentView.bounds = self.bounds;
    CGRect frame = _contentView.frame;
    frame.origin = CGPointZero;
    _contentView.frame = frame;
}

@end

@interface PSTextBoardItem () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) PSTextBoard *textBoard;

@end

@implementation PSTextBoardItem
{
    PSTextLabel  *_label;
    
    CGFloat _scale;
    CGFloat _arg;
    
    CGPoint _initialPoint;
    CGFloat _initialArg;
    CGFloat _initialScale;
    
    CALayer *_leftTopRectLayer;
    CALayer *_rightTopRectLayer;
	CALayer *_leftBottomRectLayer;
	CALayer *_rightBottomRectLayer;
    
    CGFloat _rotation;
}

static PSTextBoardItem *activeView = nil;

+ (void)setActiveTextView:(PSTextBoardItem *)view
{
    if(view != activeView){
		activeView.active = NO;
        activeView = view;
		activeView.active = YES;
        
        [activeView.archerBGView.superview bringSubviewToFront:activeView.archerBGView];
        [activeView.superview bringSubviewToFront:activeView];
        
    }
}

+ (void)setInactiveTextView:(PSTextBoardItem *)view {
    if (activeView) {activeView = nil;}
    view.active = NO;
}

- (instancetype)initWithTool:(PSTextBoard *)tool text:(NSString *)text font:(UIFont *)font orImage:(UIImage *)image
{
	self = [super initWithFrame:CGRectMake(0, 0, 132, 132)];
    if(self){
        
        _archerBGView = [[PSTextBoardItemOverlapView alloc] initWithFrame:CGRectZero];
        _archerBGView.backgroundColor = [UIColor clearColor];
        
        _label = [[PSTextLabel alloc] init];
        _label.numberOfLines = 0;
        _label.font = font;// [UIFont systemFontOfSize:MAX_FONT_SIZE];
        _label.minimumScaleFactor = font.pointSize * 0.8f;
        _label.adjustsFontSizeToFitWidth = YES;
        _label.textAlignment = NSTextAlignmentCenter;
		_label.textColor = [UIColor whiteColor];
        _label.text = text;
        _label.layer.allowsEdgeAntialiasing = true;

		
        self.text = text;
        [self addSubview:_label];
        
        _textBoard = tool;
       
        CGSize size = [_label sizeThatFits:CGSizeMake(CGRectGetWidth(_textBoard.previewView.drawingView.frame) - 2*LABEL_OFFSET, FLT_MAX)];
        _label.frame = CGRectMake(LABEL_OFFSET, LABEL_OFFSET, size.width + 20, size.height + _label.font.pointSize);
        self.frame = CGRectMake(0, 0, CGRectGetWidth(_label.frame) + 2*LABEL_OFFSET, CGRectGetHeight(_label.frame) + 2*LABEL_OFFSET);
        
        _arg = 0;
        [self setScale:1];
        
        [self initGestures];
    }
	
    return self;
}

- (void)initGestures
{
    _label.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap:)];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPan:)];
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPinch:)];
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidRotation:)];
    
    [pinch requireGestureRecognizerToFail:tap];
    [rotation requireGestureRecognizerToFail:tap];
    
   [self.textBoard.previewView.scrollView.panGestureRecognizer requireGestureRecognizerToFail:pan];
    
    tap.delegate = [PSImageEditorGestureManager instance];
    pan.delegate = [PSImageEditorGestureManager instance];
    pinch.delegate = [PSImageEditorGestureManager instance];
    rotation.delegate = [PSImageEditorGestureManager instance];
    
    [self addGestureRecognizer:tap];
    [self addGestureRecognizer:pan];
    [self addGestureRecognizer:pinch];
    [self addGestureRecognizer:rotation];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if(view == self) {
        return self;
    }
    return view;
}


#pragma mark- gesture events

// TODO: 移除文字
//- (void)pushedDeleteBtn:(id)sender
//{
//    PSTextBoardItem *nextTarget = nil;
//
//    const NSInteger index = [self.superview.subviews indexOfObject:self];
//
//    for(NSInteger i=index+1; i<self.superview.subviews.count; ++i){
//        UIView *view = [self.superview.subviews objectAtIndex:i];
//        if([view isKindOfClass:[PSTextBoardItem class]]){
//            nextTarget = (PSTextBoardItem *)view;
//            break;
//        }
//    }
//
//    if(nextTarget==nil){
//        for(NSInteger i=index-1; i>=0; --i){
//            UIView *view = [self.superview.subviews objectAtIndex:i];
//            if([view isKindOfClass:[PSTextBoardItem class]]){
//                nextTarget = (PSTextBoardItem *)view;
//                break;
//            }
//        }
//    }
//
//    [[self class] setActiveTextView:nextTarget];
//    [self removeFromSuperview];
//    [_archerBGView removeFromSuperview];
//}

- (void)remove {
    
    [[self class] setActiveTextView:self];
    [self removeFromSuperview];
    [_archerBGView removeFromSuperview];
}

- (void)hiddenToolBar:(BOOL)hidden animation:(BOOL)animation {
    
    if (self.delegate && [self.delegate respondsToSelector:
                          @selector(textBoardItem:hiddenToolBar:animation:)]) {
        [self.delegate textBoardItem:self hiddenToolBar:hidden animation:animation];
    }
}

- (void)viewDidTap:(UITapGestureRecognizer*)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        if(self.active){
            [self textBoardItemDidTap:sender];
        } else {
            //取消当前
          //  [self.textTool.editor resetCurrentTool];
        }
        [[self class] setActiveTextView:self];
        [self hiddenToolBar:NO animation:YES];
        
    }
}

- (void)viewDidPan:(UIPanGestureRecognizer*)recognizer
{
    //平移
    [[self class] setActiveTextView:self];
    UIView *piece = _archerBGView;
    CGPoint translation = [recognizer translationInView:piece.superview];
    piece.center = CGPointMake(piece.center.x + translation.x, piece.center.y + translation.y);
    [recognizer setTranslation:CGPointZero inView:piece.superview];
    
    BOOL activation = NO;
    
    if (recognizer.state == UIGestureRecognizerStateBegan ||
        recognizer.state == UIGestureRecognizerStateChanged) {
        activation = YES;
        [self hiddenToolBar:YES animation:YES];
        //取消当前
      //  [self.textTool.editor resetCurrentTool];
    } else if (recognizer.state == UIGestureRecognizerStateEnded ||
               recognizer.state == UIGestureRecognizerStateFailed ||
               recognizer.state == UIGestureRecognizerStateCancelled) {
        activation = NO;
        // TODO:XXX
        CGRect rectCoordinate = [piece.superview convertRect:piece.frame toView:_textBoard.previewView.imageView.superview];
        if (!CGRectIntersectsRect(CGRectInset(_textBoard.previewView.imageView.frame, 30, 30), rectCoordinate)) {
            [UIView animateWithDuration:.2f animations:^{
                piece.center = piece.superview.center;
                self.center = piece.center;
                
            }];
        }
        [self hiddenToolBar:NO animation:YES];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:
                          @selector(textBoardItem:translationGesture:activation:)]) {
        [self.delegate textBoardItem:self translationGesture:recognizer activation:activation];
    }
    
    [self layoutSubviews];
}

- (void)viewDidPinch:(UIPinchGestureRecognizer *)recognizer {
    //缩放
    [[self class] setActiveTextView:self];
    
    if (recognizer.state == UIGestureRecognizerStateBegan ||
        recognizer.state == UIGestureRecognizerStateChanged) {
        //坑点：recognizer.scale是相对原图片大小的scal
        
        CGFloat scale = [(NSNumber *)[_archerBGView valueForKeyPath:@"layer.transform.scale.x"] floatValue];
        NSLog(@"scale = %f", scale);
        [self hiddenToolBar:YES animation:YES];
        //取消当前
        //[self.textTool.editor resetCurrentTool];
        
        CGFloat currentScale = recognizer.scale;
        
        if (scale > MAX_TEXT_SCAL && currentScale > 1) {
            return;
        }
        
        if (scale < MIN_TEXT_SCAL && currentScale < 1) {
            return;
        }
        
        
        _archerBGView.transform = CGAffineTransformScale(_archerBGView.transform, currentScale, currentScale);
        recognizer.scale = 1;
        [self layoutSubviews];
        [self hiddenToolBar:YES animation:YES];
    } else if (recognizer.state == UIGestureRecognizerStateEnded ||
               recognizer.state == UIGestureRecognizerStateFailed ||
               recognizer.state == UIGestureRecognizerStateCancelled) {
        [self hiddenToolBar:NO animation:YES];
    }
}

- (void)viewDidRotation:(UIRotationGestureRecognizer *)recognizer {
    //旋转
    if (recognizer.state == UIGestureRecognizerStateBegan ||
        recognizer.state == UIGestureRecognizerStateChanged) {
        
        _archerBGView.transform = CGAffineTransformRotate(_archerBGView.transform, recognizer.rotation);
        _rotation = _rotation + recognizer.rotation;
        recognizer.rotation = 0;
        [self layoutSubviews];
        [self hiddenToolBar:YES animation:YES];
        //取消当前
       // [self.textTool.editor resetCurrentTool];
    } else if (recognizer.state == UIGestureRecognizerStateEnded ||
               recognizer.state == UIGestureRecognizerStateFailed ||
               recognizer.state == UIGestureRecognizerStateCancelled) {
        [self hiddenToolBar:NO animation:YES];
    }
}

// TODO:点击文字
#pragma mark - Edit it again
- (void)textBoardItemDidTap:(UITapGestureRecognizer *)recognizer {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(textBoardItemDidClickItem:)]) {
        [self.delegate textBoardItemDidClickItem:self];
    }
    
    self.textBoard.isEditAgain = YES;
    self.textBoard.textView.textView.text = self.text;
    self.textBoard.textView.textView.font = self.font;

    __weak typeof (self)weakSelf = self;
    self.textBoard.editAgainCallback = ^(NSString *text){
        weakSelf.text = text;
        [weakSelf resizeSelf];
        weakSelf.font = weakSelf.textBoard.textView.textView.font;
        weakSelf.fillColor = weakSelf.textBoard.textView.textView.textColor;
    };
    
    
    //事件源
//    [self.textTool.editor editTextAgain];

    
}

- (void)resizeSelf {
	
    CGSize size = [_label sizeThatFits:CGSizeMake(CGRectGetWidth(self.textBoard.previewView.drawingView.frame) - 2*LABEL_OFFSET, FLT_MAX)];
   _label.frame = CGRectMake(LABEL_OFFSET, LABEL_OFFSET, size.width + 20, size.height + _label.font.pointSize);
    self.bounds = CGRectMake(0, 0, CGRectGetWidth(_label.frame) + 2*LABEL_OFFSET, CGRectGetHeight(_label.frame) + 2*LABEL_OFFSET);
    _archerBGView.bounds = self.bounds;
	
	_leftTopRectLayer.frame = CGRectMake(_scale/2.f - 2, - 2, 4, 4);
    _rightTopRectLayer.frame = CGRectMake(CGRectGetWidth(_label.frame) - 2 - _scale/2.f, - 2, 4, 4);
    _leftBottomRectLayer.frame = CGRectMake(_scale/2.f - 2, _scale/2.f + CGRectGetHeight(_label.frame) - 2, 4, 4);
    _rightBottomRectLayer.frame = CGRectMake(CGRectGetWidth(_label.frame) - 2 - _scale/2.f, CGRectGetHeight(_label.frame) - 2 - _scale/2.f, 4, 4);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect boundss;
    if (!_archerBGView.superview) {
        [self.superview insertSubview:_archerBGView belowSubview:self];
        _archerBGView.frame = self.frame;
        boundss = self.bounds;
    }
    boundss = _archerBGView.bounds;
    self.transform = CGAffineTransformMakeRotation(_rotation);
    
    CGFloat w = boundss.size.width;
    CGFloat h = boundss.size.height;
    CGFloat scale = [(NSNumber *)[_archerBGView valueForKeyPath:@"layer.transform.scale.x"] floatValue];
    
    self.bounds = CGRectMake(0, 0, w*scale, h*scale);
    self.center = _archerBGView.center;
    
    _label.frame = CGRectMake(LABEL_OFFSET, LABEL_OFFSET, self.bounds.size.width - 2*LABEL_OFFSET, self.bounds.size.height - 2*LABEL_OFFSET);
    {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
		
		if (!_leftTopRectLayer) {
			_leftTopRectLayer = [CALayer layer];
			_leftTopRectLayer.backgroundColor = [UIColor whiteColor].CGColor;
			[_label.layer addSublayer:_leftTopRectLayer];
		}
		_leftTopRectLayer.frame = CGRectMake(_scale/2.f - 2, - 2, 4, 4);
		
        if (!_rightTopRectLayer) {
            _rightTopRectLayer = [CALayer layer];
            _rightTopRectLayer.backgroundColor = [UIColor whiteColor].CGColor;
            [_label.layer addSublayer:_rightTopRectLayer];
        }
        _rightTopRectLayer.frame = CGRectMake(CGRectGetWidth(_label.frame) - 2 - _scale/2.f, - 2, 4, 4);

        if (!_leftBottomRectLayer) {
            _leftBottomRectLayer = [CALayer layer];
            _leftBottomRectLayer.backgroundColor = [UIColor whiteColor].CGColor;
            [_label.layer addSublayer:_leftBottomRectLayer];
        }
        _leftBottomRectLayer.frame = CGRectMake(_scale/2.f - 2, CGRectGetHeight(_label.frame) - 2 - _scale/2.f, 4, 4);
        
        if (!_rightBottomRectLayer) {
            _rightBottomRectLayer = [CALayer layer];
            _rightBottomRectLayer.backgroundColor = [UIColor whiteColor].CGColor;
            [_label.layer addSublayer:_rightBottomRectLayer];
        }
        _rightBottomRectLayer.frame = CGRectMake(CGRectGetWidth(_label.frame) - 2 - _scale/2.f, CGRectGetHeight(_label.frame) - 2 - _scale/2.f, 4, 4);
        [CATransaction commit];
    }
}

#pragma mark- Properties

- (void)setActive:(BOOL)active {
	
	_active = active;
	
    dispatch_async(dispatch_get_main_queue(), ^{
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
   
        _label.layer.borderWidth = (active) ? 1/_scale : 0;
        _label.layer.shadowColor = [UIColor grayColor].CGColor;
        _label.layer.shadowOffset= CGSizeMake(0, 0);
        _label.layer.shadowOpacity = .6f;
        _label.layer.shadowRadius = 2.f;
        
        _leftTopRectLayer.hidden =
		_rightTopRectLayer.hidden =
		_leftBottomRectLayer.hidden =
		_rightBottomRectLayer.hidden = !active;
		
        [CATransaction commit];
        
//        if (active) {
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeColor:) name:@"kColorPanNotificaiton" object:nil];
//        } else {
//            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kColorPanNotificaiton" object:nil];
//        }
    });
}

- (void)changeColor:(NSNotification *)notification {
    UIColor *currentColor = (UIColor *)notification.object;
    self.fillColor = currentColor;
}

- (void)sizeToFitWithMaxWidth:(CGFloat)width lineHeight:(CGFloat)lineHeight
{
    self.transform = CGAffineTransformIdentity;
    _label.transform = CGAffineTransformIdentity;
    
    CGSize size = [_label sizeThatFits:CGSizeMake(width / (15/MAX_FONT_SIZE), FLT_MAX)];
    _label.frame = CGRectMake(16, 16, size.width, size.height);
    
    CGFloat viewW = (CGRectGetWidth(_label.frame) + 32);
    CGFloat viewH = _label.font.lineHeight;
    
    CGFloat ratio = MIN(width / viewW, lineHeight / viewH);
    [self setScale:ratio];
}

- (void)setScale:(CGFloat)scale
{
    _scale = scale;
    
    self.transform = CGAffineTransformIdentity;
    
    _label.transform = CGAffineTransformMakeScale(_scale, _scale);
    
    CGRect rct = self.frame;
    rct.origin.x += (rct.size.width - (CGRectGetWidth(_label.frame) + 32)) / 2;
    rct.origin.y += (rct.size.height - (CGRectGetHeight(_label.frame) + 32)) / 2;
    rct.size.width  = CGRectGetWidth(_label.frame) + 32;
    rct.size.height = CGRectGetHeight(_label.frame) + 32;
    self.frame = rct;
    
    _label.center = CGPointMake(rct.size.width/2, rct.size.height/2);
    
    self.transform = CGAffineTransformMakeRotation(_arg);
    
    _label.layer.borderWidth = 1/_scale;
}

- (void)setFillColor:(UIColor *)fillColor
{
    _label.textColor = [UIColor clearColor];
    _archerBGView.textColor = fillColor;
}

- (UIColor*)fillColor
{
    //return _label.textColor;
    return _archerBGView.textColor;
}

- (void)setBorderColor:(UIColor *)borderColor
{
    _label.layer.borderColor = borderColor.CGColor;
}

- (UIColor*)borderColor
{
    return [UIColor colorWithCGColor:_label.layer.borderColor];
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    _label.layer.borderWidth = borderWidth;
}

- (CGFloat)borderWidth
{
    return _label.layer.borderWidth;
}

- (void)setFont:(UIFont *)font
{
    _label.font = font;
    _archerBGView.textFont = font;
}

- (UIFont*)font
{
    return _label.font;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    _label.textAlignment = textAlignment;
}

- (NSTextAlignment)textAlignment
{
    return _label.textAlignment;
}

- (void)setText:(NSString *)text
{
    if(![text isEqualToString:_text]){
        _text = text;
        _label.text = (_text.length>0) ? _text : @"";
        _archerBGView.text = _label.text;
    }
}

- (void)setImage:(UIImage *)image {
    if (_image != image) {
        _image = image;
        _archerBGView.image = image;
    }
}

@end

@interface PSTextBoard ()
@end

@implementation PSTextLabel

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//
//    }
//    return self;
//}
//
//- (void)layoutSubviews {
//    [super layoutSubviews];
//}
//
//- (void)drawTextInRect:(CGRect)rect
//{
//    CGSize shadowOffset = self.shadowOffset;
//    UIColor *txtColor = self.textColor;
//    UIFont *font = self.font;
//
//    CGContextRef contextRef = UIGraphicsGetCurrentContext();
//    CGContextSetLineWidth(contextRef, 1);
//    CGContextSetLineJoin(contextRef, kCGLineJoinRound);
//
//    CGContextSetTextDrawingMode(contextRef, kCGTextFill);
//    self.textColor = txtColor;
//    self.shadowOffset = CGSizeMake(10, 10);
//    self.font = font;
//    [super drawTextInRect:CGRectInset(rect, 5, 5)];
//
//    self.shadowOffset = shadowOffset;
//}

@end
