//
//  CurrentStationWindow.m
//  Emerald_Measure
//
//  Created by Michael on 2017/5/4.
//  Copyright © 2017年 michael. All rights reserved.
//

#import "CurrentStationWindow.h"

@interface CurrentStationWindow ()

@end

@implementation CurrentStationWindow

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

//必须重写 init
-(id)init
{
    self = [super initWithWindowNibName:@"CurrentStationWindow"];
    return self;
}

- (IBAction)clickToPopCurrentStationArrBtn:(NSPopUpButton *)sender
{
    
}

- (IBAction)clickToRefreshTableView:(NSButton *)sender
{
    
}

- (IBAction)clickToCloseCurrentWindow:(NSButton *)sender
{
    
}

@end
