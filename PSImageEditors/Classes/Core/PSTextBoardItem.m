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

static const CGFloat kLabelMinSize = 20;
static const CGFloat kTextBoardItemInset = 12;

@interface PSTextBoardItem () <UIGestureRecognizerDelegate,UITableViewDelegate>

@property (nonatomic, weak) PSTextBoard *textBoard;

@end

@implementation PSTextBoardItem
{
    UILabel  *_label;
    
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
        
    //    [activeView.containerView bringSubviewToFront:activeView];
        [activeView.superview bringSubviewToFront:activeView];
        
    }
}

+ (void)setInactiveTextView:(PSTextBoardItem *)view {
    if (activeView) {activeView = nil;}
    view.active = NO;
}

- (instancetype)initWithTool:(PSTextBoard *)tool text:(NSString *)text font:(UIFont *)font orImage:(UIImage *)image
{
    if(self = [super init]){
		
		//_containerView = [[UIView alloc] init];
//        _archerBGView = [[PSTextBoardItemOverlapView alloc] initWithFrame:CGRectZero];
//        _archerBGView.backgroundColor = [UIColor clearColor];
		
        _label = [[UILabel alloc] init];
        _label.numberOfLines = 0;
        _label.font = font;
        _label.minimumScaleFactor = font.pointSize * 0.8f;
        _label.adjustsFontSizeToFitWidth = YES;
        _label.textAlignment = NSTextAlignmentCenter;
		_label.textColor = [UIColor whiteColor];
        _label.text = text;
        _label.layer.allowsEdgeAntialiasing = true;
		
		//_label.backgroundColor = [UIColor yellowColor];
		
        self.text = text;
        [self addSubview:_label];
        
        _textBoard = tool;
		
        CGSize size = [_label sizeThatFits:CGSizeMake(CGRectGetWidth(_textBoard.previewView.drawingView.frame) - 2*kTextBoardItemInset, FLT_MAX)];
        //_label.frame = CGRectMake(LABEL_OFFSET, LABEL_OFFSET, size.width + 0, size.height + _label.font.pointSize);
		_label.frame = CGRectMake(kTextBoardItemInset, kTextBoardItemInset, size.width, size.height);
		
        self.frame = CGRectMake(0, 0, CGRectGetWidth(_label.frame) + 2*kTextBoardItemInset, CGRectGetHeight(_label.frame) + 2*kTextBoardItemInset);
		
        _arg = 0;
        [self setScale:1];
        
        [self initGestures];
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			id a = self;
		});
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

- (void)remove {
    
    [[self class] setActiveTextView:self];
    [self removeFromSuperview];
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
    UIView *piece = self;
    CGPoint translation = [recognizer translationInView:piece.superview];
    piece.center = CGPointMake(piece.center.x + translation.x, piece.center.y + translation.y);
    [recognizer setTranslation:CGPointZero inView:piece.superview];
    
	BOOL activation = (recognizer.state == UIGestureRecognizerStateBegan ||
					   recognizer.state == UIGestureRecognizerStateChanged);

	CGRect rectCoordinate = [piece.superview convertRect:piece.frame toView:_textBoard.previewView.imageView.superview];
	CGRect deleteCoordinate = CGRectMake(0, PS_SCREEN_H-PSBottomToolDeleteBarHeight, PS_SCREEN_W, PSBottomToolDeleteBarHeight);
	BOOL hasDeleteCoordinate = CGRectIntersectsRect(deleteCoordinate, rectCoordinate);
	BOOL beyondBorder = !CGRectIntersectsRect(CGRectInset(_textBoard.previewView.imageView.frame, 30, 30), rectCoordinate);
	
    if (activation) {
        [self hiddenToolBar:YES animation:YES];
        //取消当前
      //  [self.textTool.editor resetCurrentTool];
    } else  {
		BOOL restrictedPanAreas = NO;
		if (self.delegate && [self.delegate respondsToSelector:
							  @selector(textBoardItem:restrictedPanAreasAtTextBoard:)]) {
			restrictedPanAreas = [self.delegate textBoardItem:self restrictedPanAreasAtTextBoard:_textBoard];
		}
		if (restrictedPanAreas) {
			[UIView animateWithDuration:.2f animations:^{
				piece.center = piece.superview.center;
				self.center = piece.center;
			}];
		}
		[self hiddenToolBar:NO animation:YES];
    }
	
	if (self.delegate && [self.delegate respondsToSelector:
						  @selector(textBoardItem:translationGesture:activation:)]) {
		[self.delegate textBoardItem:self translationGesture:recognizer
						  activation:activation];
	}
    
    [self layoutSubviews];
}

