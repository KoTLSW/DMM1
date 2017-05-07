//
//  FTUART.m
//  BT_MIC_SPK
//
//  Created by EW on 16/5/27.
//  Copyright © 2016年 h. All rights reserved.
//

#import "FTUART.h"

#include "ftd2xx.h"
#include "FTDI_COM.h"
#include "FTDI_UART.h"
//==========================================
#define   BUF_LENGTH    4096    //接收缓冲区大小
//==========================================
@interface FTUART ()
{
    FT_HANDLE           port;                //端口句柄
    
    NSThread            *thread;
    
    BYTE                buf[BUF_LENGTH];     //接收缓冲区
    int                 length;              //接收缓冲区当前长度
}
@end
//==========================================
@implementation FTUART
//==========================================
- (id)init
{
    
    self = [super init];
    
    if (self)
    {
        port     = NULL;
        length   = 0;
    }
    
    return self;
}
//==========================================
-(void)FT_UART_Scan
{
    @autoreleasepool
    {
        while ([[NSThread currentThread] isCancelled] == NO)
        {
            BYTE  dat[65535];
            DWORD len=0;
            
            FT_STATUS ftStatus = UART_Get(port,dat,&len);
            
            if(ftStatus == FT_OK)
            {
                for(int i=0;i<len;i++)
                {
                    
                    if(length<BUF_LENGTH)
                    {
                        buf[length]=dat[i];
                        length=length+1;
                    }
                    
                }
            }
            //---------------
            [NSThread sleepForTimeInterval:0.001];
            //---------------
        }
        
    }
}
//==========================================
-(BOOL)FT_UART_Open:(NSString*)name baudRate:(int)baud
{
    FT_STATUS ftstate=FT_OK;
    
    ftstate |= FTDI_DeviceOpen((char*)[name UTF8String],&port);
    ftstate |= UART_Init(port,baud);
    
    //---------------------
    thread = [[NSThread alloc]initWithTarget:self
                              selector:@selector(FT_UART_Scan)
                              object:nil];
    [thread start];               //启动线程，进入测试流程
    //---------------------
    if(ftstate == FT_OK)return YES;
    else return NO;
}
//==========================================
-(BOOL)FT_UART_Close
{
    FT_STATUS ftstate=FT_OK;
    
    ftstate |= FTDI_DeviceClose(port);
    
    if(ftstate == FT_OK)return YES;
    else return NO;
}
//==========================================
-(BOOL)FT_UART_Send:(NSString*)tx
{
    FT_STATUS ftstate=FT_OK;
    
    BYTE *dat=(BYTE*)[tx UTF8String];
    DWORD len=(DWORD)strlen([tx UTF8String]);
    
    ftstate |= UART_Send(port,dat,len);
    
    if(ftstate == FT_OK)return YES;
    else return NO;
}
//==========================================
-(BOOL)FT_UART_SetRTSCTS:(BOOL)rts DTR:(BOOL)dtr
{
    FT_STATUS ftstate=FT_OK;
    
    if(rts == YES)ftstate |= UART_RTS(port,1);
    if(rts == NO)ftstate |= UART_RTS(port,0);
    
    if(dtr == YES)ftstate |= UART_RTS(port,1);
    if(dtr == NO)ftstate |= UART_RTS(port,0);
    
    if(ftstate == FT_OK)return YES;
    else return NO;
}
//==========================================
-(NSString*)FT_UART_Get
{
    
    NSString *string = [[NSString alloc]initWithBytes:buf length:length encoding:NSASCIIStringEncoding];
    
    return string;
}
//==========================================
-(NSString*)FT_UART_SendGet:(NSString*)tx Delay:(int)delay
{
    length = 0;
    
    [self FT_UART_Send:tx];
    
    usleep(delay*1000);
    
    NSString *string = [[NSString alloc]initWithBytes:buf length:length encoding:NSASCIIStringEncoding];
    
    return string;
}
//==========================================
@end
//==========================================