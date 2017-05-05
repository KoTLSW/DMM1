//
//  Plist.m
//  MKPlist_Sample
//
//  Created by Michael on 16/11/7.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import "Plist.h"

@interface Plist()
{
    NSMutableArray *testItems;
    NSString *plistPath;
    NSArray *allItemsArr;
    NSArray *arrayData;
    NSMutableArray *allPlistArr;
    NSArray *currentStationArr;
    int currentStationIndex;
}
@end

@implementation Plist

-(NSMutableArray *)PlistRead:(NSString *)fileName Key:(NSString *)key
{
    currentStationIndex =(int)[[NSUserDefaults standardUserDefaults] objectForKey:@"currentStationIndex"];
    
    if (!testItems)
    {
        testItems = [[NSMutableArray alloc] init];
    }
    
    //首先读取plist中的数据
    if (!plistPath)
    {
        plistPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    }
    
//    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    if (!allItemsArr)
    {
        allItemsArr = [NSArray arrayWithContentsOfFile:plistPath];
    }
    
    //根据传入的关键字找到对应节点
//    NSArray *arrayData = [dictionary objectForKey:key];
    if (!arrayData)
    {
        arrayData = [[NSArray alloc] init];
    }
   
    if (!allPlistArr)
    {
        allPlistArr = [[NSMutableArray alloc] init];
    }
    
    for (int i=0; i< allItemsArr.count; i++)
    {
       arrayData = [allItemsArr objectAtIndex:i];
        [allPlistArr addObject:arrayData];
    }
    
    if (!currentStationArr)
    {
        currentStationArr  = [[NSArray alloc] init];
    }
    
    //判断当前的数组属于哪个测试工站
    currentStationArr = [allPlistArr objectAtIndex:currentStationIndex];
    
    
    if (currentStationArr != nil && ![currentStationArr isEqual:@""])
    {
        for (NSDictionary *dic in currentStationArr)
        {
            //读取 plist 文件中的固定数据
            Item *item = [[Item alloc] init];
            
            item.testItems     = [dic objectForKey:@"testItems"];
            item.units   = [dic objectForKey:@"units"];
            item.min    = [dic objectForKey:@"min"];
            item.typ    = [dic objectForKey:@"typ"];
            item.max    = [dic objectForKey:@"max"];
            item.result = [dic objectForKey:@"result"];
            item.value  = [dic objectForKey:@"value"];
            item.isTest = [[dic objectForKey:@"isTest"] boolValue];
            
            [testItems addObject:item];
        }
    }
    return testItems;
}

//=============================================
- (void)PlistWrite:(NSString*)filename Item:(NSString*)item
{
    //读取plist
    NSString *plistPath = [[NSBundle mainBundle]pathForResource:filename ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    //    //添加一项内容
    //    [data setObject:@"content" forKey:item];
    
    //    //获取应用程序沙盒的Documents目录
    //    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    //    NSString *path = [paths objectAtIndex:0];
    //
    //    //得到完整的文件名
    //    NSString *filepath=[path stringByAppendingPathComponent:filename];
    //    filepath=[filepath stringByAppendingString:@".plist"];
    
    [data writeToFile:plistPath atomically:YES];
}
//=============================================

@end
