//
//  SerialPort.m
//  SerialPortDemo
//
//  Created by TOD on 11/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.


#import "SerialPort.h"


@implementation SerialPort

@synthesize devicePath;
@synthesize rest;
@synthesize readTimeout;
@synthesize writeTimeout;
@synthesize fileDescriptor;

- (id)init
{
	if ((self = [super init]))
	{
		fileDescriptor = -1;
		readTimeout = 2000;
		rest = 0;
		globalBuffer = [[NSMutableString alloc] init];
		
		strResult = [[NSMutableString alloc] initWithString:@""];
	}
	
	return self;
}



-(void) setTimeout:(int)readtimeout WriteTimeout:(int)writetimeout
{
	readTimeout = readtimeout;
	writeTimeout = writetimeout;
}

-(BOOL) Close
{
	if([self IsOpen])
	{
		// Close the fileDescriptor, that is our responsibility since the fileHandle does not own it
		int n = close(fileDescriptor);
        if(n == 0)
        {
            fileDescriptor = -1;
            return YES;
        }
        else
        {
            return NO;
        }
	}
    
    return NO;
}

-(BOOL) IsOpen
{
	return (fileDescriptor >= 0);
}

-(BOOL) Open:(NSString*) devicepath
{
    
	return [self Open:devicepath BaudRate:BAUD_DEFAULT DataBit:DATA_BITS_DEFAULT
			  StopBit:StopBitsDefault Parity:Parity_Default FlowControl:FLOW_CONTROL_DEFAULT];
}

-(BOOL) Open:(NSString *)devicepath BaudRate:(BaudRate)baudrate DataBit:(DataBits) databit
	 StopBit:(StopBits)stopbit Parity:(Parity)parityvalue
 FlowControl:(FlowControls) flowcontrolValue
{
	if([self IsOpen])
	{
		return YES;
	}
	
    //
    // We only allow three different combinations of ios_base::openmode
    // so we can use a switch here to construct the flags to be used
    // with the open() system call.
    //
    int flags = O_RDWR;
	//
    // Since we are dealing with the serial port we need to use the
    // O_NOCTTY option.
    //
    flags |= O_NOCTTY ;
    //
    // Try to open the serial port.
    //
	
	devicePath = [devicepath copy];
	
	const char *path = [devicepath fileSystemRepresentation];
	fileDescriptor = open(path, flags);
    
    if( [self fileDescriptor] == -1)
	{
		return NO;
    }
    //
    // Initialize the serial port.
    //
	//
    // Use non-blocking mode while configuring the serial port.
    //
    flags = fcntl([self fileDescriptor], F_GETFL, 0) ;
	
    if( -1 == fcntl([self fileDescriptor],  F_SETFL, flags | O_NONBLOCK ) )
	{
        return NO;
    }
    //
    // Flush out any garbage left behind in the buffers associated
    // with the port from any previous operations.
    //
    if( -1 == tcflush([self fileDescriptor], TCIOFLUSH) )
	{
        return NO;
    }
    //
    // Set up the default configuration for the serial port.
    //
    [self setBaudRate:baudrate];
	[self setDataBit:databit];
	[self setStopBit:stopbit];
	[self setParity:parityvalue];
	[self setFlowControl:flowcontrolValue];
	
	// I didn't change this issue because i didn't know wether is OK
	// but I know the issue
	
	[self setVMin:1];
	[self setVTime:0];
	
    //
    // Allow all further communications to happen in blocking
    // mode.
    //
    flags = fcntl([self fileDescriptor], F_GETFL, 0) ;
	
    if( -1 == fcntl([self fileDescriptor],  F_SETFL, flags & ~O_NONBLOCK ) )
	{
        return NO;
    }
    //
    // If we get here without problems then we are good; return a value
    // different from -1.
    //
	
    return YES;
}

-(BaudRate) setBaudRate:(BaudRate)baudrate
{
	if( -1 == [self fileDescriptor])
	{
        return BAUD_INVALID ;
    }
	
	switch (baudrate)
	{
		case BAUD_50:
		case BAUD_75:
		case BAUD_110:
		case BAUD_134:
		case BAUD_150:
		case BAUD_200:
		case BAUD_300:
		case BAUD_600:
		case BAUD_1200:
		case BAUD_1800:
		case BAUD_2400:
		case BAUD_4800:
		case BAUD_9600:
		case BAUD_19200:
		case BAUD_38400:
		case BAUD_57600:
		case BAUD_115200:
		{
			struct termios term_setting;
			
			if( -1 == tcgetattr([self fileDescriptor], &term_setting) )
			{
				return BAUD_INVALID;
			}
			//
			// Modify the baud rate in the term_setting structure.
			//
			cfsetispeed( &term_setting, baudrate);
			cfsetospeed( &term_setting, baudrate );
			//
			// Apply the modified termios structure to the serial
			// port.
			//
			if( -1 == tcsetattr([self fileDescriptor], TCSANOW, &term_setting) )
			{
				return BAUD_INVALID;
			}
			
			break ;
		}
			
		default:
			break;
	}
	
	return [self getBaudRate];
}

