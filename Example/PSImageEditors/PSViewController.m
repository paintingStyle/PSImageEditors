//
//  PSViewController.m
//  PSImageEditors
//
//  Created by rsf on 2018/8/24.
//  Copyright © 2018年 paintingStyle. All rights reserved.
//

#import "PSViewController.h"
#import <PSImageEditors.h>
#import <PSCoolPreviewsViewController.h>
#import <PSFilePreviewsViewController.h>
#import <FLAnimatedImage/FLAnimatedImage.h>

@interface PSViewController ()

@property (nonatomic, copy) NSArray *images;
@property (nonatomic, copy) NSArray *urls;

@end

@implementation PSViewController

- (void)viewDidLoad {
	[super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes =
    @{NSForegroundColorAttributeName:[UIColor whiteColor]};
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (IBAction)previewLocalImageDidClick {
	
	PSPreviewViewController *controller = [[PSPreviewViewController alloc] initWithImages:self.images
                                                                             currentIndex:0];
	[self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)previewNetworkImageDidClick {
	
    PSPreviewViewController *controller = [[PSPreviewViewController alloc] initWithURLs:self.urls
                                                                           currentIndex:5];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)coolPreviewsDidClick {
    
    PSCoolPreviewsViewController *controller = [[PSCoolPreviewsViewController alloc] initWithURLs:self.urls
                                                                                     currentIndex:0];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)filePreviewsDidClick {
	
	PSFilePreviewsViewController *controller = [[PSFilePreviewsViewController alloc] initWithImages:self.images currentIndex:0];
	[self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)selectAlbumPreviewDidClick {
    

}

- (IBAction)imageCroppingDidClick {
	
}

- (NSArray *)images {
    
    if (!_images) {
        NSMutableArray *images = [NSMutableArray array];
        for (int i=0; i<12; i++) {
            NSString *imageName = [NSString stringWithFormat:@"localImage_%02d@2x.jpg",i];
            UIImage *image = [UIImage imageNamed:imageName];
            if (image) {
                [images addObject:image];
            }else {
                NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"localImage_%02d@2x.gif",i] ofType:nil];
                NSData *data = [NSData dataWithContentsOfFile:path];
                FLAnimatedImage *image = [[FLAnimatedImage alloc] initWithAnimatedGIFData:data];
                [images addObject:image];
            }
        }
        _images = images;
    }
    return _images;
}

- (NSArray *)urls {
    
    if (!_urls) {
        _urls = @[
                 @"http://sjbz.fd.zol-img.com.cn/t_s750x1334c/g5/M00/00/03/ChMkJ1fJV_yIIiWCAAdMxHOR9Z8AAU-HQOzoeAAB0zc59.jpeg",
                 @"http://sjbz.fd.zol-img.com.cn/t_s1600x1280c/g5/M00/00/02/ChMkJ1fJVOmIdszkACTYyds6TMoAAU90QOumT0AJNjh570.jpg",
                 @"http://sjbz.fd.zol-img.com.cn/t_s1600x1280c/g5/M00/00/00/ChMkJ1fJTwmIKraYABxSxsLu7y0AAU9PwA6izwAHFLe620.jpg",
                 @"http://sjbz.fd.zol-img.com.cn/t_s768x1280c/g5/M00/03/07/ChMkJlmqm8yIOqFxABdaTd6OYi4AAgI0gJsPEQAF1pl924.jpg",
                 @"http://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1535104855324&di=798e8e041edf11018f5d5a6d47defdbe&imgtype=0&src=http%3A%2F%2Fs9.rr.itc.cn%2Fr%2FwapChange%2F20163_30_21%2Fa4wbc34410568825352.jpg",
                 @"http://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1535104890436&di=d70950cc71c00fb018c189c49509341d&imgtype=0&src=http%3A%2F%2Fww1.sinaimg.cn%2Fbmiddle%2Fb15a116cgw1eng000ufdeg20ay05zwli.gif",
                 @"http://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1535104972710&di=b2d012029bb107cfb64f2fc58689cffc&imgtype=0&src=http%3A%2F%2F2017.zcool.com.cn%2Fcommunity%2F037b7355775cafb0000018c1b222864.gif",
                 @"http://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=1437422813,2114266192&fm=15&gp=0.jpg",
                 @"http://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=3987935587,2207705039&fm=26&gp=0.jpg",
                 @"http://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=2195511506,455868731&fm=15&gp=0.jpg"
                 ];
    }
    return _urls;
}

@end
