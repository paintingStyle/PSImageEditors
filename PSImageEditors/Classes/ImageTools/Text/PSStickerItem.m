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
							 imageRect:(CGRect)imageRect
{
    PSStickerItem *item = [[self alloc] initMain];
    item.attributedText = text;
	item.imageRect = imageRect;
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


//- (UIImage * __nullable)displayImage
//{
//    if (self.image) {
//        return self.image;
//    } else if (/*self.text.text.length || */self.attributedText.length) {
//
//        if (_textCacheDisplayImage == nil) {
//
//			CGFloat w = ceilf(self.imageRect.size.width) *0.6;
//            NSRange range = NSMakeRange(0, 1);
//            CGSize textSize = [self.attributedText sizeWithConstrainedToSize:CGSizeMake(w, CGFLOAT_MAX)];
//
//            NSDictionary *typingAttributes = [self.attributedText attributesAtIndex:0 effectiveRange:&range];
//
//			CGFloat distance = 0.0;
//			UIColor *backgroundColor = typingAttributes[NSBackgroundColorAttributeName];
//			if (!CGColorEqualToColor(backgroundColor.CGColor, [UIColor clearColor].CGColor)) {
//				distance = 5;
//			}
//
//            UIColor *textColor = [typingAttributes objectForKey:NSForegroundColorAttributeName];
//
//            CGPoint point = CGPointMake(self.textInsets.left, self.textInsets.top);
//			CGSize size = CGSizeMake(textSize.width, textSize.height +distance); // 修复中文字体显示间距不一样
//            size.width += (self.textInsets.left+self.textInsets.right);
//            size.height += (self.textInsets.top+self.textInsets.bottom);
//
//            @autoreleasepool {
//                /** 创建画布 */
//                UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
//                CGContextRef context = UIGraphicsGetCurrentContext();
//                [self.attributedText drawInContext:context withPosition:point andHeight:textSize.height andWidth:textSize.width];
//
//                UIImage *temp = UIGraphicsGetImageFromCurrentImageContext();
//                UIGraphicsEndImageContext();
//                _textCacheDisplayImage = temp;
//            }
//
//        }
//
//        return _textCacheDisplayImage;
//    }
//    return nil;
//}

@end



@implementation PSStickerItem (View)

- (UIView * __nullable)displayView
{
	
	NSRange range = NSMakeRange(0, 1);
	NSDictionary *attrs = [self.attributedText attributesAtIndex:0 effectiveRange:&range];
	UIColor *fillColor = attrs[NSBackgroundColorAttributeName];
	UIColor *strokeColor = attrs[NSForegroundColorAttributeName];
	UIFont *font = attrs[NSFontAttributeName];


	CGSize textSize = [self sizeWithFont:font maxSize:CGSizeMake(CGFLOAT_MAX, font.pointSize) text:self.attributedText.string];
	CGFloat limit = ceilf(self.imageRect.size.width *0.6);
	NSInteger numberOfLines = 1;
	
	if (textSize.width > limit) {
		CGFloat maxH = ceilf([self sizeWithFont:font maxSize:CGSizeMake(limit, CGFLOAT_MAX) text:self.attributedText.string].height);
		textSize = CGSizeMake(limit, maxH);
		numberOfLines = 0;
	}

	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, textSize.width +self.textInsets.left+self.textInsets.right,
																   textSize.height +self.textInsets.top+self.textInsets.bottom)];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.textInsets.left, self.textInsets.top, textSize.width, textSize.height)];
	label.attributedText = self.attributedText;
	label.numberOfLines = numberOfLines;
	label.tag = kLabelTag;
	[contentView addSubview:label];
	
	
//	NSRange range = NSMakeRange(0, 1);
//	NSDictionary *attrs = [self.attributedText attributesAtIndex:0 effectiveRange:&range];
//	UIColor *fillColor = attrs[NSBackgroundColorAttributeName];
//	UIColor *strokeColor = attrs[NSForegroundColorAttributeName];
//	UIFont *font = attrs[NSFontAttributeName];
//
//	UILabel *label = [[UILabel alloc] init];
//	label.text = self.attributedText.string;
//	label.font = font;
//	label.textColor = strokeColor;
//	label.backgroundColor = fillColor;
//	label.tag = kLabelTag;
//	label.numberOfLines = 0;
//	[label sizeToFit];
//	label.frame = CGRectMake(self.textInsets.left, self.textInsets.top, label.frame.size.width, label.frame.size.height);
//
//	if (label.frame.size.width > self.imageRect.size.width *0.6) {
//		CGFloat maxH = [self sizeWithFont:font maxSize:CGSizeMake(self.imageRect.size.width *0.6, CGFLOAT_MAX) text:label.text].height;
//		label.frame = CGRectMake(self.textInsets.left, self.textInsets.top, self.imageRect.size.width *0.6, maxH);
//	}
//
//	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, label.frame.size.width +self.textInsets.left+self.textInsets.right,
//																		 label.frame.size.height +self.textInsets.top+self.textInsets.bottom)];
//	[contentView addSubview:label];
//
	return contentView;
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

@end

