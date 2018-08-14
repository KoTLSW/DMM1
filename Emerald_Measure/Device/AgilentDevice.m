//
//  Agilent34410A.m
//  X322MotorTest
//
//  Created by CW-IT-MINI-001 on 14-1-11.
//  Copyright (c) 2014年 __MyCompanyName__. All rights reserved.
//

#import "AgilentDevice.h"

@implementation AgilentDevice
@synthesize isOpen=_isOpen;

// 2015.1.19 start
-(id)init
{
    if (self = [super init]) {
        _isOpen = FALSE;
    }
    
    return  self;
}


+(NSArray *)getArratWithCommunicateType:(enum AgilentCommunicateType)communicateType;
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
    
    switch (communicateType) {
        case MODE_LAN_Type:
            status = viFindRsrc (deRM, "TCPIP0::169.254.4.10::?*", &findLt, &numInstr, instrDes);
            break;
        case MODE_USB_Type:
             status = viFindRsrc (deRM, "USB0::0x0957::?*", &findLt, &numInstr, instrDes);
            break;
            
        default:
            NSLog(@"其它的通信方式");
            break;
    }
    
    while (status==0 && numInstr--) {
        NSString *instr = [NSString stringWithUTF8String:instrDes];
        [array addObject:instr];
        status = viFindNext(findLt, instrDes);
        if (status < VI_SUCCESS)continue;
    }
    
    viClose (deRM);
    return array;
}
// 2015.1.19 end


-(BOOL) OpenDevice:(NSString *)serial andCommunicateType:(enum AgilentCommunicateType)communicateType

{
    if (_isOpen) return YES;
    
//    status = viOpen (defaultRM, "TCPIP0::169.254.4.10::5025::SOCKET", VI_NULL, VI_NULL, &instr);
    
    switch (communicateType) {
        case MODE_LAN_Type:
              status = viOpen (defaultRM, instrDescriptor, VI_NULL, VI_NULL, &instr);
            break;
        case MODE_USB_Type:
             status = viOpen (defaultRM, instrDescriptor, VI_NULL, VI_NULL, &instr);
            break;
        case MODE_GPIB_Type:
            status = viOpen(defaultRM, instrDescriptor, VI_NULL,VI_NULL, &instr);
        default:
            NSLog(@"其它的通信方式");
            break;
    }
    

    if (status < VI_SUCCESS)
    {
        
        return NO;
    }
    _isOpen = YES;
    
    return YES;
}


-(enum AgilentMessureMode)getMessureMode:(NSString*)strUnit
{
    enum AgilentMessureMode mode=MODE_DEFAULT;
    
    if ([strUnit isEqualToString:@"Ohm"]
        || [strUnit isEqualToString:@"kOhm"]
        ||[strUnit isEqualToString:@"mOhm"]){
        mode=MODE_RES_4W;
    }else if ([strUnit isEqualToString:@"A"]
              ||[strUnit isEqualToString:@"mA"]
              ||[strUnit isEqualToString:@"uA"]){
        mode=MODE_CURR_DC;
    }else if ([strUnit isEqualToString:@"V"]
              ||[strUnit isEqualToString:@"mV"]
              ||[strUnit isEqualToString:@"kV"]){
        mode=MODE_VOLT_DC;
    }
    
    return mode;
}


-(NSString*)readValueBaseModeWithinCount:(NSString*)agilentSerial
                                 andMode:(enum AgilentMessureMode)mode
                      andCommunicateType:(enum AgilentCommunicateType)communicateType
                                  andCmd:(NSString*)strCmd
                            andReadCount:(int)readCount{
      NSString* strResult=@"";
      NSString * strTemp =@"";
    int countTemp=0;
    int count=0;
    
    do{
        [self delayMs:20];
        [self WriteLine:strCmd andCommunicateType:communicateType];
        [self delayMs:20];
        if (communicateType==MODE_LAN_Type) {
            
           strTemp=[self ReadData:16 andCommunicateType:communicateType];
        }
        else
        {
           strTemp=[self ReadData:readCount andCommunicateType:communicateType];
        
        }

        if ((strTemp==nil || strTemp.length<1)) {
            [self CloseDevice];
            [self Find:agilentSerial andCommunicateType:communicateType];
            [self OpenDevice:nil andCommunicateType:communicateType];
            [self SetMessureMode:mode andCommunicateType:communicateType];
            NSLog(@"Set Agilent mode again!");
            strTemp=[self ReadData:5 andCommunicateType:communicateType];
            countTemp++;
        }
        
        if (strTemp && strTemp.length>0) {
            count++;
            strResult=[NSString stringWithFormat:@"%@%@%@",strResult,@",",strTemp];
        }
    }while (count<readCount&& countTemp<5);
    
    return strResult;
}


