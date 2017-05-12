//
//  KEYSIGHT33210A.h
//  HowToWorks
//
//  Created by h on 17/5/11.
//  Copyright © 2017年 bill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HiperTimer.h"
#import "visa.h"

enum Agilent33210AMessureMode
{
    MODE_Sine,      //正弦波
    MODE_Square,    //方波
    MODE_Ramp,      //锯齿波
    MODE_Pulse,     //脉冲
    MODE_Noise,     //噪声
};


enum Agilent33210ACommunicateType
{
    Agilent33210A_USB_Type,  //USB通信
    Agilent33210A_LAN_Type,  //网口通信
    Agilent33210A_UART_Type, //串口通信
};

@interface Agilent33210A : NSObject
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

-(BOOL) Find:(NSString *)serial andCommunicateType:(enum Agilent33210ACommunicateType)communicateType;
-(BOOL) OpenDevice:(NSString *)serial andCommunicateType:(enum Agilent33210ACommunicateType)communicateType;
-(void) CloseDevice;


/**
 *  波形发生器
 *
 *  @param mode            波形类型
 *  @param communicateType 通信类型
 *  @param FREQuency       频率
 *  @param VOLTage         电压
 *  @param OFFSet          偏移    ==0.4
 */
-(void)SetMessureMode:(enum Agilent33210AMessureMode)mode andCommunicateType:(enum Agilent33210ACommunicateType)communicateType andFREQuency:(NSString*)FREQuency andVOLTage:(NSString*)VOLTage andOFFSet:(NSString*)OFFSet;


-(BOOL) WriteLine:(NSString*) data andCommunicateType:(enum Agilent33210ACommunicateType)communicateType;

-(NSString*)ReadData:(int)readDataCount andCommunicateType:(enum Agilent33210ACommunicateType)communicateType;

+(NSArray *)getArratWithCommunicateType:(enum Agilent33210ACommunicateType)communicateType;
@end
