//
//  ViewController.m
//  MK_TestingModel_Sample
//
//  Created by Michael on 16/11/10.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import "ViewController.h"
#import "MK_Table.pch"
#import "MK_File.pch"
#import "MK_Alert.pch"
#import "MK_Timer.pch"
#import "SerialPort.h"
#import "AgilentDevice.h"
#import "AppDelegate.h"
#import "AlertWindowController.h"
#import "KeithleyDevice.h"
#import "BYDSFCManager.h"
#import "TestStep.h"
#import "Agilent3458A.h"
#import "Agilent33210A.h"
#import "Param.h"



NSString  *param_path=@"Param";
@implementation ViewController
{
    //************ Device *************
    SerialPort          * serialPort;
    SerialPort          * fixtureSerial;   //治具串口
    SerialPort          * humitureSerial;  //温湿度串口
    KeithleyDevice      * keithleySerial;  //泰克调试
    Agilent3458A        * agilent3458A;    //安捷伦万用表
    Agilent33210A       * agilent33210A;   //波形发生器
    

    //************* timer *************
    NSString *start_time;               //启动测试的时间
    NSString *end_time;                 //结束测试的时间
    NSThread * myThrad;                  // 自定义主线程
    NSThread * secondThrad;              //温湿度线程
    
    //************ table **************
    Table *mk_table;                       // table类
    Plist *plist;                          // plist类
    Param *param;                          // param参数类
    NSMutableArray *itemArr;            // plist文件测试项数组
    Item *testItem ;
    NSString *itemResult; //每一个测试项的结果
    NSMutableArray *testResultArr; // 返回的结果数组
    int index;                          // 测试流程下标
    int item_index;                     // 测试项下标
    int row_index;                      // table 每一行下标

    __weak IBOutlet NSView *tab_View;               // 与storyboard 关联的 outline_Tab
    __unsafe_unretained IBOutlet NSTextView *logView_Info; //log_View 中显示的信息
    
    //************ testItems ************
    NSString        *agilentReadString;
    NSDictionary    *dic;
    NSString        *SonTestDevice;
    NSString        *SonTestCommand;
    NSString        *SonTestName;
    int             delayTime;
    int             ct_cnt;                //记录cycle time定时器中断的次数
    NSMutableArray  *testItemTitleArr;     //每个测试标题都加入数组中,生成数据文件要用到
    NSMutableArray  *testItemValueArr;     //每个测试结果都加入数组中,生成数据文件要用到
    
    //************ right_Side_Window *************
    MKTimer *mkTimer;               //MK 定时器对象
    int testNum;                        //测试次数
    int passNum;                        //通过次数
    NSString    *testResultStr;     //测试结果
    
    __weak IBOutlet NSTextField *importSN;          //输入的sn
    __weak IBOutlet NSTextField *currentStateMsg;   //当前的状态信息
    __weak IBOutlet NSTextField *currentStateMsgBG;
    
    __weak IBOutlet NSTextField *testResult;        //测试结果
   
    __weak IBOutlet NSTextField *testFieldTimes;    //测试时间
    __weak IBOutlet NSTextField *testCount;         //测试次数
    
    __weak IBOutlet NSButton *PDCA_Btn;             //PDCA 按钮
    __weak IBOutlet NSButton *SFC_Btn;              //SFC  按钮
    
    __weak IBOutlet NSTextField *passNumInfoTF;
    __weak IBOutlet NSTextField *passNumCalculateTF;
    __weak IBOutlet NSTextField *failNumInfoTF;
    __weak IBOutlet NSTextField *failNumCalculateTF;
    __weak IBOutlet NSTextField *totalNumInfo;
    __weak IBOutlet NSTextField *fixtureID_TF;
    __weak IBOutlet NSTextField *stationID_TF;
    __unsafe_unretained IBOutlet NSTextView *SN_Collector;//sn 收集器
    
    IBOutlet NSTextField *HumitureTF;
    NSTimer              *humTimer;  //温湿度刷新定时器
    
    //添加的属性===========5.10====chen
    BOOL          humitureCollect;  //温湿度连接
    NSString     *humitString;      //返回来的温度数据
    BOOL          isTouch;          //是否已经完全接触
    BOOL          isUpLoadSFC;      //是否上传SFC
    BOOL          isUpLoadPDCA;     //是否上传PDCA
    PDCA         *pdca;             //PDCA对象

}


- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    fixtureSerial=[[SerialPort alloc] init];
    
    keithleySerial=[[KeithleyDevice alloc] init];
    
    humitureSerial=[[SerialPort alloc]init];
    
    agilent33210A =[[Agilent33210A alloc] init];
    
    agilent3458A =[[Agilent3458A alloc] init];
    
     param = [[Param alloc]init];
     [param ParamRead:param_path];
     isTouch=true;//治具还未下压
    
    [self redirectSTD:STDOUT_FILENO];  //冲定向log
    [self redirectSTD:STDERR_FILENO];
    
    mkTimer = [[MKTimer alloc] init];
    plist = [[Plist alloc] init];
    mk_table = [[Table alloc] init];
    
    item_index = 0;
    row_index = 0;
    index=0;
    logView_Info.editable = NO;
    testNum = 0;
    passNum = 0;
    itemArr = [NSMutableArray array];
    PDCA_Btn.enabled = NO;
    SFC_Btn.enabled = NO;
    
    //进来就判断读取哪个配置文件
    [self selectStationNoti:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectStationNoti:) name:@"changePlistFileNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectPDCA_SFC_LimitNoti:) name:@"PDCAButtonLimit_Notification" object:nil];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CancellPDCA_SFC_LimitNoti:) name:@"CancellButtonlimit_Notification" object:nil];
    
     myThrad = [[NSThread alloc] initWithTarget:self selector:@selector(Working) object:nil];
    [myThrad start];
    
    secondThrad=[[NSThread alloc] initWithTarget:self selector:@selector(TimerUpdateWindow) object:nil];
    [secondThrad start];
}



