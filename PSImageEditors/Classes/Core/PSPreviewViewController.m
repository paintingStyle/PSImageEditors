//
//  PSPreviewViewController.m
//  PSImageEditors
//
//  Created by rsf on 2018/8/24.
//  Copyright © 2018年 paintingStyle. All rights reserved.
//

#import "PSPreviewViewController.h"
#import "PSPreviewViewCell.h"
#import "PSImageEditorsHelper.h"
#import "PSActionSheet.h"
#import "UIAlertController+PSExtension.h"

static NSString *const kReusableCellIdentifier = @"PSPreviewViewCell";

@interface PSPreviewViewController ()
<UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate>  {
    
    BOOL _navigationBarHidden;
}

@property (nonatomic, strong, readwrite) NSArray *urls;
@property (nonatomic, strong, readwrite) NSArray *images;
@property (nonatomic, assign, readwrite) NSInteger currentIndex;

@property (nonatomic, assign, getter=isLocal) BOOL local;
@property (nonatomic, strong, readwrite) UICollectionView *collectionView;
@property (nonatomic, strong, readwrite) NSMutableArray<PSImageObject *> *dataSources;
@property (nonatomic, assign, readwrite) PSImageObject *currentImageObject;

@end

@implementation PSPreviewViewController

- (instancetype)initWithURLs:(NSArray *)urls
				currentIndex:(NSInteger)index {
	
	return [self initWithURLs:urls images:nil currentIndex:index];
}

- (instancetype)initWithImages:(NSArray *)images
				  currentIndex:(NSInteger)index {
	
    return [self initWithURLs:nil images:images currentIndex:index];
}

- (instancetype)initWithURLs:(NSArray *)urls
                      images:(NSArray *)images
                  currentIndex:(NSInteger)index {
    
    if (self = [super init]) {
        _urls = urls;
        _images = images;
        _currentIndex = index;
        _local = YES;
        _showNavigationBar = NO;
        _clickShowNavigationBar = YES;
        _local = images.count;
    }
    return self;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
	
	[super viewDidLoad];
	[self configUI];
	[self configData];
}

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
    if (!self.isShowNavigationBar) {
        _navigationBarHidden = self.navigationController.navigationBar.hidden;
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
	
	[super viewWillDisappear:animated];
    if (!self.isShowNavigationBar) {
        [self.navigationController setNavigationBarHidden:_navigationBarHidden animated:NO];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

#pragma mark - Method

- (void)configData {
	
	if (self.isLocal) {
		[self.images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * _Nonnull stop) {
			
			BOOL isAnimation = [obj isKindOfClass:[FLAnimatedImage class]];
			PSImageObject *imageObject = [PSImageObject imageObjectWithIndex:idx
														url:nil image:(isAnimation ? nil:obj)
														GIFImage:(isAnimation ? obj:nil)];
			[self.dataSources addObject:imageObject];
		}];
	}else {
		[self.urls enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * _Nonnull stop) {
			
			NSURL *url = nil;
			if ([obj isKindOfClass:[NSString class]]) {
				url = [NSURL URLWithString:obj];
			}else {
				url = obj;
			}
			PSImageObject *imageObject = [PSImageObject imageObjectWithIndex:idx
														url:url image:nil GIFImage:nil];
			[self.dataSources addObject:imageObject];
		}];
	}
	[self.collectionView reloadData];
    CGPoint offset = CGPointMake(self.currentIndex *CGRectGetWidth(self.collectionView.frame), 0);
    [self.collectionView setContentOffset:offset animated:NO];
}

- (void)moreButtonDidClick {
    
    [PSActionSheet sheetWithActionTitles:@[@"保存到手机"]
                             actionBlock:^(NSInteger index) {
                                 
                                 switch (index) {
                                         case 0:
                                         [self saveCurrentImageToPhotosAlbum];
                                         break;
                                     default:
                                         break;
                                 }
                             }];
}

- (void)saveCurrentImageToPhotosAlbum {
    
    if ([PSImageEditorsHelper checkAlbumIsAvailableViewController:self]) {
        if (self.currentImageObject.url) {
            [PSImageEditorsHelper imageDataWithImageURL:self.currentImageObject.url completion:^(NSData *data) {
                [PSImageEditorsHelper saveToPhotosAlbumWithImageData:data completionHandler:^(BOOL success) {
                    [self saveToPhotosAlbumSuccess:success];
                }];
            }];
        }else {
            NSData *data = self.currentImageObject.GIFImage ? self.currentImageObject.GIFImage.data:
            UIImageJPEGRepresentation(self.currentImageObject.image, 1.0f);
            [PSImageEditorsHelper saveToPhotosAlbumWithImageData:data completionHandler:^(BOOL success) {
                [self saveToPhotosAlbumSuccess:success];
            }];
        }
    }
}

- (void)saveToPhotosAlbumSuccess:(BOOL)success {
    
    NSString *message = success ? @"保存图片成功":@"保存图片失败";
    [UIAlertController ps_alertWithTaget:self
                                 message:message
                            confirmBlock:nil];
    
}

#pragma mark - Delegate

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	
	return self.dataSources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	PSPreviewViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:
							   kReusableCellIdentifier forIndexPath:indexPath];
	PSImageObject *imageObject = self.dataSources[indexPath.item];
	cell.imageObject = imageObject;
	
	return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	
    if (self.isClickShowNavigationBar) {
            [self.navigationController setNavigationBarHidden:
               !self.navigationController.navigationBar.hidden
                                                     animated:YES];
    }
    if (self.delegate && [self.delegate respondsToSelector:
                          @selector(previewViewController:didSelectItemAtIndexPath:)]) {
        [self.delegate previewViewController:self didSelectItemAtIndexPath:indexPath];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGPoint currentOffset = scrollView.contentOffset;
    NSUInteger index = round(ABS(currentOffset.x) / scrollView.frame.size.width);
    self.currentIndex = index;
    self.currentImageObject = self.dataSources[index];
    self.navigationItem.title = [NSString stringWithFormat:@"%ld/%ld",
                                 index +1,self.dataSources.count];
}

#pragma mark - InitAndLayout

- (void)configUI {
	
	UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
	layout.itemSize = [UIScreen mainScreen].bounds.size;
	layout.minimumLineSpacing = 0;
	layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
	self.collectionView = [[UICollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:layout];
	[self.collectionView registerClass:[PSPreviewViewCell class] forCellWithReuseIdentifier:kReusableCellIdentifier];
	self.collectionView.backgroundColor = [UIColor blackColor];
	self.collectionView.showsHorizontalScrollIndicator = NO;
	self.collectionView.pagingEnabled = YES;
	self.collectionView.delegate = self;
	self.collectionView.dataSource = self;
	[self.view addSubview:self.collectionView];
	PS_SCROLLVIEWINSETS_NO(self.collectionView);

    UIButton *moreButton = [[UIButton alloc] init];
    [moreButton setFrame:CGRectMake(0, 0, 44, 44)];
    moreButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [moreButton setImage:[UIImage ps_imageNamed:@"btn_previewView_more"]
                forState:UIControlStateNormal];
    [moreButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [moreButton addTarget:self action:@selector(moreButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
}

#pragma mark - Getter/Setter

- (NSMutableArray<PSImageObject *> *)dataSources {
	
	if (!_dataSources) {
		_dataSources = [NSMutableArray array];
	}
	return _dataSources;
}

@end