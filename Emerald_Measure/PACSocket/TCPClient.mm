//
//  TCPClient.m
//  TCPManager
//
//  Created by Liang on 15-4-27.
//  Copyright (c) 2015年 Liu Liang. All rights reserved.
//

#import "TCPClient.h"

#define kHost_IP     @"host ip"
#define kHost_Port   @"host port"


@implementation TCPClient


//- (id)initWithIPPort:(NSString*)ip :(short)port
- (id)initWithConfigPath:(NSString*)strConfigPath
{
    NSLog(@"path:%@",strConfigPath);
    self = [super init];
    if (self)
    {
        m_strConfigPath = [[NSMutableString alloc] initWithString:strConfigPath];
        [self parseConfigParameter];
        //m_ClientSock = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        //m_ClientSock = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
        
        //m_ClientSock = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_queue_create([strConfigPath UTF8String], DISPATCH_QUEUE_SERIAL)];
        
        m_ClientSock = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_queue_create([strConfigPath UTF8String], DISPATCH_QUEUE_CONCURRENT)];
        
        m_ClientSock.delegate = self;
        
        m_dataRecvBuffer = [[NSMutableData alloc] initWithCapacity:1024*1024*2];
        m_strReadBuffer = [[NSMutableString alloc] init];
        m_lockBuffer = [[NSLock alloc] init];
        m_strOutput  = [[NSMutableString alloc] init];
        m_strStringToDetect  = [[NSMutableString alloc] initWithString:@"\r\n"];
        m_dataDetect = [[NSMutableData alloc] initWithBytes:"\r\n" length:2];
        m_dataSendBuffer = [[NSMutableData alloc] init];
        m_rng.length = 0;
        m_rng.location = 0;
        connectionName = strConfigPath;
        [self connect];
    }
    return self;
}

- (id)initWithIPPort:(NSString*)hwName :(NSString*)ip :(short)port
{
    self = [super init];
    if (self)
    {
        m_strServerIp = [NSMutableString stringWithString:ip];
        m_port = port;
        NSLog(@"<* %@ * Connect To Server> %@:%d",hwName,ip,port);
        m_ClientSock = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_queue_create([[NSString stringWithFormat:@"%@-%d",hwName,m_port] UTF8String], DISPATCH_QUEUE_CONCURRENT)];

        m_ClientSock.delegate = self;
        
        m_dataRecvBuffer = [[NSMutableData alloc] initWithCapacity:1024*1024*2];
        m_strReadBuffer = [[NSMutableString alloc] init];
        m_lockBuffer = [[NSLock alloc] init];
        m_strOutput  = [[NSMutableString alloc] init];
        m_strStringToDetect  = [[NSMutableString alloc] initWithString:@"\r\n"];
        m_dataDetect = [[NSMutableData alloc] initWithBytes:"\r\n" length:2];
        m_strConfigPath  = [[NSMutableString alloc] init];
        m_dataSendBuffer = [[NSMutableData alloc] init];
        m_rng.length = 0;
        m_rng.location = 0;
        connectionName = hwName;
        [self connect];
    }
    return self;
}

- (void)dealloc
{
    //[m_strServerIp release];
    [m_ClientSock release];
    [m_dataRecvBuffer release];
    [m_strReadBuffer release];
    [m_lockBuffer release];
    [m_strOutput release];
    [m_strStringToDetect release];
    [m_strConfigPath release];
    [m_dataSendBuffer release];
    [m_dataDetect release];
    [super dealloc];
}

- (void)parseConfigParameter
{
    NSDictionary* dicConfig = [NSDictionary dictionaryWithContentsOfFile:m_strConfigPath];
    NSString* str  = [dicConfig valueForKey:kHost_IP];
    if (str) {
         m_strServerIp = [[NSMutableString alloc] initWithString:str];
    }
    m_port = [[dicConfig valueForKey:kHost_Port] intValue];
}

