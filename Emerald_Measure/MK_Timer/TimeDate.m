//
//  TimeDate.m
//  BT_MIC_SPK
//
//  Created by EW on 16/5/30.
//  Copyright © 2016年 h. All rights reserved.
//

#import "TimeDate.h"

//=============================================
@implementation TimeDate
//=============================================
-(NSString*)GetSystemTimeSeconds
{
    // 获取系统当前时间
    NSDate * date = [NSDate date];
    NSTimeInterval sec = [date timeIntervalSinceNow];
    NSDate * currentDate = [[NSDate alloc] initWithTimeIntervalSinceNow:sec];

    //设置时间输出格式：
    NSDateFormatter * df = [[NSDateFormatter alloc] init ];
    [df setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
    NSString * na = [df stringFromDate:currentDate];
    
    return na;
}
//=============================================
-(NSString*)GetSystemTimeDay
{
    // 获取系统当前时间
    NSDate * date = [NSDate date];
    NSTimeInterval sec = [date timeIntervalSinceNow];
    NSDate * currentDate = [[NSDate alloc] initWithTimeIntervalSinceNow:sec];
    
    //设置时间输出格式：
    NSDateFormatter * df = [[NSDateFormatter alloc] init ];
    [df setDateFormat:@"yyyyMMdd"];
    NSString * na = [df stringFromDate:currentDate];
    
    return na;
}
//=============================================
@end
//=============================================
