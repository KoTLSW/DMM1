//
//  Alart.m
//  B312_BT_MIC_SPK
//
//  Created by EW on 16/5/26.
//  Copyright © 2016年 h. All rights reserved.
//

#import "Alert.h"
//=============================================
@implementation Alert


+(Alert *)shareInstance
{
    static Alert *alert = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        alert = [[Alert alloc] init];
    });
    return alert;
}

//=============================================
- (void)ShowCancelAlert:(NSString*)message Window:(NSWindow *)window
{
    dispatch_async(dispatch_get_main_queue(), ^{
    
        NSAlert *alert = [NSAlert new];
        alert.messageText = @"ERROR";
        alert.informativeText = message;
        [alert addButtonWithTitle:@"Cancel"];
        
        //[alert runModal];
        
        [alert beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
            NSLog(@"Application exit");
            exit(0);
        }];
        
    });
}
//=============================================
@end
//=============================================

