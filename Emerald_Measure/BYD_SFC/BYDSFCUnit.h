//
//  BYDSFCUnit.h
//  PDCA_Demo
//
//  Created by CW-IT-MB-046 on 14-12-25.
//  Copyright (c) 2014年 CW-IT-MB-046. All rights reserved.
//

#import <Foundation/Foundation.h>

#define fileOfSFCConfig @"SFCConfig"

#define cPASS "PASS"
#define cFAIL "FAIL"

/*
 * list_of_failing_tests
 */
#define NC_FCT1_KEY     @"NC-FCT1-KEY"
#define NC_FCT1_VOLTAGE @"NC-FCT1-VOLTAGE"
#define NC_FCT1_POWERON @"NC-FCT1-POWERON"
#define NC_FCT1_CURRENT @"NC-FCT1-CURRENT"
#define NC_HUNG3        @"NC-HUNG3";

/*
 * SFC key name
 */

//#define SFC_MES_SERVER_IP       @"MES Server IP"
//#define SFC_NETWORK_PORT        @"net_port"

//#define SFC_J_USERNAME          @"j_username"
//#define SFC_PASSWORD            @"password"
//#define SFC_SITE                @"site"
//#define SFC_OPERATION           @"operation"
//#define SFC_RESOURCE            @"resource"
//#define SFC_CTYPE               @"c"
//#define SFC_TEST_STATIION_NAME  @"test_station_name"
//#define SFC_STATION_ID          @"station_id"        // 该工站编号
//#define SFC_PRODUCT             @"product"
//#define SFC_STATION_NUMBER      @"one_multiple"     // 该工站数目
//#define SFC_SERIAL_NUBMER       @"sn"
//#define SFC_HOST_MAC_ADDRESS    @"mac_address"
//#define SFC_FINALLY_RESULT      @"result"
//#define SFC_START_TIME          @"start_time"
//#define SFC_STOP_TIME           @"stop_time"
//#define SFC_FAIL_LIST           @"list_of_failing_tests"
//#define SFC_FAILURE_MESSAGE     @"failure_message"
//#define SFC_SW_VERSION          @"sw_version"

#define SFC_TEST_STATION_NAME       @"test_station_name"
#define SFC_TEST_STATION_ID         @"station_id"
#define SFC_TEST_SN                 @"sn"
#define SFC_TEST_C_TYPE             @"c"
#define SFC_TEST_MAC_ADDRESS        @"mac_address"
#define SFC_TEST_SW_VERSION         @"sw_version"
#define SFC_TEST_PRODUCT            @"product"
#define SFC_TEST_RESULT             @"result"
#define SFC_TEST_START_TIME         @"start_time"
#define SFC_TEST_STOP_TIME          @"stop_time"
#define SFC_TEST_FAIL_LIST          @"list_of_failing_tests"
#define SFC_TEST_FAIL_MESSAGE       @"failure_message"
#define SFC_TEST_BDA                @"bda"
#define SFC_TEST_P_TYPE             @"p"

typedef enum eRecordType
{
    eADD_RECORD,
}eType;

@interface BYDSFCUnit : NSObject
{
    NSString* _MESServerIP;
    NSString* _BDAServerIP;
    NSNumber* _netPort;
    NSString* _username;
    NSString* _password;
    NSNumber* _site;
    NSString* _operation;
    NSString* _resource;
    NSString* _cType;
    NSString* _stationName;
    NSString* _stationID;
    NSString* _product;
    NSNumber* _numberOfStation;
    NSString* _macAddress;
    NSString* _swVersion;
}

@property(readwrite, copy) NSString* MESServerIP;
@property(readwrite,copy)  NSString* BDAServerIP;
@property(readwrite, copy) NSNumber* netPort;
@property(readwrite, copy) NSString* username;
@property(readwrite, copy) NSString* password;
@property(readwrite, copy) NSNumber* site;
@property(readwrite, copy) NSString* operation;
@property(readwrite, copy) NSString* resource;
@property(readwrite, copy) NSString* cType;
@property(readwrite, copy) NSString* stationName;
@property(readwrite, copy) NSString* stationID;
@property(readwrite, copy) NSString* product;
@property(readwrite, copy) NSNumber* numberOfStation;
@property(readwrite, copy) NSString* macAddress;
@property(readwrite, copy) NSString* swVersion;


//GetIP
-(NSString*)GetServerIP;

//Get net port
-(NSNumber*) GetNetPort;

//get mac address
- (NSString *) GetMacAddress;

//set version
- (NSString *) swVersion;

@end
