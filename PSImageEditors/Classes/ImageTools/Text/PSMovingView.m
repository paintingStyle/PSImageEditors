//
//  PSMovingView.m
//  PSImageEditors
//
//  Created by rsf on 2020/8/18.
//

#import "PSMovingView.h"

#define kTextMargin 22
#define KContentViewBorderWidth 2

@interface PSMovingContentView : UIView <UIGestureRecognizerDelegate>

@end

@implementation PSMovingContentView

- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    gestureRecognizer.delegate = self;
    [super addGestureRecognizer:gestureRecognizer];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer.view == self && otherGestureRecognizer.view == self) {
        return YES;
    }
    return NO;
}

@end



@interface PSMovingView ()
{
    PSMovingContentView *_contentView;
    UIButton *_deleteButton;
    UIImageView *_circleView;
    
    CGFloat _scale;
    CGFloat _arg;
    
    CGPoint _initialPoint;
    CGFloat _initialArg;
    CGFloat _initialScale;
}

@property (nonatomic, assign) BOOL isActive;

@end

@implementation PSMovingView


+ (void)setActiveEmoticonView:(PSMovingView *)view
{
    static PSMovingView *activeView = nil;
    /** 停止取消激活 */
    [activeView cancelDeactivated];
    if(view != activeView){
        [activeView setActive:NO];
        activeView = view;
        [activeView setActive:YES];
        
        [activeView.superview bringSubviewToFront:activeView];
        
    }
    [activeView autoDeactivated];
}

- (void)dealloc
{
    [self cancelDeactivated];
}

#pragma mark - 自动取消激活
- (void)cancelDeactivated
{
    [PSMovingView cancelPreviousPerformRequestsWithTarget:self];
}

- (void)autoDeactivated
{
   // [self performSelector:@selector(setActiveEmoticonView:) withObject:nil afterDelay:self.deactivatedDelay];
}

- (void)setActiveEmoticonView:(PSMovingView *)view
{
    [PSMovingView setActiveEmoticonView:view];
}

- (void)layoutSubviews {
	[super layoutSubviews];
}

- (CGFloat)transformScaleX {
	
	CGFloat transformScaleX = [[_contentView.layer valueForKeyPath:@"transform.scale.x"] doubleValue];
	return transformScaleX;
}

- (CGFloat)transformScaleY {
	
	CGFloat transformScaleY = [[_contentView.layer valueForKeyPath:@"transform.scale.y"] doubleValue];
	return transformScaleY;
}