-(void)selectPDCA_SFC_LimitNoti:(NSNotification *)noti
{
    PDCA_Btn.enabled = YES;
    SFC_Btn.enabled = YES;
}


-(void)CancellPDCA_SFC_LimitNoti:(NSNotification *)noti
{
    PDCA_Btn.state=YES;
    SFC_Btn.state= YES;
    PDCA_Btn.enabled = NO;
    SFC_Btn.enabled  = NO;
}


-(void)selectStationNoti:(NSNotification *)noti
{
    if (plist == nil)
    {
        plist = [[Plist alloc] init];
    }
    
    if (mk_table == nil)
    {
        mk_table = [[Table alloc] init];
    }
        
    if ([noti.object isEqualToString:@"Station_0"] || [[[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentStationStatus"] isEqualToString:@"Station_0"])
    {
        NSLog(@"进入 Station_0 工站");
        stationID_TF.stringValue = @"Sensor Board";
            
        //读取 plist 文件
        itemArr = [plist PlistRead:@"Station_0" Key:@"AllItems"];
            
        mk_table = [mk_table init:tab_View DisplayData:itemArr];
            
        //改变serverSF的值
        [BYDSFCManager Instance].ServerFCKey=@"ServerFC_0";
    }
        
    if ([noti.object isEqualToString:@"Station_1"]|| [[[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentStationStatus"] isEqualToString:@"Station_1"])
    {
        NSLog(@"进入 Station_1 工站");
        stationID_TF.stringValue = @"Crown Flex";
            
        //读取 plist 文件
        itemArr = [plist PlistRead:@"Station_1" Key:@"AllItems"];
        mk_table = [mk_table init:tab_View DisplayData:itemArr];
            
        //改变serverSF的值
        [BYDSFCManager Instance].ServerFCKey=@"ServerFC_1";
    }
    
    if ([noti.object isEqualToString:@"Station_2"]|| [[[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentStationStatus"] isEqualToString:@"Station_2"])
    {
        NSLog(@"进入 Station_2 工站");
        stationID_TF.stringValue = @"Sensor Flex Sub Assembly";
            
        //读取 plist 文件
        itemArr = [plist PlistRead:@"Station_2" Key:@"AllItems"];
        mk_table = [mk_table init:tab_View DisplayData:itemArr];
            
        //改变serverSF的值
        [BYDSFCManager Instance].ServerFCKey=@"ServerFC_2";
    }
    
    if ([noti.object isEqualToString:@"Station_3"]|| [[[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentStationStatus"] isEqualToString:@"Station_3"])
    {
        NSLog(@"进入 Station_3 工站");
        stationID_TF.stringValue = @"Crown Rotation Sub Assembly";
            
        //读取 plist 文件
        itemArr = [plist PlistRead:@"Station_3" Key:@"AllItems"];
        mk_table = [mk_table init:tab_View DisplayData:itemArr];
            
        //改变serverSF的值
        [BYDSFCManager Instance].ServerFCKey=@"ServerFC_3";
    }
        
    //重新获取服务器基本
    [[BYDSFCManager Instance] getUnitValue];
        
    fixtureID_TF.stringValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentStationStatus"];
}


//sn = 123456
//================================================
//测试动作流程
//================================================
-(void)Working
{
    [NSMenu setMenuBarVisible:NO];
   
    if (testItem == nil)
    {
        testItem  = [[Item alloc] init];
    }
   
    if (testResultArr == nil)
    {
        testResultArr  = [NSMutableArray arrayWithCapacity:0];
    }
    
    while ([[NSThread currentThread] isCancelled]==NO) //线程未结束一直处于循环状态
    {
        
#pragma mark index=0 打开治具，串口通信
//------------------------------------------------------------
//index=0
//------------------------------------------------------------
        if (index == 0)
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                currentStateMsg.stringValue=@"连接治具...";
                currentStateMsg.backgroundColor = [NSColor yellowColor];
                currentStateMsgBG.backgroundColor = currentStateMsg.backgroundColor;
            });
            
            NSLog(@"连接治具...");
            
            if ([serialPort IsOpen])
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    currentStateMsg.stringValue=@"index=0,治具已经连接";
                    currentStateMsg.backgroundColor = [NSColor yellowColor];
                    currentStateMsgBG.backgroundColor = currentStateMsg.backgroundColor;
                });
                sleep(1);
                NSLog(@"index=0,治具已经连接");
                index = 1;
            }
            
            else
            {
                //========================test Code============================
                BOOL uartConnect=[serialPort Open:param.fixture_uart_port_name BaudRate:BAUD_115200 DataBit:DATA_BITS_8 StopBit:StopBitsOne Parity:PARITY_NONE FlowControl:FLOW_CONTROL_NONE];
                
                //测试代码
                uartConnect = YES;
                
                if (uartConnect)
                {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        currentStateMsg.stringValue=@"index=0,治具已经连接";
                        currentStateMsg.backgroundColor = [NSColor yellowColor];
                        currentStateMsgBG.backgroundColor = currentStateMsg.backgroundColor;
                    });
                    sleep(1);
                    NSLog(@"index=0,治具已经连接");
                    index = 1;
                }
                else
                {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        currentStateMsg.stringValue=@"index=0,治具未连接";
                        currentStateMsg.backgroundColor = [NSColor redColor];
                        currentStateMsgBG.backgroundColor = currentStateMsg.backgroundColor;
                    });
                    index=1;
                    sleep(1);
                    NSLog(@"index=0,治具还未连接");
                }
            }
        }
        
#pragma mark index=1  打开安捷伦万用表---GPIB通信
//------------------------------------------------------------
//index=1
//------------------------------------------------------------
        if (index==1)
        {
           BOOL agilent3458A_isOpen = [agilent3458A FindAndOpen:nil];
            
            //测试代码
            agilent3458A_isOpen = YES;
            
            if (agilent3458A_isOpen)
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                     currentStateMsg.stringValue=@"index=1,安捷伦已经连接";
                    currentStateMsg.backgroundColor = [NSColor yellowColor];
                    currentStateMsgBG.backgroundColor = currentStateMsg.backgroundColor;
                });
                sleep(1);
                index = 2;
            }
            else
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    currentStateMsg.stringValue=@"安捷伦连接失败!";
                    currentStateMsg.backgroundColor = [NSColor redColor];
                    currentStateMsgBG.backgroundColor = currentStateMsg.backgroundColor;
                });
                sleep(1);
                NSLog(@"安捷伦连接失败!");
            }
        }
      
#pragma mark index=2 初始化温度传感器
//------------------------------------------------------------
//index=2
//------------------------------------------------------------
        if(index==2)
        {
            BOOL isCollect=[humitureSerial Open:param.humiture_uart_port_name BaudRate:BAUD_9600 DataBit:DATA_BITS_8 StopBit:StopBitsOne Parity:PARITY_NONE FlowControl:FLOW_CONTROL_NONE];
            
            //测试代码
            isCollect = YES;
            
            if (isCollect)
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    currentStateMsg.stringValue=@"index=2,温湿度串口已经连接";
                    currentStateMsg.backgroundColor = [NSColor yellowColor];
                    currentStateMsgBG.backgroundColor = currentStateMsg.backgroundColor;
                });
                NSLog(@"温湿度串口已经连接");
//              [humitureSerial WriteLine:@"ATUO"];//发送2s接收数据的
                humitureCollect=YES;
                [self HumitureStartTimer:2];
                index = 3;
            }
            else
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    currentStateMsg.stringValue=@"index=2,温湿度串口还未连接";
                    currentStateMsg.backgroundColor = [NSColor redColor];
                    currentStateMsgBG.backgroundColor = currentStateMsg.backgroundColor;
                });
                NSLog(@"温湿度串口还未连接");
            }
        }
        
