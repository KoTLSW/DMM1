//
//  AlertWindowController.h
//  DCR_TEST
//
//  Created by eastiwn on 17/3/10.
//  Copyright © 2017年 zfj. All rights reserved.
//

#import <Cocoa/Cocoa.h>


typedef void(^Block)(BOOL isOK);

@interface AlertWindowController : NSWindowController

@property(nonatomic,copy)Block backBlock;
@end
