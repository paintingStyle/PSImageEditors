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

static NSString *const kReusableCellIdentifier = @"PSPreviewViewCell";

@interface PSPreviewViewController ()
<UICollectionViewDelegate,UICollectionViewDataSource> {
	
	BOOL _navigationBarHidden;
	UIColor *_navigationBarTintColor;
	NSDictionary *_navigationBarTitleTextAttributes;
}

@property (nonatomic, strong, readwrite) NSArray<NSURL *> *urls;
@property (nonatomic, strong, readwrite) NSArray<UIImage *> *images;
@property (nonatomic, assign, readwrite) NSInteger currentIndex;

@property (nonatomic, assign, getter=isLocal) BOOL local;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray<PSImageObject *> *dataSources;

@end

@implementation PSPreviewViewController

- (instancetype)initWithURLs:(NSArray *)urls
				currentIndex:(NSInteger)index {
	
	if (self = [super init]) {
		_urls = urls;
		_currentIndex = index;
		_local = NO;
	}
	return self;
}

- (instancetype)initWithImages:(NSArray *)images
				  currentIndex:(NSInteger)index {
	
	if (self = [super init]) {
		_images = images;
		_currentIndex = index;
		_local = YES;
	}
	return self;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
	
	[super viewDidLoad];
	[self configUI];
	[self configData];
	
	self.navigationItem.title = @"3/6";

}

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	_navigationBarHidden = self.navigationController.navigationBar.hidden;
	_navigationBarTintColor = [self.navigationController.navigationBar.tintColor copy];
	_navigationBarTitleTextAttributes = [self.navigationController.navigationBar.titleTextAttributes copy];
	
	[self.navigationController setNavigationBarHidden:YES animated:NO];
	[self.navigationController.navigationBar setBackgroundImage:[PSImageEditorsHelper imageWithColor:[[UIColor blackColor] colorWithAlphaComponent:0.6]] forBarMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setShadowImage:[UIImage new]];
	self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
	self.navigationController.navigationBar.titleTextAttributes =
	@{NSForegroundColorAttributeName:[UIColor whiteColor]};
}

- (void)viewWillDisappear:(BOOL)animated {
	
	[super viewWillDisappear:animated];
	
	[self.navigationController setNavigationBarHidden:_navigationBarHidden animated:NO];
	[self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setShadowImage:nil];
	self.navigationController.navigationBar.tintColor = _navigationBarTintColor;
	self.navigationController.navigationBar.titleTextAttributes = _navigationBarTitleTextAttributes;
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
	
	[self.navigationController setNavigationBarHidden:!self.navigationController.navigationBar.hidden animated:YES];
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
}

#pragma mark - Getter/Setter

- (NSMutableArray<PSImageObject *> *)dataSources {
	
	if (!_dataSources) {
		_dataSources = [NSMutableArray array];
	}
	return _dataSources;
}

@end
