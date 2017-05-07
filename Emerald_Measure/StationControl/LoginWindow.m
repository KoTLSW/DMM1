//
//  LoginWindow.m
//  Emerald_Measure
//
//  Created by Michael on 2017/5/6.
//  Copyright © 2017年 michael. All rights reserved.
//

#import "LoginWindow.h"

@interface LoginWindow ()
{
    NSMutableDictionary *m_Dic;
}
@end

@implementation LoginWindow

-(id)init
{
    self = [super initWithWindowNibName:@"LoginWindow"];
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"UserLogin" ofType:@"plist"];
    m_Dic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
}

- (IBAction)clickToLogin:(NSButton *)sender
{
    if ([_userName.stringValue isEqualToString:[m_Dic objectForKey:@"username"]] && [_passWord.stringValue isEqualToString:[m_Dic objectForKey:@"password"]])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _messageLab.stringValue = @"enter !";
            _messageLab.textColor = [NSColor blueColor];
            
        });
        
        [self.window orderOut:self];
        
        //发送通知, 激活 PDCA 按钮功能
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PDCAButtonLimit_Notification" object:nil];
    }
    
    if ([_userName.stringValue isEqualToString:@"admin"] && [_passWord.stringValue isEqualToString:@"michael"])
    {
         [self.window orderOut:self];
        
        //发送通知,激活按钮状态
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectButtonlimit_Notification" object:nil];
        
        //发送通知, 激活 PDCA 按钮功能
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PDCAButtonLimit_Notification" object:nil];
    }
    
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _messageLab.stringValue = @"userName or passWord error!!";
            _messageLab.textColor = [NSColor redColor];
        });
    }
    
}

- (IBAction)clickToCancel:(NSButton *)sender
{
    // 4.关闭当前的登录窗口
    [self.window orderOut:self];
}

@end
