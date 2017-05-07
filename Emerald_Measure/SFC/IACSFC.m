//
//  IACSFC.m
//  FunctionTest
//
//  Created by ViKing Lai on 15/10/6.
//  Copyright (c) 2015年 ViKing Lai. All rights reserved.
//

#import "IACSFC.h"

static IACSFC *iacSFC=nil;

@implementation IACSFC
@synthesize strB235SerialNumber=_strB235SerialNumber;
@synthesize strBatterySNNumber=_strBatterySNNumber;
@synthesize strE75FlexNumber=_strE75FlexNumber;
@synthesize strSensorFlexNumber=_strSensorFlexNumber;
@synthesize strSBuild=_strSBuild;
@synthesize strMLBSNumber=_strMLBSNumber;
@synthesize strSBuildUnit=_strSBuildUnit;
@synthesize strModuleSN=_strModuleSN;

-(id)init{
    if (self=[super init]) {
//        iacMayfis=[[IACP_MAYFIS alloc] init];
        _strB235SerialNumber=[[NSString alloc] init];
        _strBatterySNNumber=[[NSString alloc] init];
        _strE75FlexNumber=[[NSString alloc] init];
        _strSensorFlexNumber=[[NSString alloc] init];
        _strSBuild=[[NSString alloc] init];
        _strMLBSNumber=[[NSString alloc] init];
        _strSBuildUnit=[[NSString alloc] init];
        _strModuleSN=[[NSString alloc] init];
    }
    
    return self;
}

+(IACSFC*)Instance{
    if (iacSFC==nil) {
        iacSFC=[[IACSFC alloc] init];
    }
    
    return iacSFC;
}

-(void)dealloc{
 
    iacSFC=nil;
    
    _strB235SerialNumber=nil;
    
    _strBatterySNNumber=nil;
    
    _strE75FlexNumber=nil;
    
    _strSensorFlexNumber=nil;
    
    _strSBuild=nil;
    
    _strMLBSNumber=nil;
    
    _strSBuildUnit=nil;
    
    _strModuleSN=nil;
}


-(BOOL)QueryAttributeValue:(enum SFCQueryType)sfcType
      acpSerialNumber:(const char *)acpSerialNumber
              timeOut:(int)timeOut{
    BOOL flag=NO;
    NSString* strKey=@"";
    switch (sfcType) {
        case SFC_Query_Battery_SN:strKey=@"battery_sn";
            break;
        case SFC_Query_E75_SN:strKey=@"flex_2";
            break;
        case SFC_Query_MLB_SN:strKey=@"mlbsn";
            break;
        case SFC_Query_Sensor_SN:strKey=@"flex_1";
            break;
        case SFC_Query_S_Build:strKey=@"sbuild";
            break;
        case SFC_Query_S_Build_Unit:strKey=@"sbuild_unit";
            break;
        case SFC_Query_SerialNumber:strKey=@"fgsn";
            break;
        case SFC_Query_Module_SN:strKey=@"flex_3";
            break;
        default:
            break;
    }
    
    int aiSize=1;
    struct QRStruct * apQRStruct[2];
    
    for (int i=0; i<aiSize; i++)
    {
        apQRStruct[i]=(struct QRStruct *)malloc(sizeof(struct QRStruct));
        
        if (apQRStruct[i]!=nil)
        {
            (*apQRStruct[i]).Qkey=(char *)malloc(sizeof(char)*10);
            memset((*apQRStruct[i]).Qkey, 0, sizeof(char)*10);
            strcpy((*apQRStruct[i]).Qkey, [strKey UTF8String]);
            (*apQRStruct[i]).Qval=(char *)malloc(sizeof(char)*18);
            memset((*apQRStruct[i]).Qval, 0, sizeof(char)*18);
        }
    }
    
    float time = 0;
    NSString *value=@"";
    
    while (time < timeOut/1000.0)
    {
        SFCQueryRecord(acpSerialNumber,apQRStruct,aiSize);
        value = [NSString stringWithUTF8String:(*apQRStruct[0]).Qval];
        
        if (value!=nil && value.length>0) {
            switch (sfcType) {
                case SFC_Query_Battery_SN:[self setStrBatterySNNumber:value];
                    break;
                case SFC_Query_E75_SN:[self setStrE75FlexNumber:value];
                    break;
                case SFC_Query_MLB_SN:[self setStrMLBSNumber:value];
                    break;
                case SFC_Query_Sensor_SN:[self setStrSensorFlexNumber:value];
                    break;
                case SFC_Query_S_Build:[self setStrSBuild:value];
                    break;
                case SFC_Query_S_Build_Unit:[self setStrSBuildUnit:value];
                    break;
                case SFC_Query_SerialNumber:[self setStrB235SerialNumber:value];
                    break;
                case SFC_Query_Module_SN:[self setStrModuleSN:value];
                    break;
                default:
                    break;
            }
            
            flag=YES;
            break;
        }
        
        [NSThread sleepForTimeInterval:0.01];
        time += 0.1;
    }
    
    free(apQRStruct[0]);
    return flag;
}