-(BaudRate) getBaudRate
{
	if( -1 == [self fileDescriptor])
	{
        return BAUD_INVALID;
    }
	
    //
    // Get the current terminal settings.
    //
    struct termios term_setting;
	
    if( -1 == tcgetattr([self fileDescriptor], &term_setting) )
	{
        return BAUD_INVALID ;
    }
    //
    // Read the input and output baud rates.
    //
    speed_t input_baud = cfgetispeed( &term_setting ) ;
    speed_t output_baud = cfgetospeed( &term_setting ) ;
    //
    // Make sure that the input and output baud rates are
    // equal. Otherwise, we do not know which one to return.
    //
    if( input_baud != output_baud )
	{
        return BAUD_INVALID;
    }
	
	BaudRate result = (BaudRate)input_baud;
    
    return result;
}

-(DataBits) setDataBit:(DataBits)dataBits
{
    if( -1 == [self fileDescriptor])
	{
        return DATA_BITS_INVALID ;
    }
	
    switch(dataBits)
	{
		case DATA_BITS_5:
		case DATA_BITS_6:
		case DATA_BITS_7:
		case DATA_BITS_8:
		{
			struct termios term_setting ;
			
			if( -1 == tcgetattr([self fileDescriptor], &term_setting))
			{
				return DATA_BITS_INVALID ;
			}
			//
			// Set the character size to the specified value. If the character
			// size is not 8 then it is also important to set ISTRIP. Setting
			// ISTRIP causes all but the 7 low-order bits to be set to
			// zero. Otherwise they are set to unspecified values and may
			// cause problems. At the same time, we should clear the ISTRIP
			// flag when the character size is 8 otherwise the MSB will always
			// be set to zero (ISTRIP does not check the character size
			// setting; it just sets every bit above the low 7 bits to zero).
			//
			if( dataBits == DATA_BITS_8 )
			{
				term_setting.c_iflag &= ~ISTRIP ; // clear the ISTRIP flag.
			}
			else
			{
				term_setting.c_iflag |= ISTRIP ;  // set the ISTRIP flag.
			}
			
			term_setting.c_cflag &= ~CSIZE ;     // clear all the CSIZE bits.
			term_setting.c_cflag |= dataBits ;  // set the character size.
			//
			// Set the new settings for the serial port.
			//
			if( -1 == tcsetattr([self fileDescriptor], TCSANOW, &term_setting) )
			{
				return DATA_BITS_INVALID ;
			}
			
			break ;
		}
		default:
			return DATA_BITS_INVALID ;
			break ;
    }
	
    return [self getDataBit];
}

-(DataBits) getDataBit
{
    if( -1 == [self fileDescriptor] )
	{
        return DATA_BITS_INVALID ;
    }
    //
    // Get the current terminal settings.
    //
    struct termios term_setting ;
	
    if( -1 == tcgetattr([self fileDescriptor], &term_setting) )
	{
        return DATA_BITS_INVALID ;
    }
    //
    // Extract the character size from the terminal settings.
    //
    int dataBits = (term_setting.c_cflag & CSIZE) ;
	
    switch( dataBits )
	{
		case CS5:
			return DATA_BITS_5 ; break ;
		case CS6:
			return DATA_BITS_6 ; break ;
		case CS7:
			return DATA_BITS_7 ; break ;
		case CS8:
			return DATA_BITS_8 ; break ;
		default:
			//
			// If we get an invalid character, we set the badbit for the
			// stream associated with the serial port.
			//
			return DATA_BITS_INVALID ;
			break ;
    } ;
	
    return DATA_BITS_INVALID ;
}

