//
//  FTDI_UART.h
//  FTDI_SPI
//
//  Created by h on 16/4/28.
//  Copyright © 2016年 h. All rights reserved.
//

#ifndef FTDI_UART_h
#define FTDI_UART_h

//=======================================================
extern FT_STATUS UART_Init(FT_HANDLE ftHandle,DWORD baudRate);
extern FT_STATUS UART_DTR(FT_HANDLE ftHandle,DWORD dtr);
extern FT_STATUS UART_RTS(FT_HANDLE ftHandle,DWORD rts);
extern FT_STATUS UART_Send(FT_HANDLE ftHandle,BYTE dat[],DWORD len);
extern FT_STATUS UART_Get(FT_HANDLE ftHandle,BYTE dat[],DWORD *len);
extern void     *UART_ScanRead(PVOID *param);
extern pthread_t UART_SetCallBack(FT_HANDLE ftHandle,void *function);
extern int       UART_ClrCallBack(FT_HANDLE ftHandle,pthread_t id);
//=======================================================

#endif /* FTDI_UART_h */
