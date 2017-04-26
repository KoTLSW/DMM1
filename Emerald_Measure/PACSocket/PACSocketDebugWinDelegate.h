//
//  PACSocketDebugWinDelegate.h
//  HowToWorks
//
//  Created by h on 17/4/18.
//  Copyright © 2017年 bill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "TCPClient.h"
#import "GCDAsyncSocket.h"


@interface PACSocketDebugWinDelegate : NSWindowController
{
    IBOutlet NSTextView *mTVOutput;
    IBOutlet NSTextField *mTFInput;
    
    //here is config info
    IBOutlet NSTextField *ipPort;
    IBOutlet NSTextField *ipaddress;
    IBOutlet NSTextFieldCell *socketName;
    //Button
    IBOutlet NSButton *btnCheckVer;
    IBOutlet NSButton *btnHelp;
    
    IBOutlet NSTextField *AddingStr;
    IBOutlet NSTextField *forTimeout;
    
    IBOutlet NSButton *btnSend;
    IBOutlet NSButton *btnQuery;
    IBOutlet NSButton *btnRead;
    IBOutlet NSButton *btnConnect;
    IBOutlet NSButton *statusPic;
    IBOutlet NSTextField *statusMsg;
    
    IBOutlet NSButton *btnSendBarcode;
    IBOutlet NSButton *btnSendTestDone;
    IBOutlet NSButton *btnSendRetest;
    
    NSThread *PACSocketCallBackThread;
    int DebugMsgCounter;
@private
    BOOL callBackEnable;
    
    
}
@property (assign) NSMutableDictionary * dicConfiguration;
@property (copy) NSString * strCfgFile;
@property (assign) GCDAsyncSocket  *_Socket;

//show the Panel
-(void)PrintLogFromOutSide:(NSString*)msg ClientName: (NSString*)name TCPinfo:(NSString*)msgType;


- (IBAction)actCheckVer:(id)sender;
- (IBAction)actConnect:(id)sender;
- (IBAction)actHelp:(id)sender;
- (IBAction)actSend:(id)sender;
- (IBAction)actRead:(id)sender;
- (IBAction)actQuery:(id)sender;
- (IBAction)actClear:(id)sender;
- (IBAction)actSendBarcode:(id)sender;
- (IBAction)actSendRetest:(id)sender;
- (IBAction)actSendTestdone:(id)sender;

@end
