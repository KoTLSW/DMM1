//
//  SerialPortList.m
//  SerialPortDemo
//
//  Created by TOD on 11/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SerialPortList.h"

static SerialPortList* SerialPortListSingleton = nil;

@implementation SerialPortList

+ (SerialPortList *)Instance
{
    @synchronized(self) 
	{
        if (SerialPortListSingleton == nil) 
		{
#ifndef __OBJC_GC__

#else
			// Singleton creation is easy in the GC case, just create it if it hasn't been created yet,
			// it won't get collected since globals are strongly referenced.
			SerialPortListSingleton = [[self alloc] init]; 
#endif
		}
    }
	
    return SerialPortListSingleton;
}

#ifndef __OBJC_GC__

+ (id)allocWithZone:(NSZone *)zone
{
	id result = nil;
    
	@synchronized(self) 
	{
        if (SerialPortListSingleton == nil)
		{
            SerialPortListSingleton = [super allocWithZone:zone];
			result = SerialPortListSingleton;  // assignment and return on first allocation
			//on subsequent allocation attempts return nil
        }
    }
	
	return result;
}

- (id)copyWithZone:(NSZone *)zone
{
	(void)zone;
    return self;
}

//- (id)retain
//{
//    return self;
//}

//- (NSUInteger)retainCount
//{
//    return NSUIntegerMax;  //denotes an object that cannot be released
//}

//- (oneway void)release
//{
//    //do nothing
//}
//
//- (id)autorelease
//{
//    return self;
//}
//
//- (void)dealloc
//{
//	[portList release]; 
//	portList = nil;
//	[super dealloc];
//}

#endif

- (NSString *)getNextSerialPort:(io_iterator_t)serialPortIterator
{
	NSString *serialPort = nil;
	
	io_object_t serialService = IOIteratorNext(serialPortIterator);
	
	if (serialService != 0)
	{
		CFStringRef bsdPath = (CFStringRef)IORegistryEntryCreateCFProperty(serialService, CFSTR(kIOCalloutDeviceKey), kCFAllocatorDefault, 0);
		
		if(bsdPath)
		{
			serialPort = [[NSString alloc] initWithString:(__bridge NSString*)bsdPath];
		}
		
		if(bsdPath != NULL)
		{
			CFRelease(bsdPath);
		}
		

		
		// We have sucked this service dry of information so release it now.
		//(void)IOObjectRelease(serialService);
	}
	
	//return [serialPort autorelease];
    return serialPort;
}

- (void)addAllSerialPortsToArray:(NSMutableArray *)array
{
	kern_return_t kernResult; 
	CFMutableDictionaryRef classesToMatch;
	io_iterator_t serialPortIterator;
	NSString* serialPort;
	
	// Serial devices are instances of class IOSerialBSDClient
	classesToMatch = IOServiceMatching(kIOSerialBSDServiceValue);
	
	if (classesToMatch != NULL) 
	{
		CFDictionarySetValue(classesToMatch, CFSTR(kIOSerialBSDTypeKey), CFSTR(kIOSerialBSDAllTypes));
		
		// This function decrements the refcount of the dictionary passed it
		kernResult = IOServiceGetMatchingServices(kIOMasterPortDefault, classesToMatch, &serialPortIterator);   
		
		if (kernResult == KERN_SUCCESS)
		{			
			while ((serialPort = [self getNextSerialPort:serialPortIterator]) != nil) 
			{
				[array addObject:serialPort];
			}
			
			//(void)IOObjectRelease(serialPortIterator);
		} 
		else
		{
#ifdef AMSerialDebug
			NSLog(@"IOServiceGetMatchingServices returned %d", kernResult);
#endif
		}
	} 
	else
	{
#ifdef AMSerialDebug
		NSLog(@"IOServiceMatching returned a NULL dictionary.");
#endif
	}
}

- (id)init
{
	if ((self = [super init])) 
	{
		//portList = [[NSMutableArray array] retain];
//        portList = [NSMutableArray array];

//		[self addAllSerialPortsToArray:portList];
	}
	
	return self;
}

-(NSMutableArray*) portArray
{
    portList = [NSMutableArray array];
//    [portList removeAllObjects];
    [self addAllSerialPortsToArray:portList];
	return portList;
}
@end
