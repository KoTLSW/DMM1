//
//  MKCountDownTimer.h
//  MKTimer_Sample
//
//  Created by Michael on 2017/3/25.
//  Copyright © 2017年 Michael. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface MKCountDownTimer : NSObject
//================================ countDown timer ==================================
-(void)setCountDownTimer:(float)seconds;                            //设置一个倒计时器
-(void)startCountDownWithTextField:(NSTextField *)TF;               //倒计时开始
-(void)endCountDownTimer;                                           //停止并释放计时器

-(void)stopCountDownTimer;                                          //暂停倒计时
-(void)continueCountDownTimer;                                      //继续倒计时
//===================================================================================
@end
