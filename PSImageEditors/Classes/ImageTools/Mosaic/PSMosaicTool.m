//
//  PSMosaicTool.m
//  PSImageEditors
//
//  Created by rsf on 2018/11/16.
//

#import "PSMosaicTool.h"
#import "PSMosaicToolBar.h"
#import "PSDrawView.h"
#import "PSMosaicBrush.h"
#import "PSSmearBrush.h"
#import "UIImage+PSImageEditors.h"
#import "UIView+PSImageEditors.h"
#import <AVFoundation/AVFoundation.h>

static const CGFloat kMosaiclevel = 55.0f;
static const CGFloat kDrawLineWidth = 30.0f;

@interface PSMosaicTool ()<PSMosaicToolBarDelegate>

@property (nonatomic, strong) PSMosaicToolBar *mosaicToolBar;
@property (nonatomic, strong) PSDrawView *splashView;

@property (nonatomic, assign) BOOL rectangularMosaic;

@end

@implementation PSMosaicTool {
    UIImageView *_drawingView;
}

- (void)initialize {
    
	if (!_drawingView) {
	  self.rectangularMosaic = YES;
	  _drawingView = [[UIImageView alloc] initWithFrame:self.editor.imageView.bounds];
	  [self.editor.imageView addSubview:_drawingView];
	}
}

#pragma mark - Subclasses Override

- (void)resetRect:(CGRect)rect {
	
	_drawingView.frame = self.editor.imageView.bounds;
	self.splashView.frame = _drawingView.bounds;
	
	[self.splashView removeAllObjects];
	
	self.produceChanges = [self canUndo];
	if (self.canUndoBlock) {
		self.canUndoBlock([self canUndo]);
	}

    if (self.rectangularMosaic) {
        [self changeRectangularMosaic];
    }else {
        [self changeGrindArenaceousMosaic];
    }
}

- (void)setup {
    
    [super setup];
	
	_drawingView.userInteractionEnabled = YES;
	self.editor.imageView.userInteractionEnabled = YES;
    self.editor.scrollView.panGestureRecognizer.enabled = NO;
	
	if (!_splashView) {
		_splashView = [[PSDrawView alloc] initWithFrame:_drawingView.bounds];
		_splashView.brush = [PSMosaicBrush new];
		_splashView.clipsToBounds = YES;
		[_drawingView addSubview:_splashView];
	}
	if (!self.mosaicToolBar) {
		self.mosaicToolBar = [[PSMosaicToolBar alloc] init];
		self.mosaicToolBar.delegate = self;
		self.mosaicToolBar.mosaicType = PSMosaicToolBarEventGrindArenaceous;
		[self.editor.view addSubview:self.mosaicToolBar];
		[self.mosaicToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
			make.bottom.equalTo(self.editor.bottomToolBar.editorItemsView.mas_top);
			make.left.right.equalTo(self.editor.bottomToolBar);
			make.height.equalTo(@(PSMosaicToolBarHeight));
		}];
	}
	
	if (![PSMosaicBrush mosaicBrushCache]) {
	   CGSize canvasSize = AVMakeRectWithAspectRatioInsideRect(self.editor.imageView.image.size, self.editor.imageView.bounds).size;
	   [PSMosaicBrush loadBrushImage:self.editor.imageView.image scale:15.0 canvasSize:canvasSize useCache:YES complete:^(BOOL success) {}];
	}
	if (![PSSmearBrush smearBrushCache]) {
	   CGSize canvasSize = AVMakeRectWithAspectRatioInsideRect(self.editor.imageView.image.size, self.editor.imageView.bounds).size;
	   [PSSmearBrush loadBrushImage:self.editor.imageView.image canvasSize:canvasSize useCache:YES complete:^(BOOL success) {}];
	}
	if (self.rectangularMosaic) {
		[self changeRectangularMosaic];
	}else {
		[self changeGrindArenaceousMosaic];
	}
	
	
    @weakify(self);
	self.splashView.drawBegan = ^{
		@strongify(self);
		[self.editor hiddenToolBar:YES animation:YES];
	};
	self.splashView.drawEnded = ^{
		@strongify(self);
		self.produceChanges = [self canUndo];
		[self.editor hiddenToolBar:NO animation:YES];
		if (self.canUndoBlock) {
			self.canUndoBlock([self canUndo]);
		}
	};

	self.splashView.userInteractionEnabled = YES;
	self.produceChanges = [self canUndo];
    [self.mosaicToolBar setToolBarShow:YES animation:NO];
	if (self.canUndoBlock) {
		self.canUndoBlock([self canUndo]);
	}
}

- (void)cleanup {
    [super cleanup];
	
    _drawingView.userInteractionEnabled = NO;
	self.editor.imageView.userInteractionEnabled = NO;
	self.splashView.userInteractionEnabled = NO;
    self.editor.scrollView.panGestureRecognizer.enabled = YES;
    [self.mosaicToolBar setToolBarShow:NO animation:NO];
}

- (void)hiddenToolBar:(BOOL)hidden animation:(BOOL)animation {
	
	[self.mosaicToolBar setToolBarShow:!hidden animation:animation];
}

- (UIImage *)mosaicImage {

	UIImage *image = [_drawingView captureImageAtFrame:_drawingView.bounds];
	return image;
}

- (void)changeRectangularMosaic {
	
    self.rectangularMosaic = YES;
	
	PSMosaicBrush *brush = [[PSMosaicBrush alloc] init];
	[self.splashView setBrush:brush];
	self.splashView.brush.lineWidth = 25;
}

- (void)changeGrindArenaceousMosaic {
	
	self.rectangularMosaic = NO;
	
	PSSmearBrush *brush = [[PSSmearBrush alloc] initWithImageName:@"icon_mosaic_smear@2x.png"];
	NSBundle *bundle = [self mediaEditingBundle];
	brush.bundle = bundle;
	[self.splashView setBrush:brush];
	self.splashView.brush.lineWidth = 25 *5;
}

- (NSBundle *)mediaEditingBundle {
    static NSBundle *editingBundle = nil;
    if (editingBundle == nil) {
        editingBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:NSClassFromString(@"_PSImageEditorViewController")] pathForResource:@"PSImageEditors" ofType:@"bundle"]];
    }
    return editingBundle;
}

- (void)undo {
	[self.splashView undo];
}

- (BOOL)canUndo {
    return [self.splashView canUndo];
}

#pragma mark - PSMosaicToolBarDelegate

- (void)mosaicToolBarType:(PSMosaicType)type event:(PSMosaicToolBarEvent)event {
    
    switch (event) {
        case PSMosaicToolBarEventRectangular:
            [self changeRectangularMosaic];
            break;
        case PSMosaicToolBarEventGrindArenaceous:
            [self changeGrindArenaceousMosaic];
            break;
        default:
            break;
    }
}

@end
