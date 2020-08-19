//
//  PSStickerItem.m
//  PSImageEditors
//
//  Created by rsf on 2020/8/18.
//

#import "PSStickerItem.h"
#import "NSAttributedString+PSCoreText.h"

@interface PSStickerItem ()

@property (nonatomic, assign) UIEdgeInsets textInsets; // 控制字体与控件边界的间隙
@property (nonatomic, strong) UIImage *textCacheDisplayImage;

@end

@implementation PSStickerItem

+ (instancetype)mainWithAttributedText:(NSAttributedString *)text
{
    PSStickerItem *item = [[self alloc] initMain];
    item.attributedText = text;
    return item;
}

- (instancetype)initMain
{
    self = [self init];
    if (self) {
 
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _textInsets = UIEdgeInsetsMake(7.f, 7.f, 7.f, 7.f);
    }
    return self;
}



- (UIImage * __nullable)displayImage
{
    if (self.image) {
        return self.image;
    } else if (/*self.text.text.length || */self.attributedText.length) {
        
        if (_textCacheDisplayImage == nil) {
            
            NSRange range = NSMakeRange(0, 1);
            CGSize textSize = [self.attributedText sizeWithConstrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-(self.textInsets.left+self.textInsets.right), CGFLOAT_MAX)];
            NSDictionary *typingAttributes = [self.attributedText attributesAtIndex:0 effectiveRange:&range];
            
            UIColor *textColor = [typingAttributes objectForKey:NSForegroundColorAttributeName];
            
            CGPoint point = CGPointMake(self.textInsets.left, self.textInsets.top);
            CGSize size = textSize;
            size.width += (self.textInsets.left+self.textInsets.right);
            size.height += (self.textInsets.top+self.textInsets.bottom);
            
            @autoreleasepool {
                /** 创建画布 */
                UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
                CGContextRef context = UIGraphicsGetCurrentContext();
                
                UIColor *shadowColor = ([textColor isEqual:[UIColor blackColor]]) ? [UIColor whiteColor] : [UIColor blackColor];
                CGColorRef shadow = [shadowColor colorWithAlphaComponent:0.8f].CGColor;
                CGContextSetShadowWithColor(context, CGSizeMake(1, 1), 3.f, shadow);
                CGContextSetAllowsAntialiasing(context, YES);
                
                [self.attributedText drawInContext:context withPosition:point andHeight:textSize.height andWidth:textSize.width];
                
                UIImage *temp = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                _textCacheDisplayImage = temp;
            }
            
        }
        
        return _textCacheDisplayImage;
    }
    return nil;
}

@end



@implementation PSStickerItem (View)

- (UIView * __nullable)displayView
{
	UIView *view = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, self.displayImage.size}];
		   view.layer.contents = (__bridge id _Nullable)(self.displayImage.CGImage);
	return view;
}

@end

