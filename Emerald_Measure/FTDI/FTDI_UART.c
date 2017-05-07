//
//  FTDI_UART.c
//  FTDI_SPI
//
//  Created by h on 16/4/28.
//  Copyright © 2016年 h. All rights reserved.
//


#include <stdio.h>
#include "ftd2xx.h"
#include "WinTypes.h"
#include <unistd.h>
#include "stdlib.h"
#include "stdio.h"
#include "stdarg.h"
//=======================================================
typedef void (*callback) (BYTE *dat,DWORD len);                               //声明一个函数指针

typedef struct _param{
    FT_HANDLE ftHandle;
    callback  function;
}param;
//=======================================================
FT_STATUS UART_Init(FT_HANDLE ftHandle,DWORD baudRate){

    FT_STATUS ftStatus = FT_OK;
    
    ftStatus |= FT_ResetDevice(ftHandle);

    ftStatus |= FT_SetBaudRate(ftHandle,baudRate);
    
    ftStatus |= FT_SetDataCharacteristics(ftHandle,FT_BITS_8,FT_STOP_BITS_1,FT_PARITY_NONE);
    
    ftStatus |= FT_SetFlowControl(ftHandle, FT_FLOW_NONE, 0x0, 0x0);
    
    return ftStatus;
}
//=======================================================
FT_STATUS UART_DTR(FT_HANDLE ftHandle,DWORD dtr){
    
    FT_STATUS ftStatus = FT_OK;
    
    if(dtr != 0)ftStatus |= FT_SetDtr(ftHandle);
    
    if(dtr == 0)ftStatus |= FT_ClrDtr(ftHandle);
    
    return ftStatus;
}
//=======================================================
FT_STATUS UART_RTS(FT_HANDLE ftHandle,DWORD rts){

    FT_STATUS ftStatus = FT_OK;
    
    if(rts != 0)ftStatus |= FT_SetRts(ftHandle);
    
    if(rts == 0)ftStatus |= FT_ClrRts(ftHandle);
    
    return ftStatus;
}
//=======================================================
FT_STATUS UART_Send(FT_HANDLE ftHandle,BYTE dat[],DWORD len){
    
    FT_STATUS ftStatus = FT_OK;
    
    DWORD need_write=len;                                                 //需要写出的长度
    DWORD real_write=0;                                                   //实际写出的长度
    
    ftStatus |=FT_Write(ftHandle,dat,need_write,&real_write);
    
    return ftStatus;
}
//=======================================================
FT_STATUS UART_Get(FT_HANDLE ftHandle,BYTE dat[],DWORD *len){
    
    FT_STATUS ftStatus = FT_OK;
    
    DWORD need_read=0;                                                    //需要读取的长度
    DWORD real_read=0;                                                    //实际读取到的长度
    BYTE  In_buf[65535];                                                  //读取到的数据缓冲区
    
    ftStatus |= FT_GetQueueStatus(ftHandle, &need_read);                  //读取当前设备中有多少数据需要读出
    
    if ((ftStatus == FT_OK) && (need_read > 0)){
        
        DWORD i=0;
        
        ftStatus |= FT_Read(ftHandle, In_buf, need_read,&real_read);      //读取当前buffer中的数据
        
        for(i=0;i<real_read;i++)dat[i]=In_buf[i];
        
        len[0]= real_read;
        
    }
    
    return ftStatus;
}
//=======================================================
void *UART_ScanRead(void *param){
    
    struct _param{
        FT_HANDLE ft;
        callback  func;
    };
    
    struct _param *p=(struct _param *)param;
    
    while(1){
        
        BYTE  dat[65535];
        DWORD len=0;
        
        FT_STATUS ftStatus = UART_Get(p->ft,dat,&len);
        
        if( (ftStatus == FT_OK) && (len > 0) && (p->func != NULL) ){
            
            p->func(dat,len);
            
        }else{
            
            usleep(1000);
        }
    }
    
    return NULL;
}
//=======================================================
pthread_t UART_SetCallBack(FT_HANDLE ftHandle,void *function){
    
    pthread_t id=NULL;
    
    int ret=1;
    
    param *p=(param *)malloc(sizeof(param));
    
    p->ftHandle=ftHandle;
    p->function=function;
    
    if(function != NULL){
        
        ret=pthread_create(&id,NULL,UART_ScanRead, p);
    }
    
    return id;
}
//=======================================================
int UART_ClrCallBack(FT_HANDLE ftHandle,pthread_t id){
    
    int ret=1;
    
    if(id != NULL){
        
        ret=pthread_cancel(id);
        
    }
    
    return ret;
}
//=======================================================

