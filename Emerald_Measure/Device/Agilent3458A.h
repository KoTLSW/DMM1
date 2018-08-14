//
//  Agilent3458A.h
//  Emerald_Measure
//
//  Created by eastiwn on 17/5/10.
//  Copyright © 2017年 michael. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HiperTimer.h"
#import "visa.h"

enum Agilent3458AMessureMode
{
    Agilent3458A_RES_4W,     //4线电阻模式
    Agilent3458A_RES_2W,     //2线电阻模式
    Agilent3458A_DIODE,      //二极管测试
    Agilent3458A_CURR_DC,    //直流电流
    Agilent3458A_CURR_AC,    //交流电流
    Agilent3458A_VOLT_DC,    //直流电压
    Agilent3458A_VOLT_AC,    //交流电压
    Agilent3458A_TEMP_4W,    //温度 四线
    Agilent3458A_TEMP_2W,    //温度 二线
    Agilent3458A_CAP,        //电容
    Agilent3458A_DEFAULT=Agilent3458A_VOLT_DC,
};



@interface Agilent3458A : NSObject
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

}

@property(nonatomic,strong)NSString *agilentSerial;

//扫描和打开设备
-(BOOL) FindAndOpen:(NSString *)serial;

//关闭设备
-(void) CloseDevice;

//获取GPIB设备列表
-(NSMutableArray *)getArrayAboutGPIBDevice;
//设置测量模式
-(void)SetMessureMode:(enum Agilent3458AMessureMode)mode;

//往仪器中写入字符串
-(BOOL) WriteLine:(NSString*)writeString;

//读取数据=====readDataCount 字节数
-(NSString*) ReadData:(int)readDataCount;




@end
