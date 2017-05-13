//
//  MK_FileCSV.m
//  File
//
//  Created by Michael on 16/11/2.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import "MK_FileCSV.h"
#import "GetTimeDay.h"

@implementation MK_FileCSV

//=============================
+(MK_FileCSV *)shareInstance
{
    static MK_FileCSV *fileCSV = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fileCSV = [[MK_FileCSV alloc] init];
    });
    
    return fileCSV;
}

//新建csv文件:判断文件是否存在,不存在则新建文件,存在则追加文件数据
//=============================
-(BOOL)createOrFlowCSVFileWithFolderPath:(NSString *)folderPath Sn:(NSString *)sn TestItemStartTime:(NSString *)testItemStartTime TestItemEndTime:(NSString *)testItemEndTime TestItemContent:(NSString *)testItemContent TestItemTitle:(NSString *)testItemTitle TestResult:(NSString *)testResult
{
    if (folderPath==nil || [folderPath isEqual:@""] || sn==nil || [sn isEqual:@""] || testItemStartTime==nil || [testItemStartTime isEqual:@""] || testItemEndTime==nil || [testItemEndTime isEqual:@""] || testItemContent==nil || [testItemContent isEqual:@""] ||testItemTitle==nil || [testItemTitle isEqual:@""] ||testResult==nil || [testResult isEqual:@""] )
    {
        if (sn)
        {
            sn = sn;
        }
        else
        {
            sn = @"123456789";
            sn = [NSString stringWithFormat:@"MK_%@",sn];
        }
        
        if (folderPath)
        {
            folderPath = folderPath;
        }
        else
        {
            folderPath = @"/Users/";
        }
        if (testItemStartTime)
        {
            testItemStartTime = testItemStartTime;
        }
        else
        {
            testItemStartTime = @"_Year-Month-Day-Times";
        }
        
        if (testItemEndTime)
        {
            testItemEndTime = testItemEndTime;
        }
        else
        {
            testItemEndTime = @"_Year-Month-Day-Times";
        }
        if (testItemContent)
        {
            testItemContent = testItemContent;
        }
        else
        {
            testItemContent  =@"your data is NULL NULL NULL NULL!!";
        }
        
        if (testItemTitle)
        {
            testItemTitle = testItemTitle;
        }
        else
        {
            testItemTitle  =@"NA,NA,NA,NA,NA,NA,NA";
        }
        if (testResult)
        {
            testResult = testResult;
        }
        else
        {
            testResult  =@"NA";
        }
    }
    
    //创建由 日期 命名的文件
    //获取本地时间日期
    NSDate *dateT = [[NSDate alloc] init];
    //    NSLog(@"%@",dateT);
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    // Get Current  time
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *folderDateStr = [NSString stringWithFormat:@"%@",[formatter stringFromDate:dateT]];
    
    //=============== 创建csv文件 =====================
    //创建文件管理对象
    NSString *defaultFileName = [NSString stringWithFormat:@"%@/%@_Item.csv", folderPath,folderDateStr];
    
    //************** 2017.5.13  加入温湿度的CSV文件 ***********
    if ([testItemTitle containsString:@"HumitureValue"])
    {
        defaultFileName = [NSString stringWithFormat:@"%@/%@_Hum.csv", folderPath,folderDateStr];
    }
    
    //在当前路径下判断该文件是否存在,不存在则新建文件,存在则追加文件数据
    if (![[NSFileManager defaultManager] fileExistsAtPath:defaultFileName])
    {
        //----------------------新建文件并写入数据
        //写入字符数据,列表头,以及第一次数据
        NSString *firstData = [NSString stringWithFormat:@"%@\n%@,%@,%@,%@,%@",testItemTitle,sn,testResult,testItemContent,testItemStartTime, testItemEndTime];
        
        BOOL res = [firstData writeToFile:defaultFileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        if (res)
        {
            NSLog(@"文件%@写入数据成功!!",defaultFileName);
            return YES;
        }
        else
        {
            NSLog(@"文件%@写入数据失败!!",defaultFileName);
            return NO;
        }
    }
    else
    {
        //----------------------追加文件数据
        //打开原文件
        NSFileHandle *inFile = [NSFileHandle fileHandleForReadingAtPath:defaultFileName];
        
        //打开文件处理类,用于写操作
        inFile = [NSFileHandle fileHandleForWritingAtPath:defaultFileName];
        
        //找到并定位到 infile 的末尾位置(在此后追加文件数据
        [inFile seekToEndOfFile];
        
        //写入新的字符数据
        NSString *newStr = [NSString stringWithFormat:@"\n%@, %@, %@, %@, %@",sn,testResult,testItemContent,testItemStartTime, testItemEndTime];;
        
        //与第一次写入的字符对比
        if (![newStr isEqualToString:testItemContent])
        {
            [inFile writeData:[newStr dataUsingEncoding:NSUTF8StringEncoding]];
            NSLog(@"追加文件成功");
            //关闭文件
            [inFile closeFile];
             return YES;
        }
        else
        {
            NSLog(@"追加文件失败");
            //关闭文件
            [inFile closeFile];
            return NO;
        }
    }
}

//清空 userDefault 缓存
-(void)cleanUserDefault
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CSVsecondFolderPathKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//读取指定路径的 csv 文件内容
-(NSString *)CSV_ReadFromPath:(NSString *)path
{
    NSString *str=nil;
    
    if(path != nil)
    {
        //创建写文件句柄
        NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:path];
        
        //找到并定位到0
        [file seekToFileOffset:0];
        
        //读入字符串
        NSData *data = [file readDataToEndOfFile];
        
        str = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
        
        //关闭文件
        [file closeFile];
    }
    
    return str;
}


@end
