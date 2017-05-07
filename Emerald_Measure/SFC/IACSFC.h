//
//  IACSFC.h
//  FunctionTest
//
//  Created by ViKing Lai on 15/10/6.
//  Copyright (c) 2015年 ViKing Lai. All rights reserved.
//

#ifndef IACSFC_H_H
#define IACSFC_H_H

#import <Foundation/Foundation.h>
#import "HiperTimer.h"
#import "TypeConverter.h"
#import "IPSFCPost_API.h"


enum SFCQueryType{
    SFC_Query_Battery_SN,
    SFC_Query_E75_SN,
    SFC_Query_Sensor_SN,
    SFC_Query_MLB_SN,
    SFC_Query_S_Build,
    SFC_Query_S_Build_Unit,
    SFC_Query_SerialNumber,
    SFC_Query_Module_SN,
};

enum SFCUploadType{
    SFC_CHECK_STATION_SN,
    SFC_UPLOAD_RESULT,
    SFC_UPLOAD_FAIL_ITEM,
};

@interface IACSFC : NSObject{
//    IACP_MAYFIS *iacMayfis;
    NSString* _strB235SerialNumber;
    NSString* _strSensorFlexNumber;
    NSString* _strE75FlexNumber;
    NSString* _strBatterySNNumber;
    NSString* _strSBuild;
    NSString* _strMLBSNumber;
    NSString* _strSBuildUnit;
    NSString* _strModuleSN;
}

@property(readwrite,copy)NSString* strSBuildUnit;
@property(readwrite,copy)NSString* strB235SerialNumber;
@property(readwrite,copy)NSString* strSensorFlexNumber;
@property(readwrite,copy)NSString* strE75FlexNumber;
@property(readwrite,copy)NSString* strBatterySNNumber;
@property(readwrite,copy)NSString* strSBuild;
@property(readwrite,copy)NSString* strMLBSNumber;
@property(readwrite,copy)NSString* strModuleSN;

+(IACSFC*)Instance;

-(NSString*)QueryAttribute:(char *)acpQueryKey
           acpSerialNumber:(const char *)acpSerialNumber
                   timeOut:(int)timeOut;

-(BOOL)QueryAttributeValue:(enum SFCQueryType)sfcType
           acpSerialNumber:(const char *)acpSerialNumber
                   timeOut:(int)timeOut;

-(void)AddRecord:(NSString *)acpQueryKey
   acpQueryValue:(NSString *)acpQueryValue
 acpSerialNumber:(const char *)acpSerialNumber;

-(void)ClearData;

@end


#endif
