//
//  pudding.h
//  DFU
//
//  Created by TOD on 2/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "InstantPudding_API.h"


@interface pudding : NSObject 
{
@private
	IP_UUTHandle UID;
	IP_API_Reply reply;
	IP_TestSpecHandle testSpec;
	IP_TestResultHandle testResult;
	
	NSString* ErrorInfo;
	NSString* DoneErrorInfo;
	NSString* CommitErrorInfo;
	NSString* UartFileLog;
	NSString* DCSDFileLog;
}

@property(readwrite,copy) NSString* ErrorInfo;
@property(readwrite,copy) NSString* DoneErrorInfo;
@property(readwrite,copy) NSString* CommitErrorInfo;
@property(readwrite,copy) NSString* UartFileLog;
@property(readwrite,copy) NSString* DCSDFileLog;

-(BOOL) UUTStartTest;

-(BOOL) ValidateSerialNumber:(NSString*)sn;
-(BOOL) ValidateAMIOK:(NSString *)sn;
-(BOOL) AddAttribute:(NSString*) attributeName AttributeValue:(NSString*) attributeValue;
-(BOOL) AddBlob:(NSString*) fileName FilePath:(NSString*) filePath;
-(BOOL) SetStartTime:(time_t) startTime;
-(BOOL) SetEndTime:(time_t) endTime;
-(BOOL) UUTRelease;

-(NSString*) GetFailInfomation;
-(NSString*) GetSITEInfo;
-(NSString*)GetStationType;
-(NSString*)GetStationID;

-(BOOL) AddTestItem:(NSString*)itemName TestValue:(NSString*)testValue
		 TestResult:(NSString*)tr ErrorInfo:(NSString*)errorInfo Priority:(NSString*)priority;


-(BOOL) AddTestItemAndSubItems:(NSString*)itemName SubItems:(NSArray*)subItems TestValues:(NSArray*)testValues 
				   TestResults:(NSArray*)tesetResults ErrorInfoes:(NSArray*)errorInfoes Priorities:(NSArray*)priorities;

-(BOOL) AddTestItemAndSubItems:(NSString*)itemName SubItems:(NSArray*)subItems 
					LowerSpecs:(NSArray*)lowerSpecs UpperSpecs:(NSArray*)upperSpecs Units:(NSArray*)units
					TestValues:(NSArray*)testValues TestResults:(NSArray*)tesetResults 
				   ErrorInfoes:(NSArray*)errorInfoes Priorities:(NSArray*)priorities;

-(BOOL) AddTestItem:(NSString*)itemName 
		  LowerSpec:(NSString*)lowerSpec UpperSpec:(NSString*)upperSpec Unit:(NSString*)unit
		  TestValue:(NSString*)testValue TestResult:(NSString*)tr
		  ErrorInfo:(NSString*)errorInfo Priority:(NSString*)priority;

@end