#pragma mark index=3 初始化波形发生器
        //------------------------------------------------------------
        //index=3
        //------------------------------------------------------------
        if(index==3)
        {
            //测试代码
            param.isWaveNeed = YES;
            
            if (param.isWaveNeed)  //有些工站需要，有些不需要
            {
                BOOL agilent33210A_isFind = [agilent33210A Find:nil andCommunicateType:Agilent33210A_USB_Type];
                BOOL agilent33210A_isOpen =[agilent33210A OpenDevice: nil andCommunicateType:Agilent33210A_USB_Type];
             
                //测试代码
                agilent33210A_isFind = YES;
                agilent33210A_isOpen = YES;
                
                if (agilent33210A_isFind && agilent33210A_isOpen)
                {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        currentStateMsg.stringValue=@"index=3,波形发生器已连接";
                        currentStateMsg.backgroundColor = [NSColor yellowColor];
                        currentStateMsgBG.backgroundColor = currentStateMsg.backgroundColor;
                    });
                    index = 4;
                    
                    //测试代码
                    index = 5;
                }
                else
                {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        currentStateMsg.stringValue=@"波形发生器连接失败!";
                        currentStateMsg.backgroundColor = [NSColor redColor];
                        currentStateMsgBG.backgroundColor = currentStateMsg.backgroundColor;
                    });
                    sleep(1);
                    NSLog(@"波形发生器连接失败!");
                }
            }
            else
            {
                index = 4;
                
                //测试代码
                index = 5;
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    currentStateMsg.stringValue=@"设备初始化完成";
                    currentStateMsg.backgroundColor = [NSColor yellowColor];
                    currentStateMsgBG.backgroundColor = currentStateMsg.backgroundColor;
                });
            }
        }
        
#pragma mark index=4 确保产品接触完整的指令
        //------------------------------------------------------------
        //index=4
        //------------------------------------------------------------
        if (index==4)
        {
            while (isTouch)
            {
                isTouch=false;//下压成功
                [fixtureSerial WriteLine:@"reset"];
                sleep(0.5);
        
                if ([[[fixtureSerial ReadExisting] uppercaseString ]containsString:@"RESET_OK"])
                {
                    currentStateMsg.stringValue=@"复位成功!";
                    currentStateMsg.backgroundColor = [NSColor yellowColor];
                    currentStateMsgBG.backgroundColor = currentStateMsg.backgroundColor;
                    NSLog(@"复位成功!");
                    break;
                }
            }
            
            sleep(0.5);
            if(![currentStateMsg.stringValue containsString:@"请按双启按钮"])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    currentStateMsg.stringValue = @"请按双启按钮";
                    currentStateMsg.backgroundColor = [NSColor yellowColor];
                    currentStateMsgBG.backgroundColor = currentStateMsg.backgroundColor;
                    //***********TestCode***********************//
                    //index=5;
                    //********************************************//
                });
            }
        
            //返回Teststart,可以开始检测SN
            if ([[fixtureSerial ReadExisting] isEqualToString:@"TestStart"])
            {
                index=5;
            }
        }
        