-(NSString*)readValueBaseModeWithinTime:(enum AgilentMessureMode)mode
                                 andCommunicateType:(enum AgilentCommunicateType)communicateType
                                 andCmd:(NSString*)strCmd
                            andReadTime:(int)time{
     NSString* strResult=@"";
    
    switch (mode) {
        case MODE_VOLT_DC:
        case MODE_CURR_DC:
        case MODE_RES_4W:{
            HiperTimer* timer=[[HiperTimer alloc] init];
            [timer Start];
            
            while ([timer durationMillisecond]<time) {
                [self WriteLine:strCmd andCommunicateType:communicateType];
                [NSThread sleepForTimeInterval:0.02];
                
                HiperTimer * timer1=[[HiperTimer alloc] init ];
                [timer1 Start];
                
                NSString * strTemp=@"";
                
                if (communicateType==MODE_LAN_Type) {
                    
                    strTemp=[self ReadData:16 andCommunicateType:communicateType];
                }
                else
                {
                    strTemp=[self ReadData:50 andCommunicateType:communicateType];
                    
                }
                
                if ((strTemp==nil || strTemp.length<1) &&[timer1 durationMillisecond]>1500) {
                    [self CloseDevice];
                    [self OpenDevice:nil andCommunicateType:communicateType];
                    [self SetMessureMode:mode andCommunicateType:communicateType];
                    NSLog(@"Set Agilent mode again!");
                    strTemp=[self ReadData:5 andCommunicateType:communicateType];
                }
                
                if (strTemp && strTemp.length>0) {
                    strResult=[NSString stringWithFormat:@"%@%@%@",strResult,@",",strTemp];
                }
            }
        }
            break;
        default:
            break;
    }

    return strResult;
}

