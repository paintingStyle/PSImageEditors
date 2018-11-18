//
//  PSMosaicToolBar.h
//  PSImageEditors
//
//  Created by rsf on 2018/11/16.
//

#import "PSEditorToolBar.h"

typedef NS_ENUM(NSInteger, PSMosaicType) {
    
    PSMosaicTypeRectangular = 0, /// !< 矩形马赛克
    PSMosaicTypeGrindArenaceous /// !< 磨砂马赛克
};

typedef NS_ENUM(NSInteger, PSMosaicToolBarEvent) {
    
    PSMosaicToolBarEventRectangular = 0,
    PSMosaicToolBarEventGrindArenaceous,
    PSMosaicToolBarEventUndo
};

@protocol PSMosaicToolBarDelegate<NSObject>

@optional

- (void)mosaicToolBarType:(PSMosaicType)type event:(PSMosaicToolBarEvent)event;

@end

@interface PSMosaicToolBar : PSEditorToolBar

/// 是否可以撤销
@property (nonatomic, assign) BOOL canUndo;

@property (nonatomic, assign) PSMosaicType mosaicType;
@property (nonatomic, weak) id<PSMosaicToolBarDelegate> delegate;

@end
