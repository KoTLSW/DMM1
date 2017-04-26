//
//  TCPClient.h
//  TCPManager
//
//  Created by Liang on 15-4-27.
//  Copyright (c) 2015年 Liu Liang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@interface TCPClient : NSObject
{
    GCDAsyncSocket* m_ClientSock;
    NSMutableString* m_strServerIp;
    short m_port;
    BOOL m_ConnState;
    NSMutableString* m_strConfigPath;
    NSMutableString* m_strStringToDetect;
    NSMutableData* m_dataDetect;
    NSMutableData* m_dataRecvBuffer;
    NSMutableString* m_strReadBuffer;
    NSMutableString* m_strOutput;
    NSLock* m_lockBuffer;
    NSString *connectionName;
    NSMutableData* m_dataSendBuffer;
    NSRange m_rng;
}
//-(void)setoutputview:(NSTextView *) view;
//- (id)initWithIPPort:(NSString*)ip :(short)port;

- (id)initWithConfigPath:(NSString*)strConfigPath;
- (id)initWithIPPort:(NSString*)hwName :(NSString*)ip :(short)port;
- (BOOL)getConnectState;
- (NSData*)getStubData;
- (void)clearStubData;
- (void)clearBuffer;

- (void)setDetectString:(NSString*)strDetectString;
- (int)send:(NSString*)str;
- (int)waitString:(int)timeout;
- (int)waitString:(int)timeout detectString:(NSString*) dectstr;
- (NSString*)readString;
- (NSString*)sendRecv:(NSString*)str :(int)timeout :(NSString*)dectstr;
- (void)tcpDisconnect;

- (void)setDetectBytes:(NSString*)strBytesToDetect;
-(int)waitBytes:(int)timeout;
-(int)sendBytes:(NSString*)str;
- (NSString*)readBytes;
- (NSString*)sendRecvBytes:(NSString*)str :(int)timeout;

@property (copy) NSString * connectionName;

@end
