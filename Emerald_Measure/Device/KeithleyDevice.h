//
//  KeithleyDevice.h
//  HowToWorks
//
//  Created by eastiwn on 17/5/5.
//  Copyright © 2017年 bill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SerialPort.h"

enum KeithleyDeviceMessureMode
{
    K_MODE_RES_4W,     //4线电阻模式
    K_MODE_RES_2W,     //2线电阻模式
    K_MODE_DIODE,      //二极管测试
    K_MODE_CURR_DC,    //直流电流
    K_MODE_CURR_AC,    //交流电流
    K_MODE_VOLT_DC,    //直流电压
    K_MODE_VOLT_AC,    //交流电压
    K_MODE_CAP,        //电容
    K_MODE_DEFAULT=K_MODE_VOLT_DC,
};

@interface KeithleyDevice :SerialPort

/**
 *  设置万用表的测试模式
 *
 *  @param mode 设置模式
 */
-(void)SetMessureMode:(enum KeithleyDeviceMessureMode)mode;

@end
