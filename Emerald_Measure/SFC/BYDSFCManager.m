//
//  BYDSFCManager.m
//  PDCA_Demo
//
//  Created by CW-IT-MB-046 on 14-12-25.
//  Copyright (c) 2014年 CW-IT-MB-046. All rights reserved.
//

#import "BYDSFCManager.h"

static BYDSFCManager* bydSFC=nil;

@implementation BYDSFCManager
@synthesize SFCErrorType=_SFCErrorType;
@synthesize errorMessage = _errorMessage;
@synthesize SFCCheckType=_SFCCheckType;
@synthesize strUpdateBDA=_strUpdateBDA;  //获取产品的BDA
@synthesize strMSEBDA=_strMSEBDA;        //服务器BDA
@synthesize ServerFCKey=_ServerFCKey;    //


- (id) init
{
    if (self = [super init])
    {
        _unit = [[BYDSFCUnit alloc] init];
        configPlist=[[PlistFile alloc] init:PLIST_CONFIG_FILE_NAME];
        
        if (configPlist != nil)
        {
            _ServerFCKey=@"ServerFC_0";
            [self getUnitValue];
            
            
        }
    
        _errorMessage = @"";
        _strSN=[[NSString alloc] init];
        _strUpdateBDA=[[NSString alloc] init];
    }
    
    return self;
}


//Create static instance
+(BYDSFCManager*)Instance
{
    if(bydSFC==nil)
    {
        bydSFC=[[BYDSFCManager alloc] init];
    }
    
    return bydSFC;
}

//create an url
- (NSString *) createURL:(enum eSFC_Check_Type)sfcCheckType
                      sn:(NSString *)sn
              testResult:(NSString *)result
               startTime:(NSString *)tmStartStr
                 endTime:(NSString *)tmEndStr
               bdaSerial:(NSString*)strbdaSerial
           faiureMessage:(NSString *)failMsg