- (instancetype)initWithItem:(PSStickerItem *)item
{
    UIView *view = item.displayView;
    if (view == nil) {
        return nil;
    }
    self = [super initWithFrame:CGRectMake(0, 0, view.frame.size.width+kTextMargin, view.frame.size.height+kTextMargin)];
    if (self){
        //_deactivatedDelay = 4.f;
        _view = view;
        _item = item;
        _contentView = [[PSMovingContentView alloc] initWithFrame:view.bounds];
        _contentView.layer.borderColor = [[UIColor whiteColor] CGColor];
		_contentView.layer.borderWidth = KContentViewBorderWidth;
        
        _contentView.center = self.center;
        [_contentView addSubview:view];
        view.userInteractionEnabled = self.isActive;
		view.frame = _contentView.bounds;
        [self addSubview:_contentView];
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.frame = CGRectMake(0, 0, 22, 22);
        _deleteButton.center = _contentView.frame.origin;
        [_deleteButton addTarget:self action:@selector(pushedDeleteBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_deleteButton setImage:[UIImage ps_imageNamed:@"btn_text_item_close"]  forState:UIControlStateNormal];
        [self addSubview:_deleteButton];
		
        _circleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
        _circleView.center = CGPointMake(CGRectGetMaxX(_contentView.frame), CGRectGetMaxY(_contentView.frame));
        [_circleView setImage:[UIImage ps_imageNamed:@"btn_text_item_zoom"]];
        [self addSubview:_circleView];
        
        _scale = 1.f;
        _screenScale = 1.f;
        _arg = 0;
        _minScale = 1.0f;
        _maxScale = 3.0f;
        
        [self initGestures];
        [self setActive:NO];
		[self setScale:_scale rotation:_arg];
    }
    return self;
}

- (void)setItem:(PSStickerItem *)item
{
    _item = item;
    [_view removeFromSuperview];
    _view = item.displayView;
    if (_view) {
        [_contentView addSubview:_view];
        _view.userInteractionEnabled = self.isActive;
        [self updateFrameWithViewSize:_view.frame.size];
    } else {
        [self removeFromSuperview];
    }
}

/** 更新坐标 */
- (void)updateFrameWithViewSize:(CGSize)viewSize
{
    /** 记录自身中心点 */
    CGPoint center = self.center;
    /** 更新自身大小 */
    CGRect frame = self.frame;
    frame.size = CGSizeMake(viewSize.width+kTextMargin, viewSize.height+kTextMargin);
    self.frame = frame;
    self.center = center;
    
    /** 还原缩放率 */
    _contentView.transform = CGAffineTransformIdentity;
    
    /** 更新主体大小 */
    CGRect contentFrame = _contentView.frame;
    contentFrame.size = viewSize;
    _contentView.frame = contentFrame;
    _contentView.center = center;
    _deleteButton.center = _contentView.frame.origin;
    _circleView.center = CGPointMake(CGRectGetMaxX(_contentView.frame), CGRectGetMaxY(_contentView.frame));
    [self updateShadow];
    /** 更新显示视图大小 */
    _view.frame = _contentView.bounds;
    
    [self setScale:_scale rotation:_arg];
}

- (void)updateShadow
{
	CGFloat shadowRadius = 5;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineJoinStyle = kCGLineJoinRound;
    
    UIBezierPath *leftPath = [UIBezierPath bezierPathWithRect:CGRectMake(-shadowRadius/2, 0, shadowRadius, _contentView.bounds.size.height-shadowRadius)];
    UIBezierPath *topPath = [UIBezierPath bezierPathWithRect:CGRectMake(shadowRadius/2, -shadowRadius/2, _contentView.bounds.size.width-shadowRadius, shadowRadius)];
    UIBezierPath *rightPath = [UIBezierPath bezierPathWithRect:CGRectMake(_contentView.bounds.size.width-shadowRadius/2, shadowRadius, shadowRadius, _contentView.bounds.size.height-shadowRadius)];
    UIBezierPath *bottomPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, _contentView.bounds.size.height-shadowRadius/2, _contentView.bounds.size.width-shadowRadius, shadowRadius)];
	
	
    [path appendPath:topPath];
    [path appendPath:leftPath];
    [path appendPath:rightPath];
    [path appendPath:bottomPath];
	
    _contentView.layer.shadowPath = path.CGPath;
}

- (void)initGestures
{
    self.userInteractionEnabled = YES;
    _contentView.userInteractionEnabled = YES;
    _circleView.userInteractionEnabled = YES;
    [_contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap:)]];
    [_contentView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPan:)]];
    [_circleView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(circleViewDidPan:)]];
    
    /** Add two finger pinching and rotating gestures */
    [_contentView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPinch:)]];
    [_contentView addGestureRecognizer:[[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidRotation:)]];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView* view= [super hitTest:point withEvent:event];
    if(view==self){
        view = nil;
    }
    if (view == nil) {
        [PSMovingView setActiveEmoticonView:nil];
    }
    return view;
}

- (void)setActive:(BOOL)active
{
    _isActive = active;
    _deleteButton.hidden = !active;
    _circleView.hidden = !active;
	_contentView.layer.borderWidth = (active) ? KContentViewBorderWidth/_scale/self.screenScale : 0;
    _contentView.layer.cornerRadius = (active) ? 3/_scale/self.screenScale : 0;
    _contentView.layer.shadowColor = (active) ? [UIColor blackColor].CGColor : [UIColor clearColor].CGColor;
    
    _view.userInteractionEnabled = active;
}

