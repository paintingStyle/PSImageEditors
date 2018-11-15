//
//  UIAlertController+PSExtension.m
//  tyfocg
//
//  Created by paintingStyle on 2017/11/29.
//  Copyright © 2017年 com.worldTravelNetscape.tyfocg. All rights reserved.
//

#import "UIAlertController+PSExtension.h"

@implementation UIAlertController (PSExtension)

+ (void)ps_alertWithTaget:(id)taget
                  message:(NSString *)message
             confirmBlock:(PSAlertControllerCompletionHandle)confirmBlock {
    
    [self alertWithTaget:taget title:nil message:message confirmTitle:@"确定" cancelTitle:nil destructiveTitle:nil preferredStyle:UIAlertControllerStyleAlert confirmBlock:confirmBlock cancelBlock:nil destructiveBlock:nil];
}

+ (void)ps_alertWithTaget:(id)taget
                    title:(nullable NSString *)title
                  message:(nullable NSString *)message
             confirmTitle:(NSString *)confirmTitle
              cancelTitle:(NSString *)cancelTitle
             confirmBlock:(PSAlertControllerCompletionHandle)confirmBlock
              cancelBlock:(PSAlertControllerCompletionHandle)cancelBlock {
    
    [self alertWithTaget:taget title:title message:message confirmTitle:confirmTitle cancelTitle:cancelTitle destructiveTitle:nil preferredStyle:UIAlertControllerStyleAlert confirmBlock:confirmBlock cancelBlock:cancelBlock destructiveBlock:nil];
}

+ (void)ps_actionSheetWithTaget:(id)taget
                          title:(nullable NSString *)title
                        message:(nullable NSString *)message
                   confirmTitle:(NSString *)confirmTitle
                    cancelTitle:(NSString *)cancelTitle
                   confirmBlock:(PSAlertControllerCompletionHandle)confirmBlock
                    cancelBlock:(PSAlertControllerCompletionHandle)cancelBlock {
    
    [self alertWithTaget:taget title:title message:message confirmTitle:confirmTitle cancelTitle:cancelTitle destructiveTitle:nil preferredStyle:UIAlertControllerStyleActionSheet confirmBlock:confirmBlock cancelBlock:cancelBlock destructiveBlock:nil];
}

+ (void)ps_alertWithTaget:(id)taget
                    title:(nullable NSString *)title
                  message:(nullable NSString *)message
         destructiveTitle:(NSString *)destructiveTitle
              cancelTitle:(NSString *)cancelTitle
         destructiveBlock:(PSAlertControllerCompletionHandle)destructiveBlock
              cancelBlock:(PSAlertControllerCompletionHandle)cancelBlock {
    
    [self alertWithTaget:taget title:title message:message confirmTitle:nil cancelTitle:cancelTitle destructiveTitle:destructiveTitle preferredStyle:UIAlertControllerStyleAlert confirmBlock:nil cancelBlock:cancelBlock destructiveBlock:destructiveBlock];
}

+ (void)ps_actionSheetWithTaget:(id)taget
                          title:(nullable NSString *)title
                        message:(nullable NSString *)message
               destructiveTitle:(NSString *)destructiveTitle
                    cancelTitle:(NSString *)cancelTitle
               destructiveBlock:(PSAlertControllerCompletionHandle)destructiveBlock
                    cancelBlock:(PSAlertControllerCompletionHandle)cancelBlock {
    
    [self alertWithTaget:taget title:title message:message confirmTitle:nil cancelTitle:cancelTitle destructiveTitle:destructiveTitle preferredStyle:UIAlertControllerStyleActionSheet confirmBlock:nil cancelBlock:cancelBlock destructiveBlock:destructiveBlock];
}

+ (void)alertWithTaget:(id)taget
                 title:(nullable NSString *)title
               message:(nullable NSString *)message
          confirmTitle:(NSString *)confirmTitle
           cancelTitle:(NSString *)cancelTitle
      destructiveTitle:(NSString *)destructiveTitle
        preferredStyle:(UIAlertControllerStyle)preferredStyle
          confirmBlock:(PSAlertControllerCompletionHandle)confirmBlock
           cancelBlock:(PSAlertControllerCompletionHandle)cancelBlock
      destructiveBlock:(PSAlertControllerCompletionHandle)destructiveBlock {
    
    __weak typeof(taget)weakTaget = taget;
    
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:title message:message
                                 preferredStyle:preferredStyle];
    
    if (confirmTitle.length) {
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:confirmTitle style:UIAlertActionStyleDefault handler:confirmBlock];
        [alertController addAction:confirmAction];
    }
    
    if (destructiveTitle.length) {
        UIAlertAction *destructiveAction = [UIAlertAction actionWithTitle:destructiveTitle style:UIAlertActionStyleDestructive handler:destructiveBlock];
        [alertController addAction:destructiveAction];
    }
    
    if (cancelTitle.length) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:cancelBlock];
        [alertController addAction:cancelAction];
    }
    
    [weakTaget presentViewController:alertController animated:YES completion:nil];
}

+ (void)ps_alertWithTaget:(id)taget
                    title:(nullable NSString *)title
                  message:(nullable NSString *)message
           multipleTitles:(NSArray<NSString *> *)multipleTitles
              cancelTitle:(NSString *)cancelTitle
             confirmBlock:(PSAlertControllerCompletionHandle)confirmBlock
              cancelBlock:(PSAlertControllerCompletionHandle)cancelBlock {
    
    __weak typeof(taget)weakTaget = taget;
    
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:title message:message
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    [multipleTitles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (!obj.length && idx >14) { return; }
        
        UIAlertAction *itemAction = [UIAlertAction actionWithTitle:obj style:UIAlertActionStyleDefault handler:confirmBlock];
        [alertController addAction:itemAction];
    }];
    
    if (cancelTitle.length) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:cancelBlock];
        [alertController addAction:cancelAction];
    }
    
    [weakTaget presentViewController:alertController animated:YES completion:nil];
}

@end
