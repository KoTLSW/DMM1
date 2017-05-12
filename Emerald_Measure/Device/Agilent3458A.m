//
//  Agilent3458A.m
//  Emerald_Measure
//
//  Created by eastiwn on 17/5/10.
//  Copyright © 2017年 michael. All rights reserved.
//

#import "Agilent3458A.h"

@implementation Agilent3458A


-(id)init
{
    if (self==[super init]) {
        
        _isOpen=false;
        
        return  self;
    }
    
    return nil;
}



-(NSMutableArray *)getArrayAboutGPIBDevice
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
    
    while (status==0 && numInstr--) {
        NSString *instrString = [NSString stringWithUTF8String:instrDes];
        [array addObject:instrString];
        status = viFindNext(findLt, instrDes);
        if (status < VI_SUCCESS)continue;
    }
    
    viClose (deRM);
    return array;
}



-(BOOL)FindAndOpen:(NSString *)serial
{
    sleep(0.5);
    status = viOpenDefaultRM (&defaultRM);
    
    if (status < VI_SUCCESS)
    {
        exit (EXIT_FAILURE);
    }
        
        /*
         * Find all the VISA resources in our system and store the number of resources
         * in the system in numInstrs.  Notice the different query descriptions a
         * that are available.
         
         Interface         Expression
         --------------------------------------
         GPIB              "GPIB[0-9]*::?*INSTR"
         VXI               "VXI?*INSTR"
         GPIB-VXI          "GPIB-VXI?*INSTR"
         Any VXI           "?*VXI[0-9]*::?*INSTR"
         Serial            "ASRL[0-9]*::?*INSTR"
         PXI               "PXI?*INSTR"
         All instruments   "?*INSTR"
         All resources     "?*"
         */
    
        
    if (serial == nil)
    {
        status = viFindRsrc(defaultRM, "GPIB[0-9]*::?*INSTR",&findList, &numInstrs, instrDescriptor);
    }
    else
    {
        const char *s = [serial UTF8String];
        status = viFindRsrc (defaultRM, (char*)s, &findList, &numInstrs, instrDescriptor);
    }
    
     if (status<VI_SUCCESS)
     {
         printf ("An error occurred while finding resources.\n");
         fflush(stdin);
         viClose (defaultRM);
         return NO;
     }
     else
     {
        self.agilentSerial=serial;
        NSLog(@"%s",instrDescriptor);
        //打开设备
         BOOL isOK = [self OpenDevice];
         
        return isOK;
     }
}



-(BOOL) OpenDevice
{
    if (_isOpen) return YES;
    status = viOpen(defaultRM, instrDescriptor, VI_NULL,VI_NULL, &instr);
    if (status==VI_SUCCESS) {
         return YES;
    }else
    {
        _isOpen=false;
         return NO;
    }
}



-(void)SetMessureMode:(enum Agilent3458AMessureMode)agilentMode
{
    switch (agilentMode) {
        case Agilent3458A_CURR_DC:{
             [self WriteLine:@"OUTPUT 722;"];usleep(1000);
             [self WriteLine:@"FUNC DCI"];usleep(1000);
             [self WriteLine:@"DCI 10E-9"];usleep(1000);
             [self WriteLine:@"NPLC 1"];usleep(1000);
            }break;
        case Agilent3458A_CURR_AC:{
            
            [self WriteLine:@"OUTPUT 722;"];usleep(1000);
            [self WriteLine:@"FUNC ACI"];usleep(1000);
            [self WriteLine:@"ACBAND 5E3,8E3"];usleep(1000);
   
        }
            break;
        case Agilent3458A_VOLT_DC:{
        
            [self WriteLine:@"OUTPUT 722;"];usleep(1000);
            [self WriteLine:@"FUNC DCV"];usleep(1000);
            [self WriteLine:@"NPLC 1"];usleep(1000);

        }
            break;
        case Agilent3458A_VOLT_AC:{
            
            [self WriteLine:@"OUTPUT 722;"];usleep(1000);
            [self WriteLine:@"FUNC ACV"];usleep(1000);
            [self WriteLine:@"ACBAND 5E3,8E3"];usleep(1000);
        
        
        }
            break;
        case Agilent3458A_RES_4W:{
        
            [self WriteLine:@"OUTPUT 722;"];usleep(1000);
            [self WriteLine:@"FUNC OHMF"];usleep(1000);
        }
            break;
        case Agilent3458A_RES_2W:{
            [self WriteLine:@"OUTPUT 722;"];usleep(1000);
            [self WriteLine:@"FUNC OHM"];usleep(1000);
        }
            break;

        default:
            break;
    }
}


-(BOOL) WriteLine:(NSString*)writeString
{
    /*  Now we must enable the service request event so that VISA
     *  will receive the events.  Note: one of the parameters is
     *  VI_QUEUE indicating that we want the events to be handled by
     *  a synchronous event queue.  The alternate mechanism for handling
     *  events is to set up an asynchronous event handling function using
     *  the VI_HNDLR option.  The events go into a queue which by default
     *  can hold 50 events.  This maximum queue size can be changed with
     *  an attribute but it must be called before the events are enabled.
     */
        status = viEnableEvent (instr, VI_EVENT_SERVICE_REQ, VI_QUEUE, VI_NULL);

        
        NSString* dataLine = [[NSString alloc] initWithFormat:@"%@\n", writeString];
        NSInteger dataLen = [dataLine length];
        char inputBuffer[dataLen];
        strcpy(inputBuffer, [dataLine UTF8String]);
        
        status = viWrite (instr, (ViBuf)inputBuffer, (ViUInt32)strlen(inputBuffer), &writeCount);
        if (status < VI_SUCCESS)
        {
            return NO;
        }
        
        return YES;
}


//GPIB通信
-(NSString*) ReadData:(int)readDataCount{
    
    unsigned char buffer[20* readDataCount];   //建立缓存空间
    memset(buffer, 0,20*readDataCount);      //对内存空间进行清零处理
    status = viRead (instr, buffer, readDataCount, &retCount);
    if (status < VI_SUCCESS)
    {
        return @"";
    }
    
    NSString *result = [[NSString alloc] initWithUTF8String:(const char*)buffer];
    return result ;
}


-(void)CloseDevice
{
    if (!_isOpen) return;
    /* Now close the session we just opened.                            */
    /* In actuality, we would probably use an attribute to determine    */
    /* if this is the instrument we are looking for.                    */
    viClose (instr);
    status = viClose(findList);
    status = viClose (defaultRM);
    
    //2015.1.19
    _isOpen = FALSE;
}




@end
