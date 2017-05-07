//
//  FTDI_SPI.c
//  FTDI_SPI
//
//  Created by star on 16/4/28.
//  Copyright © 2016年 star. All rights reserved.
//

#include <stdio.h>
#include "ftd2xx.h"
#include "WinTypes.h"
#include <unistd.h>
//=======================================================
void SPI_CSH(BYTE *out_buf,DWORD *need_write){
    for(int loop=0;loop<5;loop++){ //one 0x80 command can keep 0.2us, do 5 times to stay in this situatiofor 1us
        out_buf[(*need_write)++] = 0x80;//GPIO command for ADBUS
        out_buf[(*need_write)++] = 0x08;//set CS high, MOSI and SCL low
        out_buf[(*need_write)++] = 0x0b;//bit3:CS, bit2:MISO,bit1:MOSI, bit0:SCK
    }
}
//=======================================================
void SPI_CSL(BYTE *out_buf,DWORD *need_write){
    for(int loop=0;loop<5;loop++){ //one 0x80 command can keep 0.2us, do 5times to stay in this situation for 1us
        out_buf[(*need_write)++] = 0x80;//GPIO command for ADBUS
        out_buf[(*need_write)++] = 0x00;//set CS, MOSI and SCL low
        out_buf[(*need_write)++] = 0x0b;//bit3:CS, bit2:MISO,bit1:MOSI, bit0:SCK
    }
}
//=======================================================
FT_STATUS SPI_WR_BYTES(FT_HANDLE ftHandle, BYTE wdat[],BYTE rdat[],DWORD len){
    
    int i=0;
    
    FT_STATUS ftStatus = FT_OK;
    
    DWORD need_read=len;                                                  //需要读取的长度
    DWORD real_read=0;                                                    //实际读取到的长度
    BYTE  In_buf[65535];                                                  //读取到的数据缓冲区
    
    DWORD need_write=0;                                                   //需要写出的长度
    DWORD real_write=0;                                                   //实际写出的长度
    BYTE  Out_buf[65535];                                                 //写出数据缓冲区
    
    //---------------------
    //ftStatus |= FT_GetQueueStatus(ftHandle, &need_read);                  //读取当前设备中有多少数据需要读出
    //ftStatus |= FT_Read(ftHandle, In_buf, need_read,&real_read);          //读取当前buffer中的数据，目的是清空buffer
    //---------------------
    SPI_CSL(Out_buf,&need_write);
    //---------------------
    //Out_buf[need_write++] = 0x31;
    Out_buf[need_write++] = 0x31;
    Out_buf[need_write++] = 0xFF & ((len-1) & 0xFF);                      //length ValueL
    Out_buf[need_write++] = 0XFF & ((len-1) >> 8);                        //length ValueH
    
    for(i=0;i<len;i++)Out_buf[need_write++] = wdat[i];                    //写入要发送的数据
    //---------------------
    SPI_CSH(Out_buf,&need_write);
    //---------------------
    ftStatus |= FT_Write(ftHandle, Out_buf, need_write,&real_write);      //发送bad command到芯片
    
    usleep(1500);
    
    ftStatus |= FT_GetQueueStatus(ftHandle, &need_read);                  //读取当前设备中有多少数据需要读出
    
    ftStatus |= FT_Read(ftHandle, In_buf, need_read, &real_read);         //读取芯片缓冲区的数据
    
    for(i=0;i<len;i++)rdat[i]=In_buf[i];                                  //复制数据
    //---------------------
    
    return ftStatus;
}
//=======================================================
FT_STATUS SPI_WR_SHORTS(FT_HANDLE ftHandle, short wdat[],short rdat[],DWORD len){
    
    int i=0;
    
    FT_STATUS ftStatus = FT_OK;
    
    DWORD need_read=len*2;                                                //需要读取的长度
    DWORD real_read=0;                                                    //实际读取到的长度
    BYTE  In_buf[65535];                                                  //读取到的数据缓冲区
    
    DWORD need_write=0;                                                   //需要写出的长度
    DWORD real_write=0;                                                   //实际写出的长度
    BYTE  Out_buf[65535];                                                 //写出数据缓冲区
    
    
    DWORD length = len*2;
    //---------------------
    ftStatus |= FT_GetQueueStatus(ftHandle, &need_read);                  //读取当前设备中有多少数据需要读出
    ftStatus |= FT_Read(ftHandle, In_buf, need_read,&real_read);          //读取当前buffer中的数据，目的是清空buffer
    //---------------------
    SPI_CSL(Out_buf,&need_write);
    //---------------------
    //Out_buf[need_write++] = 0x31;
    Out_buf[need_write++] = 0x31;
    Out_buf[need_write++] = 0xFF & ((length-1) & 0xFF);                   //length ValueL
    Out_buf[need_write++] = 0XFF & ((length-1) >> 8);                     //length ValueH
    
    for(i=0;i<len;i++){
        Out_buf[need_write++] = (wdat[i]>>8)&0xff;                        //写入要发送的数据
        Out_buf[need_write++] = (wdat[i]>>0)&0xff;                        //写入要发送的数据
    }
    //---------------------
    SPI_CSH(Out_buf,&need_write);
    //---------------------
    ftStatus |= FT_Write(ftHandle, Out_buf, need_write,&real_write);      //发送bad command到芯片
    
    usleep(1500);
    
    ftStatus |= FT_GetQueueStatus(ftHandle, &need_read);                  //读取当前设备中有多少数据需要读出
    
    ftStatus |= FT_Read(ftHandle, In_buf, need_read, &real_read);         //读取芯片缓冲区的数据
    
    for(i=0;i<len;i++)rdat[i]=In_buf[i*2+0]*256+In_buf[i*2+1];            //复制数据
    //---------------------
    
    return ftStatus;
}
//=======================================================
FT_STATUS SPI_Init(FT_HANDLE ftHandle,int speed,int div){
    
    int i=0,j=0,m=0;
    
    short clk_div=(12000000 / (speed *2))-1;
    
    FT_STATUS ftStatus = FT_OK;
    
    DWORD need_read=0;                                                    //需要读取的长度
    DWORD real_read=0;                                                    //实际读取到的长度
    BYTE  In_buf[512];                                                    //读取到的数据缓冲区
    
    DWORD need_write=0;                                                   //需要写出的长度
    DWORD real_write=0;                                                   //实际写出的长度
    BYTE  Out_buf[512];                                                   //写出数据缓冲区
    
    if(div != 0)clk_div=(60000000 / (speed *2))-1;
    
    ftStatus |= FT_ResetDevice(ftHandle);                                 //复位当前设备
    
    ftStatus |= FT_GetQueueStatus(ftHandle, &need_read);                  //读取当前设备中有多少数据需要读出
    if ((ftStatus == FT_OK) && (need_read > 0)){
        ftStatus |= FT_Read(ftHandle, In_buf, need_read,&real_read);      //读取当前buffer中的数据，目的是清空buffer
    }
    
    ftStatus |= FT_SetUSBParameters(ftHandle, 65535, 65535);              //设置usb传输包大小
    ftStatus |= FT_SetChars(ftHandle, 0, 0, 0, 0);                        //禁止错误
    ftStatus |= FT_SetTimeouts(ftHandle, 500, 500);                       //设置读写超时时间为3秒
    ftStatus |= FT_SetLatencyTimer(ftHandle, 1);                          //设置响应时间
    
    ftStatus |= FT_SetBitMode(ftHandle, 0x0, 0x00);                       //复位芯片的mode
    ftStatus |= FT_SetBitMode(ftHandle, 0xFF, FT_BITMODE_MPSSE);          //设置芯片为mpsse模式，其它io为输出模式
    
    if (ftStatus != FT_OK){
        //printf("FTDI device init fail!\n");
        return ftStatus;
    }
    
    usleep(50000);                                                        //延时50毫秒等待芯片完成设置
    
    //---------------------------
    for(i=0;i<10;i++){                                                        //最大重试10次
        
        need_write = 0;                                                       //清空需要发送的长度
        Out_buf[need_write++] = 0xAA;                                         //添加"0XAA"的bad command到发送缓冲区
        ftStatus |= FT_Write(ftHandle, Out_buf, need_write,&real_write);      //发送bad command到芯片
        
        m=0;
        do{
            ftStatus |= FT_GetQueueStatus(ftHandle, &need_read);              //读取当前设备中有多少数据需要读出
            m=m+1;
        }while ((need_read == 0) && (ftStatus == FT_OK) && (m<1000) );
        
        if(m<1000){
            
            char bCommandEchod1 = 0;
            ftStatus |= FT_Read(ftHandle, In_buf, need_read,&real_read);      //读取当前buffer中的数据，目的是清空buffer
            for(j = 0; j < (real_read - 1); j++){                             //循环检测读取到的数据
                if ((In_buf[j] == 0xFA) && (In_buf[j+1]== 0xAA)){
                    bCommandEchod1 = 1;
                    break;
                }
            }
            
            if(bCommandEchod1 == 1){
                break;
            }
            
        }
        
    }
    
    if(i>=10)return FT_OTHER_ERROR;
    //---------------------------
    for(i=0;i<10;i++){                                                        //最大重试10次
        
        need_write = 0;                                                       //清空需要发送的长度
        Out_buf[need_write++] = 0xAB;                                         //添加"0XAB"的bad command到发送缓冲区
        ftStatus |= FT_Write(ftHandle, Out_buf, need_write,&real_write);      //发送bad command到芯片
        
        m=0;
        do{
            ftStatus |= FT_GetQueueStatus(ftHandle, &need_read);              //读取当前设备中有多少数据需要读出
            m=m+1;
        }while ((need_read == 0) && (ftStatus == FT_OK) && (m<1000) );
        
        if(m<1000){
            
            char bCommandEchod2 = 0;
            ftStatus |= FT_Read(ftHandle, In_buf, need_read,&real_read);          //读取当前buffer中的数据，目的是清空buffer
            for(j = 0; j < (real_read - 1); j++){                                 //循环检测读取到的数据
                if ((In_buf[j] == 0xFA) && (In_buf[j+1]== 0xAB)){
                    bCommandEchod2 = 1;
                    break;
                }
            }
            if(bCommandEchod2 == 1){
                break;
            }
            
        }
        
    }
    
    if(i>=10)return FT_OTHER_ERROR;
    //--------------------------
    //FT232H, FT2232H & FT4232H ONLY
    //--------------------------
    if(div != 0){
        need_write=0;
        Out_buf[need_write++] = 0x8A;                                         //Ensure disable clock divide by 5 for 60Mhz master clock
        Out_buf[need_write++] = 0x97;                                         //Ensure turn off adaptive clocking
        Out_buf[need_write++] = 0x8D;                                         //disable 3 phase data clock
        
        ftStatus |= FT_Write(ftHandle, Out_buf, need_write,&real_write);      // Send out the commands
    }
    //--------------------------
    need_write = 0;
    Out_buf[need_write++] = 0x80;                                         //设置第一次进入MPSSE模式的io方向
    Out_buf[need_write++] = 0xFF;                                         //IO输出高电平
    Out_buf[need_write++] = 0xFF;                                         //全部输出
    
    // SK frequency  = 12MHz /((1 +  [(1 +0xValueH*256) OR 0xValueL])*2)
    Out_buf[need_write++] = 0x86;                                         //设置clk的指令
    Out_buf[need_write++] = 0xFF & (clk_div & 0xFF);                      //ValueL
    Out_buf[need_write++] = 0XFF & (clk_div >> 8);                        //ValueH
    
    ftStatus |= FT_Write(ftHandle, Out_buf, need_write,&real_write);      //发送bad command到芯片
    
    usleep(10000);                                                        //Delay for a while
    //--------------------------
    need_write = 0;
    //Out_buf[need_write++] = 0x84;                                         //打开loop back,TDI和TDO短接在一起
    Out_buf[need_write++] = 0x85;                                       //关闭loop back,TDI和TDO不短接
    ftStatus |= FT_Write(ftHandle, Out_buf, need_write,&real_write);      //发送bad command到芯片
    
    usleep(10000);                                                        //Delay for a while
    //--------------------------
    m=0;
    do{
        ftStatus |= FT_GetQueueStatus(ftHandle, &need_read);              //读取当前设备中有多少数据需要读出
        m=m+1;
    }while ((need_read == 0) && (ftStatus == FT_OK) && (m<1000) );
    
    if(m<1000){
        ftStatus |= FT_Read(ftHandle, In_buf, need_read,&real_read);      //读取当前buffer中的数据，目的是清空buffer
    }
    //--------------------------
    //printf("SPI initial successful\n");
    //--------------------------
    
    return ftStatus;
}
//=======================================================
FT_STATUS SPI_Open(char *name,FT_HANDLE	ftHandle){

    FT_STATUS ftStatus = FT_OK;
    
    ftStatus |= FT_OpenEx(name,FT_OPEN_BY_SERIAL_NUMBER,&ftHandle);
    
    return ftStatus;
}
//=======================================================
FT_STATUS SPI_Close(FT_HANDLE ftHandle){
    
    FT_STATUS ftStatus = FT_OK;
    
    ftStatus |= FT_Close(ftHandle);
    
    return ftStatus;
}
//=======================================================





