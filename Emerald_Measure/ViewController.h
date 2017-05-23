//
//  ViewController.h
//  MK_TestingModel_Sample
//
//  Created by Michael on 16/11/10.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController <NSTextViewDelegate,NSTextFieldDelegate>
@property (weak) IBOutlet NSButton *stopBtn;
@property (weak) IBOutlet NSButton *startBtn;

@end