-(StopBits) setStopBit:(StopBits) stop_bits
{
    if( -1 == [self fileDescriptor])
	{
        return  STOP_BITS_INVALID;
    }
    //
    // Get the current terminal settings.
    //
    struct termios term_setting ;
	
    if( -1 == tcgetattr([self fileDescriptor], &term_setting) )
	{
		return STOP_BITS_INVALID;
    }
	
    switch( stop_bits )
	{
		case StopBitsOne:
			term_setting.c_cflag &= ~CSTOPB ;
			break ;
		case StopBitsTwo:
			term_setting.c_cflag |= CSTOPB ;
			break ;
		default:
			return  STOP_BITS_INVALID;
			break ;
    }
    //
    // Set the new settings for the serial port.
    //
    if( -1 == tcsetattr([self fileDescriptor], TCSANOW, &term_setting) )
	{
        return STOP_BITS_INVALID;
    }
	
	return [self getStopBit];
}

-(StopBits) getStopBit
{
    if( -1 == [self fileDescriptor] )
	{
        return STOP_BITS_INVALID;
    }
    //
    // Get the current terminal settings.
    //
    struct termios term_setting ;
	
    if( -1 == tcgetattr([self fileDescriptor], &term_setting) )
	{
        return STOP_BITS_INVALID ;
    }
    //
    // If CSTOPB is set then the number of stop bits is 2 otherwise it
    // is 1.
    //
    if( term_setting.c_cflag & CSTOPB )
	{
        return StopBitsTwo ;
    }
	else
	{
        return StopBitsOne ;
    }
}

-(Parity) setParity:(Parity) parityValue
{
    if( -1 == [self fileDescriptor] )
	{
        return PARITY_INVALID ;
    }
    //
    // Get the current terminal settings.
    //
    struct termios term_setting ;
	
    if( -1 == tcgetattr([self fileDescriptor], &term_setting) )
	{
        return PARITY_INVALID ;
    }
    //
    // Set the parity in the termios structure.
    //
    switch( parityValue )
	{
		case PARITY_EVEN:
			term_setting.c_cflag |= PARENB ;
			term_setting.c_cflag &= ~PARODD ;
			break ;
		case PARITY_ODD:
			term_setting.c_cflag |= PARENB ;
			term_setting.c_cflag |= PARODD ;
			break ;
		case PARITY_NONE:
			term_setting.c_cflag &= ~PARENB ;
			break ;
		default:
			return PARITY_INVALID ;
    }
    //
    // Write the settings back to the serial port.
    //
    if( -1 == tcsetattr([self fileDescriptor], TCSANOW, &term_setting) )
	{
        return PARITY_INVALID ;
    }
	
    return [self getParity] ;
}

-(Parity) getParity
{
    if( -1 == [self fileDescriptor] )
	{
        return PARITY_INVALID ;
    }
    //
    // Get the current terminal settings.
    //
    struct termios term_setting ;
	
    if( -1 == tcgetattr([self fileDescriptor], &term_setting) )
	{
        return PARITY_INVALID ;
    }
    //
    // Get the parity setting from the termios structure.
    //
    if( term_setting.c_cflag & PARENB )
	{   // parity is enabled.
        if( term_setting.c_cflag & PARODD )
		{ // odd parity
            return PARITY_ODD ;
        }
		else
		{                              // even parity
            return PARITY_EVEN ;
        }
		
    }
	else
	{                                // no parity.
        return PARITY_NONE ;
    }
	
    return PARITY_INVALID ; // execution should never reach here.
}

-(FlowControls) setFlowControl:(FlowControls) flow_c
{
    if( -1 == [self fileDescriptor] )
	{
        return FLOW_CONTROL_INVALID ;
    }
    //
    // Flush any unwritten, unread data from the serial port.
    //
    if( -1 == tcflush([self fileDescriptor], TCIOFLUSH) )
	{
        return FLOW_CONTROL_INVALID ;
    }
    //
    // Get the current terminal settings.
    //
    struct termios tset;
	
    int retval = tcgetattr([self fileDescriptor], &tset);
	
    if (-1 == retval)
	{
        return FLOW_CONTROL_INVALID ;
    }
    //
    // Set the flow control. Hardware flow control uses the RTS (Ready
    // To Send) and CTS (clear to Send) lines. Software flow control
    // uses IXON|IXOFF
    //
    if ( FLOW_CONTROL_HARD == flow_c )
	{
        tset.c_iflag &= ~ (IXON|IXOFF);
        tset.c_cflag |= CRTSCTS;
        tset.c_cc[VSTART] = _POSIX_VDISABLE;
        tset.c_cc[VSTOP] = _POSIX_VDISABLE;
    }
	else if ( FLOW_CONTROL_SOFT == flow_c )
	{
        tset.c_iflag |= IXON|IXOFF;
        tset.c_cflag &= ~CRTSCTS;
        tset.c_cc[VSTART] = CTRL_Q;
        tset.c_cc[VSTOP]  = CTRL_S;
    }
	else
	{
        tset.c_iflag &= ~(IXON|IXOFF);
        tset.c_cflag &= ~CRTSCTS;
    }
	
    retval = tcsetattr([self fileDescriptor], TCSANOW, &tset);
	
    if (-1 == retval)
	{
        return FLOW_CONTROL_INVALID ;
    }
	
    return [self getFlowControl];
}

