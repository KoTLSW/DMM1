//
//  ViewController.m
//  HowToWorks
//
//  Created by h on 17/3/16.
//  Copyright © 2017年 bill. All rights reserved.
//

#import "ViewController.h"
#import "TestContext.h"
#import "AppDelegate.h"


//================================================
NSString  *param_path=@"Param";
NSString  *plist_path=@"TestItem";
NSString  *tmconfig_path=@"TmConfig";

//================================================
@interface ViewController ()
{
    
    
    SerialPort          * fixtureSerial;//治具串口
    
    SerialPort          * humitureSerial; //温湿度串口
    
    KeithleyDevice      * keithleySerial; //泰克调试
    
    
    
    CTestContext        *ctestcontext;  //导入CTestContext类，便于使用字典
    
    Param               *param;         //配置文件参数
    
    Plist               *plist;         //plist配置文件
    NSMutableArray      *item;          //测试项目
    
    int                 chart_l_index;  //当前使用到的图标下标
    int                 chart_r_index;  //当前使用到的图标下标
    
    Table               *table;         //表格
    PDCA                *pdca;          //上传pdca
    FileCSV             *csv;           //生成本地数据报表
    Folder              *folder;        //创建文件夹对象
    Agilent34410A       * agilent;      //安捷伦对象
    TimeDate            *timedate;      //创建时间对象
    Humiture            *humiture;      //温湿度对象
    
    NSTimer             *timer;         //cycle time 计时器
    int                 ct_cnt;         //记录cycle time定时器中断的次数
    
    NSThread *myThrad;                  // 自定义线程
    NSThread *myThread;                 //定义启动线程
    int                 index;          //过程控制下标
    int                 pause;          //暂停下标
    int                 time;           //过程延时，计数
    
    int                 item_index;     //测试流程下标
    int                 row_index;      //表格需要更新的行号
    NSString            *dutsn;         //产品sn
    NSString            *sbuild;        //产品sbuild
    NSString            *dutport;       //产品usb port
    
    NSString            *start_time;    //启动测试的时间
    NSString            *end_time;      //结束测试的时间
    
    
    BOOL                humitureCollect;  //温湿度连接
    BOOL                isTouch;          //是否已经完全接触
    
    //--------pass和fail数量信息统计--------
    int testpasscount;
    int testfailcount;
    int testtotalcount;
    int testpassrate;
    int testfailrate;
}
@end
//================================================
@implementation ViewController
//================================================
//=======网口相关===========
@synthesize dicConfiguration;
@synthesize difConfigInstrument;
@synthesize arrayInstrument;
@synthesize strCfgFile;
//=======网口相关===========

@synthesize ex_param  = param;
//================================================
#pragma mark - 隐藏（不关闭App）
-(IBAction)hideWindow:(id)sender{
    [[NSApplication sharedApplication] hide:self];
}
#pragma mark - 最小化
-(IBAction)miniaturizeWindow:(id)sender{
    [self.view.window miniaturize:self];
}
#pragma mark - 最大化
-(IBAction)zoomWindow:(id)sender{
    [self.view.window zoom:self];
}
//==================================================

- (void)viewDidLoad
{
    //隐藏菜单
    [NSMenu setMenuBarVisible:YES];
    
    ctestcontext = new CTestContext();
    //创建仪器仪表对象
    difConfigInstrument = [[NSMutableDictionary alloc] init];
    
    NSString *username= [ctestcontext->m_dicConfiguration valueForKey:kContextUserName];
    [UserName setStringValue:username];
    //--------------------------
    param = [[Param alloc]init];
    [param ParamRead:param_path];
    //--------------------------
    plist = [[Plist alloc]init];
    //--------------------------
    pdca=[[PDCA alloc]init];
    //--------------------------
    csv=[[FileCSV alloc]init];
    //--------------------------
    folder=[[Folder alloc]init];
    //--------------------------
    timedate=[[TimeDate alloc]init];
    //--------------------------
    agilent=[[Agilent34410A alloc]init];
     //--------------------------
    humiture=[[Humiture alloc]init];
     //--------------------------
    fixtureSerial=[[SerialPort alloc]init];
     //--------------------------
    humitureSerial=[[SerialPort alloc]init];
     //--------------------------
    keithleySerial=[[KeithleyDevice alloc]init];
    
    //设置为第一响应
    [SN1 becomeFirstResponder];
    
    //---------------设置版本号，标题等-----------
    [TesterTitle setStringValue:[NSString stringWithFormat:@"%@__%@",param.ui_title,param.dut_type]];           //设置title
    //--------------------------
    [TesterVersion setStringValue:param.tester_version];   //设置version
    //--------------------------
    [Station setStringValue:param.station];   //设置station
    //--------------------------
    [StationID setStringValue:param.stationID];   //设置stationID
    //--------------------------
    [FixtureID setStringValue:param.fixtureID];   //设置fixtureID
    //--------------------------
    [LineNo setStringValue:param.lineNo];   //设置lineNO
    //--------------------------
    [ctestcontext->m_dicConfiguration setObject:param.csv_path forKey:@"csv_path"];  //把csv路径存到字典里，在perferem类的初始化里需要用到
    //--------------------------
    item  = [plist PlistRead:plist_path Key:param.dut_type];     //加载对应产品的测试项
    //--------------------------
    table = [[Table alloc]init:TABLE1 DisplayData:item];    //根据测试项初始化表格
    //--------------------------
    [self redirectSTD:STDOUT_FILENO];  //冲定向log
    [self redirectSTD:STDERR_FILENO];
    //----------初始化界面信息----------------
    [self initUiMsg];
    
    [self InitialCtrls];
    
    //添加观察者(Add notification monitor)
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnUiNotification:) name:kNotificationShowErrorTipOnUI object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnUiNotification:) name:kNotificationPreferenceChange object:nil];
    
    //--------------------------
    myThread = [[NSThread alloc]                       //启动线程，进入测试流程
                initWithTarget:self
                selector:@selector(Action)
                object:nil];
    [myThread start];
    
     [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(TimerUpdateWindow) userInfo:nil repeats:YES];
    
    [super viewDidLoad];
}


//更新窗体
-(void)TimerUpdateWindow
{
    @autoreleasepool
    {
        if (humitureCollect) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSString  * string=[humitureSerial ReadExisting];
                [HumitureTF setStringValue:string];
                
            });

        }
   }
}





-(void)viewWillDisappear
{
    //关闭程序时，做一些清理动作
    [NSApp terminate:self];
    //=================
    [myThread cancel];
    myThread = nil;
}