#pragma mark index=5  输入产品sn
//------------------------------------------------------------
//index=5
//------------------------------------------------------------
        if (index == 5)
        {
            [self GetSFC_PDCAState];//获取是否上传的状态
            NSLog(@"输入产品sn");
            sleep(1);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //判断 SN 的规则
                if (importSN.stringValue.length==8||[importSN.stringValue isEqualToString:@"123456"])
                {
                    //赋值SN
                    currentStateMsg.backgroundColor = [NSColor redColor];
                    [TestStep Instance].strSN=importSN.stringValue;;
                   
                    //根据SFC状态，检验SN是否过站
                    if (isUpLoadSFC)
                    {
                        if (![[TestStep Instance]StepSFC_CheckUploadSN:isUpLoadSFC])
                        {
                            NSLog(@"已经过站");
                            sleep(2);
                            index = 4;
                        }
                        else
                        {
                            index=6;//进入正常测试中
                        }
                    }
                    else
                    {
                         index=6;//进入正常测试中
                    }
                }
                else
                {
                    currentStateMsg.stringValue = @"sn错误，请重新输入";
                    currentStateMsg.backgroundColor = [NSColor redColor];
                    currentStateMsgBG.backgroundColor = currentStateMsg.backgroundColor;
                    return ;
                }
                
                //cycle_test,开始测试前清空tableView
                [mk_table ClearTable];
                 ct_cnt = 0;
            });
        }
    
#pragma mark index=6  开始产品测试
//------------------------------------------------------------
//index=6
//------------------------------------------------------------
        if (index == 6)
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                currentStateMsg.stringValue = @"index=6 sn 正确!";
                currentStateMsg.backgroundColor = [NSColor greenColor];
                currentStateMsgBG.backgroundColor = currentStateMsg.backgroundColor;
                testResult.stringValue = @"Running";
            });
            NSLog(@"产品测试");
            testResult.backgroundColor = [NSColor colorWithRed:176/255.0f green:216/255.0f blue:252/255.0f alpha:1];
            
            //========定时器开始========
            if (ct_cnt == 0)
            {
               /**
                *  GCD 定时器
                */
                [mkTimer setTimer:0.1];
                [mkTimer startTimerWithTextField:testFieldTimes];
                ct_cnt = 1;
            }
            //=========================
            
            //在这里加入测试的起始时间
            if (row_index == 0)
            {
                NSLog(@"j记录 pdca 的起始测试时间");
                [pdca PDCA_GetStartTime];                        //记录pcda的起始测试时间
                start_time = [[GetTimeDay shareInstance] getFileTime];    //启动测试的时间,csv里面用
            }
            
            testItem = itemArr[item_index];
            NSLog(@"%@=========%@========%@",testItem.testName, testItem.value, itemArr[item_index]);
            
            //加载测试项
            BOOL boolResult = [self TestItem:testItem];
            
            //测试结果转为字符串格式
            if (boolResult == YES)
            {
                itemResult = @"PASS";
            }
            else
            {
                itemResult = @"FAIL";
            }
            //把测试结果加入到可变数组中
            [testResultArr addObject:itemResult];
            
            [mk_table flushTableRow:testItem RowIndex:row_index];
            
            row_index++;
            item_index++;
            
            //走完测试流程,进入下一步
            if (item_index == itemArr.count)
            {
                //异步加载主线程显示,弹出啊 log_View
                dispatch_async(dispatch_get_main_queue(), ^{
                    //遍历测试结果,输出总测试结果
                    for (int i = 0; i< testResultArr.count; i++)
                    {
                        if ([testResultArr[i] isEqualToString:@"FAIL"])
                        {
                            testResult.backgroundColor = [NSColor redColor];
                            [testResult setStringValue:@"FAIL"];
                            break;
                        }
                        else
                        {
                            testResult.backgroundColor = [NSColor greenColor];
                            [testResult setStringValue:@"PASS"];
                        }
                    }
                    testResultStr = testResult.stringValue;
                    sleep(0.5);
                });
                
                index = 7;
            }
        }

