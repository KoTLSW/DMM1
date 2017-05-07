//
//  MKCountDownTimer.m
//  MKTimer_Sample
//
//  Created by Michael on 2017/3/25.
//  Copyright © 2017年 Michael. All rights reserved.
//

#import "MKCountDownTimer.h"

@interface MKCountDownTimer()
{
    NSThread *mythread;
    NSTextField *timerLab;
    dispatch_queue_t   mk_queue;
    dispatch_source_t  mk_timer;
    float ct_cnt;
}
@end

@implementation MKCountDownTimer

//***************** set CountDown *********************
-(void)setCountDownTimer:(float)seconds
{
    timerLab = [[NSTextField alloc] init];
    mk_timer = nil;
    mk_queue = nil;
    ct_cnt = 0;
    mythread = [[NSThread alloc] initWithTarget:self selector:@selector(timeWorking) object:nil];
    
    if (mk_queue==nil)
    {
        mk_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    
    if (mk_timer==nil)
    {
        mk_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    }
    
    dispatch_source_set_timer(mk_timer, dispatch_walltime(NULL, 0), seconds * NSEC_PER_SEC, 0);
    dispatch_resume(mk_timer);
}

-(void)timeWorking
{
    if (timerLab == nil || [timerLab.stringValue isEqualToString:@"0"] || timerLab==0 || [timerLab.stringValue isEqualToString:@""] || [timerLab.stringValue isEqualToString:@" "])
    {
        [self endCountDownTimer];
        return;
    }
    
    ct_cnt = [timerLab.stringValue floatValue]*10;
    
    dispatch_source_set_event_handler(mk_timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            ct_cnt = ct_cnt-1;
            timerLab.stringValue = [[NSString alloc] initWithFormat:@"CT:%.1f S",ct_cnt*0.1];
        });
        
        if (ct_cnt==0)
        {
            [self endCountDownTimer];
        }
    });
}

//***************** stop CountDown *********************
-(void)stopCountDownTimer
{
    dispatch_suspend(mk_timer);
}

//***************** continue CountDown *********************
-(void)continueCountDownTimer
{
    dispatch_resume(mk_timer);
}

//***************** start CountDown *********************
-(void)startCountDownWithTextField:(NSTextField *)TF
{
    timerLab = TF;
    [mythread start];
}

//***************** end CountDown *********************
-(void)endCountDownTimer
{
    if (mk_timer == nil)
    {
        return;
    }
    [mythread cancel];
    dispatch_source_cancel(mk_timer);
    //定时器对象置空
    mk_queue = nil;
    mk_timer = nil;
    timerLab = nil;
    mythread = nil;
    ct_cnt = 0;
}

@end