-(void)initUiMsg
{
    //--------------------------
    index=4;
    pause=0;
    row_index=0;
    time=0;
    ct_cnt=0;
    item_index=0;
    
    //--------------------------BOOl变量初始化
    humitureCollect=false;
    isTouch=true;//治具还未下压
    
    
    //--------pass和fail数量信息统计--------
    testpasscount = 0;
    testfailcount = 0;
    testtotalcount = 0;
    testpassrate = 0;
    testfailrate = 0;
    //------------初始化界面的一些信息--------------
    [SN1 setStringValue:@""];                      //清空条码SN1
    //--------------------------
    [SB1 setStringValue:@""];                      //清空条码SB1
    //清空ErrorIteam
    NSRange range;
    range = NSMakeRange(0, [[ErrorIteam string] length]);
    [ErrorIteam replaceCharactersInRange:range withString:@"41234341353553534534523452345345234\r\n523452346523465234634623623626456345643563\r\n4563463456345634563456345634563456345634564563\r\n456356465466562346243645"];
    //--------------------------
    [TestPassCount setStringValue:@"0"];            //清空TestPass计数
    //--------------------------
    [TestFailCount setStringValue:@"0"];            //清空TestFail计数
    //--------------------------
    [TestTotalCount setStringValue:@"0"];           //清空TestTotal计数
    //--------------------------
    [TestPassRate setStringValue:@"***"];             //清空TestPassRate计数
    //--------------------------
    [TestFailRate setStringValue:@"***"];             //清空TestFailRate计数
    //--------------------------
    [TestTime setStringValue:@"0"];                 //清空TestTime计数
    //---------------------------
    [TestStatus setBackgroundColor:[NSColor blueColor]];
    [ResultBackGroundTF setBackgroundColor:[NSColor blueColor]];
    [TestStatus setStringValue:@"Pause"];
    
    
    //定义默认选择的脚本,从配置文件中拿出来的
    if ([param.dut_type isEqualToString:@"Test1"])
    {
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:0] forKey:kContextscriptSelect];
    }
    else if ([param.dut_type isEqualToString:@"Test2"])
    {
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:1] forKey:kContextscriptSelect];
    }
    else if ([param.dut_type isEqualToString:@"Test3"])
    {
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:2] forKey:kContextscriptSelect];
    }
    else if ([param.dut_type isEqualToString:@"Test4"])
    {
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:3] forKey:kContextscriptSelect];
    }
    else if ([param.dut_type isEqualToString:@"Test5"])
    {
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:4] forKey:kContextscriptSelect];
    }
    
    //判断用户权限，进行相关设置
    int AuthorityLevel = [[ctestcontext->m_dicConfiguration valueForKey:kContextAuthority] intValue];
    if (AuthorityLevel==0 )
    {
        //初始化字典变量
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:1] forKey:kContextcheckScanBarcode];
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:0] forKey:kConTextcheckSFC];
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:0] forKey:kContextcheckPuddingPDCA];
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:1] forKey:kContextcheckDebugOut];
    }
    else if (AuthorityLevel==1)
    {
        //初始化字典变量
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:1] forKey:kContextcheckScanBarcode];
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:0] forKey:kConTextcheckSFC];
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:0] forKey:kContextcheckPuddingPDCA];
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:1] forKey:kContextcheckDebugOut];
    }
    else if (AuthorityLevel==2)
    {
        //初始化字典变量
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:1] forKey:kContextcheckScanBarcode];
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:1] forKey:kConTextcheckSFC];
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:1] forKey:kContextcheckPuddingPDCA];
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:1] forKey:kContextcheckDebugOut];
    }

}

//初始化函数，用于初始化字典中的值，及设置配置界面的状态
-(void)InitialCtrls
{
    int SFCState = [[ctestcontext->m_dicConfiguration valueForKey:kConTextcheckSFC] intValue];
    if (SFCState)
    {
        [SFCStatus setStringValue:@"SFC ON"];
        [SFCStatus setTextColor:[NSColor greenColor]];
    }
    else
    {
        [SFCStatus setStringValue:@"SFC OFF"];
        [SFCStatus setTextColor:[NSColor highlightColor]];
    }
    int PDCAState = [[ctestcontext->m_dicConfiguration valueForKey:kContextcheckPuddingPDCA] intValue];
    if (PDCAState)
    {
        [PDCAStatus setStringValue:@"PDCA ON"];
        [PDCAStatus setTextColor:[NSColor greenColor]];
    }
    else
    {
        [PDCAStatus setStringValue:@"PDCA OFF"];
        [PDCAStatus setTextColor:[NSColor highlightColor]];
    }
    
}
-(void)ReloadScript:(NSString*)dut_type
{
    //刷新测试项界面
    //--------------------------
    item  = [plist PlistRead:plist_path Key:dut_type];     //加载对应产品的测试项
    //--------------------------
    table = [table init:TABLE1 DisplayData:item];          //根据测试项初始化表格
    //--------------------------
}