- (void)setScale:(CGFloat)scale
{
    [self setScale:scale rotation:MAXFLOAT];
}

- (void)setScale:(CGFloat)scale rotation:(CGFloat)rotation
{
    if (rotation != MAXFLOAT) { 
        _arg = rotation;
    }
	_scale = MIN(MAX(scale, _minScale), _maxScale);
	
    self.transform = CGAffineTransformIdentity;
    
    _contentView.transform = CGAffineTransformMakeScale(_scale, _scale);
	
    CGRect rct = self.frame;
    rct.origin.x += (rct.size.width - (_contentView.frame.size.width + kTextMargin)) / 2;
    rct.origin.y += (rct.size.height - (_contentView.frame.size.height + kTextMargin)) / 2;
    rct.size.width  = _contentView.frame.size.width + kTextMargin;
    rct.size.height = _contentView.frame.size.height + kTextMargin;
    self.frame = rct;
    
    _contentView.center = CGPointMake(rct.size.width/2, rct.size.height/2);
    _deleteButton.center = CGPointMake(_contentView.frame.origin.x, _contentView.frame.origin.y);
    _circleView.center = CGPointMake(CGRectGetMaxX(_contentView.frame), CGRectGetMaxY(_contentView.frame));
    
    self.transform = CGAffineTransformMakeRotation(_arg);


	// 解决UILabel字体模糊, 这里只处理单行文本
	UILabel *label = [_view.subviews.lastObject viewWithTag:kLabelTag];
	if (label.numberOfLines != 0) {
		label.font = [UIFont systemFontOfSize:18 *_scale];
		label.transform = CGAffineTransformMakeScale(1 / _scale, 1 / _scale);
		label.sizeToFit;
	}
	
    if (_isActive) {
		_contentView.layer.borderWidth =  KContentViewBorderWidth/_scale/self.screenScale;
        _contentView.layer.cornerRadius = 3/_scale/self.screenScale;
    }
}

- (CGSize)sizeWithFont:(UIFont *)font
			   maxSize:(CGSize)maxSize
				  text:(NSString *)text {
	
	CGSize size = CGSizeZero;
	if (text.length > 0) {
		CGRect frame = [text boundingRectWithSize:maxSize options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{ NSFontAttributeName: font } context:nil];
		size = CGSizeMake(frame.size.width, frame.size.height + 1);
	}
	return size;
}

- (void)setScreenScale:(CGFloat)screenScale
{
    _screenScale = screenScale;
    CGFloat scale = 1.f/screenScale;
    _deleteButton.transform = CGAffineTransformMakeScale(scale, scale);
    _circleView.transform = CGAffineTransformMakeScale(scale, scale);
    _deleteButton.center = _contentView.frame.origin;
    _circleView.center = CGPointMake(CGRectGetMaxX(_contentView.frame), CGRectGetMaxY(_contentView.frame));
}

- (CGFloat)scale
{
    return _scale;
}

- (CGFloat)rotation
{
    return _arg;
}

#pragma mark - Touch Event

- (void)pushedDeleteBtn:(id)sender
{
    [self cancelDeactivated];
    [self removeFromSuperview];
	if (self.delete) {
		self.delete();
	}
}

- (void)viewDidTap:(UITapGestureRecognizer*)sender
{
	
	CGPoint point = [sender locationInView:self.superview];
	if (self.tapEnded) {
		BOOL ended =  self.tapEnded(self, point);
		if (!ended) { return; }
	}
    [[self class] setActiveEmoticonView:self];
}

