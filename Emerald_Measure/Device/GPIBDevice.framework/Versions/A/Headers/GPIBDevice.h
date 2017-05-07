//
//  GPIBDevice.h
//  GPIBDevice
//
//  Created by GS on 15-5-7.
//  Copyright (c) 2015年 ___CW___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VISA/visa.h>
#import <VISA/visatype.h>
#import <VISA/vpptype.h>

@interface GPIBDevice : NSObject
{
    char instrDescriptor[VI_FIND_BUFLEN];
    ViUInt32 numInstrs;
    ViFindList findList;
    ViSession defaultRM, instr;
    ViStatus status;
    ViUInt32 retCount;
    ViUInt32 writeCount;
    unsigned char buffer[4096* 100];
    char stringinput[512];
}

-(BOOL) WriteLine:(NSString*) data;
-(NSString*) Read;
-(BOOL) Find;
-(BOOL) Open;
-(void) Close;

@end