//================================================
#pragma mark Notification
-(void)OnUiNotification:(NSNotification *)nf
{
    NSString *name = [nf name];
    if ([name isEqualToString:kNotificationShowErrorTipOnUI])
    {
        [self performSelectorOnMainThread:@selector(ShowErrorTipView:) withObject:[nf object] waitUntilDone:YES];
    }
    if ([name isEqualToString:kNotificationPreferenceChange]) {
        [self performSelectorOnMainThread:@selector(PreferenceChange:) withObject:[nf object] waitUntilDone:YES];
    }
}
-(void)ShowErrorTipView:(NSString*)Str
{
    [IndexMsg setStringValue:Str];
    [IndexMsg setHidden:NO];
}
-(void)PreferenceChange:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{

    int SFCState = [[ctestcontext->m_dicConfiguration valueForKey:kConTextcheckSFC] intValue];
        
    if (SFCState)
    {
        [SFCStatus setStringValue:@"SFC ON"];
        [SFCStatus setTextColor:[NSColor greenColor]];
    }
    else
    {
        [SFCStatus setStringValue:@"SFC OFF"];
        [SFCStatus setTextColor:[NSColor highlightColor]];
    }
    int PDCAState = [[ctestcontext->m_dicConfiguration valueForKey:kContextcheckPuddingPDCA] intValue];
    if (PDCAState)
    {
        [PDCAStatus setStringValue:@"PDCA ON"];
        [PDCAStatus setTextColor:[NSColor greenColor]];
    }
    else
    {
        [PDCAStatus setStringValue:@"PDCA OFF"];
        [PDCAStatus setTextColor:[NSColor highlightColor]];
    }
    //根据所选的脚本，进行切换，以及本地plist文件的更改和重新读取。
    if (0 == [[ctestcontext->m_dicConfiguration valueForKey:kContextscriptSelect] intValue])
    {
        NSString *Test1Name = @"Test1";
        [self ReloadScript:Test1Name];
        [param ParamWrite:param_path Content:Test1Name Key:@"dut_type"];
            }
    else if (1 == [[ctestcontext->m_dicConfiguration valueForKey:kContextscriptSelect] intValue])
    {
        NSString *Test2Name = @"Test2";
        [self ReloadScript:Test2Name];
        [param ParamWrite:param_path Content:Test2Name Key:@"dut_type"];
    }
    else if (2 == [[ctestcontext->m_dicConfiguration valueForKey:kContextscriptSelect] intValue])
    {
        NSString *Test3Name = @"Test3";
        [self ReloadScript:Test3Name];
        [param ParamWrite:param_path Content:Test3Name Key:@"dut_type"];
    }
    else if (3 == [[ctestcontext->m_dicConfiguration valueForKey:kContextscriptSelect] intValue])
    {
        NSString *Test4Name = @"Test4";
        [self ReloadScript:Test4Name];
        [param ParamWrite:param_path Content:Test4Name Key:@"dut_type"];
    }
    else if (4 == [[ctestcontext->m_dicConfiguration valueForKey:kContextscriptSelect] intValue])
    {
        NSString *Test5Name = @"Test5";
        [self ReloadScript:Test5Name];
        [param ParamWrite:param_path Content:Test5Name Key:@"dut_type"];
    }
    NSString *csvpathfromdic = [ctestcontext->m_dicConfiguration valueForKey:kContextCsvPath];
    if (csvpathfromdic.length != 0)
    {
        [param ParamWrite:param_path Content:csvpathfromdic Key:@"csv_path"];
    }
    [param ParamRead:param_path];
    [TesterTitle setStringValue:[NSString stringWithFormat:@"%@__%@",param.ui_title,param.dut_type]];           //设置title
        
    });        
}
//================================================
+(id)GetObject
{
    return self;
}
//================================================
-(void)Action
{
    @autoreleasepool {
        //隐藏菜单
        [NSMenu setMenuBarVisible:NO];
        while([[NSThread currentThread] isCancelled] == NO)
        {
            
            //***********************初始化治具
            if (index == 0) {
                
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowErrorTipOnUI object:[NSString stringWithFormat:@"Index:0,初始化治具"]];
                
                BOOL isCollect=[fixtureSerial Open:param.fixture_uart_port_name BaudRate:BAUD_115200 DataBit:DATA_BITS_8 StopBit:StopBitsOne Parity:PARITY_NONE FlowControl:FLOW_CONTROL_NONE];
                
                if (isCollect)
                {
                    NSLog(@"治具串口已经连接");
                    //治具复位
//                    [fixtureSerial WriteLine:@"Reset"];
//                    [HiperTimer DelaySecond:0.6];
//                    backString=[serialPort ReadExisting];
//                    sleep(1);
                    index = 1;
                }
                else
                {
                    NSLog(@"治具串口还未连接");
                    
                    
                }

                
            }
            //***********************初始化温湿度传感器
            if (index == 1) {
                
          
                  [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowErrorTipOnUI object:[NSString stringWithFormat:@"Index:1,初始温湿度传感器"]];
                 BOOL isCollect=[humitureSerial Open:param.humiture_uart_port_name BaudRate:BAUD_9600 DataBit:DATA_BITS_8 StopBit:StopBitsOne Parity:PARITY_NONE FlowControl:FLOW_CONTROL_NONE];
                
                if (isCollect)
                {
                    NSLog(@"温湿度串口已经连接");
                    [humitureSerial WriteLine:@"ATUO"];//发送2s接收数据的
                    humitureCollect=YES;
                    index = 2;
                }
                else
                {
                    NSLog(@"温湿度串口还未连接");
                    
                }
                
              
                
            }
   
            //***********************初始化安捷伦万用表&&泰克
            if (index == 2) {
                
                  [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowErrorTipOnUI object:[NSString stringWithFormat:@"Index:2,万用表连接中"]];
                //安捷伦
//                BOOL state=[agilent Find:nil andCommunicateType:MODE_LAN_Type];
//                if (state) {
//                    
//                    BOOL flag=[agilent OpenDevice:nil andCommunicateType:MODE_LAN_Type];
//                    if (flag)
//                    {
//                        //设备连接完后,发送测试电阻的指令
//                        //[agilent SetMessureMode:MODE_RES_4W andCommunicateType:MODE_LAN_Type];
//                        index=3;
//                        NSLog(@"安捷伦已OK,请按双启动按钮");
//                    }
//                    else
//                    {
//                        NSLog(@"安捷伦未连接");
//          
//                    }
//                    
//                }
                
              //泰克
               BOOL flag=[keithleySerial Open:@"//dev//cu.usbserial-FTA2VSNH" BaudRate:BAUD_9600 DataBit:DATA_BITS_8 StopBit:StopBitsOne Parity:PARITY_NONE FlowControl:FLOW_CONTROL_NONE];
            
                if (flag)
                {
                    index=3;
                    
                    NSLog(@"泰克设备已经连接");
                    
                    //设置测试模式
                    [keithleySerial SetMessureMode:K_MODE_VOLT_DC];
                    
                    for (int i=0;i<10;i++) {
                        [keithleySerial WriteLine:@"read?"];
                        
                        sleep(0.5);

                        NSString  * readString=[keithleySerial ReadExisting];
                        NSLog(@"打印readString的值%@",readString);
                    }
                }
                else
                {
                    NSLog(@"泰克万用表未连接");
                    
                }
                
            
             }
            
            if (index == 3) {//
                
                while (isTouch) {
                    isTouch=false;//下压成功
                    [fixtureSerial WriteLine:@"Reset"];
                    sleep(0.5);
                    if ([[[fixtureSerial ReadExisting] uppercaseString ]containsString:@"OK"])
                    {
                        NSLog(@"复位成功");
                        break;
                        
                    }

                }
                //等待双启动按钮
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowErrorTipOnUI object:[NSString stringWithFormat:@"Index:3,等待双启动按钮"]];
                //[fixtureSerial WriteLine:@"start"];
                sleep(0.5);
                //返回Teststart,可以开始进行测试
                if ([[fixtureSerial ReadExisting] isEqualToString:@"TestStart"])
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowErrorTipOnUI object:[NSString stringWithFormat:@"Index:3,治具工作状态"]];
                    index=4;
                }
            
            }
        
            if (index == 4){//等待输入SN，程序开始运行
                
           
              
                
                int SFCState=[[ctestcontext->m_dicConfiguration valueForKey:kConTextcheckSFC] intValue];
              
                int ifscanSN = [[ctestcontext->m_dicConfiguration valueForKey:kContextcheckScanBarcode] intValue];
                if (ifscanSN == 1)
                {
                    if ([[SN1 stringValue] length] != 17)
                    {
                        if (![[IndexMsg stringValue]isEqualToString:@"Index:4,请输入17位条码"])
                        {
                         [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowErrorTipOnUI object:[NSString stringWithFormat:@"Index:4,请输入17位条码"]];
                        }
                    }
                    else
                    {
                        dutsn = [SN1 stringValue];
                        
                        [[BYDSFCManager Instance]setStrSN:dutsn];//赋值
                        if (SFCState==1) {//上传SFC,检验SN的产品是否已经过站
                            if ([[TestStep Instance]StepSFC_CheckUploadSN:SFCState]) {
                                
                                NSLog(@"已经过站");
                            }
                            else
                            {
                                index = 5;
                            
                            }
                            
                        }
                        
                    
                    }
                    
                    [NSThread sleepForTimeInterval:0.2];
                }
                else
                {
                    dutsn = @"No Scan SN!!!";
    
                }
            }
            
            //开始测试后，锁住编辑框，禁止编辑
            if(index == 5)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowErrorTipOnUI object:[NSString stringWithFormat:@"Index:5,开始测试"]];
                //NSLog(@"=============================index is 0\r\n");
                dispatch_async(dispatch_get_main_queue(), ^{

                        //清空表格
                        [table ClearTable];
                        //设置状态
                        [TestStatus setStringValue:@"Run"];
                        [TestStatus setBackgroundColor:[NSColor blueColor]];
                        [ResultBackGroundTF setBackgroundColor:[NSColor blueColor]];

                        //清空条码并锁住条码编辑框
                        [SN1Lable setStringValue:[SN1 stringValue]];
                        [SN1 setStringValue:@""];
                        [SB1 setStringValue:@""];
                        SN1.editable = NO;
                        SB1.editable = NO;
                        //清空log显示
                        NSRange range;
                        range = NSMakeRange(0, [[LOGVIEW1 string] length]);
                        [LOGVIEW1 replaceCharactersInRange:range withString:@""];

                });
                    [NSThread sleepForTimeInterval:1];
                    //记录pdca的测试时间以及启动测试的时间
                    [pdca PDCA_GetStartTime];
                    start_time = [timedate GetSystemTimeSeconds];
                    item_index = 0;
                    row_index = 0;
                    ct_cnt = 0;
                    index = 6;
                    //先停止定时器，防止重复调用[self StartTimer:0.1];方法出现错误
                    [self StopTimer];
                    //开启定时器，0.1秒一次
                    [self StartTimer:0.1];
            }
            
            //开始运行脚本
            if(index == 6)
            {
                sleep(1);
               // NSLog(@"=============================index is 1\r\n");
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowErrorTipOnUI object:[NSString stringWithFormat:@"Index:6,开始运行脚本"]];
                Item *testitem = item[item_index];
                if (testitem.isNeedTest == YES) //如果测试项需要测试
                {
                    [self TestItem:testitem];
                    if(testitem.isNeedShow) //如果测试项需要显示就更新测试项显示结果
                    {
                        [table SelectRow:row_index];
                        [table flushTableRow:testitem RowIndex:row_index];
                        row_index = row_index+1;
                    }
//                    //如果测试项返回的结果不是数值，就不进行下一项的测试
//                    if ((testitem.isPdcaValue == NO)&&([testitem.testResult isEqualToString:@"FAIL"]))
//                    {
//                        index = 3;
//                    }
                }
                item_index = item_index+1;
                if (item_index > ([item count]-1))
                {
                    index = 7;
                }
            }
            //脚本执行完成，解锁编辑窗口并清空
            if (index == 7)
            {
                sleep(1);
               // NSLog(@"=============================index is 2\r\n");
                dispatch_async(dispatch_get_main_queue(), ^{
                    //解锁编辑框
                    SN1.editable = YES;
                    SB1.editable = YES;
                
                    BOOL pf = YES;
                    
                    for (int i=0; i<[item count]; i++)
                    {
                        Item *testitem = item[i];
                        //需要测试
                        if (testitem.isNeedTest)
                        {
                            if ((testitem.isNeedShow))
                            {
                                if ([testitem.testResult isEqualToString:@"FAIL"])
                                {
                                    pf = NO;
                                }
                            }
                        }
                    }
                    
                    if (pf == YES)
                    {
                        [TestStatus setBackgroundColor:[NSColor greenColor]];
                        [ResultBackGroundTF setBackgroundColor:[NSColor greenColor]];
                        [TestStatus setStringValue:@"PASS"];
                        testpasscount = testpasscount+1;
                        testtotalcount = testtotalcount+1;
                        testpassrate = testpasscount/testtotalcount;
                        [TestPassCount setStringValue:[NSString stringWithFormat:@"%d",testpasscount]];
                        [TestTotalCount setStringValue:[NSString stringWithFormat:@"%d",testtotalcount]];
                        [TestPassRate setStringValue:[NSString stringWithFormat:@"%.2f%%",(double)testpasscount/(double)testtotalcount*100]];
                        //同事更新fail的统计数据
                        testfailrate = testfailcount/testtotalcount;
                        [TestFailCount setStringValue:[NSString stringWithFormat:@"%d",testfailcount]];
                        [TestFailRate setStringValue:[NSString stringWithFormat:@"%.2f%%",(double)testfailcount/(double)testtotalcount*100]];
                    }
                    else
                    {
                        [TestStatus setBackgroundColor:[NSColor redColor]];
                        [ResultBackGroundTF setBackgroundColor:[NSColor redColor]];
                        [TestStatus setStringValue:@"FAIL"];
                        testfailcount = testfailcount+1;
                        testtotalcount = testtotalcount+1;
                        testfailrate = testfailcount/testtotalcount;
                        [TestFailCount setStringValue:[NSString stringWithFormat:@"%d",testfailcount]];
                        [TestTotalCount setStringValue:[NSString stringWithFormat:@"%d",testtotalcount]];
                        [TestFailRate setStringValue:[NSString stringWithFormat:@"%.2f%%",(double)testfailcount/(double)testtotalcount*100]];
                        //同事统计Pass的统计数据
                        testpassrate = testpasscount/testtotalcount;
                        [TestPassCount setStringValue:[NSString stringWithFormat:@"%d",testpasscount]];
                        [TestPassRate setStringValue:[NSString stringWithFormat:@"%.2f%%",(double)testpasscount/(double)testtotalcount*100]];
                    }
                    
                });
                //记录PDCA结束时间;记录测试结束时间
                [pdca PDCA_GetEndTime];
                end_time = [timedate GetSystemTimeSeconds];
                //停止定时器
                [self StopTimer];
                 [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowErrorTipOnUI object:[NSString stringWithFormat:@"Index:7,脚本执行完成"]];
                //---------------------
                index = 8;
            }
            //上传PDCA，生成本地CSV数据
            if (index == 8)
            {
                sleep(1);
                 [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowErrorTipOnUI object:[NSString stringWithFormat:@"Index:8,上传PDCA,生成CSV"]];
               // NSLog(@"=============================index is 3\r\n");
                
                int SFCState=[[ctestcontext->m_dicConfiguration valueForKey:kConTextcheckSFC] intValue];
                
                int PdcaState = [[ctestcontext->m_dicConfiguration valueForKey:kContextcheckPuddingPDCA] intValue];
                
                if(PdcaState==1)//上传PDCA
                {
                   [self UploadPDCA];
                 
                }
                if(SFCState==1)//上传PDCA
                {
                    
                    if ( ![[TestStep Instance]StepSFC_CheckUploadResult:SFCState=0?NO:YES andIsTestPass: [TestStatus.stringValue isEqualToString:@"FAIL"]?NO:YES  andFailMessage:nil]) {
                        
                        [self UpdateLableStatus:@"SFC上传失败" andColor:[NSColor redColor]];
                       
                        
                    }
                }
                
                if (csv != nil)
                {
                    NSString *path = param.csv_path;
                    [folder Folder_Creat:path];
                    path = [path stringByAppendingString:[NSString stringWithFormat:@"/%@/",param.dut_type]];
                    [folder Folder_Creat:path];
                    NSString *timeday = [timedate GetSystemTimeDay];
                    path = [path stringByAppendingString:timeday];
                    path = [path stringByAppendingString:@".csv"];
                    BOOL need_title = [csv CSV_Open:path];
                    [self SaveCSV:need_title];
                }
                sleep(1);
                index = 3;
                isTouch=true;
            }
            if (index == 9999)
            {
                [NSThread sleepForTimeInterval:0.2];
            }
            [NSThread sleepForTimeInterval:0.01];
        }
    }
}