- (void)viewDidPan:(UIPanGestureRecognizer*)sender
{
    
    CGPoint p = [sender translationInView:self.superview];
    if(sender.state == UIGestureRecognizerStateBegan){
        [[self class] setActiveEmoticonView:self];
        _initialPoint = self.center;
        [self cancelDeactivated];
    }
    self.center = CGPointMake(_initialPoint.x + p.x, _initialPoint.y + p.y);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
		
		// 超出紧贴边界
        CGRect rect = [self convertRect:_contentView.frame toView:self.superview];
		CGRect r = self.frame;
		
		if (rect.origin.x < 0) {
			CGFloat distacn = CGRectGetWidth(_circleView.frame) *0.5 +(7 *_scale);
			r.origin.x = -(distacn);
		}
		if (rect.origin.x > CGRectGetWidth(self.superview.frame) -rect.size.width) {
			CGFloat distacn = _scale <= 1.0 ? 0:(7 *_scale)-4;
			r.origin.x = CGRectGetWidth(self.superview.frame) -rect.size.width + distacn;
		}
		if (rect.origin.y < PS_SAFEAREA_TOP_DISTANCE) {
			CGFloat distacn = CGRectGetWidth(_circleView.frame) +(7 *_scale);
			r.origin.y = PS_IPHONE_X_FUTURE_MODELS ? PS_SAFEAREA_TOP_DISTANCE -(7 *_scale) :distacn;
		}
		if (rect.origin.y > CGRectGetHeight(self.superview.frame) -rect.size.height -self.bottomSafeDistance) {
			r.origin.y = CGRectGetHeight(self.superview.frame)-self.bottomSafeDistance- (7 *_scale);
		}
		
		if (!CGRectEqualToRect(self.frame, r)) {
			[UIView animateWithDuration:0.25f animations:^{
				self.frame = r;
			}];
		}
        [self autoDeactivated];
    }
	
	if (self.moveCenter) {
		self.moveCenter(sender.state);
	}
}

- (void)viewDidPinch:(UIPinchGestureRecognizer*)sender
{
    if(sender.state == UIGestureRecognizerStateBegan){
        [[self class] setActiveEmoticonView:self];
        [self cancelDeactivated];
        _initialScale = _scale;
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        [self autoDeactivated];
    }
    [self setScale:(_initialScale * sender.scale)];
    if(sender.state == UIGestureRecognizerStateBegan && sender.state == UIGestureRecognizerStateChanged){
        sender.scale = 1.0;
    }
}

- (void)viewDidRotation:(UIRotationGestureRecognizer*)sender
{
    if(sender.state == UIGestureRecognizerStateBegan){
        [[self class] setActiveEmoticonView:self];
        [self cancelDeactivated];
        _initialArg = _arg;
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        [self autoDeactivated];
    }
    _arg = _initialArg + sender.rotation;
    [self setScale:_scale];
    if(sender.state == UIGestureRecognizerStateBegan && sender.state == UIGestureRecognizerStateChanged){
        sender.rotation = 0.0;
    }
}


- (void)circleViewDidPan:(UIPanGestureRecognizer*)sender
{
    CGPoint p = [sender translationInView:self.superview];
    
    static CGFloat tmpR = 1;
    static CGFloat tmpA = 0;
    if(sender.state == UIGestureRecognizerStateBegan){
        [self cancelDeactivated];
        _initialPoint = [self.superview convertPoint:_circleView.center fromView:_circleView.superview];
        
        CGPoint p = CGPointMake(_initialPoint.x - self.center.x, _initialPoint.y - self.center.y);
        tmpR = sqrt(p.x*p.x + p.y*p.y);
        tmpA = atan2(p.y, p.x);
        
       // _initialArg = _arg;
        _initialScale = _scale;
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        [self autoDeactivated];
    }
    
    p = CGPointMake(_initialPoint.x + p.x - self.center.x, _initialPoint.y + p.y - self.center.y);
    CGFloat R = sqrt(p.x*p.x + p.y*p.y);
	
	// 屏蔽旋转
    //CGFloat arg = atan2(p.y, p.x);
    //_arg = _initialArg + arg - tmpA;
    [self setScale:(_initialScale * R / tmpR)];
}


@end
