//
//  CPACSocket.cpp
//  PACSocket
//
//  Created by Louis on 13-11-13.
//  Copyright (c) 2013年 Louis. All rights reserved.
//

#include "CPACSocket.h"
#include "PACSocketDebugWinDelegate.h"

extern PACSocketDebugWinDelegate *SocketDebugWinDelegate;

#define PORT_BASE 0

CPACSocket::CPACSocket()
{
    pthread_mutex_init(&mMutexLock, NULL) ;
    pthread_cond_init(&mCondLock, NULL) ;
}

CPACSocket::~CPACSocket()
{
    if (client != NULL) {
        [client release];
        client = nil;
    }
    pthread_cond_init(&mCondLock, NULL) ;
    pthread_mutex_destroy(&mMutexLock) ;
    return ;
}

void CPACSocket::TCPClientRemove()
{
    if(client!=NULL)
    {
        [client tcpDisconnect];
        [client release];
        client = NULL;
    }
}

int CPACSocket::getConnectState()
{
    return [client getConnectState];
}

const char* CPACSocket::getStubData()
{
    const void * dataTmp = [[client getStubData]bytes];
    if(dataTmp) return (const char*)dataTmp;
    else return NULL;
}

int CPACSocket::CreateTCPClient(const char* name, const char* ip, short port)
{
    
    if((port < PORT_BASE || (int)port > 32768))
        return -1;
    client = (TCPClient*)[[TCPClient alloc] initWithIPPort:[NSString stringWithUTF8String:name] :[NSString stringWithUTF8String:ip] :port];
    client.connectionName = [NSString stringWithUTF8String:name];
    [NSThread sleepForTimeInterval:0.1f];

    return [client getConnectState];
}

int CPACSocket::TCPSendString(char* szString)
{
    if (client)
    {
        [client readString];
        [NSThread sleepForTimeInterval:0.001];
        [SocketDebugWinDelegate PrintLogFromOutSide:[NSString stringWithUTF8String:szString] ClientName: client.connectionName TCPinfo:@"S"];
        [NSThread sleepForTimeInterval:0.001];

        return [client send:[NSString stringWithUTF8String:szString]];

        return 0;

    }
    return -99999;
}

int CPACSocket::TCPSetDetectString(const char* detectString)
{
    int r = 0;
    [client setDetectString:[NSString stringWithUTF8String:detectString]];
    return r;
}


int CPACSocket::TCPWaitForString(int timeout)
{
    int r = 0;
    r = [client waitString:timeout];
    return r;
    
}

int CPACSocket::TCPDetectString(char* szDetectString, int iTimeout)
{
    int r = 0;
    if (client)
    {
        TCPSetDetectString(szDetectString);
        r = TCPWaitForString(iTimeout);
    }
    else{
        r = -99999;
    }
    
    return r;
}


const char* CPACSocket::TCPReadString()
{
    if (client)
    {
        [client clearBuffer];
        [NSThread sleepForTimeInterval:0.001];
        NSString * tmp = [client readString];
        [NSThread sleepForTimeInterval:0.001];
        if (![tmp  isEqual: @""])
        {
            [SocketDebugWinDelegate PrintLogFromOutSide:tmp ClientName: client.connectionName TCPinfo:@"R"];
        }
        return [tmp UTF8String];
    }
    return NULL;
}

const char* CPACSocket::TCPSendReceive(char* str, int timeout ,const char* dectstr)
{
    NSString *tempStr = [NSString stringWithUTF8String:dectstr];
    if (client)
    {
        [client readString];
        [client clearBuffer];
        [NSThread sleepForTimeInterval:0.001];
        [SocketDebugWinDelegate PrintLogFromOutSide:[NSString stringWithUTF8String:str] ClientName: client.connectionName TCPinfo:@"S"];
        [NSThread sleepForTimeInterval:0.001];
        const char* readBuf = [[client sendRecv:[NSString stringWithFormat:@"%s",str] :timeout :tempStr]UTF8String];
        if (readBuf == NULL)
        {
            NSString * tmp = [client readString];
            [NSThread sleepForTimeInterval:0.001];
            if ([tmp isNotEqualTo:@""]) {
                [SocketDebugWinDelegate PrintLogFromOutSide:tmp ClientName: client.connectionName TCPinfo:@"R"];
            }
            else
            {
                const char *cmdNull = "null";
                [SocketDebugWinDelegate PrintLogFromOutSide:[NSString stringWithUTF8String:cmdNull] ClientName: client.connectionName TCPinfo:@"R"];
            }
            [NSThread sleepForTimeInterval:0.001];
        }
        else
        {
            [NSThread sleepForTimeInterval:0.001];
            [SocketDebugWinDelegate PrintLogFromOutSide:[NSString stringWithUTF8String:readBuf] ClientName: client.connectionName TCPinfo:@"R"];
            [NSThread sleepForTimeInterval:0.001];
        }

        
        return readBuf;
    }
    else
    {
        return NULL;
    }
}



