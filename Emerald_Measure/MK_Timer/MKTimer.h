//
//  MKTimer.h
//  MKTimer_Sample
//
//  Created by Michael on 2017/3/3.
//  Copyright © 2017年 Michael. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface MKTimer : NSObject
//================================= set timer =======================================
-(void)setTimer:(float)seconds;                                     // 设置一个定时器
-(void)startTimerWithTextField:(NSTextField *)TF;                   //定时器开始
-(void)endTimer;                                                    //定时器结束

-(void)stopTimer;                                                   //暂停倒计时
-(void)continueTimer;                                               //继续倒计时
//===================================================================================
@end
