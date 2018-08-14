//
//  WindowController.m
//  Emerald_Measure
//
//  Created by mac on 2017/9/18.
//  Copyright © 2017年 michael. All rights reserved.
//

#import "TestWindowController.h"


static NSString *const kStoryboardName = @"Main";
static NSString *const kWindowControllerIdentifier = @"TestWindowController";

@interface TestWindowController ()

@end

@implementation TestWindowController

+(instancetype)windowController{
    
    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:kStoryboardName bundle:[NSBundle mainBundle]];
    TestWindowController *WC = [storyboard instantiateControllerWithIdentifier:kWindowControllerIdentifier];
    [WC.window setAnimationBehavior:NSWindowAnimationBehaviorDocumentWindow];
    [WC.window makeFirstResponder:nil];
    return WC;
}



- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
