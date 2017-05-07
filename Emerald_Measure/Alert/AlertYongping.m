//
//  AlertYongping.m
//  Emerald_Measure
//
//  Created by h on 17/5/7.
//  Copyright © 2017年 michael. All rights reserved.
//

#import "AlertYongping.h"
static AlertYongping * SharedInstance;
@implementation AlertYongping

+(id)allocWithZone:(struct _NSZone *)zone
{
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,^{
        
        SharedInstance =[super allocWithZone:zone];
    });
    
    
    return SharedInstance;
    
}


//=============================================
- (void)ShowCancelAlert:(NSString*)message Window:(NSWindow *)window
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSAlert *alert = [NSAlert new];
        alert.messageText = @"OK";
        alert.informativeText = message;
        [alert addButtonWithTitle:@"确定"];
        
        //第一种方式，以modal的方式出现
        [alert runModal];
        
        //第二种方式，以sheet的方式出现
        
        //        [alert beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
        //
        //            if (result==NSAlertFirstButtonReturn) {
        //
        //            }
        //            else if(result==NSAlertSecondButtonReturn)
        //            {
        //
        //            }
        //            else if(result==NSAlertThirdButtonReturn)
        //            {
        //
        //
        //            }
        //            else
        //            {
        //                NSLog(@"Application exit");
        //                //退出app
        //                exit(0);
        //            
        //            }
        //        }];
        
    });
}
//=============================================
@end
//=============================================