#pragma mark index=7  上传pdca，生成本地数据报表
//------------------------------------------------------------
//index=7
//------------------------------------------------------------
        if (index == 7)
        {
            //========定时器结束========
            [mkTimer endTimer];
            //记录PDCA结束时间;记录测试结束时间
            [pdca PDCA_GetEndTime];
            ct_cnt = 0;
            //========================
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                currentStateMsg.stringValue = @"index=7 生成数据文件";
                currentStateMsg.backgroundColor = [NSColor greenColor];
                currentStateMsgBG.backgroundColor = currentStateMsg.backgroundColor;
            });
            sleep(1);
            
            if([MK_FileCSV shareInstance]!= nil)       //生成本地数据报表
            {
                testNum++; //测试
                
                //文件夹路径
                NSString *currentPath=@"/Users/value";
        
                //测试结束并创建文件的时间
                end_time = [[GetTimeDay shareInstance] getFileTime];
        
                //产品 sn
                NSString *currentSN = importSN.stringValue;
                
                //创建总文件夹
                [[MK_FileFolder shareInstance] createOrFlowFolderWithCurrentPath:currentPath SubjectName:@"Emerald_Log"];
                
                //创建对应不同工站的文件夹
                NSString *currentStationTitle = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentStationStatus"];
                
                if ([currentStationTitle isEqualToString: @"Station_0"])
                {
                     [[MK_FileFolder shareInstance] createOrFlowFolderWithCurrentPath:[NSString stringWithFormat:@"%@/Emerald_Log/%@/",currentPath,[[GetTimeDay shareInstance] getCurrentDay]] SubjectName:@"Station_0"];
                }
                if ([currentStationTitle isEqualToString: @"Station_1"])
                {
                     [[MK_FileFolder shareInstance] createOrFlowFolderWithCurrentPath:[NSString stringWithFormat:@"%@/Emerald_Log/%@/",currentPath,[[GetTimeDay shareInstance] getCurrentDay]] SubjectName:@"Station_1"];
                }
                if ([currentStationTitle isEqualToString: @"Station_2"])
                {
                     [[MK_FileFolder shareInstance] createOrFlowFolderWithCurrentPath:[NSString stringWithFormat:@"%@/Emerald_Log/%@/",currentPath,[[GetTimeDay shareInstance] getCurrentDay]] SubjectName:@"Station_2"];
                }
                if ([currentStationTitle isEqualToString: @"Station_3"])
                {
                    [[MK_FileFolder shareInstance] createOrFlowFolderWithCurrentPath:[NSString stringWithFormat:@"%@/Emerald_Log/%@/",currentPath,[[GetTimeDay shareInstance] getCurrentDay]] SubjectName:@"Station_3"];
                }
                
                //csv文件列表头,测试标题项遍历当前plisth文件的测试项(拼接),温湿度传感器
                NSString *titleStr;
                NSMutableString *titleMutableStr;
                if (titleMutableStr == nil)
                {
                    titleMutableStr = [[NSMutableString alloc] init];
                }
                for (int i = 0; i< testItemTitleArr.count; i++)
                {
                    titleStr = [testItemTitleArr objectAtIndex:i];
                    [titleMutableStr appendString:[NSString stringWithFormat:@",%@",titleStr]];
                }
                
                NSString *csvTitle = [NSString stringWithFormat:@"SN,TestResult,%@,TempValue,StartTime,EndTime",titleMutableStr];
                NSString *humitureCSVTitle = [NSString stringWithFormat:@"SN,TestResult,HumitureValue,StartTime,EndTime"];
                
                //csv测试项内容,同上
                NSString *contentStr;
                NSMutableString *contentMutableStr;
                if (contentMutableStr == nil)
                {
                    contentMutableStr = [[NSMutableString alloc] init];
                }
                for (int i=0; i< testItemValueArr.count; i++)
                {
                    contentStr = [testItemValueArr objectAtIndex:i];
                    [contentMutableStr appendString:[NSString stringWithFormat:@",%@",contentStr]];
                }
                NSString *csvContent = [NSString stringWithFormat:@"%@,%@",contentMutableStr,HumitureTF.stringValue];
                
                //创建 csv 文件,并写入数据
                [[MK_FileCSV shareInstance] createOrFlowCSVFileWithFolderPath:[MK_FileFolder shareInstance].folderPath Sn:currentSN TestItemStartTime:start_time TestItemEndTime:end_time TestItemContent:csvContent TestItemTitle:csvTitle TestResult:testResultStr];
                
                //创建温湿度 csv 文件, sn,当前值,开始时间,结束时间
                [[MK_FileCSV shareInstance] createOrFlowCSVFileWithFolderPath:[MK_FileFolder shareInstance].folderPath Sn:currentSN TestItemStartTime:start_time TestItemEndTime:end_time TestItemContent:HumitureTF.stringValue TestItemTitle:humitureCSVTitle TestResult:@"--"];
                
                //创建 txt 文件,并写入数据
                [[MK_FileTXT shareInstance] createOrFlowTXTFileWithFolderPath:[MK_FileFolder shareInstance].folderPath Sn:currentSN TestItemStartTime:start_time TestItemEndTime:end_time TestItemContent:csvContent TestResult:testResultStr];
               
                index = 8;
            }
            
            //上传PDCA和SFC
            if (isUpLoadPDCA)
            {
                
                [self UploadPDCA];
            }
            
            if (isUpLoadSFC)
            {
                if ( ![[TestStep Instance]StepSFC_CheckUploadResult:isUpLoadSFC andIsTestPass: [testResult.stringValue isEqualToString:@"FAIL"]?NO:YES  andFailMessage:nil])
                {
                    currentStateMsg.stringValue = @"SFC上传失败";
                    currentStateMsg.backgroundColor = [NSColor greenColor];
                    currentStateMsgBG.backgroundColor = currentStateMsg.backgroundColor;
                }
            }
        }
        
