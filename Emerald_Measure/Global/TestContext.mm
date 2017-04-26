//
//  TestContext.cpp
//  CoreLib
//
//  Created by Ryan on 12-12-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#include "TestContext.h"

NSMutableDictionary * CTestContext::m_dicGlobal =nil;
NSMutableDictionary * CTestContext::m_dicConfiguration =nil;

CTestContext::CTestContext()
{
    m_dicContext = [NSMutableDictionary new];
    if (m_dicGlobal == nil)
    {
        m_dicGlobal = [NSMutableDictionary new];
    }
    
    if (m_dicConfiguration == nil)
    {
        m_dicConfiguration = [NSMutableDictionary new];
    }
}

CTestContext::~CTestContext()
{
    [m_dicContext release];
    m_dicContext = nil;
    [m_dicGlobal release];
    m_dicGlobal = nil;
    [m_dicConfiguration release];
    m_dicConfiguration = nil;
}

const char * CTestContext::getContext(char *szkey,int index) const
{
    id value=nil;
    switch (index) {
        case 0:
            value = [m_dicContext valueForKey:[NSString stringWithUTF8String:szkey]];
            break;
        case 1:
            value = [m_dicGlobal valueForKey:[NSString stringWithUTF8String:szkey]];
            break;
        case 2:
            value = [m_dicConfiguration valueForKey:[NSString stringWithUTF8String:szkey]];
            break;
            
        default:
            break;
    }
    
    if ([value isKindOfClass:[NSString class]])
    {
        return [value UTF8String];
    }
    else
    {
        return [[value stringValue] UTF8String];
    }
    return NULL;
}