-(FlowControls) getFlowControl
{
    if( -1 == [self fileDescriptor] )
	{
        return FLOW_CONTROL_INVALID ;
    }
    //
    // Get the current terminal settings.
    //
    struct termios tset ;
	
    if( -1 == tcgetattr([self fileDescriptor], &tset) )
	{
        return FLOW_CONTROL_INVALID ;
    }
    //
    // Check if IXON and IXOFF are set in c_iflag. If both are set and
    // VSTART and VSTOP are set to 0x11 (^Q) and 0x13 (^S) respectively,
    // then we are using software flow control.
    //
    if( (tset.c_iflag & IXON)         &&
	   (tset.c_iflag & IXOFF)        &&
	   (CTRL_Q == tset.c_cc[VSTART]) &&
	   (CTRL_S == tset.c_cc[VSTOP] ) )
	{
        return FLOW_CONTROL_SOFT ;
    }
	else if ( ! ( (tset.c_iflag & IXON) ||(tset.c_iflag & IXOFF) ) )
	{
        if ( tset.c_cflag & CRTSCTS )
		{
            //
            // If neither IXON or IXOFF is set then we must have hardware flow
            // control.
            //
            return FLOW_CONTROL_HARD ;
        }
		else
		{
            return FLOW_CONTROL_NONE ;
        }
    }
    //
    // If none of the above conditions are satisfied then the serial
    // port is using a flow control setup which we do not support at
    // present.
    //
    return FLOW_CONTROL_INVALID ;
}

-(short) setVMin:(short) vminValue
{
    if( -1 == [self fileDescriptor] )
	{
        return -1 ;
    }
	
    if ( vminValue < 0 || vminValue > 255 )
	{
        return -1 ;
    }
	
    //
    // Get the current terminal settings.
    //
    struct termios term_setting ;
	
    if( -1 == tcgetattr([self fileDescriptor], &term_setting) )
	{
        return -1 ;
    }
	
    term_setting.c_cc[VMIN] = (cc_t)vminValue;
    //
    // Set the new settings for the serial port.
    //
    if( -1 == tcsetattr([self fileDescriptor], TCSANOW, &term_setting) )
	{
        return -1 ;
    }
	
    return [self getVMin];
}

-(short) getVMin
{
    if( -1 == [self fileDescriptor] )
	{
        return -1 ;
    }
    //
    // Get the current terminal settings.
    //
    struct termios term_setting ;
	
    if( -1 == tcgetattr([self fileDescriptor], &term_setting) )
	{
        return -1 ;
    }
	
    return term_setting.c_cc[VMIN];
}

- (short) setVTime:(short) vtime
{
    if( -1 == [self fileDescriptor] )
	{
        return -1 ;
    }
	
    if ( vtime < 0 || vtime > 255 )
	{
        return -1 ;
    };
	
    //
    // Get the current terminal settings.
    //
	
    struct termios term_setting ;
	
    if( -1 == tcgetattr([self fileDescriptor], &term_setting) )
	{
        return -1 ;
    }
	
    term_setting.c_cc[VTIME] = (cc_t)vtime;
    //
    // Set the new settings for the serial port.
    //
    if( -1 == tcsetattr([self fileDescriptor], TCSANOW, &term_setting) )
	{
        return -1 ;
    }
	
    return [self getVTime];
}

-(short) getVTime
{
    if( -1 == [self fileDescriptor] )
	{
        return -1 ;
    }
    //
    // Get the current terminal settings.
    //
    struct termios term_setting ;
	
    if( -1 == tcgetattr([self fileDescriptor] , &term_setting) )
	{
        return -1 ;
    }
	
    return term_setting.c_cc[VTIME];
}

-(void)SetGlobalBUffer:(NSString*)buffer
{
    //	[globalBuffer release];
    //	[buffer retain];
	globalBuffer = [NSMutableString stringWithString:buffer];
}

-(int) GetNumOfDataInBuffer
{
	int result = 0;
	int err = ioctl(fileDescriptor, FIONREAD, (char *)&result);
	
	if (err != 0)
	{
		result = -1;
	}
	
	return result;
}

