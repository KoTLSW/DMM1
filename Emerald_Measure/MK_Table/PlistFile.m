//
//  Config.m
//  TestResistance
//
//  Created by TOD on 6/26/14.
//  Copyright (c) 2014 CeWay. All rights reserved.
//

#import "PlistFile.h"

@implementation PlistFile

@synthesize strFileName=_strFileName;
@synthesize strFilePath=_strFilePath;
@synthesize dataDictionary=_dataDictionary;

//static Config *instance=nil;

//+(Config *)Instance
//{
//    if (instance==nil)
//    {
//        instance=[[super allocWithZone:NULL] init];
//        
//    }
//    return instance;
//}


-(id)init:(NSString*)strPlistName
{
    if(self=[super init])
    {
        _strFilePath=[[NSString alloc] init];
        _dataDictionary=[[NSMutableDictionary alloc] init];
        
        [self setStrFilePath:[[NSBundle mainBundle] pathForResource:strPlistName ofType:@"plist"]];
        [self ReadPlistParam];
    }
    
    return self;
}



//读取plist文件参数
-(void)ReadPlistParam
{
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:_strFilePath];
    
    if ([_dataDictionary count] > 0)
    {
        [_dataDictionary removeAllObjects];
    }
    
    [_dataDictionary addEntriesFromDictionary:dictionary];
}

//
-(NSArray*)ReadArray:(NSString*)strKey
{
    NSArray* arrayResult=[_dataDictionary objectForKey:strKey];
    return  arrayResult;
}

//get dictionary from dictionary
-(NSDictionary*)ReadDictionary:(NSString*)strKey
{
   NSDictionary* dicResult=[_dataDictionary objectForKey:strKey];
    return dicResult;
}

//get string from dictionary
-(NSString*)ReadString:(NSString*)strKey
{
    NSString* strResult=[_dataDictionary objectForKey:strKey];
    return strResult;
}



@end
