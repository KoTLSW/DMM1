//
//  SPI_Test.m
//  B312_BT_MIC_SPK
//
//  Created by EW on 16/5/26.
//  Copyright © 2016年 h. All rights reserved.
//

#import "SPI_Test.h"

#include "ftd2xx.h"
#include "FTDI_COM.h"
#include "FTDI_SPI.h"
#include "FTDI_UART.h"
//================================================
@interface SPI_Test ()
{
    int                 index3;
    
    FT_HANDLE           uart;           //测试板uart端口
    FT_HANDLE           spi;            //测试板spi端口
}
@end
//========================================
@implementation SPI_Test
//========================================
-(void)Action3
{
    @autoreleasepool
    {
        int time_cnt=0;
        short fre=200;
        
        while ([[NSThread currentThread] isCancelled] == NO)
        {
            //---------------
            //NSLog(@"index3=%d",index3);
            //---------------
            if(index3==0)
            {
                while( FTDI_DeviceOpen("SPI",&spi) != 0);
                while( SPI_Init(spi,500000,0) != 0);
                
                short wdat[]={0xcccc,0xcccc}; //reset
                short rdat[]={0x0000,0x0000};
                
                FT_STATUS ftstate = SPI_WR_SHORTS(spi, wdat,rdat,2);
                
                usleep(1000000);
                
                if(ftstate == FT_OK)index3=1;
            }
            //---------------
            if(index3==1)
            {
                short wdat[]={0x1111,0x1111}; //开始录音
                short rdat[]={0x0000,0x0000};
                
                FT_STATUS ftstate = SPI_WR_SHORTS(spi, wdat,rdat,2);
                
                if(ftstate == FT_OK)index3=2;
            }
            //---------------
            if(index3==2)
            {
                short wdat[]={0x2222}; //检测是否录完
                short rdat[]={0x0000};
                
                FT_STATUS ftstate = SPI_WR_SHORTS(spi, wdat,rdat,1);
                
                if((rdat[0]==0x0001)&&(ftstate == FT_OK))index3=3;
            }
            //---------------
            if(index3==3)
            {
                
                short wdat[]={0x3000,0x3000};
                short rdat[]={0x0000,0x0000};
                
                FT_STATUS ftstate = SPI_WR_SHORTS(spi, wdat,rdat,2);   //发送无效字节，准备数据
                
                if(ftstate == FT_OK)index3=4;
            }
            //---------------
            if(index3==4)
            {
                
                short wdat[4097];
                short rdat[4097];
                
                for(int i=0;i<4096;i++)wdat[i]=0x3000|i;
                
                FT_STATUS ftstate = SPI_WR_SHORTS(spi, wdat,rdat,4097);
                
                if(ftstate == FT_OK){
                    
//                    for(int i=0;i<4096;i++)rdat[i]=rdat[i+1];           //数据左移一个
//                    //-----------------
//                    double wave[2048];
//                    
//                    for(int i=0;i<2048;i++)wave[i]=rdat[i+50]*0.00005035;  //转换为实际电压
//                    //----------------
//                    float ts=1/97656.25;
//                    
//                    for(int i=0;i<1024;i++)[chart_wave SetPoint:i x:i*ts y:wave[i]];
//                    
//                    [chart_wave Repaint];
//                    //-----------------
//                    [fft FFT:wave Length:2048 Samplerate:97656.25 Calibration:0.32];
//                    
//                    for(int i=0;i<1024;i++)[chart_fft SetPoint:i x:((i*97656.25)/2048000) y:fft.DB[i]];
//                    
//                    [chart_fft Repaint];
//                    
//                    NSLog(@"THD=%0.4f SNR=%0.4f",fft.THD,fft.SNR);
                    //-----------------
                    
                    index3=1;
                }
            }
            //---------------
            
            //---------------
            if(index3==5)
            {
                
                short wdat[]={0x4000,0x4000};
                short rdat[]={0x0000,0x0000};
                SPI_WR_SHORTS(spi, wdat,rdat,2);   //发送无效字节，准备数据
                
                index3=6;
            }
            //---------------
            if(index3==6)
            {
                
                short wdat[4097];
                short rdat[4097];
                
                for(int i=0;i<4096;i++)wdat[i]=0x4000|i;
                
                SPI_WR_SHORTS(spi, wdat,rdat,4097);
                
                for(int i=0;i<4096;i++)rdat[i]=rdat[i+1];  //数据左移一个
                
//                for(int i=0;i<1024;i++)[chart_fft SetPoint:i x:i y:rdat[i]+32768];
//                
//                [chart_fft Repaint];
                
                index3=7;
            }
            //---------------
            if(index3==7)
            {
                short wdat[]={0x5555,0x5555}; //开始录音
                short rdat[]={0x0000,0x0000};
                
                SPI_WR_SHORTS(spi, wdat,rdat,2);
                
                index3=8;
            }
            //---------------
            if(index3==8)
            {
                short wdat[]={0x6666}; //检测是否录完
                short rdat[]={0x0000};
                
                SPI_WR_SHORTS(spi, wdat,rdat,1);
                
                if(rdat[0]==0x0001)index3=9;
            }
            //---------------
            if(index3==9)
            {
                
                short wdat[]={0x7000,0x7000};
                short rdat[]={0x0000,0x0000};
                SPI_WR_SHORTS(spi, wdat,rdat,2);   //发送无效字节，准备数据
                
                index3=10;
            }
            //---------------
            if(index3==10)
            {
                
                short wdat[4097];
                short rdat[4097];
                
                for(int i=0;i<4096;i++)wdat[i]=0x7000|i;
                
                SPI_WR_SHORTS(spi, wdat,rdat,4097);
                
                for(int i=0;i<4096;i++)rdat[i]=rdat[i+1];  //数据左移一个
                
//                for(int i=0;i<1024;i++)[chart_mic SetPoint:i x:i y:rdat[i]+32768];
//                
//                [chart_mic Repaint];
                
                index3=7;
            }
            //---------------
            if(index3==11)
            {
                short wdat[]={0xa000+fre}; //spk放音
                short rdat[]={0x0000};
                
                SPI_WR_SHORTS(spi, wdat,rdat,1);
                
                index3=12;
            }
            //---------------
            if(index3==12)
            {
                time_cnt=0;
                index3=13;
                
                fre=fre+500;
                
                if(fre>4000)index3=14;
            }
            //－－－－－－－－－
            if(index3==13)
            {
                time_cnt=time_cnt+1;
                if(time_cnt>100)index3=11;
            }
            //－－－－－－－－－
            if(index3==14)
            {
                short wdat[]={0xbbbb}; //spk关闭
                short rdat[]={0x0000};
                
                SPI_WR_SHORTS(spi, wdat,rdat,1);
                
                fre=200;
                
                index3=15;
            }
            //---------------
            if(index3==15)
            {
                index3=1;
            }
            //---------------
            [NSThread sleepForTimeInterval:0.001];
            //---------------
        }
    }
}
//========================================
@end
