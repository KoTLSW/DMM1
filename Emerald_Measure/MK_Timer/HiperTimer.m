//
//  HiperTimer.m
//  SerialPortDemo
//
//  Created by TOD on 11/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HiperTimer.h"

@implementation HiperTimer

-(id) init
{
//	[super init];
	
//	time_t entry_time;
//	mStart = time(&entry_time);

    if(self=[super init])
    {
        
    }
    
	return self;
}

//-(double) Duration
//{
////	time_t entry_time;
////	mStop = time(&entry_time);
////	
////	double tmp = mStop - mStart;
////	
////	return tmp;	
//}

-(int) durationMillisecond
{
//	time_t entry_time;
//	mStop = time(&entry_time);
//	
//	double tmp = mStop - mStart;
//	
//	return (int)tmp * 1000;		
	
	if(gettimeofday(&tv, NULL) == 0)
		mEnd = tv.tv_sec * 1000 + tv.tv_usec/1000;
	
	return (int)(mEnd - mStart);
}

+(void) DelaySecond:(double) delaytime
{
	[self DelayMillsecond: delaytime * 1000];
}

+(void) DelayMillsecond:(int) delaytime
{	
	HiperTimer* timer = [[HiperTimer alloc] init];

	[timer Start];
	
	while (true)
	{
		if([timer durationMillisecond] >= delaytime)
		{
		    break;
		}
	}	
	
}

-(void) Start
{
	//time(&mStart);
	
	if(gettimeofday(&tv, NULL) == 0)
		mStart = tv.tv_sec * 1000 + tv.tv_usec/1000;
}

@end