//================================================
//上传pdca
//================================================
-(void)UploadPDCA
{
    BOOL PF = YES;    //所有测试项是否pass
    
    [pdca PDCA_Init:dutsn SW_name:param.sw_name SW_ver:param.sw_ver];   //上传sn，sw_name,sw_ver
    
    [pdca PDCA_AddAttribute:sbuild FixtureID:param.fixture_id];         //上传s_build，fixture_id
    
    for(int i=0;i<[item count];i++)
    {
        Item *testitem=item[i];
        
        if(testitem.isNeedTest)  //需要测试的才需要上传
        {
            Item *testitem = item[i];
            
            if((testitem.isNeedShow == YES)&&(testitem.isNeedTest))    //需要显示并且需要测试的才上传
            {
                if(testitem.isPdcaValue)   //如果测试结果是数值
                {
                    BOOL pass_fail=YES;
                    
                    if( ![testitem.testResult isEqualToString:@"PASS"] )
                    {
                        pass_fail = NO;
                        
                        PF = NO;
                    }
                    
                    [pdca PDCA_UploadValue:testitem.testName
                                     Lower:testitem.testLowerLimit
                                     Upper:testitem.testUpperLimit
                                      Unit:testitem.testValueUnit
                                     Value:testitem.testValue
                                 Pass_Fail:pass_fail
                     ];
                }
                else                       //如果测试结果只有pass或fail
                {
                    if([testitem.testResult isEqualToString:@"PASS"])
                    {
                        [pdca PDCA_UploadPass:testitem.testName];
                    }
                    else
                    {
                        [pdca PDCA_UploadFail:testitem.testName Message:testitem.testMessage];
                        PF = NO;
                    }
                }
            }
        }
    }
    
    [pdca PDCA_Upload:PF];     //上传汇总结果
}
//================================================
//保存csv
//================================================
-(void)SaveCSV:(BOOL)need_title
{
    BOOL PF = YES;         //所有测试项是否pass
    
    NSString *title=@"";
    NSString *line=@"";
    
    title = @"SN, SW Name, SW Ver, Fixture_ID, Start Time, End Time,";

    line = [NSString stringWithFormat:@"%@, %@, %@, %@, %@, %@,",dutsn, param.sw_name, param.sw_ver, param.fixture_id, start_time, end_time];
    
    
    for(int i=0;i<[item count];i++)
    {
        Item *testitem=item[i];
        
        if(testitem.isNeedTest)  //需要测试的才需要上传
        {
            Item *testitem = item[i];
            
            if((testitem.isNeedShow == YES)&&(testitem.isNeedTest))    //需要显示并且需要测试的才保存
            {
                if(testitem.isPdcaValue)   //如果测试结果是数值
                {
                    BOOL pass_fail=YES;
                    
                    if( ![testitem.testResult isEqualToString:@"PASS"] )
                    {
                        pass_fail = NO;
                        
                        PF = NO;
                    }
                    title = [title stringByAppendingString:@"Iteam Name"];
                    title = [title stringByAppendingString:@","];
                    title = [title stringByAppendingString:@"Item Value"];
                    title = [title stringByAppendingString:@","];
                    title = [title stringByAppendingString:@"Item Unit"];
                    title = [title stringByAppendingString:@","];
                    
                    line=[line stringByAppendingString:testitem.testName];
                    line=[line stringByAppendingString:@","];
                    line=[line stringByAppendingString:testitem.testValue];
                    line=[line stringByAppendingString:@","];
                    line=[line stringByAppendingString:testitem.testValueUnit];
                    line=[line stringByAppendingString:@","];

                    
                }
                else                       //如果测试结果只有pass或fail
                {
                    title = [title stringByAppendingString:@"Iteam Name"];
                    title = [title stringByAppendingString:@","];
                    title = [title stringByAppendingString:@"Item Value"];
                    title = [title stringByAppendingString:@","];
                    title = [title stringByAppendingString:@"Item Unit"];
                    title = [title stringByAppendingString:@","];
                    
                    
                    line=[line stringByAppendingString:testitem.testName];
                    line=[line stringByAppendingString:@","];
                    
                    if([testitem.testResult isEqualToString:@"PASS"])
                    {
                        line=[line stringByAppendingString:testitem.testResult];
                        line=[line stringByAppendingString:@","];
                    }
                    else
                    {
                        line=[line stringByAppendingString:testitem.testResult];
                        line=[line stringByAppendingString:@","];
                        PF = NO;
                    }
                }
            }
        }
    }
    
    title = [title stringByAppendingString:@"Test Result"];
    title = [title stringByAppendingString:@","];
    title=[title stringByAppendingString:@""];
    title=[title stringByAppendingString:@"\n"];
    
    NSString *test_result;
    if (PF)
    {
        test_result = @"PASS";
    }
    else
    {
        test_result = @"FAIL";
    }
    line=[line stringByAppendingString:test_result];
    line=[line stringByAppendingString:@"\n"];
    line=[line stringByAppendingString:@""];
    line=[line stringByAppendingString:@"\n"];   //end_time
    if(need_title == YES)[csv CSV_Write:title];
    
    [csv CSV_Write:line];
}
//================================================
// 开始定时器
//================================================
-(void)StartTimer:(float)seconds
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //定义一个NSTimer
        timer = [NSTimer scheduledTimerWithTimeInterval:seconds
                                                 target:self
                                               selector:@selector(IrqTimer:)
                                               userInfo:nil
                                                repeats:YES
                 ];
        
    });
    
}
//================================================
// 停止定时器
//================================================
-(void)StopTimer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(timer != nil){
            [timer invalidate];// 定时器调用invalidate后，就会自动执行release方法。不需要在显示的调用release方法
        }
    });
}
//================================================
// 定时器回调函数，刷新cycle time界面显示
//================================================
-(void)IrqTimer:(NSTimer *)timer
{
    ct_cnt = ct_cnt + 1;
    
    NSString *strtime=[[NSString alloc]initWithFormat:@"%0.1f",ct_cnt*0.1];
    
    [TestTime setStringValue:[NSString stringWithFormat:@"%@  s",strtime]];
}


