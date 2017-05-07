//
//  FTDI_COM.h
//  FTDI_SPI
//
//  Created by h on 16/4/28.
//  Copyright © 2016年 h. All rights reserved.
//

#ifndef FTDI_COM_h
#define FTDI_COM_h
//=======================================================
extern FT_STATUS FTDI_DeviceCount(DWORD *numDevs);
extern FT_STATUS FTDI_DeviceName(DWORD index,char *name);
extern FT_STATUS FTDI_DeviceOpen(char *name,FT_HANDLE *ftHandle);
extern FT_STATUS FTDI_DeviceClose(FT_HANDLE ftHandle);
//=======================================================
#endif /* FTDI_COM_h */