#pragma mark index=8  结束测试
//------------------------------------------------------------
//index=8
//------------------------------------------------------------
        if (index == 8)
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                currentStateMsg.stringValue = @"index=8 结束测试";
                currentStateMsg.backgroundColor = [NSColor greenColor];
                currentStateMsgBG.backgroundColor = currentStateMsg.backgroundColor;
            });
            sleep(1);
            
            testItem = nil;
            plist = nil;
            row_index=0;
            item_index=0;
            testItemTitleArr = nil;
            testItemValueArr = nil;
            
            //每次结束测试都刷新主界面
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([testResult.stringValue isEqualToString:@"PASS"])
                {
                    passNum++;
                }
                testCount.stringValue = [NSString stringWithFormat:@"%d/%d",passNum,testNum];
                totalNumInfo.stringValue = [NSString stringWithFormat:@"%d",testNum];
                
                passNumInfoTF.stringValue = [NSString stringWithFormat:@"%d",passNum];
                passNumCalculateTF.stringValue = [NSString stringWithFormat:@"%.2f%%",((double)passNum/(double)testNum)*100];
                
                failNumInfoTF.stringValue = [NSString stringWithFormat:@"%d",(testNum - passNum)];
                failNumCalculateTF.stringValue = [NSString stringWithFormat:@"%.2f%%",((double)(testNum-passNum)/(double)testNum)*100];
                
              //录入sn 收集器
                NSString *str1 = [NSString stringWithFormat:@"%@__%@__%@_%@",importSN.stringValue,testResultStr,HumitureTF.stringValue,[[GetTimeDay shareInstance] getCurrentTime]];
                NSString *str2 = SN_Collector.string;
                SN_Collector.string = [str2 stringByAppendingString:[NSString stringWithFormat:@"%@\n",str1]];
                
                if ([testResult.stringValue isEqualToString:@"PASS"])
                {
                    [SN_Collector setTextColor:[NSColor greenColor]];
                }
                else
                {
                    [SN_Collector setTextColor:[NSColor redColor]];
                }
                
                //是否需要写入本地缓存
                importSN.stringValue = @"";
            });

            //重新进入操作治具复位处
            index = 4;
            
            //测试代码
            index = 5;
            
            isTouch=YES;
        }
    }
}


//==================== 冲定向log ============================
- (void)redirectNotificationHandle:(NSNotification *)nf{
    NSData *data = [[nf userInfo] objectForKey:NSFileHandleNotificationDataItem];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
    if(logView_Info != nil)
    {
        NSRange range;
        range = NSMakeRange ([[logView_Info string] length], 0);
        [logView_Info replaceCharactersInRange: range withString: str];
        [logView_Info scrollRangeToVisible:range];
    }
    [[nf object] readInBackgroundAndNotify];
}

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
//==================== 冲定向log ============================


