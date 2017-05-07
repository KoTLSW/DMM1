//
//  TypeConverter.h
//  X322MotorTest
//
//  Created by CW-IT-MINI-001 on 13-12-6.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#ifndef TYPE_CONVERTER_H_H
#define TYPE_CONVERTER_H_H



#import <Foundation/Foundation.h>
#import "string.h"
#import "stdio.h"

@interface TypeConverter : NSObject

 //定义静态实例
+(TypeConverter*)Instance;

//将十进制装换成任意2~16进制
-(NSString*)ToAny:(int)number andDigits:(int)digits;

//十六进制向十进制转换
-(int)HexStrToInt:(NSString*)str;

//八进制向十进制转换
-(int)OctalStrToInt:(NSString*)octalStr;

//二进制向十进制转换
-(int)BinaryStrToInt:(NSString*)binaryStr;

////convert hex string to double
-(double)HexStrToDou:(NSString*)hexStr;

//将字符转换成AScall码形式
-(NSString*)CharToHexStr:(unsigned char*)chr Length:(int)length;

- (double) strToDouble:(NSString *)numStr isNumber:(BOOL *)isNumber;

@end

#endif
