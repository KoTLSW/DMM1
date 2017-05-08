//
//  pudding.m
//  DFU
//
//  Created by TOD on 2/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "pudding.h"


@implementation pudding

@synthesize ErrorInfo;
@synthesize DoneErrorInfo;
@synthesize CommitErrorInfo;
@synthesize UartFileLog;
@synthesize DCSDFileLog;

BOOL failedAtLeastOneTest;

-(id) init
{
	if (self = [super init])
    {
        ErrorInfo = [[NSString alloc] init];
        DoneErrorInfo = [[NSString alloc] init];
        CommitErrorInfo = [[NSString alloc] init];
        UartFileLog = [[NSString alloc] init];
        DCSDFileLog = [[NSString alloc] init];
        
        BOOL isDir = [[NSFileManager defaultManager] fileExistsAtPath:@"/vault/System-1A/ZIP" isDirectory:nil];
        
        if(!isDir)
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:@"/vault/System-1A/ZIP" withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
	
	return self;
}

- (void)dealloc
{	
	[ErrorInfo release];
	ErrorInfo = nil;
	
	[DoneErrorInfo release];
	DoneErrorInfo = nil;
	
	[CommitErrorInfo release];
	CommitErrorInfo = nil;
	
	[UartFileLog release];
	UartFileLog = nil;
	
	[DCSDFileLog release];
	DCSDFileLog =nil;
	
	[super dealloc];
}

-(BOOL) UUTStartTest
{
	BOOL flag = NO;
	failedAtLeastOneTest= NO;
	
	reply = IP_UUTStart(&UID);
	
	if(IP_success(reply))
	{
		[self setErrorInfo:@""];
		flag = YES;
	}
	else
	{
		[self setErrorInfo:[NSString stringWithUTF8String:IP_reply_getError(reply)]];
		flag = NO;
	}
	
	if (reply) 
	{
		IP_reply_destroy(reply);
		reply = NULL;
	}
	
	if (!flag)
	{
		if(UID)
		{
			IP_UID_destroy(UID);
			UID = NULL;
		}
	}
	
	return flag;
}

-(void) UIDCancel
{
	if(UID)
	{
		IP_UUTCancel(UID);
		UID = NULL;
	}
}

-(BOOL) ValidateSerialNumber:(NSString*)sn
{
	BOOL flag = NO;
	reply = IP_validateSerialNumber( UID, [sn UTF8String] );
	
	NSString* error =  [NSString stringWithUTF8String:IP_reply_getError(reply)];
	
	if((error != nil) && [error length] > 1 )
	{
		[self setErrorInfo:[NSString stringWithUTF8String:IP_reply_getError(reply)]];
		flag = NO;
	}
	else
	{
		[self setErrorInfo:@""];
		flag = YES;
	}
	
	if (reply) 
	{
		IP_reply_destroy(reply);
		reply = NULL;
	}
	
	if(!flag)
	{
		[self UIDCancel];
	}
	
	return flag;
}

-(BOOL) ValidateAMIOK:(NSString *)sn
{
	BOOL flag = NO;
	reply = IP_amIOkay( UID, [sn UTF8String] );
	
	if(IP_success(reply))
	{
		[self setErrorInfo:@""];
		flag = YES;
	}
	else
	{
		[self setErrorInfo:[NSString stringWithUTF8String:IP_reply_getError(reply)]];
		flag = NO;
	}
	
	if (reply) 
	{
		IP_reply_destroy(reply);
		reply = NULL;
	}
	
	if(!flag)
	{
		[self UUTRelease];
	}
	
	return flag;
}

-(BOOL) AddAttribute:(NSString*) attributeName AttributeValue:(NSString*) attributeValue
{
	BOOL flag = NO;
	reply = IP_addAttribute( UID, [attributeName UTF8String], [attributeValue UTF8String] );
	
	if(IP_success(reply))
	{
		[self setErrorInfo:@""];
		flag = YES;
	}
	else
	{
		[self setErrorInfo:[NSString stringWithUTF8String:IP_reply_getError(reply)]];
		flag = NO;
	}
	
	if (reply) 
	{
		IP_reply_destroy(reply);
		reply = NULL;
	}
	
	if(!flag)
	{
		[self UIDCancel];
	}
	
	return flag;
}

-(NSString*)GetStationType
{
    NSMutableString* result = [[NSMutableString alloc] initWithString:@""];
    
    BOOL flag = NO;
	size_t length = 0;
	char* stationType;
	reply = IP_getGHStationInfo(UID, IP_STATION_TYPE, NULL,&length);
    
    if (IP_success(reply))
    {
        IP_reply_destroy(reply);
        
        stationType = new char[length + 1];
        
        reply = IP_getGHStationInfo(UID, IP_STATION_TYPE, &stationType ,&length);
        
        if(IP_success(reply))
        {
            [self setErrorInfo:@""];
            flag = YES;
        }
        else
        {
            [self setErrorInfo:[NSString stringWithUTF8String:IP_reply_getError(reply)]];
            flag = NO;
        }
        
        if (reply)
        {
            IP_reply_destroy(reply);
            reply = NULL;
        }
        
        [result appendFormat:@"%s", stationType];
        
        delete[] stationType;
        stationType = NULL;
    }
	
	if(!flag)
	{
		[self UUTRelease];
	}
	
	return [result autorelease];
}

-(NSString*)GetStationID
{
    NSMutableString* result = [[NSMutableString alloc] initWithString:@""];
    
    BOOL flag = NO;
	size_t length = 0;
	char* stationID;
	reply = IP_getGHStationInfo(UID, IP_STATION_ID, NULL,&length);
    
    if (IP_success(reply))
    {
        IP_reply_destroy(reply);
        
        stationID = new char[length + 1];
        
        reply = IP_getGHStationInfo(UID, IP_STATION_ID, &stationID ,&length);
        
        if(IP_success(reply))
        {
            [self setErrorInfo:@""];
            flag = YES;
        }
        else
        {
            [self setErrorInfo:[NSString stringWithUTF8String:IP_reply_getError(reply)]];
            flag = NO;
        }
        
        if (reply)
        {
            IP_reply_destroy(reply);
            reply = NULL;
        }
        
        [result appendFormat:@"%s", stationID];
        
        delete[] stationID;
        stationID = NULL;
    }
	
	if(!flag)
	{
		[self UUTRelease];
	}
	
	return [result autorelease];
}

-(BOOL) AddBlob:(NSString*) fileName FilePath:(NSString*) filePath
{
	BOOL flag = NO;
	reply = IP_addBlob(UID, [fileName UTF8String], [filePath UTF8String]);
	
	if(IP_success(reply))
	{
		[self setErrorInfo:@""];
		flag = YES;
	}
	else
	{
		[self setErrorInfo:[NSString stringWithUTF8String:IP_reply_getError(reply)]];
		flag = NO;
	}
	
	if (reply) 
	{
		IP_reply_destroy(reply);
		reply = NULL;
	}
	
	if(!flag)
	{
		[self UIDCancel];
	}
	
	return flag;
}

-(BOOL) SetStartTime:(time_t) startTime
{
	BOOL flag = NO;
	reply = IP_setStartTime(UID,startTime);
	
	if(IP_success(reply))
	{
		[self setErrorInfo:@""];
		flag = YES;
	}
	else
	{
		[self setErrorInfo:[NSString stringWithUTF8String:IP_reply_getError(reply)]];
		flag = NO;
	}
	
	if (reply) 
	{
		IP_reply_destroy(reply);
		reply = NULL;
	}
	
	if(!flag)
	{
		[self UIDCancel];
	}
	
	return flag;
}

-(BOOL) SetEndTime:(time_t) endTime
{
	BOOL flag = NO;
	reply = IP_setStopTime(UID,endTime);
	
	if(IP_success(reply))
	{
		[self setErrorInfo:@""];
		flag = YES;
	}
	else
	{
		[self setErrorInfo:[NSString stringWithUTF8String:IP_reply_getError(reply)]];
		flag = NO;
	}
	
	if (reply) 
	{
		IP_reply_destroy(reply);
		reply = NULL;
	}
	
	if(!flag)
	{
		[self UIDCancel];
	}
	
	return flag;
}

-(BOOL) AddDCSDAndUartLog
{
	BOOL flag = NO;
    BOOL isZipFileName = NO;
    
    NSArray* LogNames = [UartFileLog componentsSeparatedByString:@";"];
    NSMutableString* DCSDfileFloder = [[NSMutableString alloc] initWithString:@""];
    NSMutableString* cmd = [[NSMutableString alloc] initWithString:@"tar -zcpf"];
    NSMutableString* fileName = [[NSMutableString alloc] initWithString:@""];
    
    for (NSString* logName in LogNames)
    {
        NSMutableString* uartFile = [[NSMutableString alloc] initWithString:@""];
        
        if([logName length] > 0)
        {
            [uartFile setString:logName];
            NSRange range1 = [uartFile rangeOfString:@"/" options:NSBackwardsSearch];
            [uartFile setString:[uartFile stringByReplacingCharactersInRange:range1 withString:@" "]];
            
            if (!isZipFileName)
            {
                [fileName setString:logName];
                [fileName setString:[fileName stringByReplacingOccurrencesOfString:@"/UartLog" withString:@"/ZIP"]];
                [fileName setString:[fileName stringByReplacingOccurrencesOfString:@"/TestFlowLog" withString:@"/ZIP"]];
                [fileName setString:[fileName stringByReplacingOccurrencesOfString:@".txt" withString:@".zip"] ];
                [cmd appendFormat:@" %@ -C %@", fileName, uartFile];
                isZipFileName = YES;
            }
            else
            {
                [cmd appendFormat:@" -C %@",uartFile];
            }
        }
  
        [uartFile release];
    }
    
    if(![cmd isEqualToString:@"tar -zcpf"])
    {
        system([cmd UTF8String]);
            
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileName])
        {
            flag = [self AddBlob:@"TestLog" FilePath:fileName];
        }
    }
    else
    {
        flag = YES;
    }
    
    
    [fileName release];
    fileName = nil;
    [cmd release];
    cmd = nil;
    [DCSDfileFloder release];
    DCSDfileFloder = nil;
    
    
	return flag;
}

