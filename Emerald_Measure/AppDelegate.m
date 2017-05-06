//
//  AppDelegate.m
//  Emerald_Measure
//
//  Created by Michael on 2017/4/24.
//  Copyright © 2017年 michael. All rights reserved.
//

#import "AppDelegate.h"
#import "PACSocketDebugWinDelegate.h"
#import "SerialPortDelegate.h"

@interface AppDelegate ()
{
    PACSocketDebugWinDelegate *pacSocketDelegate;
    SerialPortDelegate *serialPortDelegate;
}
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

//菜单工具的弹出_socketTool
- (IBAction)Socket_Tool:(id)sender
{
    
    if (!pacSocketDelegate)
    {
        pacSocketDelegate = [[PACSocketDebugWinDelegate alloc] init];
    }
    [pacSocketDelegate showWindow:self];
}

//菜单工具的弹出_serialTool
- (IBAction)SerialPort_Tool:(id)sender
{
    if (!serialPortDelegate)
    {
        serialPortDelegate = [[SerialPortDelegate alloc] init];
    }
    [serialPortDelegate showWindow:self];
}




@end