//private
-(void) ReadSerialPort
{
	//NSAutoreleasePool *pool =[[NSAutoreleasePool alloc] init];
	char chr_to_str[SERIALPORT_MAXBUFSIZE] = "";
	size_t num = 0;
	
	if( [self GetNumOfDataInBuffer] > 1 )
	{
		num = read([self fileDescriptor],&chr_to_str,SERIALPORT_MAXBUFSIZE);
		
		chr_to_str[num + 1] = '\0';
		
		for(int i = 0;i < num;i++)
		{
			if(chr_to_str[i] == '\0')
			{
				chr_to_str[i] = ' ';
			}
		}
		
		NSString* readBuffer = [[NSString alloc] initWithCString:chr_to_str encoding:NSUTF8StringEncoding];
        
        if (readBuffer != nil)
        {
            if([globalBuffer length] > 0)
            {
                [globalBuffer appendString:readBuffer];
            }
            else
            {
                [globalBuffer setString:readBuffer];
            }
        }
        
		
		//[readBuffer autorelease];
    }
	
	//[pool release];
}

-(NSString*) ReadExisting
{
	//NSAutoreleasePool *pool =[[NSAutoreleasePool alloc] init];
    
	[self ReadSerialPort];
    
    //    while (true)
    //	{
    //		[self ReadSerialPort];
    
    //        if (rang.length > 0)
    //        {
    //            //NSAutoreleasePool *pool =[[NSAutoreleasePool alloc] init];
    //
    //            NSString* readbuff = [globalBuffer substringToIndex:rang.location + rang.length]; // program quit unexcepted in this function substringToIndex
    //            NSString* remainbuff = [globalBuffer substringFromIndex:rang.location + rang.length];
    //            [globalBuffer setString:remainbuff];
    //            readbuff = [readbuff stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //            [strResult setString:readbuff];
    //
    //        }
    //
    //
    //		[NSThread sleepForTimeInterval:100 / 1000.0];
    //	}
	
	//[hp autorelease];
	
	
	
	
    
    
    NSString* existing = [globalBuffer copy];
	[self SetGlobalBUffer:@""];
	//[globalBuffer retain];
	
	//[pool release];
	
	//return [existing autorelease];
    return existing;
}

-(NSString*) ReadLine
{
	return [self ReadTo:@"\n"];
}

-(NSString*) ReadTo:(NSString*)data
{
	return [self ReadTo:data TimeOut:readTimeout ReadInterval:rest];
}

-(NSString*) ReadTo:(NSString*)data TimeOut:(int)timeOut ReadInterval:(int)restTime
{
	//NSAutoreleasePool *pool =[[NSAutoreleasePool alloc] init];
	
	if([data length] == 0)
	{
		return @"";
	}
	
	NSRange rang;
	HiperTimer* hp = [[HiperTimer alloc] init];
	
	[hp Start];
	
	while (true)
	{
		[self ReadSerialPort];
		
		rang = [globalBuffer rangeOfString:data];
		
		if(rang.length > 0)
		{
			break;
		}
		
		if([hp durationMillisecond] >= timeOut)
		{
		    break;
		}
		
		[NSThread sleepForTimeInterval:restTime / 1000.0];
	}
	
	//[hp autorelease];
	
	if (rang.length > 0)
	{
		//NSAutoreleasePool *pool =[[NSAutoreleasePool alloc] init];
		
		NSString* readbuff = [globalBuffer substringToIndex:rang.location + rang.length]; // program quit unexcepted in this function substringToIndex
		NSString* remainbuff = [globalBuffer substringFromIndex:rang.location + rang.length];
		[globalBuffer setString:remainbuff];
		readbuff = [readbuff stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[strResult setString:readbuff];
        
		//[pool release];
	}
	else
	{
		[strResult setString:@""];
	}
	
	//[pool release];
	
	return strResult;
}

-(void) Write:(NSString*)data
{
	//NSAutoreleasePool *pool =[[NSAutoreleasePool alloc] init];
	
	NSData *dataValue = [data dataUsingEncoding:NSUTF8StringEncoding];
	[self WriteData:dataValue];
	
	//[pool release];
}

-(void) WriteLine:(NSString*)data
{
	NSString* dataline = [[NSString alloc] initWithFormat:@"%@\r\n", data];
	[self Write:dataline];
	//[dataline release];
}

-(void) WriteData:(NSData*)data
{
	if([self IsOpen])
	{
		const char *dataBytes = (const char*)[data bytes];
		NSUInteger dataLen = [data length];
		
		write([self fileDescriptor], dataBytes, dataLen);
	}
}

@end
