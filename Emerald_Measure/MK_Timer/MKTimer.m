//
//  MKTimer.m
//  MKTimer_Sample
//
//  Created by Michael on 2017/3/3.
//  Copyright © 2017年 Michael. All rights reserved.
//

#import "MKTimer.h"

@interface MKTimer()
{
    NSThread *mythread;
    NSTextField *timerLab;
    dispatch_queue_t   mk_queue;
    dispatch_source_t  mk_timer;
    float ct_cnt;
}
@end


@implementation MKTimer
#pragma mark set_Timer
//************* set timer ***************
-(void)setTimer:(float)seconds
{
    timerLab = [[NSTextField alloc] init];
    mk_queue = nil;
    mk_timer= nil;
    ct_cnt = 0;
    mythread = [[NSThread alloc] initWithTarget:self selector:@selector(timeWorking) object:nil];
    
    //创建异步队列
    if (mk_queue==nil)
    {
        mk_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    if (mk_timer==nil)
    {
        mk_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    }
    
    dispatch_source_set_timer(mk_timer, dispatch_walltime(NULL, 0), seconds * NSEC_PER_SEC, 0); //每秒执行
    // 开启定时器
    dispatch_resume(mk_timer);
}

-(void)timeWorking
{
    // 事件回调
    dispatch_source_set_event_handler(mk_timer, ^{
        
        // 在主线程中实现需要的功能
        dispatch_async(dispatch_get_main_queue(), ^{
            ct_cnt = ct_cnt + 1;
            timerLab.stringValue =[[NSString alloc]initWithFormat:@"CT:%.1f S",ct_cnt*0.1];
        });
    });
    
}


//************* start timer *************
-(void)startTimerWithTextField:(NSTextField *)TF
{
    timerLab = TF;
    [mythread start];
}

//************* end timer ****************
-(void)endTimer
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

//***************** stop timer *********************
-(void)stopTimer
{
    if(!mk_timer)
    {
        return;
    }
    dispatch_suspend(mk_timer);
}

//***************** continue timer *********************
-(void)continueTimer
{
    if(!mk_timer)
    {
        return;
    }
    dispatch_resume(mk_timer);
}


@end