#pragma mark=================测试项指令解析

-(BOOL)TestItem:(Item*)testitem
{
    BOOL ispass=NO;
    //--------------------
    //TestOne
    //--------------------
    for (int i=0; i<[testitem.testAllCommand count]; i++)
    {
        //治具===================Fixture
        //波形发生器==============OscillDevice
        //安捷伦万用表============Aglient
        //延迟时间================SW
        NSString     * agilentReadString;
        NSDictionary * dic=[testitem.testAllCommand objectAtIndex:i];
        NSString * SonTestDevice=dic[@"TestDevice"];
        NSString * SonTestCommand=dic[@"TestCommand"];
        int delayTime=[dic[@"TestDelayTime"] intValue]/1000;
        
        //**************************治具=Fixture
        if ([SonTestDevice isEqualToString:@"Fixture"]) {
            
            NSLog(@"治具发送指令%@========%@",SonTestDevice,SonTestCommand);
            
            [fixtureSerial WriteLine:SonTestCommand];
            sleep(0.2);
            
            NSString  * readString;
            int indexTime=0;
            
            while (YES) {
                
                readString=[fixtureSerial ReadExisting];
                
                if ([readString isEqualToString:@"OK"]||indexTime==testitem.testRetryTimes)
                {
                    break;
                }
                indexTime++;
            }
        }
        //**************************波形发生器=WaveDevice
        else if ([SonTestDevice isEqualToString:@"WaveDevice"]) {
            
            //波形发生器a
            //                NSLog(@"治具发送指令%@========%@",SonTestDevice,SonTestCommand)
            //                sleep(0.2);
            //                int indexTime=0;
            //                NSString * readString;
            //                while (YES) {
            //                    readString=[self SendReceive:@"Oscill" CMD:NULL TimeOut:1000 Detect:'\r'];
            //                    if ([readString isEqualToString:@"OK"]||indexTime==2)
            //                    {
            //                        break;
            //                    }
            //                    indexTime++;
            //                }
            NSLog(@"*************示波器发送指令**************%@",SonTestDevice);
            
        }
         //**************************万用表==Agilent或者Keithley
        else if ([SonTestDevice isEqualToString:@"Agilent"]||[SonTestDevice isEqualToString:@"Keithley"])
        {
        
            //万用表发送指令
            if ([SonTestCommand isEqualToString:@"DC Volt"]) {//直流电压测试
                [agilent SetMessureMode:MODE_VOLT_DC andCommunicateType:MODE_LAN_Type];
                [keithleySerial SetMessureMode:K_MODE_VOLT_DC];
                NSLog(@"设置直流电压模式");
            }
            else if([SonTestCommand isEqualToString:@"AC Volt"])
            {
                [agilent SetMessureMode:MODE_VOLT_AC andCommunicateType:MODE_LAN_Type];
                [keithleySerial SetMessureMode:K_MODE_VOLT_AC];
                NSLog(@"设置交流电压模式");
            }
            else if ([SonTestCommand isEqualToString:@"DC Current"])
            {
                [agilent SetMessureMode:MODE_CURR_DC andCommunicateType:MODE_LAN_Type];
                [keithleySerial SetMessureMode:K_MODE_CURR_DC];
                NSLog(@"设置直流电流模式");
                
            }
            else if ([SonTestCommand isEqualToString:@"AC Current"])
            {
                
                [agilent SetMessureMode:MODE_CURR_AC andCommunicateType:MODE_LAN_Type];
                [keithleySerial SetMessureMode:K_MODE_CURR_AC];
                NSLog(@"设置交流电流模式");
                
            }
            else if ([SonTestCommand containsString:@"RES"])//电阻分单位KΩ,MΩ,GΩ
            {
                
                [agilent SetMessureMode:MODE_RES_4W andCommunicateType:MODE_LAN_Type];
                [keithleySerial SetMessureMode:K_MODE_RES_4W];
                NSLog(@"设置自动电阻模式");
                
                
            }
            else//其它的值
            {
                //5次电压递增测试
                if ([testitem.testDevice isEqualToString:@"SF-5a"]) {//设备
                    
                    int indexTime=0;
                    
                    while (YES) {
                        
                        [agilent WriteLine:@"Read?" andCommunicateType:MODE_LAN_Type];
                        
                        agilentReadString=[agilent ReadData:16 andCommunicateType:MODE_LAN_Type];
                        
                        //大于1，直接跳出，并发送reset指令
                        if (agilentReadString.length>0&&[agilentReadString floatValue]>=1)
                        {
                            [fixtureSerial WriteLine:@"Reset"];
                            break;
                        }
                        if ([agilentReadString floatValue]<1)//读取3次，3次后等待15秒再发送
                        {
                            indexTime++;
                            
                            if (indexTime==testitem.testRetryTimes-1) {
                                
                                sleep(13.5);
                                
                                [agilent WriteLine:@"Read?" andCommunicateType:MODE_LAN_Type];
                                
                                agilentReadString=[agilent ReadData:16 andCommunicateType:MODE_LAN_Type];
                                
                                break;
                                
                            }
                        
                        
                        }

                    }
                    
                }
                //其它正常读取情况
                else
                {
                    [agilent WriteLine:@"Read?" andCommunicateType:MODE_LAN_Type];
                    agilentReadString=[agilent ReadData:16 andCommunicateType:MODE_LAN_Type];

                
                }
                
                testitem.testValue=@"1.5";//为获取万用表的值
                
                if ([SonTestCommand containsString:@"Read"]) {
                    
                    //1和2工站===============SF-2a&&SF-2b计算
                    if ([testitem.testName isEqualToString:@"Sensor Board SF-2a"]||[testitem.testName isEqualToString:@"Crown flex RF-2a"]||[testitem.testName isEqualToString:@"Sensor_Flex SF-1a"]) {
                        
                        float num=[agilentReadString floatValue];
                        testitem.testValue = [NSString stringWithFormat:@"%f%@", ((0.8 - num)/num)*10,@"G"];
                        
                    }
                    if ([testitem.testName isEqualToString:@"Sensor Board SF-2b"]||[testitem.testName isEqualToString:@"Crown flex RF-2b"]||[testitem.testName isEqualToString:@"Sensor_Flex SF-1b"])
                    {
                        float num=[agilentReadString floatValue];
                        if ([testitem.testName isEqualToString:@"Sensor_Flex SF-1b"]) {
                            testitem.testValue = [NSString stringWithFormat:@"%f%@", ((1.41421*0.8 - num)/num)*5,@"G"];
                        }
                        else
                        {
                            testitem.testValue = [NSString stringWithFormat:@"%f%@", ((1.41421*0.8 - num)/num)*10,@"G"];
                        }
                    }
                    
                    
                    NSLog(@"%f=====================%f",[testitem.testLowerLimit floatValue],[testitem.testUpperLimit floatValue]);
                    
                    if ([testitem.testValue floatValue]>=[testitem.testLowerLimit floatValue]&&[testitem.testValue floatValue]<=[testitem.testUpperLimit floatValue])
                    {
                        
                        testitem.testValue  = [NSString stringWithFormat:@"%@",testitem.testValue];
                        testitem.testResult = @"PASS";
                        testitem.testMessage= @"";
                        testitem.isPdcaValue= YES;
                        ispass = YES;
                        
                    }
                    else
                    {
                        testitem.testValue  = [NSString stringWithFormat:@"%@",testitem.testValue];
                        testitem.testResult = @"FAIL";
                        testitem.testMessage= @"";
                        testitem.isPdcaValue= YES;
                        ispass = NO;
                    }
                }
            }
            
            }
        else if([SonTestDevice isEqualToString:@"SW"])
        {
            //延迟时间
             NSLog(@"延迟时间**************%@",SonTestDevice);
             sleep(delayTime);
        }
        else
        {
            NSLog(@"其它设备模式");
        }
    }
    
    

    
    
//    if ([testitem.testName containsString:@"Sensor"])
//    {
//        
//        NSString  * agilentReadString;
//        
//        for (int i=0;i<[testitem.testAllCommand count];i++)
//        {
//            NSDictionary * dic=[testitem.testAllCommand objectAtIndex:i];
//            NSString * SonTestDevice=dic[@"TestDevice"];
//            NSString * SonTestCommand=dic[@"TestCommand"];
//            int delayTime=[dic[@"TestDelayTime"] intValue]/1000;
//            if ([SonTestDevice isEqualToString:@"Fixture"])
//            {
//    
//                NSLog(@"治具发送指令%@========%@",SonTestDevice,SonTestCommand);
//
//                [fixtureSerial WriteLine:SonTestCommand];
//                sleep(0.2);
//                
//                NSString  * readString;
//                int indexTime=0;
//
//                while (YES) {
//  
//                  readString=[fixtureSerial ReadExisting];
//                
//                  if ([readString isEqualToString:@"OK"]||indexTime==testitem.testRetryTimes)
//                    {
//                        break;
//                    }
//                    indexTime++;
//                }
//            }
//            else if ([SonTestDevice isEqualToString:@"Agilent"])
//            {
//                //万用表发送指令
//                if ([SonTestCommand isEqualToString:@"DC Volt"]) {//直流电压测试
//                    [agilent SetMessureMode:MODE_VOLT_DC andCommunicateType:MODE_LAN_Type];
//                    NSLog(@"设置直流电压模式");
//                }
//                else if([SonTestCommand isEqualToString:@"AC Volt"])
//                {
//                    [agilent SetMessureMode:MODE_VOLT_AC andCommunicateType:MODE_LAN_Type];
//                    NSLog(@"设置交流电压模式");
//                }
//                else if ([SonTestCommand isEqualToString:@"DC Current"])
//                {
//                    [agilent SetMessureMode:MODE_CURR_DC andCommunicateType:MODE_LAN_Type];
//                     NSLog(@"设置直流电流模式");
//                
//                }
//                else if ([SonTestCommand isEqualToString:@"AC Current"])
//                {
//                
//                    [agilent SetMessureMode:MODE_CURR_AC andCommunicateType:MODE_LAN_Type];
//                     NSLog(@"设置交流电流模式");
//                
//                }
//                else if ([SonTestCommand isEqualToString:@"RES"])//电阻分单位KΩ,MΩ,GΩ
//                {
//                    
//                    if ([testitem.testValueUnit isEqualToString:@"KΩ"]) {
//                        
//                        NSLog(@"电阻范围为===========KΩ");
//                        
//                    }
//                    else if ([testitem.testValueUnit isEqualToString:@"MΩ"]){
//                    
//                        NSLog(@"电阻范围为===========MΩ");
//                    }
//                    else if ([testitem.testValueUnit isEqualToString:@"GΩ"])
//                    {
//                        NSLog(@"电阻范围为===========GΩ");
//                        
//                    }
//                    else
//                    {
//                        NSLog(@"电阻默认为===========Ω");
//                    }
//                    
//                
//                }
//                else//其它的值
//                {
//                    [agilent WriteLine:@"Read?" andCommunicateType:MODE_LAN_Type];
//                    agilentReadString=[agilent ReadData:16 andCommunicateType:MODE_LAN_Type];
//                
//                }
//                
//                testitem.testValue=@"1.5";//为获取万用表的值
//                
//                if ([SonTestCommand containsString:@"Read"]) {
//                    
//                    //SF-2a&&SF-2b计算
//                    if ([testitem.testName isEqualToString:@"Sensor SF-2a"]) {
//                        
//                        float num=[agilentReadString floatValue];
//                        testitem.testValue = [NSString stringWithFormat:@"%f%@", ((0.8 - num)/num)*10,@"G"];
//                        
//                    }
//                    if ([testitem.testName isEqualToString:@"Sensor SF-2b"])
//                    {
//                        float num=[agilentReadString floatValue];
//                        testitem.testValue = [NSString stringWithFormat:@"%f%@", ((1.41421*0.8 - num)/num)*10,@"G"];
//                        
//                    }
//                    NSLog(@"%f=====================%f",[testitem.testLowerLimit floatValue],[testitem.testUpperLimit floatValue]);
//                    
//                    if ([testitem.testValue floatValue]>=[testitem.testLowerLimit floatValue]&&[testitem.testValue floatValue]<=[testitem.testUpperLimit floatValue])
//                    {
//                        
//                        testitem.testValue  = [NSString stringWithFormat:@"%@",testitem.testValue];
//                        testitem.testResult = @"PASS";
//                        testitem.testMessage= @"";
//                        testitem.isPdcaValue= YES;
//                        ispass = YES;
//
//                    }
//                    else
//                    {
//                        testitem.testValue  = [NSString stringWithFormat:@"%@",testitem.testValue];
//                        testitem.testResult = @"FAIL";
//                        testitem.testMessage= @"";
//                        testitem.isPdcaValue= YES;
//                        ispass = NO;
//                    }
//                }
//            }
//            else if ([SonTestDevice isEqualToString:@"Oscill"])
//            {
//                //波形发生器a
////                NSLog(@"治具发送指令%@========%@",SonTestDevice,SonTestCommand)
////                sleep(0.2);
////                int indexTime=0;
////                NSString * readString;
////                while (YES) {
////                    readString=[self SendReceive:@"Oscill" CMD:NULL TimeOut:1000 Detect:'\r'];
////                    if ([readString isEqualToString:@"OK"]||indexTime==2)
////                    {
////                        break;
////                    }
////                    indexTime++;
////                }
//                NSLog(@"*************示波器发送指令**************%@",SonTestDevice);
//                
//            }
//            else if([SonTestDevice isEqualToString:@"SW"])
//            {
//                //延迟时间
//                 NSLog(@"延迟时间**************%@",SonTestDevice);
//                 sleep(delayTime);
//            }
//            
//        }
//    }
//    else
//    {
//        NSLog(@"其它各种情况");
//    
//    }
    

    return ispass;
}
//================================================
- (IBAction)SPK:(id)sender {
    
    pause = index;
    index = 20000;
    
}
//================================================

