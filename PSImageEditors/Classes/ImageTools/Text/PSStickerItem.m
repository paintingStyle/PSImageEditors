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