-(BOOL) UUTRelease
{
	if(UID == NULL)
	{
		return YES;
	}
	
	BOOL flag = NO;
	
	if (![self AddDCSDAndUartLog])
	{
		return NO;
	}	
	
	IP_API_Reply doneReply = IP_UUTDone(UID);
    [self setDoneErrorInfo:[NSString stringWithUTF8String:IP_reply_getError(doneReply)]];
    
    if(!IP_success(doneReply))
	{
        if(IP_reply_isOfClass(doneReply,IP_MSG_CLASS_PROCESS_CONTROL))
        {
            NSLog (@"AmIOK error returned from:IP_UUTDone() " );
            NSLog(@"%@",DoneErrorInfo);
        }
        else
        {
            NSLog (@"Error from:IP_UUTDone() " );
            NSLog(@"%@",DoneErrorInfo);
        }
	}
	
	if(doneReply)
	{
		IP_reply_destroy(doneReply);
		doneReply = NULL;
	}
	
	//## required step #4:  IP_UUTCommit()
  	BOOL commitFlag = NO;
	
	IP_API_Reply commitReply = IP_UUTCommit(UID, failedAtLeastOneTest ? IP_FAIL : IP_PASS );
	
	if ( IP_success( commitReply ) )
	{
		[self setCommitErrorInfo:@""];
		commitFlag = YES;
	}
	else
	{
		[self setCommitErrorInfo:[NSString stringWithUTF8String:IP_reply_getError(commitReply)]];
		commitFlag = NO;
	}
	
	if(commitReply)
	{
		IP_reply_destroy( commitReply );
		commitReply = NULL;
	}
	
	if(UID)
	{
		IP_UID_destroy( UID );
		UID = NULL;
	}
	
	return flag & commitFlag;
}

