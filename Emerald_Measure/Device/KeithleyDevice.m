//
//  KeithleyDevice.m
//  HowToWorks
//
//  Created by eastiwn on 17/5/5.
//  Copyright © 2017年 bill. All rights reserved.
//

#import "KeithleyDevice.h"

@implementation KeithleyDevice

-(void)SetMessureMode:(enum KeithleyDeviceMessureMode)mode
{
    switch (mode) {
        case K_MODE_RES_4W
            :
        {
            [self WriteLine:@"*RST"];usleep(10*1000);
            [self WriteLine:@"*CLS"]; usleep(50);
            [self WriteLine:@"ABORT"]; usleep(50);
//          [self WriteLine:@":SENS:FUNC 'FRES'"]; usleep(10*1000);
//          [self WriteLine:@":SENS:FRES:NPLC 1"]; usleep(10*1000);   //shorter has faster
//           [self WriteLine:@":SENS:FRES:RANG 100"]; usleep(10*1000);   // 电阻的范围0-100ohm，可以根据实际情况设定
            [self WriteLine:@"CONF:FRES"];
        }
            break;
            
        case K_MODE_RES_2W:
        {
            [self WriteLine:@"*RST"];usleep(10*1000);
            [self WriteLine:@"*CLS"]; usleep(50);
            [self WriteLine:@"ABORT"]; usleep(50);
            //[self WriteLine:@":SENS:FUNC 'RES'"]; usleep(10*1000);
            //[self WriteLine:@":SENS:RES:NPLC 1"]; usleep(10*1000);   //shorter has faster
            //[self WriteLine:@":SENS:RES:RANG 100"]; usleep(10*1000);   // 电阻的范围0-100ohm，可以根据实际情况设定
            [self WriteLine:@"CONF:RES"];
        }
            break;
            
        case K_MODE_DIODE:
        {
            [self WriteLine:@"*RST"];usleep(10*1000);
            [self WriteLine:@"*CLS"]; usleep(50);
            [self WriteLine:@"ABORT"]; usleep(50);
            [self WriteLine:@"CONF:DIOD"]; usleep(10*1000);
            
            
        }
            break;
            
            
        case K_MODE_CURR_DC:
        {
            [self WriteLine:@"*RST"];  usleep(10*1000);
            [self WriteLine:@"*CLS"];  usleep(10*1000);
            [self WriteLine:@"ABORT"]; usleep(10*1000);
            [self WriteLine:@":SENS:FUNC 'CURR:DC'"];usleep(10*1000);
            [self WriteLine:@":SENS:CURR:DC:NPLC 0.02"]; usleep(10*1000);  //shorter has faster speed
            [self WriteLine:@":SENS:CURR:DC:RANG 1"];usleep(10*1000);
        }
            
            
            break;
        case K_MODE_CURR_AC:
        {
            [self WriteLine:@"*RST"];  usleep(10*1000);
            [self WriteLine:@"*CLS"];  usleep(10*1000);
            [self WriteLine:@"ABORT"]; usleep(10*1000);
            [self WriteLine:@":SENS:FUNC 'CURR:AC'"]; usleep(10*1000);
            [self WriteLine:@":SENS:CURR:AC:DETector:BANDwidth 20"]; usleep(10*1000);  //shorter has faster speed
            [self WriteLine:@":SENS:CURR:AC:RANG 1"];usleep(10*1000);
            
        }
            break;
        case K_MODE_VOLT_DC:
        {
            [self WriteLine:@"*RST"];usleep(10*1000);
            [self WriteLine:@"*CLS"];  usleep(10*1000);
            [self WriteLine:@"ABORT"]; usleep(10*1000);
            //[self WriteLine:@":SENS:FUNC 'VOLT:DC'"];usleep(10*1000);
            //[self WriteLine:@":SENS:VOLT:DC:NPLC 0.02"]; usleep(10*1000);  //shorter has faster speed
            //[self WriteLine:@":SENS:VOLT:DC:RANG 10"];usleep(10*1000);
             [self WriteLine:@"CONF:VOLT"];
            
        }
            break;
        case K_MODE_VOLT_AC:
        {
            [self WriteLine:@"*RST"];usleep(10*1000);
            [self WriteLine:@"*CLS"];  usleep(10*1000);
            [self WriteLine:@"ABORT"]; usleep(10*1000);
            [self WriteLine:@":SENS:FUNC 'VOLT:AC'"];usleep(10*1000);
            [self WriteLine:@":SENS:VOLT:AC:DETector:BANDwidth 20"]; usleep(10*1000);  //shorter has faster speed
            [self WriteLine:@":SENS:VOLT:AC:RANG 10"];usleep(10*1000);
            
        }
            break;
            
            
    
        case K_MODE_CAP:
        {
            [self WriteLine:@"*RST"];usleep(10*1000);
            [self WriteLine:@"*CLS"];  usleep(10*1000);
            [self WriteLine:@"ABORT"]; usleep(10*1000);
            [self WriteLine:@":SENS:FUNC 'CAP'"]; usleep(10*1000);
            [self WriteLine:@":SENS:CAP:RANG:AUTO ON"];usleep(10*1000);
        }
            break;
            
        default:
            break;
    }



}

@end
