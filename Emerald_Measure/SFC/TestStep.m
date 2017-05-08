
//  TestStep.m
//  FCMTest
//
//  Created by GS on 15-5-7.
//  Copyright (c) 2015年 GS. All rights reserved.
//

#import "TestStep.h"



static TestStep* test=nil;

@implementation TestStep
@synthesize strSN=_strSN;
@synthesize strErrorMessage=_strErrorMessage;
@synthesize timeDate=_timeDate;


-(id)init
{
    if (self=[super init])
    {
        testScriptPlist=[[PlistFile alloc] init:PLIST_TESTSCRIPT_FILE_NAME];
        configPlist=[[PlistFile alloc] init:PLIST_CONFIG_FILE_NAME];
        _strSN=[[NSString alloc] init];
        _strErrorMessage=[[NSString alloc] init];
        _timeDate=[[TimeDate alloc]init];
      
        
    }
    
    return self;
}

//
+(TestStep*)Instance
{
    if (test==nil)
    {
        test=[[TestStep alloc] init];
    }
    
    return test;
}

-(void)dealloc
{
    [testScriptPlist release];
    testScriptPlist=nil;
    [configPlist release];
    configPlist=nil;
    [_strSN release];
    _strSN=nil;
    [_strErrorMessage release];
    _strErrorMessage=nil;

    
    [super dealloc];
}



//初始化测试信息
-(void)StepInitTest
{
    //Write log file header
//    [[LogFile Instance] WriteHeader:_strSN andTestTime:[GetTimeDay GetCurrentTime] andHeader:[configPlist ReadArray:CONFIG_LOG_HEADER]];
    //文件名字
    NSString* strFileName=[NSString stringWithFormat:@"%@_%@.txt",_strSN,[_timeDate GetSystemTimeSeconds]];
    //文件路径
    NSString* strFilePath=[[configPlist ReadDictionary:CONFIG_FILE_PATH_NAME] objectForKey:CONFIG_TEST_LOG_PATH];
    //Write Test log file
    //[[TestLog Instance] SetFilePath:strFilePath  andFileName:strFileName];
    //设置pdca文件路2efb.pi;

    isTestResultPass=YES;
    
    [[BYDSFCManager Instance] setSFCErrorType:SFC_Default];
}

//SFC检测上传sn
-(BOOL)StepSFC_CheckUploadSN:(BOOL)isUploadSFC
{
    BOOL flag=YES;
    
    //检测是否需要上传SFC
    if(isUploadSFC)
    {
        flag=NO;
//        [[BYDSFCManager Instance]setStrLogFileText:@""];
        [[BYDSFCManager Instance] setSFCCheckType:e_SN_CHECK];
        [[BYDSFCManager Instance] checkSerialNumber:_strSN];
        
        switch ([[BYDSFCManager Instance] SFCErrorType])
        {
            case SFC_StayInNextStation:_strErrorMessage=@"测试已经过站";
                break;
            case SFC_StayInFrontStation:_strErrorMessage=@"测试前一工站还没测";
                break;
            case SFC_OutOfTestCount:_strErrorMessage=@"测试已经超过上传次数";
                break;
            case SFC_SN_Error:_strErrorMessage=@"SN错误,此类错误是由于前面站还没测引起的";
                break;
            case SFC_ErrorNet:_strErrorMessage=@"网络链接错误";
                break;
            case SFC_TimeOut_Error:_strErrorMessage=@"SFC超时错误";
                break;
            case SFC_Exist_Error:_strErrorMessage=@"BDA绑定错误";
                break;
            case SFC_Success:
            {
                flag=YES;
            }
                break;
            case SFC_Default:
            default:_strErrorMessage=@"其它错误";
                break;
        }
        
        if(!flag)
        {
            flag=YES;//复位治具
            //复位治具
//            [[FixtureDevice Instance] WriteLine:nil andCmd:[[[testScriptPlist ReadDictionary:FIXTURE_ACTION] objectForKey:FIXTURE_RESET] objectForKey:COMMAND_TEST_COMMAND]];
        }
        else
        {
            time(&tmStart);
        }
    }
    
    return flag;
}





//SFC检测上传结果
-(BOOL)StepSFC_CheckUploadResult:(BOOL)isUploadSFC  andIsTestPass:(BOOL)isTestPass andFailMessage:(NSString*)strMessage
{
    BOOL flagUploadResult=YES;

    if(isUploadSFC)
    {
        [[BYDSFCManager Instance] setSFCCheckType:e_COMPLETE_RESULT_CHECK];
        time(&tmStop);
        
        if(isTestPass)
        {
            int count= 0;
            do
            {
                flagUploadResult=[[BYDSFCManager Instance] checkComplete:_strSN result:@"PASS"
                                        startTime:tmStart endTime:tmStop   failMessage:@""];
                [NSThread sleepForTimeInterval:0.5];
                count++;
            }
            while (count<3 && !flagUploadResult);

        }
        else
        {
            flagUploadResult=[[BYDSFCManager Instance] checkComplete:_strSN result:@"FAIL"
                            startTime:tmStart endTime:tmStop failMessage:strMessage];
        }
    }
    
    return flagUploadResult;
}




//延时
-(void)DelayTime:(int)time
{
    HiperTimer* timer=[[HiperTimer alloc] init];
    [timer Start];
    while ([timer durationMillisecond]<time);
    [timer release];
}







//往偶数字符串中插入空格
-(NSMutableString *)appendingWithNull:(NSString *)string
{
    
    NSMutableString  * str1=[[NSMutableString alloc]init];
    NSMutableString  * str2=[[NSMutableString alloc]init];
    NSMutableString  * str3=[[NSMutableString alloc]init];
    
    for (int i=0; i<[string length]/2; i++)
    {
        str1=[NSMutableString stringWithString:[string substringWithRange:NSMakeRange(i*2, 2)]];
        [str1 appendString:@" "];
        
        [str2 appendString:str1];
    }
    
    
    if ([str2 length]>=17)
    {
       str3=(NSMutableString *)[str2 substringWithRange:NSMakeRange(0, 17)];
    }
    else
    {
       str3=[NSMutableString new];
        
    }
    
    return str3;
}




//获取特定位置，并截取字符串
-(NSString *)getStringFromString:(NSString *)textString
{

    NSRange range=[textString rangeOfString:@"0000:"];

    
    NSString * str2=[textString substringWithRange:NSMakeRange(range.location+6, 8)];



    return str2;
}




//将16进制的字符串转化为byte数组
-(NSData*) hexToBytes:(NSString *)hexString {
    
    NSMutableData* data = [NSMutableData data];
    
    int idx;
    
    for (idx = 0; idx+2 <= hexString.length; idx+=2) {
        
        NSRange range = NSMakeRange(idx, 2);
        
        NSString* hexStr = [hexString substringWithRange:range];
        
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        
        unsigned int intValue;
        
        [scanner scanHexInt:&intValue];
        
        [data appendBytes:&intValue length:1];
        
    }
    
    return data;
    
}



@end
