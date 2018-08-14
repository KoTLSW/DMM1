//
//  AgilentTools.m
//  Emerald_Measure
//
//  Created by mac on 2017/8/17.
//  Copyright © 2017年 michael. All rights reserved.
//

#import "AgilentTools.h"


static AgilentTools* AgilentToolsSingleton = nil;

@implementation AgilentTools


+ (AgilentTools *)Instance
{
    @synchronized(self)
    {
        if (AgilentToolsSingleton == nil)
        {
            AgilentToolsSingleton = [[self alloc] init];
        }
    }
    
    return AgilentToolsSingleton;
}



-(NSArray *)getUsbArray{
    NSMutableArray * array=[[NSMutableArray alloc]init];
    ViSession deRM;
    ViFindList findLt = 0;
    ViUInt32 numInstr = 0;
    char instrDes[VI_FIND_BUFLEN];
    int status = viOpenDefaultRM (&deRM);
    if (status < VI_SUCCESS)
    {
        exit (EXIT_FAILURE);
    }
    status = viFindRsrc (deRM, "USB0::0x2A8D::?*", &findLt, &numInstr, instrDes);
    
    while (status==0 && numInstr--) {
        NSString *instr = [NSString stringWithUTF8String:instrDes];
        [array addObject:instr];
        status = viFindNext(findLt, instrDes);
        if (status < VI_SUCCESS)continue;
    }
    
    viClose (deRM);
    return array;
}


-(NSArray *)getTcpArray
{
    NSMutableArray * array=[[NSMutableArray alloc]init];
    ViSession deRM;
    ViFindList findLt = 0;
    ViUInt32 numInstr = 0;
    char instrDes[VI_FIND_BUFLEN];
    int status = viOpenDefaultRM (&deRM);
    if (status < VI_SUCCESS)
    {
        exit (EXIT_FAILURE);
    }
    
    //第二个参数可以进行适当的变更
    status = viFindRsrc (deRM, "TCPIP0::192.168.1.10::?*", &findLt, &numInstr, instrDes);
    
    while (status==0 && numInstr--) {
        NSString *instr = [NSString stringWithUTF8String:instrDes];
        [array addObject:instr];
        status = viFindNext(findLt, instrDes);
        if (status < VI_SUCCESS)continue;
    }
    
    viClose (deRM);
    return array;
}



-(NSArray *)getGPIBArray
{
    
   NSMutableArray * array=[[NSMutableArray alloc]init];
   ViSession deRM;
   ViFindList findLt = 0;
   ViUInt32 numInstr = 0;
   char instrDes[VI_FIND_BUFLEN];
   int openStatus = viOpenDefaultRM (&deRM);
   if (openStatus < VI_SUCCESS)
   {
      exit (EXIT_FAILURE);
   }
        
   openStatus = viFindRsrc (deRM,  "GPIB[0-9]*::?*INSTR", &findLt, &numInstr, instrDes);
        
        while (openStatus==0 && numInstr--) {
            NSString *instrString = [NSString stringWithUTF8String:instrDes];
            [array addObject:instrString];
            openStatus = viFindNext(findLt, instrDes);
            if (openStatus < VI_SUCCESS)continue;
        }
        
        viClose (deRM);
        return array;

}


@end