-(NSString*) GetFailInfomation
{
	return ErrorInfo;
}

-(NSString*) GetSITEInfo
{
    NSMutableString* result = [[NSMutableString alloc] initWithString:@""];
	BOOL flag = NO;
	size_t length;
	char* siteName;
	reply = IP_getGHStationInfo(UID, IP_SITE, NULL,&length);
    
    if(IP_success(reply))
    {
        IP_reply_destroy(reply);
        
        siteName = new char[length + 1];
        
        reply = IP_getGHStationInfo(UID, IP_SITE, &siteName ,&length);
        
        if(IP_success(reply))
        {
            [self setErrorInfo:@""];
            flag = YES;
        }
        else
        {
            [self setErrorInfo:[NSString stringWithUTF8String:IP_reply_getError(reply)]];
            flag = NO;
        }
        
        if (reply)
        {
            IP_reply_destroy(reply);
            reply = NULL;
        }
        
        [result appendFormat:@"%s", siteName];
        
        delete[] siteName;
        siteName = NULL;
    }
    else
    {
        
        [self setErrorInfo:[NSString stringWithUTF8String:IP_reply_getError(reply)]];
        flag = NO;
    }
	
	
	if(!flag)
	{
		[self UUTRelease];
	}
	
	return [result autorelease];
}

