//
//  PSImageLoadFailedView.m
//  PSImageEditors
//
//  Created by rsf on 2018/8/28.
//

#import "PSImageLoadFailedView.h"

@interface PSImageLoadFailedView ()

@end

@implementation PSImageLoadFailedView

- (instancetype)init {
	
	if (self = [super init]) {
		
		UIImageView *loadFailedImageView = [[UIImageView alloc] initWithImage:
											[UIImage ps_imageNamed:@"icon_image_loadFailed"]];
		[self addSubview:loadFailedImageView];
		[loadFailedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(self);
			make.centerY.equalTo(self).offset(-30);
		}];
		
		UILabel *loadFailedLabel = [[UILabel alloc] init];
		loadFailedLabel.font = [UIFont systemFontOfSize:16];
		loadFailedLabel.textColor = [UIColor whiteColor];
		loadFailedLabel.text = @"无法加载该图片";
		[self addSubview:loadFailedLabel];
		[loadFailedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
			make.top.equalTo(loadFailedImageView.mas_bottom).offset(10);
			make.centerX.equalTo(loadFailedImageView);
			make.height.equalTo(@20);
		}];
	}
	return self;
}

@end
