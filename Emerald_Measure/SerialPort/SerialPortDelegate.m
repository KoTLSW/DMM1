//
//  SerialPortDelegate.m
//  HowToWorks
//
//  Created by h on 17/4/12.
//  Copyright © 2017年 bill. All rights reserved.
//

#import "SerialPortDelegate.h"
@interface SerialPortDelegate()
{
    SerialPort *serialport;
    SerialPortList *serialPortList;
}
@end

@implementation SerialPortDelegate

-(id)init
{
    self = [super initWithWindowNibName:@"SerialPort"];
    return self;
}

-(void)windowDidLoad{
    [super windowDidLoad];
    serialport = [[SerialPort alloc] init];
    serialPortList = [[SerialPortList alloc] init];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(IBAction)btSearch:(id)sender
{
    [SerialPortAddress removeAllItems];
    NSMutableArray *portlist= [[NSMutableArray alloc] init];
    portlist = [serialPortList portArray];
    for (int i = 0; i < [portlist count]; i++)
    {
        [SerialPortAddress addItemWithTitle:[portlist objectAtIndex:i]];
    }

}
-(IBAction)btOpen:(id)sender
 {
//    BOOL serialIsOpen = [serialport Open:SerialPortAddress.title BaudRate:BAUD_9600 DataBit:DATA_BITS_8 StopBit:StopBitsOne Parity:PARITY_NONE FlowControl:FLOW_CONTROL_NONE];
    int num = [SerialPortBaudrate.title intValue];
    BOOL serialIsOpen = [serialport Open:SerialPortAddress.title BaudRate:[SerialPortBaudrate.title intValue] DataBit:(int)SerialPortDataBits.indexOfSelectedItem StopBit:(int)SerialPortStopBits.indexOfSelectedItem Parity:(int)SerialPortParity.indexOfSelectedItem FlowControl:(int)SerialPortFlowControls.indexOfSelectedItem];
     [self addTextLog:[NSString stringWithFormat:@"连接成功（1）连接失败（0）\n当前连接返回值：%hhd",serialIsOpen]];
 }

-(IBAction)btClose:(id)sender
{
    [serialport Close];
    BOOL ret = [serialport IsOpen];
}

-(IBAction)btSend:(id)sender
 {
     NSString *cmd = [SerialPortCmd stringValue];
    [self addTextLog:[NSString stringWithFormat:@"Send Cmd:========\n %@",cmd]];
     [serialport WriteLine:[SerialPortCmd stringValue]];
 }
-(IBAction)btRead:(id)sender
{
    NSString *ReadData = [serialport ReadExisting];
    [self addTextLog:[NSString stringWithFormat:@"Read Data:=======\n %@",ReadData]];
}
-(IBAction)btQuery:(id)sender
{
    [serialport WriteLine:@"HELP"];
    sleep(0.4);
    NSString *ReadData = [serialport ReadExisting];
    [self addTextLog:[NSString stringWithFormat:@"Read Data:\n %@",ReadData]];
}

-(void)addTextLog:(NSString*)msg
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss.SSS : "];
    NSAttributedString *attributedString;
//    msg = [msg stringByReplacingOccurrencesOfString:@"\r" withString:@""];
//    msg = [msg stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *str = [NSString stringWithFormat:@"%@ %@\r",[dateFormatter stringFromDate:[NSDate date]],msg];
    attributedString = [[NSAttributedString alloc] initWithString:str];
    NSUInteger length = 0;
    length = [[SerialPortLog textStorage] length];
    
    if (length > 1000000)
    {
        NSLog(@"The length of log data is too big, much then 1000000 bytes, cleared at %@",str);
        [[SerialPortLog textStorage] replaceCharactersInRange:NSMakeRange(0, [[SerialPortLog textStorage] length]) withString:@"Too much data, cleared to save memory\r\n"];
    }
    
    NSRange theRange = NSMakeRange(length, 0);
    [SerialPortLog scrollRangeToVisible:theRange];
    
    [[SerialPortLog textStorage]appendAttributedString:attributedString];
    
    
}
@end
