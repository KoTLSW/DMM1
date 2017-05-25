//
//  BYDSFCManager.h
//  PDCA_Demo
//
//  Created by CW-IT-MB-046 on 14-12-25.
//  Copyright (c) 2014年 CW-IT-MB-046. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BYDSFCUnit.h"
#import "PlistFile.h"
//#import "PDCA.h"
#import "Macro.h"//￼
#import <Regex/Regex.h>


// 指定的检查类型
enum eSFC_Check_Type
{
    e_SN_CHECK,
    e_COMPLETE_RESULT_CHECK,
    e_BDA_RESULT_CHECK,
    e_BDA_VERIFY_CHECK,
    e_BDA_QUERY_CHECK,//给产品分配BDA
};

//
enum eSFC_Back_Type
{
    SFC_Success,        //
    SFC_BDA_Not_Regex_SN,
    SFC_Exist_Error,
    SFC_OutOfTestCount,//
    SFC_StayInNextStation,  //
    SFC_StayInFrontStation,
    SFC_ErrorNet,               //网络错误
    SFC_SN_Error,               //SN错误
    SFC_TimeOut_Error,          //超时错误
    SFC_Default,
};

@interface BYDSFCManager : NSObject
{
    PlistFile* configPlist;
    BYDSFCUnit* _unit;
    NSString* _errorMessage;
    BOOL _isCheckPass;
    enum eSFC_Back_Type  _SFCErrorType;
    enum eSFC_Check_Type _SFCCheckType;
    NSString* _strSN;
    NSString* _strUpdateBDA;

}


@property(readwrite)enum eSFC_Back_Type  SFCErrorType;
@property(readwrite)enum eSFC_Check_Type SFCCheckType;
@property(readwrite,copy)NSString   * strSN;
@property(readwrite,copy)NSString   * strUpdateBDA;
@property(readwrite,copy)NSString   * strMSEBDA;
@property(nonatomic,strong)NSString * ServerFCKey;
@property(readonly, nonatomic) NSString* errorMessage;



+(BYDSFCManager*)Instance;



- (NSString *) createURL:(enum eSFC_Check_Type)sfcCheckType
                      sn:(NSString *)sn
              testResult:(NSString *)result
               startTime:(NSString *)tmStartStr
                 endTime:(NSString *)tmEndStr
               bdaSerial:(NSString*)strbdaSerial
           faiureMessage:(NSString *)failMsg;
/*!
 * @abstract    错误消息
 */


/*!eSFC_Check_Type
 * @abstract    在SFC系统中检测指定的Serial Number产品是否已经通过测试
 * @param   sn  产品序列号
 */
- (BOOL) checkSerialNumber:(NSString *)sn;


/*!
 * @abstract    上传最终测试结果至SFC系统
 * @param   sn      产品序列号
 * @param   result  最终测试结果
 * @param   tmStart 开始测试时的时间
 * @param   tmEnd   结束测试时的时间
 * @param   failMsg 错误信息
 
 */
- (BOOL) checkComplete:(NSString *)sn
                result:(NSString *)result
             startTime:(time_t)tmStart
               endTime:(time_t)tmEnd
           failMessage:(NSString *)failMsg;




-(void)getUnitValue;


@end
