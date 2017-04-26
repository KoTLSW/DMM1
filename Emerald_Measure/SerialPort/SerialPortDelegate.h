//
//  SerialPortDelegate.h
//  HowToWorks
//
//  Created by h on 17/4/12.
//  Copyright © 2017年 bill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "SerialPortList.h"
#import "SerialPort.h"

@interface SerialPortDelegate : NSWindowController{
    
    IBOutlet NSPopUpButton *SerialPortAddress;
    IBOutlet NSPopUpButton *SerialPortBaudrate;
    IBOutlet NSPopUpButton *SerialPortDataBits;
    IBOutlet NSPopUpButton *SerialPortParity;
    IBOutlet NSPopUpButton *SerialPortStopBits;
    IBOutlet NSPopUpButton *SerialPortFlowControls;
    IBOutlet NSTextView *SerialPortLog;
    
    IBOutlet NSTextField *SerialPortCmd;
    
}

-(IBAction)btSearch:(id)sender;
-(IBAction)btOpen:(id)sender;
-(IBAction)btClose:(id)sender;
-(IBAction)btSend:(id)sender;
-(IBAction)btRead:(id)sender;
-(IBAction)btQuery:(id)sender;

@end