-(BOOL) AddTestItem:(NSString*)itemName TestValue:(NSString*)testValue 
		 TestResult:(NSString*)tr ErrorInfo:(NSString*)errorInfo Priority:(NSString*)priority
{
	BOOL flag = NO;
	BOOL resultflag = NO;
	BOOL checkResult = NO;
	
	testSpec = IP_testSpec_create();
	
	if(!testSpec)
	{
		NSLog (@"Error from IP_testSpec_create %@",itemName);
		
		[self UIDCancel];
		
		if(testSpec)
		{
			IP_testSpec_destroy(testSpec);
			testSpec = NULL;
		}
		
		return flag;
	}
	
	testResult = IP_testResult_create();
	
	if(!testResult)
	{
		NSLog(@"Error from IP_testResult_create %@",itemName);
		
		[self UIDCancel];
		
		if(testResult)
		{
			IP_testResult_destroy(testResult);
			testResult = NULL;
		}
		
		if(testSpec)
		{
			IP_testSpec_destroy(testSpec);
			testSpec = NULL;
		}
		
		return resultflag;
	}
	
	checkResult = IP_testSpec_setTestName( testSpec, [itemName UTF8String], [itemName length] );
	
	if(!checkResult)
	{
		NSLog(@"Error from IP_testSpec_setTestName %@",itemName);
		[self UIDCancel];
		
		if(testResult)
		{
			IP_testResult_destroy(testResult);
			testResult = NULL;
		}
		
		if(testSpec)
		{
			IP_testSpec_destroy(testSpec);
			testSpec = NULL;
		}
		return checkResult;
	}
	
	//compare test result isPass
	if([[tr uppercaseString] isEqualToString:@"PASS"])
	{
		checkResult = IP_testResult_setResult( testResult, IP_PASS );
	}
	else if ([[tr uppercaseString] isEqualToString:@"FAIL"])
	{
		failedAtLeastOneTest = YES;
		checkResult = IP_testResult_setResult( testResult, IP_FAIL);
	}
	else
	{
		checkResult = IP_testResult_setResult( testResult, IP_NA );
	}
	
	if(!checkResult)
	{
		NSLog(@"Error from IP_testResult_setResult %@",itemName);
		[self UIDCancel];
		
		if(testResult)
		{
			IP_testResult_destroy(testResult);
			testResult = NULL;
		}
		
		if(testSpec)
		{
			IP_testSpec_destroy(testSpec);
			testSpec = NULL;
		}
		
		return checkResult;
	}

	checkResult = IP_testResult_setMessage( testResult, [errorInfo UTF8String], [errorInfo length] );
	
	if(!checkResult)
	{
		NSLog(@"Error from IP_testResult_setMessage %@",itemName);
		[self UIDCancel];
		
		if(testResult)
		{
			IP_testResult_destroy(testResult);
			testResult = NULL;
		}
		
		if(testSpec)
		{
			IP_testSpec_destroy(testSpec);
			testSpec = NULL;
		}
		
		return checkResult;
	}
	
	
	//## required step #2:  IP_addResult()
	reply = IP_addResult(UID, testSpec, testResult );
	
	NSString* error =  [NSString stringWithUTF8String:IP_reply_getError(reply)];
	
	if((error != nil) && [error length] > 1 )
	{
		[self setErrorInfo:[NSString stringWithUTF8String:IP_reply_getError(reply)]];
		//flag = NO;
	}
	else
	{
		[self setErrorInfo:@""];
		flag = YES;
	}
	
	if(IP_success(reply))
	{
		[self setErrorInfo:@""];
		flag = YES;
	}
	else
	{
		[self setErrorInfo:[NSString stringWithUTF8String:IP_reply_getError(reply)]];
		//flag = NO;
	}
			
	if(testResult)
	{
		IP_testResult_destroy(testResult);
		testResult = NULL;
	}
	
	if(testSpec)
	{
		IP_testSpec_destroy(testSpec);
		testSpec = NULL;
	}
	
	if(!flag)
	{
		[self UIDCancel];
	}
	
	return flag;
}

