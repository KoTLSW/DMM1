//
//  AppDelegate.m
//  Emerald_Measure
//
//  Created by Michael on 2017/4/24.
//  Copyright © 2017年 michael. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginWindow.h"
#import "ChooseWindowController.h"
#import "TestWindowController.h"

@interface AppDelegate ()
{
    LoginWindow *loginWindow;
    
}
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)StationControl_Tool:(id)sender
{
    
    if (!loginWindow)
    {
        loginWindow = [[LoginWindow alloc] init];
    }

    [loginWindow showWindow:self];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"disableToSelectStationNoti" object:nil];
    
}

- (IBAction)onCSAction:(id)sender {
   //selectOnCS
     [[NSNotificationCenter defaultCenter] postNotificationName:@"selectOnCS" object:nil];
    
}


- (IBAction)offCSAction:(id)sender {
    
    //selectOffCS
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectOffCS" object:nil];
    
}


@end
