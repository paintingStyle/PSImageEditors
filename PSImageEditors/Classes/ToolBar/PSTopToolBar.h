//
//  PSTopToolBar.h
//  PSImageEditors
//
//  Created by rsf on 2018/11/16.
//

#import "PSEditorToolBar.h"
@class PSTopToolBar;

typedef NS_ENUM(NSUInteger, PSTopToolBarType) {
    
    PSTopToolBarTypeClose = 0,
    PSTopToolBarTypeCancelAndDoneIcon,
};

typedef NS_ENUM(NSUInteger, PSTopToolBarEvent) {
    
    PSTopToolBarEventCancel = 0,
    PSTopToolBarEventDone,
};

@protocol PSTopToolBarDelegate<NSObject>


- (void)topToolBar:(PSTopToolBar *)toolBar event:(PSTopToolBarEvent)event;

@end

@interface PSTopToolBar : PSEditorToolBar

@property (nonatomic, weak) id<PSTopToolBarDelegate> delegate;

@property (nonatomic, assign) PSTopToolBarType type;

- (instancetype)initWithType:(PSTopToolBarType)type;

@end