//================================================
//测试项指令解析
//================================================
-(BOOL)TestItem:(Item*)testitem
{
    sleep(1);
    BOOL ispass=NO;
    if (testItemValueArr == nil)
    {
        testItemValueArr = [NSMutableArray arrayWithCapacity:0];
    }
    if (testItemTitleArr == nil)
    {
        testItemTitleArr = [NSMutableArray arrayWithCapacity:0];
    }
    
    for (int i=0; i<[testitem.testAllCommand count]; i++)
    {
        //治具===================Fixture
        //波形发生器==============OscillDevice
        //安捷伦万用表============Aglient
        //延迟时间================SW
        dic=[testitem.testAllCommand objectAtIndex:i];
        SonTestDevice=dic[@"TestDevice"];
        SonTestCommand=dic[@"TestCommand"];
        SonTestName=dic[@"TestName"];
        delayTime = [dic[@"TestDelayTime"] intValue]/1000;
        
        //**************************治具=Fixture
        if ([SonTestDevice isEqualToString:@"Fixture"])
        {
            NSLog(@"治具发送指令%@========%@",SonTestDevice,SonTestCommand);
            
            [fixtureSerial WriteLine:SonTestCommand];
            sleep(0.2);
            
            NSString  * readString;
            int indexTime=0;
            
            while (YES)
            {
                readString=[fixtureSerial ReadExisting];
                if ([readString isEqualToString:@"RESET_OK"]||indexTime==[testitem.retryTimes intValue])
                {
                    break;
                }
                indexTime++;
            }
        }
        //**************************波形发生器=WaveDevice
        else if ([SonTestDevice isEqualToString:@"WaveDevice"])
        {
            if ([SonTestCommand isEqualToString:@"MODE_Sine"])
            {
                [agilent33210A SetMessureMode:MODE_Sine andCommunicateType:Agilent33210A_USB_Type andFREQuency:param.waveFrequence andVOLTage:param.waveVolt andOFFSet:param.waveOffset];
            }
            else if([SonTestCommand isEqualToString:@"MODE_Square"])
            {
                [agilent33210A SetMessureMode:MODE_Square andCommunicateType:Agilent33210A_USB_Type andFREQuency:param.waveFrequence andVOLTage:param.waveVolt andOFFSet:param.waveOffset];

            }
            else if([SonTestCommand isEqualToString:@"MODE_Ramp"])
            {
                 [agilent33210A SetMessureMode:MODE_Ramp andCommunicateType:Agilent33210A_USB_Type andFREQuency:param.waveFrequence andVOLTage:param.waveVolt andOFFSet:param.waveOffset];
            
            }
            else if([SonTestCommand isEqualToString:@"MODE_Pulse"])
            {
                   [agilent33210A SetMessureMode:MODE_Pulse andCommunicateType:Agilent33210A_USB_Type andFREQuency:param.waveFrequence andVOLTage:param.waveVolt andOFFSet:param.waveOffset];
            
            }
            else if([SonTestCommand isEqualToString:@"MODE_Noise"])
            {
                    [agilent33210A SetMessureMode:MODE_Noise andCommunicateType:Agilent33210A_USB_Type andFREQuency:param.waveFrequence andVOLTage:param.waveVolt andOFFSet:param.waveOffset];
            
            }
            else//其它情况
            {
                NSLog(@"波形发生器其它情况");
            }

            NSLog(@"%@*************示波器发送指令**************%@",SonTestDevice,SonTestCommand);
            
        }
        //**************************万用表==Agilent或者Keithley
        else if ([SonTestDevice isEqualToString:@"Agilent"]||[SonTestDevice isEqualToString:@"Keithley"])
        {
            //万用表发送指令
            if ([SonTestCommand isEqualToString:@"DC Volt"])
            {
                //直流电压测试
                [agilent3458A SetMessureMode:Agilent3458A_VOLT_DC];
                NSLog(@"设置直流电压模式");
            }
            else if([SonTestCommand isEqualToString:@"AC Volt"])
            {
                [agilent3458A SetMessureMode:Agilent3458A_VOLT_AC];
                 NSLog(@"设置交流电压模式");
            }
            else if ([SonTestCommand isEqualToString:@"DC Current"])
            {
                [agilent3458A SetMessureMode:Agilent3458A_CURR_DC];
                NSLog(@"设置直流电流模式");
            }
            else if ([SonTestCommand isEqualToString:@"AC Current"])
            {
                [agilent3458A SetMessureMode:Agilent3458A_CURR_AC];
                NSLog(@"设置交流电流模式");
            }
            else if ([SonTestCommand containsString:@"RES"])//电阻分单位KΩ,MΩ,GΩ
            {
                [agilent3458A SetMessureMode:Agilent3458A_RES_2W];
                
                NSLog(@"设置自动电阻模式");
            }
            else//其它的值
            {
                //5次电压递增测试
                if ([testitem.testName containsString:@"RF_5a"]) //设备
                {
                    int indexTime=0;
                    
                    while (YES)
                    {
                        [agilent3458A WriteLine:@"END"];
                        
                        agilentReadString=[agilent3458A ReadData:16];
                        
                        //测试代码
                        agilentReadString = @"0.5";
                        
                        //大于1，直接跳出，并发送reset指令
                        if (agilentReadString.length>0&&[agilentReadString floatValue]>=1)
                        {
                            [fixtureSerial WriteLine:@"reset"];
                            
                            break;
                        }
                        if ([agilentReadString floatValue]<1)//读取3次，3次后等待15秒再发送
                        {
                            indexTime++;
                            
                            if (indexTime==[testitem.retryTimes intValue]-1)
                            {
                                sleep(13.5);
                                [agilent3458A WriteLine:@"END"];
                                agilentReadString=[agilent3458A ReadData:16];
                                
                                //测试代码
                                agilentReadString = @"0.5";
                                
                                break;
                            }
                        }
                    }
                    
                    testitem.value = agilentReadString;
                }
                //其它正常读取情况
                else
                {
                    [agilent3458A WriteLine:@"END"];
                    agilentReadString=[agilent3458A ReadData:16];
                    
                    //测试代码
                    agilentReadString = @"5.5";
                }
                
                float num=[agilentReadString floatValue];
                
                if ([SonTestCommand containsString:@"Read"])
                {
                    if ([testitem.units isEqualToString:@"GΩ"])//GΩ的情况计算
                    {
                        testitem.value = [NSString stringWithFormat:@"%.3f", (((0.8 - num)/num)*10)/1000];
                    }
                    else if ([testitem.units isEqualToString:@"MΩ"])//MΩ的情况计算
                    {
                        if ([testitem.testName isEqualToString:@"Sensor_Flex SF-1b"]||[testitem.testName isEqualToString:@"Crown Rotation SF-1b"])
                        {
                            testitem.value = [NSString stringWithFormat:@"%.3f", ((1.41421*0.8 - num)/num)*5];
                        }
                        
                        else
                        {
                            testitem.value = [NSString stringWithFormat:@"%.3f", ((1.41421*0.8 - num)/num)*10];
                        }
                    }
                    else if ([testitem.units isEqualToString:@"kΩ"]&&[SonTestCommand containsString:@"Read"])//KΩ的情况计算
                    {
                        num=num/(10E+02);
                        testitem.value = [NSString stringWithFormat:@"%.3f",num];
                    }
                    
                    else if ([testitem.units containsString:@"uA"]&&[SonTestCommand containsString:@"Read"])
                    {
                        testitem.value = [NSString stringWithFormat:@"%.3f",num*1000000];
                    }
                    
                    else
                    {
                        testitem.value = [NSString stringWithFormat:@"%.3f",num];
                    }
                    
                    if ([testitem.max isEqualToString:@"∞"]&&[testitem.value floatValue]>=[testitem.min floatValue])
                    {
                        testitem.value  = [NSString stringWithFormat:@"%@",testitem.value];
                        testitem.result = @"PASS";
                        ispass = YES;
                    }
                    
                    else if (([testitem.value floatValue]>=[testitem.min floatValue]&&[testitem.value floatValue]<=[testitem.max floatValue]))
                    {
                        testitem.value  = [NSString stringWithFormat:@"%@",testitem.value];
                        testitem.result = @"PASS";
                        testItem.messageError=nil;
                        ispass = YES;
                    }
                    
                    else
                    {
                        testitem.value  = [NSString stringWithFormat:@"%@",testitem.value];
                        testitem.result = @"FAIL";
                        testItem.messageError=[NSString stringWithFormat:@"%@Fail",testitem.testName];
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
    
    //获取万用表最终的值
    testitem.value = agilentReadString;
    
    //每次的测试项与测试标题存入可变数组中
    [testItemValueArr addObject:testItem.value];
    [testItemTitleArr addObject: testItem.testName];
    return ispass;
}

-(void)refreshTheInfoBox
{
    dispatch_async(dispatch_get_main_queue(), ^{
        passNumInfoTF.stringValue = @"0";
        passNumCalculateTF.stringValue = @"0%";
        failNumInfoTF.stringValue = @"0";
        failNumCalculateTF.stringValue = @"0%";
        totalNumInfo.stringValue = @"0";
        testNum = 0;
        passNum = 0;
        testCount.stringValue = @"0/0";
        SN_Collector.string = @"";
    });
}

#pragma mark-Button action
- (IBAction)clickToRefreshInfoBox:(NSButton *)sender
{
    [self refreshTheInfoBox];
}


//停止线程
- (IBAction)clickToStop_ReStart:(NSButton *)sender
{
    PDCA_Btn.enabled = NO;
    SFC_Btn.enabled = NO;
    
    sleep(0.5);
    if (myThrad!=nil) {
        [mkTimer endTimer];
        [self HumitureStopTimer];
        [myThrad cancel];
         myThrad = nil;
        [self closeAllDevice];
        index = 0;
        item_index = 0;
        row_index = 0;
        testItemValueArr = nil;
        testItemTitleArr = nil;
        [NSMenu setMenuBarVisible:YES];
    }
}


//开始按钮
- (IBAction)start_Button_Action:(id)sender
{
    if (myThrad==nil)
    {
        //启动线程,进入测试流程
        myThrad = [[NSThread alloc] initWithTarget:self selector:@selector(Working) object:nil];
        index = 0;
        item_index = 0;
        row_index = 0;
        testItemValueArr = nil;
        testItemTitleArr = nil;
        [myThrad start];
    }
}



- (IBAction)ClickUploadPDCAAction:(id)sender
{
    NSLog(@"点击上传 PDCA");
}


- (IBAction)clickUpLoadSFCAction:(id)sender
{
     NSLog(@"点击上传 SFC");
}



/**
 *  必须要清除本地的存储数据,否则可能导致文件创建失败
 */
//界面消失后取消线程
-(void)viewWillDisappear
{
    //=================
    [myThrad cancel];
    myThrad = nil;
    
    //主动释放掉
    [self closeAllDevice];
}


//获取按钮的状态
-(void)GetSFC_PDCAState
{
    dispatch_sync(dispatch_get_main_queue(),^{
            isUpLoadSFC=[SFC_Btn state]==1?YES:NO;
            isUpLoadPDCA=[PDCA_Btn state]==1?YES:NO;
    });
}



//================================================
//上传pdca
//================================================
-(void)UploadPDCA
{
    BOOL PF = YES;    //所有测试项是否pass
    //========================尚不清楚下面的参数意思
    [pdca PDCA_Init:importSN.stringValue SW_name:param.sw_name SW_ver:param.sw_ver];   //上传sn，sw_name,sw_ver
    [pdca PDCA_AddAttribute:param.s_build FixtureID:param.fixture_id];         //上传s_build，fixture_id
    //========================
    for(int i=0;i<[itemArr count];i++)
    {
        Item *testitem=itemArr[i];
        
        if(testitem.isTest)  //需要测试的才需要上传
        {
            Item *testitem = itemArr[i];
             BOOL pass_fail=YES;
            if( ![testitem.result isEqualToString:@"PASS"] )
            {
                pass_fail = NO;
                
                PF = NO;
            }
            
            
            [pdca PDCA_UploadValue:testitem.testName
                             Lower:testitem.min
                             Upper:testitem.max
                              Unit:testitem.units
                             Value:testitem.value
                         Pass_Fail:pass_fail
             ];

        }
        else //如果测试结果只有pass或fail
        {
            if([testitem.result isEqualToString:@"PASS"])
            {
                [pdca PDCA_UploadPass:testitem.testName];
            }
            else
            {
                [pdca PDCA_UploadFail:testitem.testName Message:testitem.messageError];
                 PF = NO;
            }
        }
        
    }
    
    [pdca PDCA_Upload:PF];     //上传汇总结果
}



- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}



//================================================
// 开始刷新温度定时器
//================================================
-(void)HumitureStartTimer:(float)seconds
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //定义一个NSTimer
        humTimer = [NSTimer scheduledTimerWithTimeInterval:seconds
                                                    target:self
                                                  selector:@selector(TimerUpdateWindow)
                                                  userInfo:nil
                                                   repeats:YES
                    ];
    });
}
//================================================
// 停止温度定时器
//================================================
-(void)HumitureStopTimer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(humTimer != nil){
            [humTimer invalidate];// 定时器调用invalidate后，就会自动执行release方法。不需要在显示的调用release方法
        }
    });
}


#pragma mark--------------更新温湿度窗口
//更新温度窗体
-(void)TimerUpdateWindow
{
    @autoreleasepool
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //执行耗时操作
            [humitureSerial WriteLine:@"READ"];
            sleep(2);
            NSString * string=[humitureSerial ReadExisting];
            
            //测试代码
            string = @"45℃/23";
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (string.length>0)
                {
                    if (string.length>10)
                    {
                        [HumitureTF setStringValue:[string substringToIndex:11]];
                         humitString=[string substringToIndex:11];
                    }
                    else
                    {
                        [HumitureTF setStringValue:string];
                        humitString=string;
                    }
                }
                
                else
                {
                    [HumitureTF setStringValue:humitString];
                    
                }
            });
        });
    }
}

#pragma mark--------释放所有设备
-(void)closeAllDevice
{
    //主动释放掉
    [humitureSerial Close];
    [fixtureSerial Close];
    [agilent33210A CloseDevice];
    [agilent3458A CloseDevice];
    
}

@end
