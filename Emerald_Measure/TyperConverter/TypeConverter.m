//
//  TypeConverter.m
//  X322MotorTest
//
//  Created by CW-IT-MINI-001 on 13-12-6.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "TypeConverter.h"

static TypeConverter* typeConvert=nil;

@implementation TypeConverter

//创建静态实例，也即是单例模式
+(TypeConverter*)Instance
{
    if(typeConvert==nil)
    {
        typeConvert=[[TypeConverter alloc] init];
    }
    
    return typeConvert;
}

//字符转换成字符串
-(NSString*)CharToHexStr:(unsigned char*)chr Length:(int)length
{	
	NSMutableString* str = [NSMutableString stringWithCapacity:2];
	
	for (int i = 0; i < length; i++)
	{
		NSString* strSingle = [NSString stringWithFormat:@"%x ", chr[i]];
		
		if ([strSingle length] < 3)
		{
			[str appendString:[NSString stringWithFormat:@"0%@", strSingle]];
		}
		else
		{
			[str appendString:strSingle];
		}
	}
	
	return str;
}

//十进制向任意进制转换
-(NSString*)ToAny:(int)number andDigits:(int)digits
{
    if(digits>16 || digits<2)
    {
        return @"";
    }
    
    NSMutableString* strTemp=[[NSMutableString alloc] initWithString:@""];
    NSMutableString* strResult=[[NSMutableString alloc] initWithString:@""];
    
    while (number)
    {
        switch (number%digits)
        {
            case 15:[strTemp appendString:@"F"];
                break;
            case 14:[strTemp appendString:@"E"];
                break;
            case 13:[strTemp appendString:@"D"];
                break;
            case 12:[strTemp appendString:@"C"];
                break;
            case 11:[strTemp appendString:@"B"];
                break;
            case 10:[strTemp appendString:@"A"];
                break;
            default:[strTemp appendString:[NSString stringWithFormat:@"%d",number%digits]];
                break;
        }
        
        number=number/digits;
    }
    
    for (int i=(int)[strTemp length]; i>0; i--)
    {
        [strResult appendString:[[strTemp substringFromIndex:i-1] substringToIndex:1]];
    }
    
    return strResult;
}


//convert hex string to int
-(int)HexStrToInt:(NSString*)hexStr
{
    int result = 0;
    NSString* str = [[hexStr uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    for (int i = 0; i < [str length]; i++)
    {
        int charValue = [str characterAtIndex:i];
        
        if ((charValue >= '0') && (charValue <= '9'))
        {
            result += (charValue - '0') * pow(16, ([str length] - 1 -i));
        }
        else if ((charValue >= 'A') && (charValue <= 'F'))
        {
            result += (charValue - 'A' + 10) * pow(16, ([str length] - 1 -i));
        }
    }
    
    return result;
}

//八进制转换成十进制
-(int)OctalStrToInt:(NSString*)octalStr
{
    int result = 0;
    
    NSString* str = [[octalStr uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    for (int i = 0; i < [str length]; i++)
    {
        int charValue = [str characterAtIndex:i];
        
        if ((charValue >= '0') && (charValue <= '9'))
        {
            result += (charValue - '0') * pow(8, ([str length] - 1 -i));
        }
        else if ((charValue >= 'A') && (charValue <= 'F'))
        {
            result += (charValue - 'A' + 10) * pow(8, ([str length] - 1 -i));
        }
    }
    
    return result;
}

//二进制向十进制转换
-(int)BinaryStrToInt:(NSString*)binaryStr
{
    int result = 0;
    
    NSString* str = [[binaryStr uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    for (int i = 0; i < [str length]; i++)
    {
        int charValue = [str characterAtIndex:i];
        
        if ((charValue >= '0') && (charValue <= '9'))
        {
            result += (charValue - '0') * pow(2, ([str length] - 1 -i));
        }
        else if ((charValue >= 'A') && (charValue <= 'F'))
        {
            result += (charValue - 'A' + 10) * pow(2, ([str length] - 1 -i));
        }
    }
    
    return result;
}


//convert hex string to double
-(double)HexStrToDou:(NSString*)hexStr
{
    double result = 0;
    
    NSString* str = [[hexStr uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    for (int i = 0; i < [str length]; i++)
    {
        int charValue = [str characterAtIndex:i];
        
        if ((charValue >= '0') && (charValue <= '9'))
        {
            result += (charValue - '0') * pow(16, ([str length] - 1 -i));
        }
        else if ((charValue >= 'A') && (charValue <= 'F'))
        {
            result += (charValue - 'A' + 10) * pow(16, ([str length] - 1 -i));
        }
    }
    
    return result;
}


- (double) strToDouble:(NSString *)numStr isNumber:(BOOL *)isNumber
{
    int index = 0;
    int dotCount = 0;           // 统计点的个数
    double result = 0;          // 转换的结果
    BOOL bHexNumber = NO;
    NSString* lowercaseStr = [numStr lowercaseString];
    
    if ([lowercaseStr rangeOfString:@"0x"].length > 0) {    // 是否为十六进制字符串
        index = 2;
        bHexNumber = YES;
    }
    
    NSUInteger dotLocation = [lowercaseStr length];         // 记录小数点的位置
    NSRange range = [lowercaseStr rangeOfString:@"."];
    
    if (range.length > 0) {             // 是否有小数点
        dotLocation = range.location;
    }
    
    *isNumber = YES;
    
    for (int i = index; i < [lowercaseStr length]; i++) {
        char charValue = [lowercaseStr characterAtIndex:i];
        
        if (bHexNumber) {
            if ((charValue >= '0') && (charValue <= '9')) {
                result += (charValue - '0') * pow(16, ([lowercaseStr length] - 1 - i));
            }
            else if ((charValue >= 'a') && (charValue <= 'f')) {
                result += (charValue - 'a' + 10) * pow(16, ([lowercaseStr length] - 1 - i));
            }
            else {  // 存在非数字字符和非a ~ f字符时，转换不成功
                bHexNumber = NO;
                *isNumber = NO;
                result = 0;
                break;
            }
        }
        else {
            if ((charValue >= '0') && (charValue <= '9')) {
                if (dotCount == 0) {
                    result += (charValue - '0') * pow(10, dotLocation - i - 1);
                }
                else {
                    result += (charValue - '0') * pow(10, ((double)i - [lowercaseStr length]));
                }
            }
            else if (charValue == '.') {    // 点字符数量记录
                dotCount++;
                
                if (dotCount >= 2) {        // 点字符大于一个时，转换不成功
                    *isNumber = NO;
                    result = 0;
                    break;
                }
            }
            else {  // 存在非数字字符时，转换不成功
                *isNumber = NO;
                result = 0;
                break;
            }
        }
    }
    
    return result;
}

@end