- (int)connect
{
    NSError *err = nil;
    m_ConnState=[m_ClientSock connectToHost:m_strServerIp onPort:m_port error:&err];
    if(m_ConnState == NO)//fail
    {
        NSLog(@"failed to connect server：%@",m_strServerIp);
        return -1;
        
    }else
    {
        //NSLog(@"connect server：%@ successfully",m_strServerIp);
    }
    return 0;
}

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    //NSLog(@"%@", [NSString stringWithFormat:@"socket delegate connected server:%@",host]);
    
    [m_ClientSock readDataWithTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    m_ConnState = NO;
    NSLog(@"socket disconnected:%@",err);
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSMutableData* dataTmp = [[NSMutableData alloc] initWithData:data];
    char* p = NULL;
    if ([dataTmp length] > 0) {
        p = (char*)[dataTmp mutableBytes];
        for (int i=0; i<[dataTmp length]; i++) {
            if (p[i] == '\x0') {
                p[i] = '.';
            }
        }
    }
    [m_dataRecvBuffer appendData:dataTmp];
//    [self SerialPortCallback:m_dataRecvBuffer];
//    [m_dataRecvBuffer appendData:data];
    [m_ClientSock readDataWithTimeout:-1 tag:0];
}
-(void)SerialPortCallback:(NSMutableData*)ReadData
{

    NSString * str = [[NSString alloc] initWithData:ReadData encoding:NSUTF8StringEncoding];
    if (str==nil) {
        return;
    }
    NSRange rRange = [str rangeOfString:@"\r"];
    NSRange nRange = [str rangeOfString:@"\n"];
    
    if ([str rangeOfString:@"START TEST"].location!=NSNotFound)
    {

    }
    
    if (rRange.location!=NSNotFound or nRange.location != NSNotFound) //Has get notification;
    {
        [self clearBuffer];
//        CScriptEngine * pEngine = (CScriptEngine *)[pTestEngine GetScripEngine:0];
//        const char* strfile=[str cStringUsingEncoding:NSASCIIStringEncoding];
//        if(strfile==NULL)
//            return;
//        lua_State* lua = pEngine->m_pLuaState;
//        lua_getglobal(lua, "pacsocket");//To call pacsocket.lua
//        lua_pushfstring(lua,"FixtureCallback");
//        lua_gettable(lua,-2);
//        
//        if(lua_isfunction(lua,-1))
//        {
//            lua_pushfstring(lua, strfile);
//            int err=lua_pcall(lua, 1, 0, 0);
//            if(err!=0)
//            {
//                NSLog(@"PACSocket Fixture Call Back Error, Error Code is %d\r\n",err);
//            }
//        }else if (lua_isnil(lua, -1))
//        {
//            printf("can not fond burnKeyPressOrder function");
//        }
        
    }
    if (str) {
        [str release];
        str = nil;
    }
}
//-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data2 withTag:(long)tag
//{
//    NSString *receive = [[NSString alloc] initWithData:data2 encoding:NSUTF8StringEncoding];
//    [self addText:[NSString stringWithFormat:@"%@------>%@",_Socket.connectedHost,receive]];
//
//    // [s readDataWithTimeout:-1 tag:0];
//}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
    return -1;
}
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
    return -2;
}
- (BOOL)getConnectState;
{
    return m_ConnState;
}

- (NSData*)getStubData;
{
    return m_dataRecvBuffer;
}


- (void)clearStubData //make sure all data reading operation finish before use this function
{
    NSLog(@"stubSize:%lu",(unsigned long)[m_dataRecvBuffer length]);
    [m_dataRecvBuffer setData:nil];
    m_rng.length = 0;
    m_rng.location = 0;
}

- (void)clearBuffer //make sure all data reading operation finish before use this function
{
    [m_strReadBuffer setString:@""];
}

- (void)setDetectString:(NSString*)strDetectString
{
    [m_strStringToDetect setString:strDetectString];
}

- (void)tcpDisconnect
{
    [m_ClientSock disconnect];
}

-(int)send:(NSString*)str
{
    if ((m_ConnState && str) == false) return -1;
    [m_strReadBuffer setString:@""];
    const char* szData = [str UTF8String];
    NSData* dataToSend = [NSData dataWithBytes:szData length:[str length]];
    
    [m_dataSendBuffer setData:dataToSend];
    
    [m_ClientSock writeData:m_dataSendBuffer withTimeout:-1 tag:0];
    
    [m_ClientSock readDataWithTimeout:-1 tag:0];
    
    return 0;
    
}