-(BOOL) AddTestItemAndSubItems:(NSString*)itemName SubItems:(NSArray*)subItems TestValues:(NSArray*)testValues 
		 TestResults:(NSArray*)tesetResults ErrorInfoes:(NSArray*)errorInfoes Priorities:(NSArray*)priorities
{
	BOOL flag = NO;
	BOOL resultflag = NO;
	BOOL checkResult = NO;
	
	testSpec = IP_testSpec_create();
	
	if(!testSpec)
	{
		NSLog (@"Error from IP_testSpec_create %@",itemName);
		
		[self UIDCancel];
		
		if(testSpec)
		{
			IP_testSpec_destroy(testSpec);
			testSpec = NULL;
		}
		
		return flag;
	}
	
	testResult = IP_testResult_create();
	
	if(!testResult)
	{
		NSLog(@"Error from IP_testResult_create %@",itemName);
		
		[self UIDCancel];
		
		if(testResult)
		{
			IP_testResult_destroy(testResult);
			testResult = NULL;
		}
		
		if(testSpec)
		{
			IP_testSpec_destroy(testSpec);
			testSpec = NULL;
		}
		
		return resultflag;
	}
	
	checkResult = IP_testSpec_setTestName( testSpec, [itemName UTF8String], [itemName length] );
	
	if(!checkResult)
	{
		NSLog(@"Error from IP_testSpec_setTestName %@",itemName);
		[self UIDCancel];
		
		if(testResult)
		{
			IP_testResult_destroy(testResult);
			testResult = NULL;
		}
		
		if(testSpec)
		{
			IP_testSpec_destroy(testSpec);
			testSpec = NULL;
		}
		
		return checkResult;
	}
	
	for(int i = 0; i < [subItems count]; i++)
	{
		checkResult = IP_testSpec_setSubSubTestName( testSpec, [[subItems objectAtIndex:i] UTF8String], [[subItems objectAtIndex:i] length] );
		
		if(!checkResult)
		{
			NSLog(@"Error from IP_testSpec_setSubSubTestName %@",[subItems objectAtIndex:i]);
			[self UIDCancel];
			
			if(testResult)
			{
				IP_testResult_destroy(testResult);
				testResult = NULL;
			}
			
			if(testSpec)
			{
				IP_testSpec_destroy(testSpec);
				testSpec = NULL;
			}
			
			return checkResult;
		}
		
		
		//compare test result isPass
		if([[tesetResults objectAtIndex:i] isEqualToString:@"PASS"])
		{
			checkResult = IP_testResult_setResult( testResult, IP_PASS );
		}
		else if ([[tesetResults objectAtIndex:i] isEqualToString:@"FAIL"]) 
		{
			failedAtLeastOneTest = YES;
			checkResult = IP_testResult_setResult( testResult, IP_FAIL);
		}
		else
		{
			checkResult = IP_testResult_setResult( testResult, IP_NA );
		}
		
		if(!checkResult)
		{
			NSLog(@"Error from IP_testResult_setResult %@",[subItems objectAtIndex:i]);
			[self UIDCancel];
			
			if(testResult)
			{
				IP_testResult_destroy(testResult);
				testResult = NULL;
			}
			
			if(testSpec)
			{
				IP_testSpec_destroy(testSpec);
				testSpec = NULL;
			}
			
			return checkResult;
		}
		
		checkResult = IP_testResult_setMessage( testResult, [[errorInfoes objectAtIndex:i] UTF8String], [[errorInfoes objectAtIndex:i] length] );
		
		if(!checkResult)
		{
			NSLog(@"Error from IP_testResult_setMessage %@",[subItems objectAtIndex:i]);
			[self UIDCancel];
			
			if(testResult)
			{
				IP_testResult_destroy(testResult);
				testResult = NULL;
			}
			
			if(testSpec)
			{
				IP_testSpec_destroy(testSpec);
				testSpec = NULL;
			}
			
			return checkResult;
		}
		
		//## required step #2:  IP_addResult()
		reply = IP_addResult(UID, testSpec, testResult );
		
		if(IP_success(reply))
		{
			[self setErrorInfo:@""];
			flag = YES;
		}
		else
		{
			NSLog (@"%s", "Error from IP_addResult Parametric ");
			[self setErrorInfo:[NSString stringWithUTF8String:IP_reply_getError(reply)]];
			flag = NO;
			break;
		}
		
		if(reply)
		{
			IP_reply_destroy(reply);
			reply = NULL;
		}
	}
	
	if(reply)
	{
		IP_reply_destroy(reply);
		reply = NULL;
	}
	
	if(testResult)
	{
		IP_testResult_destroy(testResult);
		testResult = NULL;
	}
	
	if(testSpec)
	{
		IP_testSpec_destroy(testSpec);
		testSpec = NULL;
	}
	
	if(!flag)
	{
		[self UIDCancel];
	}
	
	return flag;
}

