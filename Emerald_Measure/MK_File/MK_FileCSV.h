//
//  MK_FileCSV.h
//  File
//
//  Created by Michael on 16/11/2.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MK_FileCSV : NSObject

+(MK_FileCSV *)shareInstance;

/**
 *  folderPath              :传入的文件夹路径
 *  sn                      :传入产品的sn
 *  testItemStartTime       :开始测试的时间
 *  testItemEndTime         :结束测试并生成文件的时间
 *  testItemContent         :传入的数据
 *  testResult              :测试结果
 *  testItemTitle           :测试项列表头
 */
//创建csv文件并写入数据
-(BOOL)createOrFlowCSVFileWithFolderPath:(NSString *)folderPath Sn:(NSString *)sn TestItemStartTime:(NSString *)testItemStartTime TestItemEndTime:(NSString *)testItemEndTime TestItemContent:(NSString *)testItemContent TestItemTitle:(NSString *)testItemTitle TestResult:(NSString *)testResult;

//读取指定路径的 csv 文件内容
-(NSString *)CSV_ReadFromPath:(NSString *)path;

//清空 userDefault 缓存
-(void)cleanUserDefault;

@end
