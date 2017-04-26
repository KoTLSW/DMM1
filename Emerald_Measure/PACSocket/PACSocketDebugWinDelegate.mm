//
//  PACSocketDebugWinDelegate.m
//  HowToWorks
//
//  Created by h on 17/4/18.
//  Copyright © 2017年 bill. All rights reserved.
//

#import "PACSocketDebugWinDelegate.h"
#import "CPACSocket.h"
#include "TestContext.h"

#define KEY_PACSocketAddress         @"PACSocketAddress"
#define KEY_PACSocketSetting         @"PACSocketSetting"
#define KEY_PACSocketName            @"PACSocketName"
#define KEY_PACSocketTimeout         @"PACSocketTimeout"
#define KEY_PACSocketDectStr         @"PACSocketDectstr"
#define KEY_PACCallBackEnable        @"PACSocketCallBackEnable"

@interface PACSocketDebugWinDelegate()
{

    CPACSocket *PACSocket;
}
@end

PACSocketDebugWinDelegate* SocketDebugWinDelegate = (PACSocketDebugWinDelegate*)nil;
@implementation PACSocketDebugWinDelegate
@synthesize dicConfiguration,strCfgFile ;
@synthesize _Socket;
bool connectOK=false;

- (id)init
{
    self = [super initWithWindowNibName:@"PACSocketDebug"];
    PACSocket = new CPACSocket();
    if (self) {
        dicConfiguration = [[NSMutableDictionary alloc] init] ;
//        NSString *config_dir  = [[PathManager sharedManager] configPath];
//        NSString *config_file = [config_dir stringByAppendingPathComponent:@"/GT_PACSocket_Config.plist"];
//        
//        [[NSFileManager defaultManager] createDirectoryAtPath:config_dir withIntermediateDirectories:YES attributes:nil error:nil];
//        self.strCfgFile = config_file;
//        //add notification for UI Menu add....
//        [[NSNotificationCenter defaultCenter] addObserver:self selector
//                                                         :@selector(handleNotification:) name
//                                                         :kNotificationAttachMenu object
//                                                         :nil] ;
//        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector
//                                                         :@selector(handleNotification:) name
//                                                         :@"OnShowMeasurePanel" object
//                                                         :nil] ;
//        //handle notification
//        [[NSNotificationCenter defaultCenter] addObserver:self selector
//                                                         :@selector(SaveLogNotification:) name
//                                                         :kNotificationSaveLog object
//                                                         :nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector
//                                                         :@selector(SetAppDidFinishLaunching:) name
//                                                         :kNotificationAppDidFinishLaunching object
//                                                         :nil];
    }
    SocketDebugWinDelegate = self;
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(void)awakeFromNib
{
    [self LoadConfig:strCfgFile];
    NSString *strTmp = [dicConfiguration objectForKey:KEY_PACSocketAddress] ;
    if (strTmp)
    {
        [ipaddress setStringValue:strTmp];
    }
    else
    {
        [ipaddress setStringValue:@"10.0.0.32"] ;
    }
    strTmp = [dicConfiguration objectForKey:KEY_PACSocketSetting] ;
    if (strTmp)
    {
        [ipPort setStringValue:strTmp];
    }
    else
    {
        [ipPort setStringValue:@"6340"] ;
    }
    strTmp = [dicConfiguration objectForKey:KEY_PACSocketName];
    if (strTmp) {
        [socketName setStringValue:strTmp];
    }
    else
    {
        [socketName setStringValue:@"PAC"];
    }
    strTmp = [dicConfiguration objectForKey:KEY_PACSocketTimeout];
    if (strTmp) {
        [forTimeout setStringValue:strTmp];
    }
    else
    {
        [forTimeout setStringValue:@"2000"];
    }
    strTmp = [dicConfiguration objectForKey:KEY_PACSocketDectStr];
    if (strTmp) {
        [AddingStr setStringValue:strTmp];
    }
    else
    {
        [AddingStr setStringValue:@"\r\n"];
    }
    
    if (!connectOK) {
        [btnSend setEnabled:false];
        [btnCheckVer setEnabled:false];
    }
    [btnSendBarcode setHidden:true];
    [btnSendRetest setHidden:true];
    [btnSendTestDone setHidden:true];
    PACSocketCallBackThread = [[NSThread alloc]initWithTarget:self selector:@selector(socketCallBack) object:nil];
    [PACSocketCallBackThread setName:@"PACSocketCallBack"];
    [PACSocketCallBackThread start];//开始线程
}

-(void)socketCallBack
{
    NSString *ccEnable = [dicConfiguration valueForKey:KEY_PACCallBackEnable];
    NSString *strPACSocketAddr = [dicConfiguration valueForKey:KEY_PACSocketAddress] ;
    NSString *strPACSocketSetting = [dicConfiguration valueForKey:KEY_PACSocketSetting];
    NSString *strPACSocketName = [dicConfiguration valueForKey:KEY_PACSocketName];
    if (ccEnable != nil && [ccEnable  isEqual: @"true"]) {
        if (strPACSocketAddr==nil || strPACSocketAddr.length==0)
            strPACSocketAddr = @"10.0.0.32" ;
        
        if (strPACSocketSetting==nil || strPACSocketSetting.length==0)
            strPACSocketAddr = @"7600" ;
        
        PACSocket->CreateTCPClient([strPACSocketName UTF8String], [strPACSocketAddr UTF8String], [strPACSocketSetting intValue]);
        
        while (true)//
        {
            NSString *tmpInit = [CTestContext::m_dicGlobal valueForKey:kContextStartCheckUSBAfterInit];
            if ([tmpInit isEqualToString:@"InitOK"])
            {
//                if (![pTestEngine IsTesting:-1])
//                {
//                    if ([self LuaCallBackFinishOrNot]) {
//                        NSLog(@"!!!!!!!!!!!!Lua Finished!!!!!!!!!!");
//                        break;
//                    }
//                }else
//                {
//                    NSLog(@"!!!!!!!!!!!!Lua Abort!!!!!!!!!!");
//                    break;
//                }
            }
            else
            {
                NSLog(@"Init is not ready!!!No need Call Lua");
            }
            [NSThread sleepForTimeInterval:0.5f];
        }
        PACSocket->TCPClientRemove();
    }
    
    [NSThread exit];
    NSLog(@"socketCallBack:NSThread exit");
}


//-(void)OnCheckNotification:(NSNotification *)nf
//{
//    NSString* name = [nf name];
//    if ([name isEqualToString:kNotificationOnTestFinish])
//    {
//        //if([CheckChangeUUTThread isFinished])
//        //{
//        PACSocketCallBackThread = [[NSThread alloc]initWithTarget:self selector:@selector(socketCallBack) object:nil];
//        [PACSocketCallBackThread setName:@"SocketCallBack"];
//        [PACSocketCallBackThread start];//开始线程
//        //}
//        NSLog(@"socketCallBack:kNotificationOnTestFinish");
//    }
//    else if([name isEqualToString:kNotificationOnTestPause])
//    {
//        PACSocketCallBackThread = [[NSThread alloc]initWithTarget:self selector:@selector(socketCallBack) object:nil];
//        [PACSocketCallBackThread setName:@"SocketCallBack"];
//        [PACSocketCallBackThread start];//开始线程
//        NSLog(@"socketCallBack:kNotificationOnTestPause");
//    }
//    else if([name isEqualToString:kNotificationOnTestResume])
//    {
//        PACSocketCallBackThread = [[NSThread alloc]initWithTarget:self selector:@selector(socketCallBack) object:nil];
//        [PACSocketCallBackThread setName:@"SocketCallBack"];
//        [PACSocketCallBackThread start];//开始线程
//        NSLog(@"socketCallBack:kNotificationOnTestResume");
//    }
//    else if([name isEqualToString:kNotificationOnTestStop])
//    {
//        PACSocketCallBackThread = [[NSThread alloc]initWithTarget:self selector:@selector(socketCallBack) object:nil];
//        [PACSocketCallBackThread setName:@"SocketCallBack"];
//        [PACSocketCallBackThread start];//开始线程
//        NSLog(@"socketCallBack:kNotificationOnTestStop");
//    }
//}

////调Lua,循环查询是否结束,如果结束则结束循环
//-(bool)LuaCallBackFinishOrNot
//{
//    CScriptEngine * se = (CScriptEngine *)[pTestEngine GetScripEngine:0];
//    lua_State * LuaState = se->m_pLuaState;
//    //std::mutex g_manualLua_mutex;
//    bool ret = false;
//    //g_manualLua_mutex.lock();
//    lua_getglobal(LuaState, "pacsocket");
//    lua_pushfstring(LuaState,"PACSocketCallBack");
//    lua_gettable(LuaState,-2);
//    if(lua_isfunction(LuaState,-1))
//    {
//        int err=lua_pcall(LuaState, 0, 1, 0);
//        if(err==0)
//        {
//            ret = (bool)lua_toboolean(LuaState, -1);
//        }
//        else
//        {
//            printf("error with function call:\r\n%s",lua_tostring(LuaState, -1));
//            NSRunAlertPanel(@"Error", @"error with function call:\r\n%@", @"OK", nil, nil,[NSString stringWithCString:lua_tostring(LuaState, -1) encoding:NSUTF8StringEncoding]);
//        }
//    }
//    else if (lua_isnil(LuaState, -1))
//    {
//        printf("Can not find PACSocketCallBack function1");
//        NSRunAlertPanel(@"Error", @"nil! no PACSocketCallBack function!", @"OK", nil, nil);
//        return true;
//    }
//    else
//    {
//        printf("Can not find PACSocketCallBack function2");
//        NSRunAlertPanel(@"Error", @"error with PACSocketCallBack function call!", @"OK", nil, nil);
//        return true;
//    }
//    //g_manualLua_mutex.unlock();
//    
//    return ret;
//}

-(void)PACSocketDeviceInitial
{
    NSString *strPACSocketAddr = [dicConfiguration valueForKey:KEY_PACSocketAddress] ;
    NSString *strPACSocketSetting = [dicConfiguration valueForKey:KEY_PACSocketSetting];
    NSString *strPACSocketName = [dicConfiguration valueForKey:KEY_PACSocketName];
    
    
    if (strPACSocketAddr==nil || strPACSocketAddr.length==0)
        strPACSocketAddr = @"10.0.0.32" ;
    
    if (strPACSocketSetting==nil || strPACSocketSetting.length==0)
        strPACSocketAddr = @"7600" ;
    
    int ret = PACSocket->CreateTCPClient([strPACSocketName UTF8String], [strPACSocketAddr UTF8String], [strPACSocketSetting intValue]);
    if (ret < 0)
    {
        [self showWarning:[NSString stringWithFormat:@"Fail to connect to the server!"]];
        [statusMsg setStringValue:@"Connect Error!"];            }
    else
    {
        [ipaddress setEnabled:false];
        [ipPort setEnabled:false];
        [btnSend setEnabled:true];
        [btnCheckVer setEnabled:true];
        [socketName setEnabled:false];
        
        
        [btnConnect setTitle:@"Disconnect"];
        [statusMsg setStringValue:@"Connect OK!"];
        
        connectOK = true;
    }
    //    const char* receviedStr = PACSocket->getStubData();
    //    if (strlen(receviedStr)>0) {
    //        [self addText:[NSString stringWithFormat:@"<------Get data from %@: %s",[ipaddress stringValue],receviedStr]];
    //    }
    //    [self SerialPortCallback:receviedStr];
    
    //initial device
//    NSBundle * bundle = [NSBundle bundleForClass:[self class]];
//    
//    NSString * str = @"pacsocket.Reset()";
    
//    CScriptEngine * pEngine = (CScriptEngine *)[pTestEngine GetScripEngine:0];
//    
//    int err = pEngine->DoString([str UTF8String]);
//    if (err)
//    {
//        NSRunAlertPanel(@"Load Device", @"Failed to load %@,with message :\r\n%s", @"OK", nil, nil,[[bundle bundlePath] lastPathComponent],lua_tostring(pEngine->m_pLuaState, -1));
//    }
    return ;
}

-(int)LoadConfig:(NSString *)strfile
{
    NSFileManager * fm = [NSFileManager defaultManager];
    
    //default parameter
    if (![fm fileExistsAtPath:strfile]) {
        [dicConfiguration setValue:@"10.0.0.32" forKey:KEY_PACSocketAddress];
        [dicConfiguration setValue:@"7600"  forKey:KEY_PACSocketSetting];
        [dicConfiguration setValue:@"PAC" forKey:KEY_PACSocketName];
        [dicConfiguration setValue:@"2000"  forKey:KEY_PACSocketTimeout];
        [dicConfiguration setValue:@"false" forKey:KEY_PACCallBackEnable];
    }
    else
    {
        [dicConfiguration setValuesForKeysWithDictionary:[NSDictionary dictionaryWithContentsOfFile:strfile]];
    }
    
    //[self PACSocketDeviceInitial];
    return 0;
}

- (void)dealloc
{
    delete PACSocket ;
    [[NSNotificationCenter defaultCenter] removeObserver:self] ;
    [super dealloc];
}

#pragma mark--notification for Menu
////For the menu
//-(void)handleNotification:(NSNotification*)nf
//{
//    NSDictionary *userInfo = [nf userInfo] ;
//    if ([nf.name isEqualToString:kNotificationAttachMenu])
//    {
//        NSMenu * instrMenu = [userInfo objectForKey:@"menus"];
//        [instrMenu addItem:menuItem];
//    }else if ([nf.name isEqualToString:@"OnShowMeasurePanel"])
//    {
//        NSMutableDictionary *userInfo = (NSMutableDictionary*)[nf userInfo] ;
//        NSString *strMSG = [userInfo valueForKey:@"PromptMsg"] ;
//        if (strMSG==nil)
//            strMSG = @"" ;
//        int rtn = [self ShowMeasurePanel:strMSG] ;
//        [userInfo setValue:[NSString stringWithFormat:@"%d",rtn] forKey:@"MeasurePanelResult"] ;
//    }
//    
//    return ;
//}

//-(void)SaveLogNotification:(NSNotification *)nf
//{
//    NSDictionary * dic = [nf userInfo];
//    int index = [[dic objectForKey:KEY_FIXTURE_ID] intValue];
//    NSString * strpath = [dic objectForKey:KEY_NF_UARTPATH];
//    if (strpath)
//    {
//        NSString* path = [[strpath lastPathComponent] stringByReplacingOccurrencesOfString:@"uart" withString:[NSString stringWithFormat:@"Socket_%d",index]];
//        strpath = [[strpath stringByDeletingLastPathComponent]stringByAppendingString:[NSString stringWithFormat:@"/%@",path]];
//        NSLog(@"Save Uart Log : %@ at index: %d",strpath,index);
//        [self SaveLog:strpath index:index];
//    }
//}

//-(void)SetAppDidFinishLaunching:(NSNotification *)nf
//{
//    [CTestContext::m_dicGlobal setValue:@"InitOK" forKey:kContextStartCheckUSBAfterInit];
//}

-(int)SaveLog:(NSString *)filepath index:(int)uID
{
    [[NSFileManager defaultManager] createDirectoryAtPath:[filepath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
    NSError * err;
    BOOL b =  [[mTVOutput string]writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:&err];
    if (!b)
    {
        NSString * strError = [NSString stringWithFormat:@"Save TCP uart log failed!\r\n%@",[err description]];
        NSRunAlertPanel(@"Save Log", @"%@", @"OK", nil, nil, strError);
    }
    [self performSelectorOnMainThread:@selector(ClearScreen) withObject:nil waitUntilDone:YES];
    return b;
}

//-(IBAction)menu_ShowDebugPanel:(id)sender
//{
//    [mWinCtrlPanel center];
//    [mWinCtrlPanel makeKeyAndOrderFront:sender];
//}

bool mLoopAgilentMeasure = FALSE ;
-(int)ShowMeasurePanel:(NSString*)msg
{
    //enabled measure ...
    //[self performSelectorInBackground:@selector(loopELoadMeasure) withObject:nil] ;
    int rtn =0 ;
    mLoopAgilentMeasure = FALSE ;
    return rtn ;
}

-(void)showWarning:(NSString*)msg
{
    NSRunAlertPanel(@"Warning", @"%@", @"OK", nil, nil, msg);
}
unsigned int msg_count = 0;
-(void)addText:(NSString *)msg
{
    DebugMsgCounter++;
    if (DebugMsgCounter > 10000) {
        [mTVOutput setString:@""];
        DebugMsgCounter = 0;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss.SSS : "];
    
    NSAttributedString *theString;
    msg = [msg stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    msg = [msg stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSString * str = [NSString stringWithFormat:@"%@ %@\r",[dateFormatter stringFromDate:[NSDate date]],msg];
    theString = [[NSAttributedString alloc] initWithString:str];
    [[mTVOutput textStorage] appendAttributedString: theString];
    if (dateFormatter)
    {
        [dateFormatter release];
    }
    if (theString)
    {
        [theString release];
    }
}

#pragma mark--action function

- (IBAction)actCheckVer:(id)sender {
    NSString *serverIP = [ipaddress stringValue];
    
    int serverPort = [ipPort intValue];
    int ret = PACSocket->CreateTCPClient("x396", [serverIP UTF8String], (short)serverPort);
    if (ret < 0)
    {
        NSRunAlertPanel(@"PACSocket", @"debug", @"ok",nil,nil);
    }
    else
    {
        // NSRunAlertPanel(@"PACSocket", @"debugwww", @"ok",nil,nil);
    }
}


- (IBAction)actConnect:(id)sender {
    //NSRunAlertPanel(@"PACSocket", @"debug", @"ok",nil,nil);
    NSString *serverIP = [ipaddress stringValue];
    NSString *serverPort = [ipPort stringValue];
    if (([serverPort  isEqual: @""]) or ([serverIP isEqual: @""])) {
        [self showWarning:@"IP地址和端口都不能为空!"];
        //NSButtonCell *cell = [[NSButtonCell alloc]init];
        //NSImage *image = [[NSImage alloc]initWithContentsOfFile:@"/git/x396/SourceCode/IATestManager/image/Connecterror.ICO"];
        //[cell setImage:image];
        connectOK = false;
    }
    else
    {
        //NSString *serverIp = [ipaddress stringValue];
        int serverPort=[ipPort intValue];
        
        //NSString* interfacePort = [NSString stringWithFormat:@"%d", serverPort];
        
        //NSString* interface = [[serverIp stringByAppendingString:@": "] stringByAppendingString: interfacePort];
        
        
        //NSData *data = [@"Ready" dataUsingEncoding:NSUTF8StringEncoding];
        if ([btnConnect.title isEqualToString:@"Connect"])  //Connect
        {
            //_Socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
            
            NSError *error=nil;
            //connectOK = [_Socket connectToHost:serverIp onPort:serverPort error:&error];
            int ret = PACSocket->CreateTCPClient("x396", [serverIP UTF8String], (short)serverPort);
            if (ret < 0)
            {
                [self showWarning:[NSString stringWithFormat:@"Error info: %@", error]];
                [statusMsg setStringValue:@"Connect Error!"];            }
            else
            {
                //[_Socket writeData: data  withTimeout:-1 tag:0];
                //[_Socket readDataWithTimeout:-1 tag:0];
                //[self addText:[NSString stringWithFormat:@"Ready ------>%@",[ipaddress stringValue]]];
                [btnConnect setTitle:@"Disconnect"];
                [statusMsg setStringValue:@"Connect OK!"];
                [ipaddress setEnabled:false];
                [ipPort setEnabled:false];
                [btnSend setEnabled:true];
                [btnCheckVer setEnabled:true];
                [socketName setEnabled:false];
                
                [dicConfiguration setValue:[NSString stringWithFormat:@"%@",ipaddress.stringValue] forKey:KEY_PACSocketAddress] ;
                [dicConfiguration setValue:[NSString stringWithFormat:@"%@",ipPort.stringValue] forKey:KEY_PACSocketSetting] ;
                [dicConfiguration setValue:[NSString stringWithFormat:@"%@",socketName.stringValue] forKey:KEY_PACSocketName] ;
                [dicConfiguration setValue:[NSString stringWithFormat:@"%@",forTimeout.stringValue] forKey:KEY_PACSocketTimeout];
                //[self PACSocketDeviceInitial] ;
                [dicConfiguration writeToFile:strCfgFile atomically:YES];
                [CTestContext::m_dicGlobal setValue:@"InitNotOK" forKey:kContextStartCheckUSBAfterInit];
                connectOK = true;
            }
            
            
        }
        else //Disconnect
        {
            [_Socket disconnect];
            PACSocket->TCPClientRemove();//release!!
            [btnCheckVer setEnabled:false];
            [statusMsg setStringValue:@"Disconnect!"];
            [btnConnect setTitle:@"Connect"];
            [ipaddress setEnabled:true];
            [ipPort setEnabled:true];
            [btnSend setEnabled:false];
            [socketName setEnabled:true];
            [CTestContext::m_dicGlobal setValue:@"InitOK" forKey:kContextStartCheckUSBAfterInit];
            connectOK = false;
        }
    }
    
}
//
//-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data2 withTag:(long)tag
//{
//    NSString *receive = [[NSString alloc] initWithData:data2 encoding:NSUTF8StringEncoding];
//    [self addText:[NSString stringWithFormat:@"%@------>%@",_Socket.connectedHost,receive]];
//
//    // [s readDataWithTimeout:-1 tag:0];
//}
//- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
//                 elapsed:(NSTimeInterval)elapsed
//               bytesDone:(NSUInteger)length
//{
//    return -1;
//}
//- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
//                 elapsed:(NSTimeInterval)elapsed
//               bytesDone:(NSUInteger)length
//{
//    return -2;
//}

- (IBAction)actHelp:(id)sender {
    NSArray *CmdArray = [NSArray arrayWithObjects:@"version?:获取下位机版本号",@"wio<addr><port><stat>:写IO口",@"rio<addr><port>:读IO口",@"ad<addr><port>:读ADC模块指令",@"selfcheck:模块自检启动",@"back:UUT退出",@"advance:UUT进入",@"down:上针板下",@"up:上针板上",@"start:夹具准备开始",@"reset:夹具复位",@"scanner:直接操作扫描器扫描",@"barcode?:读取缓冲区内的条码",@"ledstatus:LED测试",@"pwerkey <para>:Power键动作,ON=按下,OFF=释放",@"p3key<para>:同时按4键,ON=按下,OFF=释放",@"keytest:键打击测试",@"test <para>:通知PAC测试结果",nil];
    for(int i = 0; i <[CmdArray count]; i ++)
    {
        [self addText:[NSString stringWithFormat:@"Help --------- :%@",CmdArray[i]]];
    }
    [btnSendBarcode setHidden:false];
    [btnSendRetest setHidden:false];
    [btnSendTestDone setHidden:false];
    
}

- (IBAction)actSend:(id)sender {
    if (connectOK)
    {
        NSString *str = [mTFInput stringValue];
        if ([str isNotEqualTo:@""])
        {
            str = [NSString stringWithFormat:@"%@\r\n",str];
            //[_Socket writeData:[str dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
            const char* Cstr = [str UTF8String];
            int ret = PACSocket->TCPSendString((char*)Cstr);
            if (ret>=0) {
                //[self addText:[NSString stringWithFormat:@"%@------>%@",str,[ipaddress stringValue]]];
                [mTFInput setStringValue:@""];
                [statusMsg setStringValue:@"send success!"];
                //[_Socket readDataWithTimeout:-1 tag:0];
            }
            else
            {
                [statusMsg setStringValue:@"send error!!"];
            }
        }
        else
        {
            [statusMsg setStringValue:@"the info can't be empty!"];
        }
        
    }
    else
    {
        [statusMsg setStringValue:@"you'd better connect to the server before you send the message!"];
    }
    
}

- (IBAction)actRead:(id)sender {
    const char *str = PACSocket->TCPReadString();
    if (strlen(str)==0) {
        str="null";
    }
    //[self addText:[NSString stringWithFormat:@"<------Get data from %@: %s",[ipaddress stringValue],str]];
}

- (IBAction)actQuery:(id)sender {
    if (connectOK)
    {
        NSString *str = [mTFInput stringValue];
        if ([str isNotEqualTo:@""])
        {
            //[_Socket writeData:[str dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
            NSString *AddingStrtemp = [AddingStr stringValue];
            if ([AddingStrtemp isEqualToString:@""]) {
                AddingStrtemp = @"\r\n";
            }
            int readtimeout = [forTimeout intValue];
            const char* dectstr = [AddingStrtemp UTF8String];
            str = [NSString stringWithFormat:@"%@",str];
            const char* Cstr = [str UTF8String];
            const char* ret = PACSocket->TCPSendReceive((char*)Cstr,readtimeout,dectstr);
            if (ret>0) {
                //[self addText:[NSString stringWithFormat:@"%@------>%@",str,[ipaddress stringValue]]];
                //[self addText:[NSString stringWithFormat:@"<------Get data from %@: %s",[ipaddress stringValue],ret]];
                //[mTFInput setStringValue:@""];
                [statusMsg setStringValue:@"send success!"];
                
            }
            else
            {
                [statusMsg setStringValue:@"send error!!"];
            }
        }
        else
        {
            [statusMsg setStringValue:@"the info can't be empty!"];
        }
    }
    else
    {
        [statusMsg setStringValue:@"you'd better connect to the server before you send the message!"];
    }
    
}

- (IBAction)actClear:(id)sender {
    [mTVOutput setString:@""];
}

- (IBAction)actSendBarcode:(id)sender {
    if (connectOK) {
        NSString *str = @"barcode?";
        str = [NSString stringWithFormat:@"%@\r\n",str];
        const char* Cstr = [str UTF8String];
        int ret = PACSocket->TCPSendString((char*)Cstr);
        if (ret>=0) {
            [mTFInput setStringValue:@""];
            [statusMsg setStringValue:@"send success!"];
        }
        else
        {
            [statusMsg setStringValue:@"send error!!"];
        }
    }
    else
    {
        [statusMsg setStringValue:@"Connect error!!"];
    }
}

- (IBAction)actSendRetest:(id)sender {
    if (connectOK) {
        NSString *str = @"Retest";
        str = [NSString stringWithFormat:@"%@\r\n",str];
        const char* Cstr = [str UTF8String];
        int ret = PACSocket->TCPSendString((char*)Cstr);
        if (ret>=0) {
            [mTFInput setStringValue:@""];
            [statusMsg setStringValue:@"send success!"];
        }
        else
        {
            [statusMsg setStringValue:@"send error!!"];
        }
    }
    else
    {
        [statusMsg setStringValue:@"Connect error!!"];
    }
}

- (IBAction)actSendTestdone:(id)sender {
    if (connectOK) {
        NSString *str = @"testdone Pass";
        str = [NSString stringWithFormat:@"%@\r\n",str];
        const char* Cstr = [str UTF8String];
        int ret = PACSocket->TCPSendString((char*)Cstr);
        if (ret>=0) {
            [mTFInput setStringValue:@""];
            [statusMsg setStringValue:@"send success!"];
        }
        else
        {
            [statusMsg setStringValue:@"send error!!"];
        }
    }
    else
    {
        [statusMsg setStringValue:@"Connect error!!"];
    }
}

-(void)PrintLog:(NSString*)msg
{
    [self performSelectorOnMainThread:@selector(addText:) withObject:msg waitUntilDone:YES];
}

-(void)ClearScreen
{
    [mTVOutput setString:@""];
}

-(void)PrintLogFromOutSide:(NSString*)msg ClientName: (NSString*)name TCPinfo:(NSString*)msgType
{
    if ([msgType isEqualToString:@"S"]) {
        [self PrintLog:[NSString stringWithFormat:@"%@ :------> %@",name,msg]];
    }
    else
    {
        [self PrintLog:[NSString stringWithFormat:@"%@ :<------ %@",name,msg]];
        
    }
}


@end