-(BOOL) AddTestItemAndSubItems:(NSString*)itemName SubItems:(NSArray*)subItems 
					LowerSpecs:(NSArray*)lowerSpecs UpperSpecs:(NSArray*)upperSpecs Units:(NSArray*)units
					TestValues:(NSArray*)testValues TestResults:(NSArray*)tesetResults 
				   ErrorInfoes:(NSArray*)errorInfoes Priorities:(NSArray*)priorities
{
	BOOL flag = NO;
	BOOL resultflag = NO;
	BOOL checkResult = NO;
	
	testSpec = IP_testSpec_create();
	
	if(!testSpec)
	{
		NSLog (@"Error from IP_testSpec_create %@",itemName);
		
		[self UIDCancel];
		
		if(testSpec)
		{
			IP_testSpec_destroy(testSpec);
			testSpec = NULL;
		}
		
		return flag;
	}
	
	testResult = IP_testResult_create();
	
	if(!testResult)
	{
		NSLog(@"Error from IP_testResult_create %@",itemName);
		
		[self UIDCancel];
		
		if(testResult)
		{
			IP_testResult_destroy(testResult);
			testResult = NULL;
		}
		
		if(testSpec)
		{
			IP_testSpec_destroy(testSpec);
			testSpec = NULL;
		}
		
		return resultflag;
	}
	
	checkResult = IP_testSpec_setTestName( testSpec, [itemName UTF8String], [itemName length] );
	
	if(!checkResult)
	{
		NSLog(@"Error from IP_testSpec_setTestName %@",itemName);
		[self UIDCancel];
		
		if(testResult)
		{
			IP_testResult_destroy(testResult);
			testResult = NULL;
		}
		
		if(testSpec)
		{
			IP_testSpec_destroy(testSpec);
			testSpec = NULL;
		}
		
		return checkResult;
	}
	
	for(int i = 0; i < [subItems count]; i++)
	{
		checkResult = IP_testSpec_setSubSubTestName( testSpec, [[subItems objectAtIndex:i] UTF8String], [[subItems objectAtIndex:i] length] );
		
		if(!checkResult)
		{
			NSLog(@"Error from IP_testSpec_setSubSubTestName %@",[subItems objectAtIndex:i]);
			[self UIDCancel];
			
			if(testResult)
			{
				IP_testResult_destroy(testResult);
				testResult = NULL;
			}
			
			if(testSpec)
			{
				IP_testSpec_destroy(testSpec);
				testSpec = NULL;
			}
			
			return checkResult;
		}
		
		checkResult = IP_testSpec_setLimits( testSpec, [[lowerSpecs objectAtIndex:i] UTF8String], [[lowerSpecs objectAtIndex:i] length],[[upperSpecs objectAtIndex:i] UTF8String], [[upperSpecs objectAtIndex:i] length] );
		
		if(!checkResult)
		{
			NSLog(@"Error from IP_testSpec_setLimits %@",[subItems objectAtIndex:i]);
			[self UIDCancel];
			
			if(testResult)
			{
				IP_testResult_destroy(testResult);
				testResult = NULL;
			}
			
			if(testSpec)
			{
				IP_testSpec_destroy(testSpec);
				testSpec = NULL;
			}
			
			return checkResult;
		}
		
		checkResult = IP_testSpec_setUnits( testSpec, [[units objectAtIndex:i] UTF8String], [[units objectAtIndex:i] length] );
		
		if(!checkResult)
		{
			NSLog(@"Error from IP_testSpec_setUnits %@",[subItems objectAtIndex:i]);
			[self UIDCancel];
			
			if(testResult)
			{
				IP_testResult_destroy(testResult);
				testResult = NULL;
			}
			
			if(testSpec)
			{
				IP_testSpec_destroy(testSpec);
				testSpec = NULL;
			}
			
			return checkResult;
		}
		
		
		if([[priorities objectAtIndex:i] isEqualToString:@"0"])
		{
			checkResult = IP_testSpec_setPriority( testSpec, IP_PRIORITY_REALTIME_WITH_ALARMS );
		}
		else if([[priorities objectAtIndex:i]  isEqualToString:@"1"])
		{
			checkResult = IP_testSpec_setPriority( testSpec, IP_PRIORITY_REALTIME );
		}
		else if([[priorities objectAtIndex:i]  isEqualToString:@"2"])
		{
			checkResult = IP_testSpec_setPriority( testSpec, IP_PRIORITY_DELAYED_WITH_DAILY_ALARMS );
		}
		else if([[priorities objectAtIndex:i]  isEqualToString:@"3"])
		{
			checkResult = IP_testSpec_setPriority( testSpec, IP_PRIORITY_DELAYED_IMPORT );
		}
		else if([[priorities objectAtIndex:i]  isEqualToString:@"4"])
		{
			checkResult = IP_testSpec_setPriority( testSpec, IP_PRIORITY_ARCHIVE );
		}
		else if([[priorities objectAtIndex:i]  isEqualToString:@"-2"])
		{
			checkResult = IP_testSpec_setPriority( testSpec, IP_PRIORITY_STATION_CALIBRATION_AUDIT );
		}
		
		if(!checkResult)
		{
			NSLog(@"Error from IP_testSpec_setPriority %@",[subItems objectAtIndex:i]);
			[self UIDCancel];
			
			if(testResult)
			{
				IP_testResult_destroy(testResult);
				testResult = NULL;
			}
			
			if(testSpec)
			{
				IP_testSpec_destroy(testSpec);
				testSpec = NULL;
			}
			
			return checkResult;
		}
		
		//compare test result isPass
		if([[tesetResults objectAtIndex:i] isEqualToString:@"PASS"])
		{
			checkResult = IP_testResult_setResult( testResult, IP_PASS );
		}
		else if ([[tesetResults objectAtIndex:i] isEqualToString:@"FAIL"]) 
		{
			failedAtLeastOneTest = YES;
			checkResult = IP_testResult_setResult( testResult, IP_FAIL);
		}
		else
		{
			checkResult = IP_testResult_setResult( testResult, IP_NA );
		}
		
		if(!checkResult)
		{
			NSLog(@"Error from IP_testResult_setResult %@",[subItems objectAtIndex:i]);
			[self UIDCancel];
			
			if(testResult)
			{
				IP_testResult_destroy(testResult);
				testResult = NULL;
			}
			
			if(testSpec)
			{
				IP_testSpec_destroy(testSpec);
				testSpec = NULL;
			}
			
			return checkResult;
		}
		
		checkResult = IP_testResult_setValue( testResult, [[testValues objectAtIndex:i] UTF8String], [[testValues objectAtIndex:i] length] );
		
		if(!checkResult)
		{
			NSLog(@"Error from IP_testResult_setValue %@",[subItems objectAtIndex:i]);
			[self UIDCancel];
			
			if(testResult)
			{
				IP_testResult_destroy(testResult);
				testResult = NULL;
			}
			
			if(testSpec)
			{
				IP_testSpec_destroy(testSpec);
				testSpec = NULL;
			}
			
			return checkResult;
		}
		
		checkResult = IP_testResult_setMessage( testResult, [[errorInfoes objectAtIndex:i] UTF8String], [[errorInfoes objectAtIndex:i] length] );
		
		if(!checkResult)
		{
			NSLog(@"Error from IP_testResult_setMessage %@",[subItems objectAtIndex:i]);
			[self UIDCancel];
			
			if(testResult)
			{
				IP_testResult_destroy(testResult);
				testResult = NULL;
			}
			
			if(testSpec)
			{
				IP_testSpec_destroy(testSpec);
				testSpec = NULL;
			}
			
			return checkResult;
		}
		
		//## required step #2:  IP_addResult()
		reply = IP_addResult(UID, testSpec, testResult );
		
		if(IP_success(reply))
		{
			[self setErrorInfo:@""];
			flag = YES;
		}
		else
		{
			NSLog (@"%s", "Error from IP_addResult Parametric ");
			[self setErrorInfo:[NSString stringWithUTF8String:IP_reply_getError(reply)]];
			flag = NO;
			break;
		}
		
		if(reply)
		{
			IP_reply_destroy(reply);
			reply = NULL;
		}
	}
	
	if(reply)
	{
		IP_reply_destroy(reply);
		reply = NULL;
	}
	
	if(testResult)
	{
		IP_testResult_destroy(testResult);
		testResult = NULL;
	}
	
	if(testSpec)
	{
		IP_testSpec_destroy(testSpec);
		testSpec = NULL;
	}
	
	if(!flag)
	{
		[self UIDCancel];
	}
	
	return flag;
}

