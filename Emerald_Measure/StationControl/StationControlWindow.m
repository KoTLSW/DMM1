//
//  StationControlWindow.m
//  Emerald_Measure
//
//  Created by Michael on 2017/5/6.
//  Copyright © 2017年 michael. All rights reserved.
//

#import "StationControlWindow.h"
#import "LoginWindow.h"

@interface StationControlWindow ()
{
    LoginWindow *loginWindow;
}
@end

@implementation StationControlWindow

-(id)init
{
    self = [super initWithWindowNibName:@"StationControlWindow"];
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    NSString *currentStationStr =[[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentStationStatus"];
    
    if ([currentStationStr isEqualToString:@"Station_0"])
    {
        stationBtn_0.state = YES;
    }
    if ([currentStationStr isEqualToString:@"Station_1"])
    {
        stationBtn_1.state = YES;
    }
    if ([currentStationStr isEqualToString:@"Station_2"])
    {
        stationBtn_2.state = YES;
    }
    if ([currentStationStr isEqualToString:@"Station_3"])
    {
        stationBtn_3.state = YES;
    }
    
    if (currentStationStr == nil || [currentStationStr  isEqual: @""])
    {
        stationBtn_0.state = YES;
        [[NSUserDefaults standardUserDefaults] setObject:stationBtn_0.title forKey:@"CurrentStationStatus"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    //添加选项按钮的通知监控
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(selectStationNoti:) name:@"SelectButtonlimit_Notification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disableToSelectStationNoti:) name:@"disableToSelectStationNoti" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeStationWindowNoti:) name:@"CloseStationControlWindow_Notificcation" object:nil];
}

//Notification
-(void)closeStationWindowNoti:(NSNotification *)noti
{
    [self.window orderOut:self];
}

-(void)selectStationNoti:(NSNotification *)noti
{
    stationBtn_0.enabled = YES;
    stationBtn_1.enabled = YES;
    stationBtn_2.enabled = YES;
    stationBtn_3.enabled = YES;
}
-(void)disableToSelectStationNoti:(NSNotification *)noti
{
    stationBtn_0.enabled = NO;
    stationBtn_1.enabled = NO;
    stationBtn_2.enabled = NO;
    stationBtn_3.enabled = NO;
}

- (IBAction)ClickToLogin:(NSButton *)sender
{
    if (!loginWindow)
    {
        loginWindow = [[LoginWindow alloc] init];
    }
    
    [loginWindow showWindow:self];
}
- (IBAction)ClickToOK:(NSButton *)sender
{
    [self.window orderOut:self];
}

- (IBAction)clickStation_0:(NSButton *)sender
{
    
    if (sender.state == YES)
    {
        stationBtn_1.state = NO;
        stationBtn_2.state = NO;
        stationBtn_3.state = NO;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:sender.title forKey:@"CurrentStationStatus"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changePlistFileNotification" object:sender.title];
}

- (IBAction)clickStation_1:(NSButton *)sender
{
    if (sender.state == YES)
    {
        stationBtn_0.state = NO;
        stationBtn_2.state = NO;
        stationBtn_3.state = NO;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:sender.title forKey:@"CurrentStationStatus"];
    [[NSUserDefaults standardUserDefaults] synchronize];
   
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changePlistFileNotification" object:sender.title];
}

- (IBAction)clickStation_2:(NSButton *)sender
{
    if (sender.state == YES)
    {
        stationBtn_0.state = NO;
        stationBtn_1.state = NO;
        stationBtn_3.state = NO;
    }
    [[NSUserDefaults standardUserDefaults] setObject:sender.title forKey:@"CurrentStationStatus"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changePlistFileNotification" object:sender.title];
}

- (IBAction)clickStation_3:(NSButton *)sender
{
    if (sender.state == YES)
    {
        stationBtn_0.state = NO;
        stationBtn_1.state = NO;
        stationBtn_2.state = NO;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:sender.title forKey:@"CurrentStationStatus"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changePlistFileNotification" object:sender.title];
}


@end
