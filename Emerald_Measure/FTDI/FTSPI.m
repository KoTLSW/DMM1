//
//  FTUART.m
//  BT_MIC_SPK
//
//  Created by EW on 16/5/27.
//  Copyright © 2016年 h. All rights reserved.
//

#import "FTSPI.h"

#include "ftd2xx.h"
#include "FTDI_COM.h"
#include "FTDI_SPI.h"
//==========================================
@interface FTSPI ()
{
    FT_HANDLE           spi;                //端口句柄
}
@end
//==========================================
@implementation FTSPI
//==========================================
- (id)init
{
    
    self = [super init];
    
    if (self)
    {
        spi     = NULL;
    }
    
    return self;
}
//==========================================
-(BOOL)FT_SPI_Open:(NSString*)name baudRate:(int)baud
{
    FT_STATUS ftstate=FT_OK;
    
    ftstate |= FTDI_DeviceOpen((char*)[name UTF8String],&spi);
    ftstate |= SPI_Init(spi,baud,1);
    
    if(ftstate == FT_OK)return YES;
    else return NO;
}
//==========================================
-(BOOL)FT_SPI_Close
{
    FT_STATUS ftstate=FT_OK;
    
    ftstate |= FTDI_DeviceClose(spi);
    
    if(ftstate == FT_OK)return YES;
    else return NO;
}
//==========================================
-(BOOL)FT_SPI_SendGet:(short*)tx RX:(short*)rx Length:(int)length
{
    FT_STATUS ftstate=FT_OK;
    
    ftstate |= SPI_WR_SHORTS(spi, tx,rx,length);
    
    if(ftstate == FT_OK)return YES;
    else return NO;
}
//==========================================
@end
//==========================================