-(BOOL) AddTestItem:(NSString*)itemName 
					LowerSpec:(NSString*)lowerSpec UpperSpec:(NSString*)upperSpec Unit:(NSString*)unit
					TestValue:(NSString*)testValue TestResult:(NSString*)tr
				   ErrorInfo:(NSString*)errorInfo Priority:(NSString*)priority
{
	BOOL flag = NO;
	BOOL resultflag = NO;
	BOOL checkResult = NO;
	
	testSpec = IP_testSpec_create();
	
	if(!testSpec)
	{
		NSLog (@"Error from IP_testSpec_create %@",itemName);
		
		[self UIDCancel];
		
		if(testSpec)
		{
			IP_testSpec_destroy(testSpec);
			testSpec = NULL;
		}
		
		return flag;
	}
	
	testResult = IP_testResult_create();
	
	if(!testResult)
	{
		NSLog(@"Error from IP_testResult_create %@",itemName);
		
		[self UIDCancel];
		
		if(testResult)
		{
			IP_testResult_destroy(testResult);
			testResult = NULL;
		}
		
		if(testSpec)
		{
			IP_testSpec_destroy(testSpec);
			testSpec = NULL;
		}
		
		return resultflag;
	}
	
	checkResult = IP_testSpec_setTestName( testSpec, [itemName UTF8String], [itemName length] );
	
	if(!checkResult)
	{
		NSLog(@"Error from IP_testSpec_setTestName %@",itemName);
		[self UIDCancel];
		
		if(testResult)
		{
			IP_testResult_destroy(testResult);
			testResult = NULL;
		}
		
		if(testSpec)
		{
			IP_testSpec_destroy(testSpec);
			testSpec = NULL;
		}
		
		return checkResult;
	}
	
	checkResult = IP_testSpec_setLimits( testSpec, [lowerSpec UTF8String], [lowerSpec length],[upperSpec UTF8String], [upperSpec length] );
	
	if(!checkResult)
	{
		NSLog(@"Error from IP_testSpec_setLimits %@",itemName);
		[self UIDCancel];
		
		if(testResult)
		{
			IP_testResult_destroy(testResult);
			testResult = NULL;
		}
		
		if(testSpec)
		{
			IP_testSpec_destroy(testSpec);
			testSpec = NULL;
		}
		
		return checkResult;
	}
	unit = [unit stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //6.16
	if([unit length] >= 1)    //6.16
	{
		checkResult = IP_testSpec_setUnits( testSpec, [unit UTF8String], [unit length] );
		
		if(!checkResult)
		{
			NSLog(@"Error from IP_testSpec_setUnits %@",itemName);
			[self UIDCancel];
			
			if(testResult)
			{
				IP_testResult_destroy(testResult);
				testResult = NULL;
			}
			
			if(testSpec)
			{
				IP_testSpec_destroy(testSpec);
				testSpec = NULL;
			}
			
			return checkResult;
		}
	}
	
	if([priority isEqualToString:@"0"])
	{
		checkResult = IP_testSpec_setPriority( testSpec, IP_PRIORITY_REALTIME_WITH_ALARMS );
	}
	else if([priority  isEqualToString:@"1"])
	{
		checkResult = IP_testSpec_setPriority( testSpec, IP_PRIORITY_REALTIME );
	}
	else if([priority  isEqualToString:@"2"])
	{
		checkResult = IP_testSpec_setPriority( testSpec, IP_PRIORITY_DELAYED_WITH_DAILY_ALARMS );
	}
	else if([priority  isEqualToString:@"3"])
	{
		checkResult = IP_testSpec_setPriority( testSpec, IP_PRIORITY_DELAYED_IMPORT );
	}
	else if([priority  isEqualToString:@"4"])
	{
		checkResult = IP_testSpec_setPriority( testSpec, IP_PRIORITY_ARCHIVE );
	}
	else if([priority  isEqualToString:@"-2"])
	{
		checkResult = IP_testSpec_setPriority( testSpec, IP_PRIORITY_STATION_CALIBRATION_AUDIT );
	}
	
	if(!checkResult)
	{
		NSLog(@"Error from IP_testSpec_setPriority %@",itemName);
		[self UIDCancel];
		
		if(testResult)
		{
			IP_testResult_destroy(testResult);
			testResult = NULL;
		}
		
		if(testSpec)
		{
			IP_testSpec_destroy(testSpec);
			testSpec = NULL;
		}
		
		return checkResult;
	}
	
	//compare test result isPass
	if([tr isEqualToString:@"PASS"])
	{
		checkResult = IP_testResult_setResult( testResult, IP_PASS );
	}
	else if ([tr isEqualToString:@"FAIL"]) 
	{
		failedAtLeastOneTest = YES;
		checkResult = IP_testResult_setResult( testResult, IP_FAIL);
	}
	else
	{
		checkResult = IP_testResult_setResult( testResult, IP_NA );
	}
	
	if(!checkResult)
	{
		NSLog(@"Error from IP_testResult_setResult %@",itemName);
		[self UIDCancel];
		
		if(testResult)
		{
			IP_testResult_destroy(testResult);
			testResult = NULL;
		}
		
		if(testSpec)
		{
			IP_testSpec_destroy(testSpec);
			testSpec = NULL;
		}
		
		return checkResult;
	}
	
	checkResult = IP_testResult_setValue( testResult, [testValue UTF8String], [testValue length] );
	
	if(!checkResult)
	{
		NSLog(@"Error from IP_testResult_setValue %@",itemName);
		[self UIDCancel];
		
		if(testResult)
		{
			IP_testResult_destroy(testResult);
			testResult = NULL;
		}
		
		if(testSpec)
		{
			IP_testSpec_destroy(testSpec);
			testSpec = NULL;
		}
		
		return checkResult;
	}
	
	checkResult = IP_testResult_setMessage( testResult, [errorInfo UTF8String], [errorInfo length] );
	
	if(!checkResult)
	{
		NSLog(@"Error from IP_testResult_setMessage %@",itemName);
		[self UIDCancel];
		
		if(testResult)
		{
			IP_testResult_destroy(testResult);
			testResult = NULL;
		}
		
		if(testSpec)
		{
			IP_testSpec_destroy(testSpec);
			testSpec = NULL;
		}
		
		return checkResult;
	}
	
	//## required step #2:  IP_addResult()
	reply = IP_addResult(UID, testSpec, testResult );
	
	if(IP_success(reply))
	{
		[self setErrorInfo:@""];
		flag = YES;
	}
	else
	{
		NSLog (@"%s", "Error from IP_addResult Parametric ");
		[self setErrorInfo:[NSString stringWithUTF8String:IP_reply_getError(reply)]];
		flag = NO;
	}
	
	if(reply)
	{
		IP_reply_destroy(reply);
		reply = NULL;
	}
	
	if(testResult)
	{
		IP_testResult_destroy(testResult);
		testResult = NULL;
	}
	
	if(testSpec)
	{
		IP_testSpec_destroy(testSpec);
		testSpec = NULL;
	}
	
	if(!flag)
	{
		[self UIDCancel];
	}
	
	return flag;
}

@end