- (void)viewDidPinch:(UIPinchGestureRecognizer *)recognizer {
    //缩放
    [[self class] setActiveTextView:self];
    
    if (recognizer.state == UIGestureRecognizerStateBegan ||
        recognizer.state == UIGestureRecognizerStateChanged) {
        //坑点：recognizer.scale是相对原图片大小的scal
        
        CGFloat scale = [(NSNumber *)[self valueForKeyPath:@"layer.transform.scale.x"] floatValue];
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
        
        
        self.transform = CGAffineTransformScale(self.transform, currentScale, currentScale);
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
        
        self.transform = CGAffineTransformRotate(self.transform, recognizer.rotation);
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
	
	self.textBoard.isEditAgain = YES;
	//self.textBoard.activeItem = self;
	
    if (self.delegate && [self.delegate respondsToSelector:@selector(textBoardItemDidClickItem:)]) {
        [self.delegate textBoardItemDidClickItem:self];
    }
    
//    self.textBoard.isEditAgain = YES;
//    self.textBoard.textView.textView.text = self.text;
//    self.textBoard.textView.textView.font = self.font;

    __weak typeof (self)weakSelf = self;
	self.textBoard.editAgainCallback = ^(NSString *text, NSDictionary *attrs) {

        weakSelf.text = text;
        [weakSelf resizeSelf];
		
		UIColor *fillColor = attrs[NSBackgroundColorAttributeName];
		UIColor *strokeColor = attrs[NSForegroundColorAttributeName];
		UIFont *font = attrs[NSFontAttributeName];
		
		weakSelf.font = font;
		weakSelf.strokeColor = strokeColor;
		weakSelf.fillColor = fillColor;
    };
    
    
    //事件源
//    [self.textTool.editor editTextAgain];

    
}

- (void)resizeSelf {
	
	
//	Size size = [_label sizeThatFits:CGSizeMake(CGRectGetWidth(_textBoard.previewView.drawingView.frame) - 2*kTextBoardItemInset, FLT_MAX)];
//	//_label.frame = CGRectMake(LABEL_OFFSET, LABEL_OFFSET, size.width + 0, size.height + _label.font.pointSize);
//	_label.frame = CGRectMake(kTextBoardItemInset, kTextBoardItemInset, size.width, size.height);
//
//	self.frame = CGRectMake(0, 0, CGRectGetWidth(_label.frame) + 2*kTextBoardItemInset, CGRectGetHeight(_label.frame) + 2*kTextBoardItemInset);
	
	
    CGSize size = [_label sizeThatFits:CGSizeMake(CGRectGetWidth(self.textBoard.previewView.drawingView.frame) - 2*kTextBoardItemInset, FLT_MAX)];
	if (CGSizeEqualToSize(size, CGSizeZero)) {
		size = CGSizeMake(kLabelMinSize, kLabelMinSize);
	}
	
	//	_label.frame = CGRectMake(LABEL_OFFSET, LABEL_OFFSET, size.width + 0, size.height + _label.font.pointSize);
	_label.frame = CGRectMake(kTextBoardItemInset, kTextBoardItemInset, size.width + 0, size.height);

    self.bounds = CGRectMake(0, 0, CGRectGetWidth(_label.frame) + 2*kTextBoardItemInset, CGRectGetHeight(_label.frame) + 2*kTextBoardItemInset);
    self.bounds = self.bounds;
	
	_leftTopRectLayer.frame = CGRectMake(_scale/2.f - 2, - 2, 4, 4);
    _rightTopRectLayer.frame = CGRectMake(CGRectGetWidth(self.frame) - 2 - _scale/2.f, - 2, 4, 4);
    _leftBottomRectLayer.frame = CGRectMake(_scale/2.f - 2, _scale/2.f + CGRectGetHeight(self.frame) - 2, 4, 4);
    _rightBottomRectLayer.frame = CGRectMake(CGRectGetWidth(self.frame) - 2 - _scale/2.f, CGRectGetHeight(self.frame) - 2 - _scale/2.f, 4, 4);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
//    CGRect boundss;
//    if (!self.superview) {
//        [self.superview insertSubview:self belowSubview:self];
//        self.frame = self.frame;
//        boundss = self.bounds;
//    }
//    boundss = self.bounds;
    self.transform = CGAffineTransformMakeRotation(_rotation);
	
//    CGFloat w = boundss.size.width;
//    CGFloat h = boundss.size.height;
	CGFloat w = self.bounds.size.width;
	CGFloat h = self.bounds.size.height;
    CGFloat scale = [(NSNumber *)[self valueForKeyPath:@"layer.transform.scale.x"] floatValue];
    
    self.bounds = CGRectMake(0, 0, w*scale, h*scale);
    self.center = self.center;

    
    _label.frame = CGRectMake(kTextBoardItemInset, kTextBoardItemInset, self.bounds.size.width - 2*kTextBoardItemInset, self.bounds.size.height - 2*kTextBoardItemInset);
    {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
		
		if (!_leftTopRectLayer) {
			_leftTopRectLayer = [CALayer layer];
			_leftTopRectLayer.backgroundColor = [UIColor whiteColor].CGColor;
			[self.layer addSublayer:_leftTopRectLayer];
		}
		_leftTopRectLayer.frame = CGRectMake(_scale/2.f - 2, - 2, 4, 4);
		
        if (!_rightTopRectLayer) {
            _rightTopRectLayer = [CALayer layer];
            _rightTopRectLayer.backgroundColor = [UIColor whiteColor].CGColor;
            [self.layer addSublayer:_rightTopRectLayer];
        }
        _rightTopRectLayer.frame = CGRectMake(CGRectGetWidth(self.frame) - 2 - _scale/2.f, - 2, 4, 4);

        if (!_leftBottomRectLayer) {
            _leftBottomRectLayer = [CALayer layer];
            _leftBottomRectLayer.backgroundColor = [UIColor yellowColor].CGColor;
            [self.layer addSublayer:_leftBottomRectLayer];
        }
        _leftBottomRectLayer.frame = CGRectMake(_scale/2.f - 2, CGRectGetHeight(self.frame) - 2 - _scale/2.f, 4, 4);
		
        if (!_rightBottomRectLayer) {
            _rightBottomRectLayer = [CALayer layer];
            _rightBottomRectLayer.backgroundColor = [UIColor whiteColor].CGColor;
            [self.layer addSublayer:_rightBottomRectLayer];
        }
        _rightBottomRectLayer.frame = CGRectMake(CGRectGetWidth(self.frame) - 2 - _scale/2.f, CGRectGetHeight(self.frame) - 2 - _scale/2.f, 4, 4);
		
        [CATransaction commit];
    }
}

#pragma mark- Properties

- (void)setActive:(BOOL)active {
	
	_active = active;
	
   // dispatch_async(dispatch_get_main_queue(), ^{
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
	
		self.layer.borderWidth = (active) ? 1/_scale : 0;
		self.layer.shadowColor = [UIColor grayColor].CGColor;
		self.layer.shadowOffset= CGSizeMake(0, 0);
		self.layer.shadowOpacity = .6f;
		self.layer.shadowRadius = 2.f;
		
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
  //  });
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
    
    self.layer.borderWidth = 1/_scale;
}

- (void)setFont:(UIFont *)font {
	_label.font = font;
}

- (UIFont*)font {
	return _label.font;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
	_label.textAlignment = textAlignment;
}

- (NSTextAlignment)textAlignment {
	return _label.textAlignment;
}

- (void)setText:(NSString *)text {
	_text = text;
	_label.text = text;
}

- (void)setStrokeColor:(UIColor *)strokeColor {

	//_strokeColor = strokeColor;
	_label.textColor = strokeColor;
}

- (UIColor *)strokeColor {
	return _label.textColor;
}

- (void)setBorderColor:(UIColor *)borderColor {
    self.layer.borderColor = borderColor.CGColor;
}

- (UIColor*)borderColor {
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    self.layer.borderWidth = borderWidth;
}

- (CGFloat)borderWidth {
    return self.layer.borderWidth;
}

- (void)setFillColor:(UIColor *)fillColor {
	_label.backgroundColor = fillColor;
}

- (UIColor *)fillColor {
	return _label.backgroundColor;
}

@end