//================================================
- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}
//================================================
- (void)redirectNotificationHandle:(NSNotification *)nf{
    if (1 == [[ctestcontext->m_dicConfiguration valueForKey:kContextcheckDebugOut] intValue])
    {
        NSData *data = [[nf userInfo] objectForKey:NSFileHandleNotificationDataItem];
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if(LOGVIEW1 != nil)
        {
            NSRange range;
            range = NSMakeRange ([[LOGVIEW1 string] length], 0);
            [LOGVIEW1 replaceCharactersInRange: range withString: str];
            [LOGVIEW1 scrollRangeToVisible:range];
        }
        
        [[nf object] readInBackgroundAndNotify];
    }
    else
    {        
        [[nf object] readInBackgroundAndNotify];
    }
}
//================================================
- (void)redirectSTD:(int )fd{
    
    NSPipe * pipe = [NSPipe pipe] ;
    NSFileHandle *pipeReadHandle = [pipe fileHandleForReading] ;
    dup2([[pipe fileHandleForWriting] fileDescriptor], fd) ;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(redirectNotificationHandle:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:pipeReadHandle] ;
    
    [pipeReadHandle readInBackgroundAndNotify];
}
//================================================

-(IBAction)btstart:(id)sender
{
    NSLog(@"start button is pressed!!!!");
    //隐藏菜单
    [NSMenu setMenuBarVisible:NO];
    if(myThread != nil)
    {
        NSLog(@"测试已经开始了！！！！");
    }
    else
    {
        NSLog(@"重新开启测试！！！！");
        dispatch_async(dispatch_get_main_queue(), ^{
            //--------------------------
            item  = [plist PlistRead:plist_path Key:param.dut_type];     //加载对应产品的测试项
            //--------------------------
            table = [table init:TABLE1 DisplayData:item];    //根据测试项初始化表格
            
            [self StopTimer];
            item_index = 0;
            row_index = 0;
            ct_cnt = 0;
            index = 6;
            [SN1 setStringValue:@""];
            SN1.editable = YES;
            //配置完相关配置后，再开启线程
            myThread = [[NSThread alloc]                       //启动线程，进入测试流程
                        initWithTarget:self
                        selector:@selector(Action)
                        object:nil];
            [myThread start];
            
        });
        
        
    }
    //    index = [[ctestcontext->m_dicConfiguration valueForKey:kContextindexOld] intValue];
    
}


