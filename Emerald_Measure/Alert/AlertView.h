//
//  AlertView.h
//  AlertView
//
//  Created by h on 16/11/14.
//  Copyright © 2016年 h. All rights reserved.
//

#import <Cocoa/Cocoa.h>


typedef void(^Block)(BOOL isOK);

@interface AlertView : NSView

@property(nonatomic,copy)Block backBlock;


-(id)initWithFrame:(NSRect)frameRect  andWindow:(NSView *)bottomView;


@end
