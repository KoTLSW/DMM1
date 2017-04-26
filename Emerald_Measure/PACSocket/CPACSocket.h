//
//  CPACSocket.h
//  PACSocket
//
//  Created by Louis on 13-11-13.
//  Copyright (c) 2013年 Louis. All rights reserved.
//

#ifndef __PACSocket__CPACSocket__
#define __PACSocket__CPACSocket__

#include <iostream>
#import <Foundation/Foundation.h>
#include "TCPClient.h"

class CPACSocket {
public:
    CPACSocket();
    ~CPACSocket();
public:
    //for TCP
    void TCPClientRemove();//clear port
    //To connect to server
    int CreateTCPClient(const char* name, const char* ip, short port);
    //SendString with no feedback
    int TCPSendString(char* szString);
    //int clearStubData();
    int TCPSetDetectString(const char* detectString);
    int TCPWaitForString(int timeout );//ms
    int TCPDetectString(char* szDetectString, int iTimeout);
    //To get the string for port
    const char* TCPReadString();
    //Send string then receive
    const char* TCPSendReceive(char* str, int timeout, const char* dectstr);
    const char* getStubData();
    int getConnectState();


private:
    TCPClient* client;
    NSString* m_strTCPLogPath;
    
    //for lock
    pthread_mutex_t mMutexLock ;
    pthread_cond_t  mCondLock ;

};


#endif /* defined(__PACSocket__CPACSocket__) */
