//
//  FTDI_SPI.h
//  FTDI_SPI
//
//  Created by h on 16/4/28.
//  Copyright © 2016年 h. All rights reserved.
//

#ifndef FTDI_SPI_h
#define FTDI_SPI_h
//=======================================================
/*
#include "WinTypes.h"
#include <stdio.h>
#include "ftd2xx.h"
#include "WinTypes.h"
#include <unistd.h>
*/
//=======================================================
extern void      SPI_CSL(BYTE *out_buf,DWORD *need_write);
extern void      SPI_CSH(BYTE *out_buf,DWORD *need_write);
extern FT_STATUS SPI_WR_BYTES(FT_HANDLE ftHandle, BYTE wdat[],BYTE rdat[],DWORD len);
extern FT_STATUS SPI_WR_SHORTS(FT_HANDLE ftHandle, short wdat[],short rdat[],DWORD len);
extern FT_STATUS SPI_Init(FT_HANDLE ftHandle,int speed,int div);
extern FT_STATUS SPI_Open(char *name,FT_HANDLE	ftHandle);
extern FT_STATUS SPI_Close(FT_HANDLE ftHandle);
//=======================================================
#endif /* FTDI_SPI_h */
