//
//  LoginWindow.h
//  Emerald_Measure
//
//  Created by Michael on 2017/5/6.
//  Copyright © 2017年 michael. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LoginWindow : NSWindowController

@property (weak) IBOutlet NSTextField *userName;
@property (weak) IBOutlet NSSecureTextField *passWord;
@property (weak) IBOutlet NSTextField *messageLab;

@end
