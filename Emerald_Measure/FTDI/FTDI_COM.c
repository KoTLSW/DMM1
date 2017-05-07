//
//  FTDI_COM.c
//  FTDI_SPI
//
//  Created by h on 16/4/28.
//  Copyright © 2016年 h. All rights reserved.
//

#include <stdio.h>
#include "ftd2xx.h"
#include "WinTypes.h"
#include <unistd.h>
//=======================================================
FT_STATUS FTDI_DeviceCount(DWORD *numDevs){
    
    FT_STATUS ftStatus = FT_OK;
    
    ftStatus |= FT_ListDevices(numDevs,NULL,FT_LIST_NUMBER_ONLY);
    
    return ftStatus;
}
//=======================================================
FT_STATUS FTDI_DeviceName(DWORD index,char *name){
    
    FT_STATUS ftStatus = FT_OK;
    
    ftStatus |= FT_ListDevices((PVOID)&index,name,FT_LIST_BY_INDEX|FT_OPEN_BY_SERIAL_NUMBER);
    
    return ftStatus;
}
//=======================================================
FT_STATUS FTDI_DeviceOpen(char *name,FT_HANDLE *ftHandle){
    
    FT_STATUS ftStatus = FT_OK;
    
    ftStatus |= FT_OpenEx(name,FT_OPEN_BY_SERIAL_NUMBER,ftHandle);
    
    return ftStatus;
}
//=======================================================
FT_STATUS FTDI_DeviceClose(FT_HANDLE ftHandle){
    
    FT_STATUS ftStatus = FT_OK;
    
    ftStatus |= FT_Close(ftHandle);
    
    return ftStatus;
}
//=======================================================

