//
//  Config.h
//  TestResistance
//
//  Created by TOD on 6/26/14.
//  Copyright (c) 2014 CeWay. All rights reserved.
//

#ifndef PLISTBASE_H_H
#define PLISTBASE_H_H

#import <Foundation/Foundation.h>


@interface PlistFile : NSObject
{
    NSString* _strFilePath;
    NSString* _strFileName;
    NSMutableDictionary* _dataDictionary;
}

@property(readwrite,copy)NSString* strFilePath;
@property(readwrite,copy)NSString* strFileName;
@property(readwrite,copy)NSMutableDictionary* dataDictionary;


-(id)init:(NSString*)strPlistName;

//
-(void)SetPath:(NSString*)strPlistName;

//
-(void)ReadPlistParam;

//
-(NSArray*)ReadArray:(NSString*)strKey;

//
-(NSDictionary*)ReadDictionary:(NSString*)strKey;

-(NSString*)ReadString:(NSString*)strKey;

-(void)WriteDictionaryToFile:(NSMutableDictionary*)dic;

-(void)WriteDictionaryForParentKey:(NSString*) parentKey  SubValue:(NSArray*)value;

@end

#endif