-(int)waitString:(int)timeout
{
    if (m_ConnState == NO) {
        return -1;
    }
    int r = 0;
    NSTimeInterval starttime = [[NSDate date]timeIntervalSince1970];
    double tm = (double)timeout/1000;
    while (1)
    {
        NSRange current_read_rng = m_rng;
        if ([m_dataRecvBuffer length] > 0) {
            unsigned long max_len = [m_dataRecvBuffer length];
            if (max_len > 0) {
                current_read_rng.length = max_len - current_read_rng.location;
                NSData* data = [m_dataRecvBuffer subdataWithRange:current_read_rng];
                if (data && [data length]>0) {
                    //NSString* strTmp = [NSString stringWithUTF8String:(const char*)[data bytes]];
                    NSString* strTmp = [NSString stringWithCString:(const char*)[data bytes] encoding:NSASCIIStringEncoding];
                    if (strTmp && [strTmp length]>0) {
                        NSRange range = [strTmp rangeOfString:@"\n"];
                        if (range.location!=NSNotFound)
                        {
                            //NSLog(@"decteted string successfully");
                            r = 0;
                            break;
                        }
                    }
                }
            }
        }
//        if ([m_dataRecvBuffer length]>0) {
//            NSString* strtmp = [[NSString alloc]initWithData:m_dataRecvBuffer encoding:NSUTF8StringEncoding];
//            NSRange range = [strtmp rangeOfString:@"\n"];
//            if (range.location!=NSNotFound) {
//                r=0;
//                break;
//            }
//        }
        
        NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
        if ((now-starttime)>=tm)
        {
            r = -2;
            break;
        }
        
        if ([[NSThread currentThread] isCancelled])
        {
            r = 1;
            break;
        }
        
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
        [NSThread sleepForTimeInterval:0.001];
    }
    return r;
}

-(int)waitString:(int)timeout detectString:(NSString*) dectstr
{
    if (m_ConnState == NO) {
        return -1;
    }
    int r = 0;
    NSTimeInterval starttime = [[NSDate date]timeIntervalSince1970];
    double tm = (double)timeout/1000;
    while (1)
    {
        NSRange current_read_rng = m_rng;
        if ([m_dataRecvBuffer length] > 0) {
            unsigned long max_len = [m_dataRecvBuffer length];
            if (max_len > current_read_rng.location) {
                current_read_rng.length = max_len - current_read_rng.location;
                NSData* data = [m_dataRecvBuffer subdataWithRange:current_read_rng];
                if (data && [data length]>0) {
                    //NSString* strTmp = [NSString stringWithUTF8String:(const char*)[data bytes]];
                    NSString* strTmp = [NSString stringWithCString:(const char*)[data bytes] encoding:NSASCIIStringEncoding];
                    if (strTmp && [strTmp length]>0) {
                        NSRange range = [strTmp rangeOfString:dectstr];
                        if (range.location!=NSNotFound)
                        {
                            //NSLog(@"decteted string successfully");
                            r = 0;
                            break;
                        }
                    }
                }
            }
        }
        
        NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
        if ((now-starttime)>=tm)
        {
            r = -2;
            break;
        }
        
        if ([[NSThread currentThread] isCancelled])
        {
            r = 1;
            break;
        }

        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
        [NSThread sleepForTimeInterval:0.001];
    }
    return r;
}

- (NSString*)readString
{
    [m_strReadBuffer setString:@""];
    
    if ([m_dataRecvBuffer length] > 0) {
        unsigned long max_len = [m_dataRecvBuffer length];
        if (max_len > m_rng.location) {
            m_rng.length = max_len - m_rng.location;
            NSData* data = [m_dataRecvBuffer subdataWithRange:m_rng];
            if (data && [data length]>0) {
                [m_strReadBuffer setString:[NSString stringWithCString:(const char*)[data bytes] encoding:NSASCIIStringEncoding]];
                m_rng.location = m_rng.location + m_rng.length;
            }
        }
    }
    if(![m_strReadBuffer isEqual:@""])
    {
        NSLog(@"< TCP Read NSString> %@",m_strReadBuffer);
    }
    return m_strReadBuffer;
}

- (NSString*)sendRecv:(NSString*)str :(int)timeout :(NSString *)dectstr
{
    if (m_ConnState == NO) {
        return nil;
    }
    if (str) {
        [self send:str];
    }
    int r = [self waitString:timeout];
    if (r >= 0) {
        return [self readString];
    }
    return nil;
}

- (void)setDetectBytes:(NSString*)strBytesToDetect
{
    [self decodeBytes:strBytesToDetect :m_dataDetect];
}