{
//    NSMutableString* urlString = [NSMutableString stringWithFormat:@"http://%@:%@/manufacturing/BobcatIntegerationServlet?",(sfcCheckType==e_BDA_VERIFY_CHECK)?_unit.BDAServerIP:_unit.MESServerIP, _unit.netPort];          // ip and port
    
     NSMutableString* urlString = [NSMutableString stringWithFormat:@"http://%@:%@/manufacturing/BobcatIntegerationServlet?",_unit.MESServerIP, _unit.netPort];          // ip and port
    

//    NSString* strStationID=[[PDCA Instance] GetStationID];
    NSString *strStationID = @"MK_Test_Station";

    
    switch (sfcCheckType)
    {
        case e_SN_CHECK:
        {
            [urlString appendFormat:@"%@=%@&",SFC_TEST_STATION_NAME,_unit.stationName];
            [urlString appendFormat:@"%@=%@&", SFC_TEST_STATION_ID, strStationID];
            [urlString appendFormat:@"%@=%@&", SFC_TEST_SN, sn];
            [urlString appendFormat:@"%@=%@",SFC_TEST_C_TYPE,@"validate"];
        }
            break;
        case  e_COMPLETE_RESULT_CHECK:
        {
            [urlString appendFormat:@"%@=%@&",SFC_TEST_STATION_NAME,_unit.stationName];
            [urlString appendFormat:@"%@=%@&", SFC_TEST_STATION_ID, strStationID];
            [urlString appendFormat:@"%@=%@&", SFC_TEST_SN, sn];
            [urlString appendFormat:@"%@=%@&",SFC_TEST_C_TYPE,[[configPlist ReadDictionary:CONFIG_SFC] objectForKey:CONFIG_SFC_CTYPE]];
            [urlString appendFormat:@"%@=%@&",SFC_TEST_MAC_ADDRESS,[_unit GetMacAddress]];
            
//            if ([result compare:@cFAIL] != NSOrderedSame)
//            {
                [urlString appendFormat:@"%@=%@&",SFC_TEST_SW_VERSION,[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
//            }
            
            [urlString appendFormat:@"%@=%@&",SFC_TEST_PRODUCT,[[configPlist ReadDictionary:CONFIG_SFC] objectForKey:CONFIG_SFC_PRODUCT]];
            [urlString appendFormat:@"%@=%@&",SFC_TEST_RESULT,result];
            [urlString appendFormat:@"%@=%@&",SFC_TEST_START_TIME,tmStartStr];
            [urlString appendFormat:@"%@=%@",SFC_TEST_STOP_TIME,tmEndStr];
            
            if ([result compare:@cFAIL] == NSOrderedSame)
            {
                [urlString appendFormat:@"&%@=%@", SFC_TEST_FAIL_LIST, NC_FCT1_KEY]; // fail type
                
                if ([failMsg length]>512)
                {
                    [failMsg substringToIndex:512];
                }
                
                [urlString appendFormat:@"&%@=%@", SFC_TEST_FAIL_MESSAGE, failMsg];
            }
        }
            break;
        case e_BDA_RESULT_CHECK:
        {
            [urlString appendFormat:@"%@=%@&", SFC_TEST_SN, sn];
            [urlString appendFormat:@"%@=%@&",SFC_TEST_C_TYPE,@"ADD_ATTR"];
            [urlString appendFormat:@"%@=%@&",SFC_TEST_MAC_ADDRESS,[_unit GetMacAddress]];
            [urlString appendFormat:@"%@=%@&",SFC_TEST_START_TIME,tmStartStr];
            [urlString appendFormat:@"%@=%@",SFC_TEST_BDA,strbdaSerial];
        }
            break;
            
        //**************************2016/8/6************************************************
        case e_BDA_QUERY_CHECK:
        {
            [urlString appendFormat:@"%@=%@&", SFC_TEST_SN, sn];
            [urlString appendFormat:@"%@=%@&",SFC_TEST_C_TYPE,@"QUERY_RECORD"];
            [urlString appendFormat:@"%@=%@",SFC_TEST_P_TYPE,@"assignbda"];
            
        }
            break;
        //**************************end*****************************************************
        case e_BDA_VERIFY_CHECK:
        {
            [urlString appendFormat:@"%@=%@&", SFC_TEST_SN, sn];
            [urlString appendFormat:@"%@=%@&",SFC_TEST_C_TYPE,@"QUERY_RECORD"];
            [urlString appendFormat:@"%@=%@",SFC_TEST_P_TYPE,@"bda"];
            _strUpdateBDA=strbdaSerial;
            [self setStrUpdateBDA:strbdaSerial];
        }
            break;
        default:
            break;
    }

    return urlString;
}


- (BOOL) submit:(NSString *)urlString
{
    BOOL flag = NO;
    _isCheckPass = NO;
//    [[TestLog Instance] WriteLogResult:[GetTimeDay GetCurrentTime] andText:urlString];
    NSString* url = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    if (!urlRequest)
    {
        _errorMessage = [_errorMessage stringByAppendingString:@"error: Cann't connect the server.\r\n"];
        flag = NO;
        return flag;
    }
    
    [urlRequest setTimeoutInterval:10];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [urlRequest setNetworkServiceType:NSURLNetworkServiceTypeBackground];
    [urlRequest setHTTPMethod:@"POST"];
    
    // 单独处理请求任务
    NSThread* thrdSumbit = [[NSThread alloc] initWithTarget:self
            selector:@selector(handleHttpRequest:)object:urlRequest];
   
    if ([NSURLConnection canHandleRequest:urlRequest])
    {
        [thrdSumbit start];
    }
    
    // set timeout, timeout = 5s
    float time = 0;
    while (time < 5)
    {
        if (_isCheckPass)
        {
            if (_SFCErrorType==SFC_Success)
            {
                flag=YES;
            }

            break;
        }
        
        [NSThread sleepForTimeInterval:0.01];
        time += 0.1;
    }
    
    if (time==5 &&_SFCErrorType!=SFC_Success)
    {
        _SFCErrorType=SFC_TimeOut_Error;
    }
    
    return flag;
}

- (void) handleHttpRequest:(NSURLRequest *)urlRequest
{
    _isCheckPass = NO;
    [NSThread sleepForTimeInterval:0.3];
    NSData* byteRequest = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
    NSString* backFromHttpStr = [[NSString alloc] initWithData:byteRequest encoding:NSUTF8StringEncoding];
    NSLog(@"HttpBackValue:%@",backFromHttpStr);
    
    NSMutableString* strLogFile=[[NSMutableString alloc] initWithFormat:@"HttpBackValue:%@\r\n",backFromHttpStr];

    if ([backFromHttpStr length]<1)
    {
        _SFCErrorType=SFC_ErrorNet;
    }
    else if([backFromHttpStr containsString:@"SFC_OK"])
    {
        if (_SFCCheckType==e_BDA_VERIFY_CHECK)
        {
             NSString* strBDARegex=[Regex RegexStrResult:backFromHttpStr andRegex:@"(?<==)(\\w*)(?=)"];
             strBDARegex=[strBDARegex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
             NSLog(@"regex bda:%@",strBDARegex);
             NSLog(@"Update bda:%@",_strUpdateBDA);
            [strLogFile appendFormat:@"regex bda:%@\r\n",strBDARegex];
            [strLogFile appendFormat:@"Update bda:%@\r\n",_strUpdateBDA];
            
            if ([strBDARegex isEqualToString:_strUpdateBDA])
            {
                _SFCErrorType=SFC_Success;
                NSLog(@"upload bda is equal to http back bda");
                [strLogFile appendString:@"upload bda is equal to http back bda\r\n"];
            }
            else
            {
                _SFCErrorType=SFC_BDA_Not_Regex_SN;
                NSLog(@"upload bda is not equal to http back bda");
                [strLogFile appendString:@"upload bda is not equal to http back bda\r\n"];
            }
        }
        
        //*******************************2016/8/6*************************************************************
        else if (_SFCCheckType==e_BDA_QUERY_CHECK)
        {
            NSString* strBDARegex=[Regex RegexStrResult:backFromHttpStr andRegex:@"(?<==)(\\w*)(?=)"];
            strBDARegex=[strBDARegex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [[BYDSFCManager Instance]setStrMSEBDA:strBDARegex];
            NSLog(@"====================%@",[BYDSFCManager Instance].strMSEBDA);
            [strLogFile appendFormat:@"query bda:%@\r\n",strBDARegex];
            _SFCErrorType=SFC_Success;
        }
        //*******************************2016/8/6*************************************************************
        else
        {
            _SFCErrorType=SFC_Success;
        }
    }
    else if ([Regex RegexBoolResult:backFromHttpStr andRegex:@"Done"])
    {
        _SFCErrorType =SFC_SN_Error;
    }
    else if ([Regex RegexBoolResult:backFromHttpStr andRegex:@"ERROR"])
    {
        NSString* strResult=[Regex RegexStrResult:backFromHttpStr andRegex:@"(?<=：)(.*?)(?=,)"];
        
        if ([Regex RegexBoolResult:strResult andRegex:[[configPlist ReadDictionary:CONFIG_SFC] objectForKey:CONFIG_SFC_FRONT_STATION_NAME]])
        {
            _SFCErrorType=SFC_StayInFrontStation;
        }
        else if ([Regex RegexBoolResult:strResult andRegex:[[configPlist ReadDictionary:CONFIG_SFC] objectForKey:CONFIG_SFC_NEXT_STATION_NAME]])
        {
            if (_SFCCheckType==e_COMPLETE_RESULT_CHECK)
            {
                _SFCErrorType=SFC_Success;
                NSLog(@"This is check Test result");
                [strLogFile appendString:@"This is check Test result\r\n"];
            }
            else
            {
               _SFCErrorType=SFC_StayInNextStation;
                 NSLog(@"This is check SN");
                [strLogFile appendString:@"This is check SN\r\n"];
            }
        }
        else if([Regex RegexBoolResult:backFromHttpStr andRegex:@"Exceeded"])
        {
            _SFCErrorType=SFC_OutOfTestCount;
        }
        else if([Regex RegexBoolResult:backFromHttpStr andRegex:@"exist"])
        {
            NSString* strBackBindSN=[Regex RegexStrResult:backFromHttpStr andRegex:@"(?<==)(.*?)(?=;)"];
            
            if (strBackBindSN!=nil && [strBackBindSN isEqualToString:_strSN])
            {
                _SFCErrorType=SFC_Success;
                NSLog(@"BDA Binding success");
                [strLogFile appendString:@"BDA Binding success\r\n"];

            }
            else
            {
                 _SFCErrorType=SFC_Exist_Error;
                 NSLog(@"BDA Binding error");
                [strLogFile appendString:@"BDA Binding error\r\n"];
            }
        }
        
        else
        {
            _SFCErrorType=SFC_SN_Error;
        }
    }
    
    _isCheckPass = YES;

    [NSThread exit];
}

- (NSString *) timeToStr:(time_t)time
{
    struct tm* tm = localtime(&time);
    return [NSString stringWithFormat:@"%d-%d-%d %d:%d:%d", (tm->tm_year + 1900), (tm->tm_mon + 1),
            tm->tm_mday, tm->tm_hour, tm->tm_min, tm->tm_sec];
}



- (BOOL) checkSerialNumber:(NSString *)sn
{
    NSString* url = [self createURL:e_SN_CHECK sn:sn testResult:nil
                          startTime:nil endTime:nil bdaSerial:nil faiureMessage:nil];
    NSLog(@"Check SerialNumber url:%@",url);
    return [self submit:url];
}

- (BOOL) checkComplete:(NSString *)sn
                result:(NSString *)result
             startTime:(time_t)tmStart
               endTime:(time_t)tmEnd
           failMessage:(NSString *)failMsg
{
    NSString* url = [self createURL:e_COMPLETE_RESULT_CHECK
                                 sn:sn testResult:result
                          startTime:[self timeToStr:tmStart]
                            endTime:[self timeToStr:tmEnd]
                            bdaSerial:nil
                      faiureMessage:failMsg];
    NSLog(@"CheckComplete url:%@",url);
    return [self submit:url];
}


-(void)getUnitValue{

    NSDictionary  * dic=[configPlist ReadDictionary:_ServerFCKey];
    
    _unit.MESServerIP = [dic objectForKey:CONFIG_SFC_SERVER_IP];
    _unit.BDAServerIP =[dic objectForKey:CONFIG_SFC_BDA_SERVER_IP];
    _unit.netPort     =[dic objectForKey:CONFIG_SFC_NET_PORT];
    _unit.stationID   =[dic objectForKey:CONFIG_SFC_STATION_ID];
    _unit.stationName =[dic objectForKey:CONFIG_SFC_STATION_NANE];
    _unit.cType       =[dic objectForKey:CONFIG_SFC_CTYPE];
    _unit.product     =[dic objectForKey:CONFIG_SFC_PRODUCT];
    

}


@end