-(IBAction)btstop:(id)sender
{
    NSLog(@"stop button is pressed!!!!");
    if(myThread != nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SN1 setStringValue:@""];
            SN1.editable = NO;
            //先把线程停掉，再进行相关配置
            [myThread cancel];
            myThread = nil;
            [self StopTimer];
            if(index != 9999)
            {
                [ctestcontext->m_dicConfiguration setObject:[NSNumber numberWithInt:index] forKey:kContextindexOld];
            }
            index = 9999;
            //显示菜单
            [NSMenu setMenuBarVisible:YES];
            
        });
        
        NSLog(@"当前线程已经被取消了!!!!");
        
    }
    else
    {
        NSLog(@"测试已经取消了");
    }
    
}


//更新状态栏的状态信息及背景色
-(void)UpdateLableStatus:(NSString*) strDisplayValue andColor:(NSColor*)color
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [IndexMsg setStringValue:strDisplayValue];
        [IndexMsg setBackgroundColor:color];
    });
}




-(IBAction)btpause:(id)sender
{
    NSLog(@"pause button is pressed!!!!");
}
-(IBAction)btcontinue:(id)sender
{
    NSLog(@"continue button is pressed!!!!");
}
-(IBAction)btcountreset:(id)sender
{
    NSLog(@"countreset button is pressed!!!");
    testpasscount = 0;
    testfailcount = 0;
    testtotalcount = 0;
    testpassrate = 0;
    testfailrate = 0;
    //--------------------------
    [TestPassCount setStringValue:@"0"];            //清空TestPass计数
    //--------------------------
    [TestFailCount setStringValue:@"0"];            //清空TestFail计数
    //--------------------------
    [TestTotalCount setStringValue:@"0"];           //清空TestTotal计数
    //--------------------------
    [TestPassRate setStringValue:@"***"];             //清空TestPassRate计数
    //--------------------------
    [TestFailRate setStringValue:@"***"];             //清空TestFailRate计数
    
}






@end
//================================================