//
-(void)SetMessureMode:(enum AgilentMessureMode)mode andCommunicateType:(enum AgilentCommunicateType)communicateType
{
    switch (mode) {
        case MODE_RES_4W:
        {
            [self WriteLine:@"*RST" andCommunicateType:communicateType];usleep(10*1000);
            [self WriteLine:@"*CLS" andCommunicateType:communicateType]; usleep(50);
            [self WriteLine:@"ABORT" andCommunicateType:communicateType]; usleep(50);
            [self WriteLine:@":SENS:FUNC 'FRES'" andCommunicateType:communicateType]; usleep(10*1000);
            [self WriteLine:@":SENS:FRES:NPLC 1" andCommunicateType:communicateType]; usleep(10*1000);   //shorter has faster
            [self WriteLine:@":SENS:FRES:RANG 100" andCommunicateType:communicateType]; usleep(10*1000);   // 电阻的范围0-100ohm，可以根据实际情况设定
            //[self WriteLine:@"MEAS:FRES? 100,0.0001"];
        }
            break;
            
        case MODE_RES_2W:
        {
            [self WriteLine:@"*RST" andCommunicateType:communicateType];usleep(10*1000);
            [self WriteLine:@"*CLS" andCommunicateType:communicateType]; usleep(50);
            [self WriteLine:@"ABORT" andCommunicateType:communicateType]; usleep(50);
            [self WriteLine:@":SENS:FUNC 'RES'" andCommunicateType:communicateType]; usleep(10*1000);
            [self WriteLine:@":SENS:RES:NPLC 1" andCommunicateType:communicateType]; usleep(10*1000);   //shorter has faster
            [self WriteLine:@":SENS:RES:RANG 100" andCommunicateType:communicateType]; usleep(10*1000);   // 电阻的范围0-100ohm，可以根据实际情况设定
            //[self WriteLine:@"MEAS:FRES? 100,0.0001"];
        }
            break;
            
        case MODE_DIODE:
        {
            [self WriteLine:@"*RST" andCommunicateType:communicateType];usleep(10*1000);
            [self WriteLine:@"*CLS" andCommunicateType:communicateType]; usleep(50);
            [self WriteLine:@"ABORT" andCommunicateType:communicateType]; usleep(50);
//            [self WriteLine:@"CONFigure:'CONTinuity'" andCommunicateType:communicateType]; usleep(10*1000);
            [self WriteLine:@"CONF:DIOD" andCommunicateType:communicateType]; usleep(10*1000);
            
            
        }
            break;

            
        case MODE_CURR_DC:
        {
            [self WriteLine:@"*RST" andCommunicateType:communicateType];  usleep(10*1000);
            [self WriteLine:@"*CLS" andCommunicateType:communicateType];  usleep(10*1000);
            [self WriteLine:@"ABORT" andCommunicateType:communicateType]; usleep(10*1000);
            [self WriteLine:@":SENS:FUNC 'CURR:DC'" andCommunicateType:communicateType];usleep(10*1000);
            [self WriteLine:@":SENS:CURR:DC:NPLC 0.02" andCommunicateType:communicateType]; usleep(10*1000);  //shorter has faster speed
            [self WriteLine:@":SENS:CURR:DC:RANG 1" andCommunicateType:communicateType];usleep(10*1000);
        }
            
            
            break;
        case MODE_CURR_AC:
        {
            [self WriteLine:@"*RST" andCommunicateType:communicateType];  usleep(10*1000);
            [self WriteLine:@"*CLS" andCommunicateType:communicateType];  usleep(10*1000);
            [self WriteLine:@"ABORT" andCommunicateType:communicateType]; usleep(10*1000);
            [self WriteLine:@":SENS:FUNC 'CURR:AC'" andCommunicateType:communicateType]; usleep(10*1000);
            [self WriteLine:@":SENS:CURR:AC:BANDwidth 20" andCommunicateType:communicateType]; usleep(10*1000);  //shorter has faster speed
            [self WriteLine:@":SENS:CURR:AC:RANG 1" andCommunicateType:communicateType];usleep(10*1000);
            
        }
            break;
        case MODE_VOLT_DC:
        {
            [self WriteLine:@"*RST" andCommunicateType:communicateType];usleep(10*1000);
            [self WriteLine:@"*CLS" andCommunicateType:communicateType];  usleep(10*1000);
            [self WriteLine:@"ABORT" andCommunicateType:communicateType]; usleep(10*1000);
            [self WriteLine:@":SENS:FUNC 'VOLT:DC'" andCommunicateType:communicateType];usleep(10*1000);
            [self WriteLine:@":SENS:VOLT:DC:NPLC 0.02" andCommunicateType:communicateType]; usleep(10*1000);  //shorter has faster speed
            [self WriteLine:@":SENS:VOLT:DC:RANG 10" andCommunicateType:communicateType];usleep(10*1000);
            
        }
            break;
        case MODE_VOLT_AC:
        {
            [self WriteLine:@"*RST" andCommunicateType:communicateType];usleep(10*1000);
            [self WriteLine:@"*CLS" andCommunicateType:communicateType];  usleep(10*1000);
            [self WriteLine:@"ABORT" andCommunicateType:communicateType]; usleep(10*1000);
            [self WriteLine:@":SENS:FUNC 'VOLT:AC'" andCommunicateType:communicateType];usleep(10*1000);
            [self WriteLine:@":SENS:VOLT:AC:BANDwidth 20" andCommunicateType:communicateType]; usleep(10*1000);  //shorter has faster speed
            [self WriteLine:@":SENS:VOLT:AC:RANG 10" andCommunicateType:communicateType];usleep(10*1000);
            
        }
            break;

        case MODE_TEMP_4W:
        {
            [self WriteLine:@"*RST" andCommunicateType:communicateType];usleep(10*1000);
            [self WriteLine:@"*CLS" andCommunicateType:communicateType];  usleep(10*1000);
            [self WriteLine:@"ABORT" andCommunicateType:communicateType]; usleep(10*1000);
//--------------RTD-4W------------------------------
            [self WriteLine:@":SENS:FUNC 'TEMP'" andCommunicateType:communicateType];usleep(10*1000);              //选择测试模式
            [self WriteLine:@":SENS:TEMP:TRAN:TYPE FRTD" andCommunicateType:communicateType];usleep(10*1000);       //设置探头类型
            [self WriteLine:@":SENS:TEMP:TRAN:FRTD:OCOM ON" andCommunicateType:communicateType]; usleep(10*1000);  //偏移补偿，仅限于RTD探头
            [self WriteLine:@"TEMP:ZERO:AUTO ON" andCommunicateType:communicateType]; usleep(10*1000);  //自动调零
            [self WriteLine:@"TEMP:NPLC 0.2" andCommunicateType:communicateType]; usleep(10*1000);      //设置integration time
            [self WriteLine:@"TEMP:TRAN:FRTD:TYPE 85" andCommunicateType:communicateType]; usleep(10*1000);  //偏移补偿，仅限于RTD探头
            [self WriteLine:@"UNIT:TEMP F" andCommunicateType:communicateType]; usleep(10*1000);        //偏移补偿，仅限于RTD探头
            [self WriteLine:@"TEMP:TRAN:FRTD:RES 1000" andCommunicateType:communicateType]; usleep(10*1000);  //偏移补偿，仅限于RTD探头
            
            
//--------------热敏电阻4W---------------------------
//            [self WriteLine:@":SENS:FUNC 'TEMP'" andCommunicateType:communicateType];usleep(10*1000);              //选择测试模式
//            [self WriteLine:@":SENS:TEMP:TRAN:TYPE FTHermistor" andCommunicateType:communicateType];usleep(10*1000);   //设置探头类型
//            [self WriteLine:@"TEMP:ZERO:AUTO ON" andCommunicateType:communicateType]; usleep(10*1000);  //自动调零
//            [self WriteLine:@"TEMP:TRAN:THER:TYPE 10000" andCommunicateType:communicateType]; usleep(10*1000);      //设置integration time
//            [self WriteLine:@"TEMP:NPLC 0.2" andCommunicateType:communicateType]; usleep(10*1000);      //设置integration time
//            [self WriteLine:@"UNIT:TEMP F" andCommunicateType:communicateType]; usleep(10*1000);        //偏移补偿，仅限于RTD探头
        
        }
            break;
            
        case MODE_TEMP_2W:
        {
            [self WriteLine:@"*RST" andCommunicateType:communicateType];usleep(10*1000);
            [self WriteLine:@"*CLS" andCommunicateType:communicateType];  usleep(10*1000);
            [self WriteLine:@"ABORT" andCommunicateType:communicateType]; usleep(10*1000);
//--------------RTD-4W------------------------------
            [self WriteLine:@":SENS:FUNC 'TEMP'" andCommunicateType:communicateType];usleep(10*1000);              //选择测试模式
            [self WriteLine:@":SENS:TEMP:TRAN:TYPE RTD" andCommunicateType:communicateType];usleep(10*1000);       //设置探头类型
            [self WriteLine:@":SENS:TEMP:TRAN:RTD:OCOM ON" andCommunicateType:communicateType]; usleep(10*1000);  //偏移补偿，仅限于RTD探头
            [self WriteLine:@"TEMP:ZERO:AUTO ON" andCommunicateType:communicateType]; usleep(10*1000);  //自动调零
            [self WriteLine:@"TEMP:NPLC 0.2" andCommunicateType:communicateType]; usleep(10*1000);      //设置integration time
            [self WriteLine:@"TEMP:TRAN:RTD:TYPE 85" andCommunicateType:communicateType]; usleep(10*1000);  //偏移补偿，仅限于RTD探头
            [self WriteLine:@"UNIT:TEMP F" andCommunicateType:communicateType]; usleep(10*1000);        //偏移补偿，仅限于RTD探头
            [self WriteLine:@"TEMP:TRAN:RTD:RES 1000" andCommunicateType:communicateType]; usleep(10*1000);  //偏移补偿，仅限于RTD探头
            
//--------------热敏电阻4W---------------------------
//            [self WriteLine:@":SENS:FUNC 'TEMP'" andCommunicateType:communicateType];usleep(10*1000);              //选择测试模式
//            [self WriteLine:@":SENS:TEMP:TRAN:TYPE FTHermistor" andCommunicateType:communicateType];usleep(10*1000);   //设置探头类型
//            [self WriteLine:@"TEMP:ZERO:AUTO ON" andCommunicateType:communicateType]; usleep(10*1000);  //自动调零
//            [self WriteLine:@"TEMP:TRAN:THER:TYPE 10000" andCommunicateType:communicateType]; usleep(10*1000);      //设置integration time
//            [self WriteLine:@"TEMP:NPLC 0.2" andCommunicateType:communicateType]; usleep(10*1000);      //设置integration time
//            [self WriteLine:@"UNIT:TEMP F" andCommunicateType:communicateType]; usleep(10*1000);        //偏移补偿，仅限于RTD探头
            
        }
            break;
            
        case MODE_CAP:
        {
            [self WriteLine:@"*RST" andCommunicateType:communicateType];usleep(10*1000);
            [self WriteLine:@"*CLS" andCommunicateType:communicateType];  usleep(10*1000);
            [self WriteLine:@"ABORT" andCommunicateType:communicateType]; usleep(10*1000);
            [self WriteLine:@":SENS:FUNC 'CAP'" andCommunicateType:communicateType]; usleep(10*1000);
            [self WriteLine:@":SENS:CAP:RANG:AUTO ON" andCommunicateType:communicateType];usleep(10*1000);
        }
            break;
            
        default:
            break;
    }
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


-(BOOL) WriteLine:(NSString*) data andCommunicateType:(enum AgilentCommunicateType)communicateType
{
    /*
     * At this point we now have a session open to the instrument at
     * Primary Address 2.  We can use this session handle to write
     * an ASCII command to the instrument.  We will use the viWrite function
     * to send the string "*IDN?", asking for the device's identification.
     */
    
    
    switch (communicateType) {
        case MODE_LAN_Type:
             status = viSetAttribute (instr, VI_ATTR_TCPIP_NODELAY, 8000);
            break;
        case MODE_USB_Type:
             status = viSetAttribute (instr, VI_ATTR_TMO_VALUE, 8000);
            break;
            
        default:
            NSLog(@"其它的通信方式");
            break;
    }
    
    NSString* dataLine = [[NSString alloc] initWithFormat:@"%@\n", data];
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

//*******************注意*************************//
//网口通信一次最多只能够读取16个字节，既readDataCount<=16;
-(NSString*) ReadData:(int)readDataCount  andCommunicateType:(enum AgilentCommunicateType)communicateType
{
    
    unsigned char buffer[20* readDataCount];   //建立缓存空间
    memset(buffer, 0, 20* readDataCount);      //对内存空间进行清零处理
    switch (communicateType) {
        case MODE_LAN_Type:
            status = viRead (instr, buffer, readDataCount, &retCount);
            break;
        case MODE_USB_Type:
            status = viRead (instr, buffer, 20* readDataCount, &retCount);
            break;
            
        default:
            NSLog(@"其它的通信方式");
            break;
    }

    if (status < VI_SUCCESS)
    {
        return @"";
    }
    
    NSString *result = [[NSString alloc] initWithUTF8String:(const char*)buffer];
    return result ;
}


-(BOOL) Find:(NSString *)serial andCommunicateType:(enum AgilentCommunicateType)communicateType
{
    sleep(0.5);
    status = viOpenDefaultRM (&defaultRM);
    
    
    if (status < VI_SUCCESS){
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
    
    

    
    if (serial == nil) {
        
        switch (communicateType) {
            case MODE_LAN_Type:
                status = viFindRsrc (defaultRM, "TCPIP0::169.254.4.10::?*", &findList, &numInstrs, instrDescriptor);
                break;
            case MODE_USB_Type:
                status = viFindRsrc (defaultRM, "USB0::0x0957::?*", &findList, &numInstrs, instrDescriptor);
                break;
            case MODE_GPIB_Type:
                status = viFindRsrc(defaultRM, "GPIB0::GPIBxxxxx::?*",&findList, &numInstrs, instrDescriptor);
                
            default:
                NSLog(@"其它的通信方式");
                break;
        }

        if (status < VI_SUCCESS)
        {
            return false;
        }
        
        
    }else{
        const char *s = [serial UTF8String];
        status = viFindRsrc (defaultRM, (char*)s, &findList, &numInstrs, instrDescriptor);
        
        if (status == VI_SUCCESS){
            self.agilentSerial=serial;
        }
    }
    
    if (status < VI_SUCCESS){
        printf ("An error occurred while finding resources.\n");
        fflush(stdin);
        viClose (defaultRM);
        return NO;
    }
    
    NSLog(@"%s",instrDescriptor);
    return YES;
}

-(void)delayMs:(int)ms{
    HiperTimer* timer=[[HiperTimer alloc] init];
    [timer Start];
    while ([timer durationMillisecond]<ms);
    timer=nil;
}


@end