-(int)waitBytes:(int)timeout
{
    if (m_ConnState == NO) {
        return -1;
    }
    int r = 0;
    NSTimeInterval starttime = [[NSDate date]timeIntervalSince1970];
    double tm = (double)timeout/1000.0;
    while (1)
    {
        NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
        if ((now-starttime)>=tm)
        {
            r = -2;
            break;
        }
        
        if ([[NSThread currentThread] isCancelled])
        {
            r = 1;
            break;
        }
        
        NSRange current_read_rng = m_rng;
        if ([m_dataRecvBuffer length] > 0) {
            unsigned long max_len = [m_dataRecvBuffer length];
            if (max_len > current_read_rng.location) {
                current_read_rng.length = max_len - current_read_rng.location;
                NSData* data = [m_dataRecvBuffer subdataWithRange:current_read_rng];
                if (data && [data length]>0) {
                    NSRange rngToSearch;
                    if ([data length] > [m_dataDetect length]) {
                        rngToSearch.location = [data length]-[m_dataDetect length];
                        rngToSearch.length = [m_dataDetect length];
                        NSRange range = [data rangeOfData:m_dataDetect options:NSDataSearchBackwards  range:rngToSearch];
                        if (range.location!=NSNotFound)
                        {
                            NSLog(@"decteted string successfully");
                            r = 0;
                            break;
                        }
                    }else if([data isEqualToData:m_dataDetect])
                    {
                        NSLog(@"decteted string successfully");
                        r = 0;
                        break;
                    }
                }
            }
        }
        
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
        [NSThread sleepForTimeInterval:0.001];
    }
    NSLog(@"dectetString returned r= %d",r);
    return r;
}


-(int)sendBytes:(NSString*)str
{
    if ((m_ConnState && str) == false) return -1;
    
    [self decodeBytes:str :m_dataSendBuffer];
    
    [m_ClientSock writeData:m_dataSendBuffer withTimeout:-1 tag:0];
    
    [m_ClientSock readDataWithTimeout:-1 tag:0];
    
    return 0;
    
}

- (NSString*)readBytes
{
    [m_strReadBuffer setString:@""];
    
    if ([m_dataRecvBuffer length] > 0) {
        unsigned long max_len = [m_dataRecvBuffer length];
        if (max_len > m_rng.location) {
            m_rng.length = max_len - m_rng.location;
            NSData* data = [m_dataRecvBuffer subdataWithRange:m_rng];
            if (data && [data length]>0) {
                [self encodeBytes:data :m_strReadBuffer];
                m_rng.location = m_rng.location + m_rng.length;
            }
        }
    }
    NSLog(@"< Encode Data > %@",m_strReadBuffer);
    return m_strReadBuffer;
}

- (NSString*)sendRecvBytes:(NSString*)str :(int)timeout
{
    if (m_ConnState == NO) {
        return nil;
    }
    if (str) {
        [self sendBytes:str];
    }
    int r = [self waitBytes:timeout];
    if (r >= 0) {
        return [self readBytes];
    }
    return nil;
}


-(unsigned long)encodeBytes:(NSData*)data :(NSMutableString*)mutstr
{
    if (data && mutstr) {
        if ([data length] == 0) return 0;
        [mutstr setString:@""];
#if 0
        const char* pBytes = [data bytes];
        for (int i=0; i<[data length]; i++) {
            [mutstr appendFormat:@"%02X", pBytes[i]];
        }
        return [mutstr length];
#else
        NSRange rng;
        rng.location = 0;
        rng.length = 1;
        unsigned char p[1];
        for (int i=0; i<[data length]; i++) {
            rng.location = i;
            [data getBytes:p range:rng];
            
            [mutstr appendFormat:@"%02X", p[0]];
        }
        return [mutstr length];
#endif
    }
    return 0;
}

-(unsigned long)decodeBytes:(NSString*)str :(NSMutableData*)mutdata
{
    if (str && [str length]>0 && mutdata)
    {
        if ([str length] % 2 == 0) {
            const char* pStr = [str cStringUsingEncoding:NSUTF8StringEncoding];
            if (pStr) {
                [mutdata setData:nil];
                unsigned char pSub[3] = {0,0,0};
                unsigned char p[2] = {0,0};
                
                for (int i=0; i<([str length]/2); i++) {
                    pSub[0] = pStr[i*2];
                    pSub[1] = pStr[i*2+1];
                    p[0] = strtoul((const char*)pSub, NULL, 16);
                    [mutdata appendBytes:p length:1];
                }
                return [mutdata length];
            }
        }
    }
    return 0;
}



@end