-(NSString*)QueryAttribute:(char *)acpQueryKey
           acpSerialNumber:(const char *)acpSerialNumber
                   timeOut:(int)timeOut{
    int aiSize=1;
    struct QRStruct * apQRStruct[2];
    
    for (int i=0; i<aiSize; i++)
    {
        apQRStruct[i]=(struct QRStruct *)malloc(sizeof(struct QRStruct));
        
        if (apQRStruct[i]!=nil)
        {
            (*apQRStruct[i]).Qkey=(char *)malloc(sizeof(char)*10);
            memset((*apQRStruct[i]).Qkey, 0, sizeof(char)*10);
            strcpy((*apQRStruct[i]).Qkey, acpQueryKey);
            
            (*apQRStruct[i]).Qval=(char *)malloc(sizeof(char)*18);
            memset((*apQRStruct[i]).Qval, 0, sizeof(char)*18);
        }
    }
    
    float time = 0;
    NSString *value=@"";
    
    while (time < timeOut/1000.0)
    {
        SFCQueryRecord(acpSerialNumber,apQRStruct,aiSize);
        value = [NSString stringWithUTF8String:(*apQRStruct[0]).Qval];
        
        if (value!=nil && value.length>0) {
            break;
        }
        
        [NSThread sleepForTimeInterval:0.01];
        time += 0.1;
    }
    
    
//    NSString *value = [[NSString alloc] initWithUTF8String:(*apQRStruct[0]).Qval];
    free(apQRStruct[0]);
    return value;
}


-(void)AddRecord:(NSString *)acpQueryKey
   acpQueryValue:(NSString *)acpQueryValue
 acpSerialNumber:(const char *)acpSerialNumber{
    int aiSize=1;
    struct QRStruct * apQRStruct[2];
    
    for (int i=0; i<aiSize; i++)
    {
        apQRStruct[i]=(struct QRStruct *)malloc(sizeof(struct QRStruct));
        
        if (apQRStruct[i]!=nil)
        {
            (*apQRStruct[i]).Qkey=(char *)malloc(sizeof(char)*10);
            memset((*apQRStruct[i]).Qkey, 0, sizeof(char)*10);
            strcpy((*apQRStruct[i]).Qkey, [acpQueryKey UTF8String]);
            
            (*apQRStruct[i]).Qval=(char *)malloc(sizeof(char)*18);
            memset((*apQRStruct[i]).Qval, 0, sizeof(char)*18);
            strcpy((*apQRStruct[i]).Qval, [acpQueryValue UTF8String]);
        }
    }
    
    SFCQueryRecord(acpSerialNumber,apQRStruct,aiSize);
    free(apQRStruct[0]);
}


-(void)ClearData{
    self.strB235SerialNumber=@"";
    self.strSensorFlexNumber=@"";
    self.strE75FlexNumber=@"";
    self.strBatterySNNumber=@"";
    self.strMLBSNumber=@"";
}

@end
