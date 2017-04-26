//
//  Alart.h
//  B312_BT_MIC_SPK
//
//  Created by EW on 16/5/26.
//  Copyright © 2016年 h. All rights reserved.
//
#import <Cocoa/Cocoa.h>

@interface Alert : NSObject


+(Alert *)shareInstance;

- (void)ShowCancelAlert:(NSString*)message Window:(NSWindow *)window;

@end
