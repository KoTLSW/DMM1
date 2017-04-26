//
//  SerialPortList.h
//  SerialPortDemo
//
//  Created by TOD on 11/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOKit/serial/IOSerialKeys.h>
#import <IOKit/IOKitLib.h>

//@class SerialPort;

@interface SerialPortList : NSObject 
{
@private
	NSMutableArray* portList;
}

+(SerialPortList*) Instance;
- (NSString *) getNextSerialPort:(io_iterator_t)serialPortIterator;
-(NSMutableArray*) portArray;//get serial port lists

@end
