//
//  FTUART.h
//  BT_MIC_SPK
//
//  Created by EW on 16/5/27.
//  Copyright © 2016年 h. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTUART : NSObject
//==========================================
- (id)init;
-(BOOL)FT_UART_Open:(NSString*)name baudRate:(int)baud;
-(BOOL)FT_UART_Close;
-(BOOL)FT_UART_Send:(NSString*)tx;
-(BOOL)FT_UART_SetRTSCTS:(BOOL)rts DTR:(BOOL)dtr;
-(NSString*)FT_UART_Get;
-(NSString*)FT_UART_SendGet:(NSString*)tx Delay:(int)delay;
//==========================================
@end
