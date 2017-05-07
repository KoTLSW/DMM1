//
//  FTSPI.h
//  BT_MIC_SPK
//
//  Created by EW on 16/5/27.
//  Copyright © 2016年 h. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTSPI : NSObject
//==========================================
- (id)init;
-(BOOL)FT_SPI_Open:(NSString*)name baudRate:(int)baud;
-(BOOL)FT_SPI_Close;
-(BOOL)FT_SPI_SendGet:(short*)tx RX:(short*)rx Length:(int)length;
//==========================================
@end
