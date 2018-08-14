//
//  Agilent34410A.h
//  X322MotorTest
//
//  Created by CW-IT-MINI-001 on 14-1-11.
//  Copyright (c) 2014年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HiperTimer.h"
#import "visa.h"

enum AgilentMessureMode
{
    MODE_RES_4W,     //4线电阻模式
    MODE_RES_2W,     //2线电阻模式
    MODE_DIODE,      //二极管测试
    MODE_CURR_DC,    //直流电流
    MODE_CURR_AC,    //交流电流
    MODE_VOLT_DC,    //直流电压
    MODE_VOLT_AC,    //交流电压
    MODE_TEMP_4W,    //温度 四线
    MODE_TEMP_2W,    //温度 二线
    MODE_CAP,        //电容
    MODE_DEFAULT=MODE_VOLT_DC,
};

enum AgilentCommunicateType
{
    MODE_USB_Type,  //USB通信
    MODE_LAN_Type,  //网口通信
    MODE_UART_Type, //串口通信
    MODE_GPIB_Type,//GPIB通信
};




@interface AgilentDevice : NSObject
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

-(BOOL) Find:(NSString *)serial andCommunicateType:(enum AgilentCommunicateType)communicateType;
-(BOOL) OpenDevice:(NSString *)serial andCommunicateType:(enum AgilentCommunicateType)communicateType;
-(void) CloseDevice;


-(enum AgilentMessureMode)getMessureMode:(NSString*)strUnit;
//
-(void)SetMessureMode:(enum AgilentMessureMode)mode andCommunicateType:(enum AgilentCommunicateType)communicateType;


-(NSString*)readValueBaseModeWithinCount:(NSString*)agilentSerial
                                 andMode:(enum AgilentMessureMode)mode
                    andCommunicateType:(enum AgilentCommunicateType)communicateType
                                  andCmd:(NSString*)strCmd
                            andReadCount:(int)readCount;


-(NSString*)readValueBaseModeWithinTime:(enum AgilentMessureMode)mode
                                 andCommunicateType:(enum AgilentCommunicateType)communicateType
                                 andCmd:(NSString*)strCmd
                            andReadTime:(int)time;

-(BOOL) WriteLine:(NSString*) data andCommunicateType:(enum AgilentCommunicateType)communicateType;

-(NSString*)ReadData:(int)readDataCount andCommunicateType:(enum AgilentCommunicateType)communicateType;

+(NSArray *)getArratWithCommunicateType:(enum AgilentCommunicateType)communicateType;


@end
