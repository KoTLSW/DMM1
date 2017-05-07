/*
 * Assuming libftd2xx.so is in /usr/local/lib, build with:
 * 
 *     gcc -o bitmode main.c -L. -lftd2xx -Wl,-rpath /usr/local/lib
 * 
 * and run with:
 * 
 *     sudo ./bitmode [port number]
 */
#include <stdio.h>
#include "ftd2xx.h"
#include "WinTypes.h"
#include "FTDI_COM.h"
#include "FTDI_SPI.h"
#include "FTDI_UART.h"
//=======================================================
void ReceiverData(BYTE *dat,DWORD len){
    for(int i=0;i<len;i++)printf("%c",dat[i]);
}
//=======================================================
//int main(){
//    
//    DWORD numDevs=0;
//    DWORD i=0;
//    char name[64];
//    
//    FT_HANDLE ftHandle;
//    
//    FTDI_DeviceCount(&numDevs);
//    
//    for(i=0;i<numDevs;i++){
//        
//        FTDI_DeviceName(i,name);
//        
//        printf("device [%d]=%s\n",i,name);
//    }
//    
//    //-----------------------------
//    FTDI_DeviceOpen("FTAPOWQA",&ftHandle);
//    
//    BYTE wdat[65000];
//    BYTE rdat[65000];
//    
//    for(i=0;i<sizeof(wdat);i++)wdat[i]=i%255;
//    
//    SPI_Init(ftHandle,1000000);
//    SPI_WR(ftHandle, wdat,rdat,sizeof(rdat));
//    
//    for(i=0;i<sizeof(wdat);i++)printf("0x%02x ",rdat[i]);
//    printf("\n");
//    
//    FTDI_DeviceClose(ftHandle);
//    //----------------------------
//    FTDI_DeviceOpen("FTAPOWQB",&ftHandle);
//    
//    UART_Init(ftHandle,115200);
//    UART_DTR(ftHandle,1);
//    UART_RTS(ftHandle,1);
//
//    pthread_t id = UART_SetCallBack(ftHandle,ReceiverData);
//    
//    printf("please input\n");
//    
//    BYTE buf[65535];
//    
//    while(1){
//        scanf("%s",buf);
//        
//        if(strcmp(buf,"exit")==0)break;
//        else{
//            
//            UART_Send(ftHandle,buf,strlen(buf));
//            UART_Send(ftHandle,"\r\n",2);
//        }
//        
//    }
//
//    
//    UART_ClrCallBack(ftHandle,id);
//    
//    FTDI_DeviceClose(ftHandle);
//    //----------------------------
//    return 0;
//
//}
