//
//  Regex.h
//  Regex
//
//  Created by GS on 15-5-8.
//  Copyright (c) 2015年 ___CW___. All rights reserved.
//

#ifndef REGEX_H_H
#define REGEX_H_H

#import <Foundation/Foundation.h>
#import "RegexKitLite.h"

@interface Regex : NSObject

//替换字符
+(NSString*)RegexReplaceStr:(NSString*)strInput andRemoveStr:(NSString*)strRemove
              andReplaceStr:(NSString*)strReplace;

//返回匹配字符
+(NSString*)RegexStrResult:(NSString*)strTempValue andRegex:(NSString*)strRegex;

//用所给的正则表达式从所给的字符串中匹配出
+(int)RegexIntResult:(NSString*)strTempValue andRegex:(NSString*)strRegex;

//用所给的正则表达式从所给的字符串中匹配出
+(int)RegexDoubleResult:(NSString*)strTempValue andRegex:(NSString*)strRegex;

//返回匹配列表
+(NSMutableArray *)RegexArrayResult:(NSString*)strTempValue andRegex:(NSString*)strRegex;

//返回是否匹配
+(BOOL)RegexBoolResult:(NSString*)strTempValue andRegex:(NSString*)strRegex;


@end


#endif