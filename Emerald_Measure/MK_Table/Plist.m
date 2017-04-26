//
//  Plist.m
//  MKPlist_Sample
//
//  Created by Michael on 16/11/7.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import "Plist.h"

@implementation Plist

-(NSMutableArray *)PlistRead:(NSString *)fileName Key:(NSString *)key
{
    NSMutableArray *testItems = [[NSMutableArray alloc] init];
    
    //首先读取plist中的数据
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    //根据传入的关键字找到对应节点
    NSArray *arrayData = [dictionary objectForKey:key];
    
    if (arrayData != nil && ![arrayData isEqual:@""])
    {
        for (NSDictionary *dic in arrayData)
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
