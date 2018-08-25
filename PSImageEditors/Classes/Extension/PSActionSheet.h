//
//  PSActionSheet.h
//  PSImageEditors
//
//  Created by paintingStyle on 2018/8/25.
//

#import <Foundation/Foundation.h>

typedef void (^actionClickBlock) (NSInteger index);
typedef void (^buttonClickBlock) (id obj);

@interface PSActionSheet : NSObject

+ (void)sheetWithActionTitles:(NSArray *)titles
                  actionBlock:(actionClickBlock)block;

+ (void)removeSheetView;

@end

@interface PSActionSheetButton : UIButton

@property (nonatomic,strong) buttonClickBlock clickBlock;

- (void)initWithClickBlock:(buttonClickBlock)block forControlEvents:(UIControlEvents)event;

@end
