//
//  AlertWindowController.m
//  DCR_TEST
//
//  Created by eastiwn on 17/3/10.
//  Copyright © 2017年 zfj. All rights reserved.
//

#import "AlertWindowController.h"

@interface AlertWindowController ()

@property (weak) IBOutlet NSTextField *useNameTF;

@property (weak) IBOutlet NSTextField *passwordTF;

@end

@implementation AlertWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    _useNameTF.stringValue=@"admin";
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


//登录按钮
- (IBAction)loginAction:(id)sender {
    
    NSLog(@"我已经点击了登陆按钮");
    //账号和密码正确，可以直接登出，并且改变
    if ([_useNameTF.stringValue isEqualToString:@"admin"]&&[_passwordTF.stringValue isEqualToString:@"123456"]) {
        
        [self.window orderOut:self];
        
        self.backBlock(YES);
    }
    else
    {
        //密码不正确，弹出提示框，请重新输入
        NSAlert *alert = [NSAlert new];
        alert.messageText = @"OK";
        alert.informativeText = @"登录密码错误，请重新登录";
        [alert addButtonWithTitle:@"确定"];
        [alert runModal];
    }
    
}


#pragma mark-------直接退出登录界面
- (IBAction)giveUpAction:(id)sender {
    self.backBlock(NO);
    [self.window orderOut:self];
}


@end
