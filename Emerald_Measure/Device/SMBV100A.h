//
//  SMBVINStr.h
//  Emerald_Measure
//
//  Created by mac on 03/05/2018.
//  Copyright © 2018 michael. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "HiperTimer.h"
#import "visa.h"


enum SMBV100ACommunicateType
{
    SMBV100A_USB_Type,  //USB通信
    SMBV100A_LAN_Type,  //网口通信
    SMBV100A_UART_Type, //串口通信
};

@interface SMBV100A : NSObject
{
    char instrDescriptor[VI_FIND_BUFLEN];
    
    //2015.1.19
    BOOL _isOpen;
    
    ViUInt32 numInstrs;
    ViFindList findList;
    ViSession defaultRM, instr;
    ViStatus status;
    ViUInt32 retCount;
    ViUInt32 writeCount;
    NSString * str;
    NSString* _agilentSerial;
}


@property(readwrite) BOOL isOpen;
@property(readwrite,copy)NSString* agilentSerial;

-(BOOL) Find:(NSString *)serial andCommunicateType:(enum SMBV100ACommunicateType)communicateType;
-(BOOL) OpenDevice:(NSString *)serial andCommunicateType:(enum SMBV100ACommunicateType)communicateType;
-(void) CloseDevice;


/**
 *  波形发生器
 *
 *  @param mode             波形类型
 *  @param communicateType  通信类型
 *  @param FREQ             频率
 *  @param level            分贝等级
 *  @param DEPT             百分比
 *  @param Shape            波形图
 *  @param LFOutput         设置波形频率
 */
-(void)SetMessureCommunicateType:(enum SMBV100ACommunicateType)communicateType andFREQuency:(NSString*)FREQ andLevel:(NSString *)level andDEPT:(NSString *)DEPT andLFO:(NSString *)Shape andLFOutput:(NSString *)LFOutput;


-(BOOL) WriteLine:(NSString*) data andCommunicateType:(enum SMBV100ACommunicateType)communicateType;


-(NSString*)ReadData:(int)readDataCount andCommunicateType:(enum SMBV100ACommunicateType)communicateType;


+(NSArray *)getArratWithCommunicateType:(enum SMBV100ACommunicateType)communicateType;


@end

