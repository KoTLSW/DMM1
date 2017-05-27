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
#import "TestStep.h"
#import "Agilent3458A.h"
#import "Agilent33210A.h"
#import "Param.h"
#import "InstantPudding_API_QT1.h"


NSString  *param_path=@"Param";
@implementation ViewController
{
    //************ Device *************
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
    

    __weak IBOutlet NSTextField *bigTitleTF;
    __weak IBOutlet NSTextField *versionTF;
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
    
    
//    PDCA         *pdca;             //PDCA对象
    NSString     *ReStaName;
    NSString     *ReStaID;
    BOOL debug_skip_pudding_error;
    NSMutableArray *failItemsArr;
    NSMutableArray *passItemsArr;
    
    double num;
    double DCIN2V_CURR_value;
    double DCIN3V_CURR_value;
    double POSFWDVOLTAGE_DIFF_value;
    double POSFWDVOLTAGE_value;
    double NEGFWDVOLTAGE_DIFF_value;
    double NEGFWDVOLTAGE_value;
    double RIN_value;
    double RIN_VOUT_value;
    double ZIN_value;
    double ZIN_VOUT_value;
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
//    pdca = [[PDCA alloc] init];
    passItemsArr = [NSMutableArray arrayWithCapacity:0];
    failItemsArr = [NSMutableArray arrayWithCapacity:0];
    
    humitString=@"";
    item_index = 0;
    row_index = 0;
    index=0;
    logView_Info.editable = NO;
    testNum = 0;
    passNum = 0;
    itemArr = [NSMutableArray array];
    PDCA_Btn.enabled = NO;
    SFC_Btn.enabled = NO;
//    _startBtn.enabled = NO;
    
    if (param.isDebug)
    {
        bigTitleTF.stringValue = @"Debug Mode";
        versionTF.stringValue = @"--";
    }
    else
    {
        bigTitleTF.stringValue = @"Testing";
        versionTF.stringValue = param.sw_ver;
    }
    
    //第一次运行没有本地缓存时,默认的工站
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentStationStatus"] == nil || [[[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentStationStatus"]  isEqual: @""])
    {
        NSLog(@"进入 Station_0 工站");
        stationID_TF.stringValue = @"Sensor Board";
        
        //读取 plist 文件
        itemArr = [plist PlistRead:@"Station_0" Key:@"AllItems"];
        mk_table = [mk_table init:tab_View DisplayData:itemArr];
        
        //改变serverSF的值
        [BYDSFCManager Instance].ServerFCKey=@"ServerFC_0";
    }
    else
    {
        //进来就判断读取哪个配置文件
        [self selectStationNoti:nil];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectStationNoti:) name:@"changePlistFileNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectPDCA_SFC_LimitNoti:) name:@"PDCAButtonLimit_Notification" object:nil];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CancellPDCA_SFC_LimitNoti:) name:@"CancellButtonlimit_Notification" object:nil];
    
//    //测试项线程
//     myThrad = [[NSThread alloc] initWithTarget:self selector:@selector(Working) object:nil];
//    [myThrad start];
    
    //温湿度定时器
    humTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(TimerUpdateWindow) userInfo:nil repeats:YES];
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
//    if ([NSMenu menuBarVisible] == YES)
//    {
//        [NSMenu setMenuBarVisible:NO];
//    }
   
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
            if ([fixtureSerial IsOpen])
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    currentStateMsg.stringValue=@"index=0,治具连接成功!";
                    NSLog(@"index=0,治具连接成功!");
                    [currentStateMsg setTextColor:[NSColor blueColor]];
                });
                
                [fixtureSerial WriteLine:@"reset"];
                sleep(1);
                
                if ([[[fixtureSerial ReadExisting] uppercaseString ]containsString:@"RESET_OK"])
                {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        currentStateMsg.stringValue=@"index=0,治具复位成功!";
                        NSLog(@"index=0,治具复位成功!");
                        [currentStateMsg setTextColor:[NSColor blueColor]];
                    });
                    index = 1;
                }
                else
                {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        currentStateMsg.stringValue=@"index=0,治具复位失败";
                        NSLog(@"治具复位失败");
                        [currentStateMsg setTextColor:[NSColor redColor]];
                    });
                }
            }
            
            else
            {
                //========================test Code============================
                BOOL uartConnect=[fixtureSerial Open:param.fixture_uart_port_name BaudRate:BAUD_115200 DataBit:DATA_BITS_8 StopBit:StopBitsOne Parity:PARITY_NONE FlowControl:FLOW_CONTROL_NONE];
                
                //Debug mode
                if (param.isDebug)
                {
                    uartConnect = YES;
                    index = 1;
                }

                if (uartConnect)
                {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        currentStateMsg.stringValue=@"index=0,治具连接成功!";
                        NSLog(@"index=0,治具连接成功!");
                        [currentStateMsg setTextColor:[NSColor blueColor]];
                    });
                    
                    [fixtureSerial WriteLine:@"reset"];
                    sleep(1);
                    
                    if ([[[fixtureSerial ReadExisting] uppercaseString ]containsString:@"RESET_OK"])
                    {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            currentStateMsg.stringValue=@"index=0,治具复位成功!";
                            NSLog(@"index=0,治具复位成功!");
                            [currentStateMsg setTextColor:[NSColor blueColor]];
                        });
                        index = 1;
                    }
                    else
                    {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            currentStateMsg.stringValue=@"index=0,治具复位失败";
                            NSLog(@"治具复位失败");
                            [currentStateMsg setTextColor:[NSColor redColor]];
                        });
                    }
                }
                else
                {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        currentStateMsg.stringValue=@"index=0,治具连接失败!";
                        NSLog(@"index=0,治具连接失败!");
                        [currentStateMsg setTextColor:[NSColor redColor]];
                    });
                    sleep(1);
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
            
            //Debug mode
            if (param.isDebug)
            {
                agilent3458A_isOpen = YES;
            }
            
            sleep(1);
            if (agilent3458A_isOpen)
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    currentStateMsg.stringValue=@"index=1,安捷伦连接成功!";
                    NSLog(@"安捷伦连接成功!");
                    [currentStateMsg setTextColor:[NSColor blueColor]];
                });
                index = 2;
            }
            else
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    currentStateMsg.stringValue=@"安捷伦连接失败!";
                    NSLog(@"安捷伦连接失败!");
                    [currentStateMsg setTextColor:[NSColor redColor]];
                });
                sleep(1);
            }
        }
      
#pragma mark index=2 初始化温度传感器
//------------------------------------------------------------
//index=2
//------------------------------------------------------------
        if(index==2)
        {
            BOOL isCollect=[humitureSerial Open:param.humiture_uart_port_name BaudRate:BAUD_9600 DataBit:DATA_BITS_8 StopBit:StopBitsOne Parity:PARITY_NONE FlowControl:FLOW_CONTROL_NONE];
            
            //Debug mode
            if (param.isDebug)
            {
                isCollect = YES;
            }
            
            sleep(1);
            if (isCollect)
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    currentStateMsg.stringValue=@"index=2,温湿度串口连接成功";
                    NSLog(@"温湿度串口连接成功");
                   [currentStateMsg setTextColor:[NSColor blueColor]];
                });
               
//              [humitureSerial WriteLine:@"ATUO"];//发送2s接收数据的
                humitureCollect=YES;
                [self HumitureStartTimer:2];
                index = 3;
            }
            else
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    currentStateMsg.stringValue=@"index=2,温湿度串口连接失败";
                    NSLog(@"温湿度串口连接失败");
                    [currentStateMsg setTextColor:[NSColor redColor]];
                });
                sleep(1);
            }
        }
        
#pragma mark index=3 初始化波形发生器
        //------------------------------------------------------------
        //index=3
        //------------------------------------------------------------
        if(index==3)
        {
            //Debug Mode
            if (param.isDebug)
            {
                param.isWaveNeed = YES;
            }
            
            if (param.isWaveNeed)  //有些工站需要，有些不需要
            {
                BOOL agilent33210A_isFind = [agilent33210A Find:nil andCommunicateType:Agilent33210A_USB_Type];
                BOOL agilent33210A_isOpen =[agilent33210A OpenDevice: nil andCommunicateType:Agilent33210A_USB_Type];
             
                //Debug Mode
                if (param.isDebug)
                {
                    agilent33210A_isFind = YES;
                    agilent33210A_isOpen = YES;
                }
                
                sleep(1);
                if (agilent33210A_isFind && agilent33210A_isOpen)
                {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        currentStateMsg.stringValue=@"index=3,波形发生器连接成功!";
                        NSLog(@"波形发生器连接成功!");
                        [currentStateMsg setTextColor:[NSColor blueColor]];
                    });
                    index = 4;
                    
                    //测试代码
                    index = 5;
                }
                else
                {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        currentStateMsg.stringValue=@"index=3,波形发生器连接失败!";
                        NSLog(@"波形发生器连接失败!");
                        [currentStateMsg setTextColor:[NSColor redColor]];
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
                    [currentStateMsg setTextColor:[NSColor blueColor]];
                });
                sleep(1);
            }
        }
        
#pragma mark index=4 确保产品接触完整的指令
        //------------------------------------------------------------
        //index=4
        //------------------------------------------------------------
        if (index==4)
        {
//            while (isTouch)
//            {
//                isTouch=false;//下压成功
                [fixtureSerial WriteLine:@"reset"];
                sleep(0.5);
        
                if ([[[fixtureSerial ReadExisting] uppercaseString ]containsString:@"RESET_OK"])
                {
                    currentStateMsg.stringValue=@"复位成功!";
                    NSLog(@"复位成功!");
                    sleep(1);
//                    break;
                }
                else
                {
                    currentStateMsg.stringValue=@"复位失败!";
                    NSLog(@"复位失败!");
                    sleep(1);
//                    break;
                }
//            }
            
            sleep(0.5);
//            if(![currentStateMsg.stringValue containsString:@"请按双启按钮"])
//            {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    currentStateMsg.stringValue = @"请按双启按钮";
            
//                    //***********TestCode***********************//
//                    //index=5;
//                    //********************************************//
//                });
//            }
        
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
            NSLog(@"请输入产品sn");
            sleep(1);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //判断 SN 的规则
                if (importSN.stringValue.length==17||[importSN.stringValue isEqualToString:@"0123456789ABCDEFG"])
                {
                    //赋值SN
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
                    NSLog(@"sn 错误");
                    [currentStateMsg setTextColor:[NSColor redColor]];
                    return ;
                }
                
                //cycle_test,开始测试前清空tableView
                [mk_table ClearTable];
                 ct_cnt = 0;
            });
        }
    
#pragma mark index=6  等待点击开始按钮
//------------------------------------------------------------
//index=6
//------------------------------------------------------------
        if (index == 6)
        {
            sleep(1);
            dispatch_async(dispatch_get_main_queue(), ^{
                _startBtn.enabled = YES;
                currentStateMsg.stringValue = @"请点击 Testing 按钮";
                NSLog(@"wait to start button...");
                [currentStateMsg setTextColor:[NSColor redColor]];
            });
        }
        
#pragma mark index=7  开始产品测试
//------------------------------------------------------------
//index=7
//------------------------------------------------------------
        if (index == 7)
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                _startBtn.enabled = NO;
                currentStateMsg.stringValue = @"index=6 sn 正确!";
                NSLog(@"sn 正确!");
                [currentStateMsg setTextColor:[NSColor blueColor]];
                testResult.stringValue = @"Running";
                testResult.backgroundColor = [NSColor greenColor];
            });
            
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
//                [pdca PDCA_GetStartTime];                        //记录pcda的起始测试时间
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
            
            
            //给治具发送reset指令,收到 RESET_OK 后往下跑
            [fixtureSerial WriteLine:@"reset"];
            sleep(1);
            if ([[[fixtureSerial ReadExisting] uppercaseString ]containsString:@"RESET_OK"])
            {
                NSLog(@"item testing fixture reset_ok");
                row_index++;
                item_index++;
            }
            else
            {
                NSLog(@"item testing fixture reset fail");
                if (param.isDebug)
                {
                    row_index++;
                    item_index++;
                }
            }
            
            //走完测试流程,进入下一步
            if (item_index == itemArr.count)
            {
                //异步加载主线程显示,弹出啊 log_View
                dispatch_async(dispatch_get_main_queue(), ^{
                    //遍历测试结果,输出总测试结果
                    for (int i = 0; i< testResultArr.count; i++)
                    {
                        if ([testResultArr[i] containsString:@"FAIL"])
                        {
                            [testResult setStringValue:@"FAIL"];
                            testResult.backgroundColor = [NSColor redColor];
                            break;
                        }
                        else
                        {
                            [testResult setStringValue:@"PASS"];
                            testResult.backgroundColor = [NSColor greenColor];
                        }
                    }
                    
                    testResultStr = testResult.stringValue;
                    sleep(0.5);
                });
                
                
                [fixtureSerial WriteLine:@"reset"];
                sleep(0.7);
            
                index = 8;
            }
        }

#pragma mark index=8  上传pdca，生成本地数据报表
//------------------------------------------------------------
//index=8
//------------------------------------------------------------
        if (index == 8)
        {
            //========定时器结束========
            [mkTimer endTimer];
            //记录PDCA结束时间;记录测试结束时间
//            [pdca PDCA_GetEndTime];
            ct_cnt = 0;
            //========================
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                currentStateMsg.stringValue = @"index=7 生成数据文件";
                NSLog(@"生成数据文件...");
                [currentStateMsg setTextColor:[NSColor blueColor]];
            });
            sleep(1);
            
            if([MK_FileCSV shareInstance]!= nil)       //生成本地数据报表
            {
                testNum++; //测试
                
                //文件夹路径
                NSString *currentPath=@"/vault";
        
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
            }
            
#pragma mark ------ 上传 PDCA
            if (isUpLoadPDCA)
            {
                NSLog(@"开始上传pdca");
                [self uploadPDCA_Feicui_2];
            }
            
#pragma mark ------ 上传 SFC
            if (isUpLoadSFC)
            {
                if ( ![[TestStep Instance]StepSFC_CheckUploadResult:isUpLoadSFC andIsTestPass: [testResult.stringValue isEqualToString:@"FAIL"]?NO:YES  andFailMessage:nil])
                {
                    currentStateMsg.stringValue = @"SFC上传失败";
                    [currentStateMsg setTextColor:[NSColor redColor]];
                }
                sleep(1);
            }
            
            index = 9;
        }
        
#pragma mark index=9  结束测试
//------------------------------------------------------------
//index=9
//------------------------------------------------------------
        if (index == 9)
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                currentStateMsg.stringValue = @"index=8 结束测试";
                [currentStateMsg setTextColor:[NSColor blueColor]];
            });
            sleep(1);
            
            testItem = nil;
            plist = nil;
            row_index=0;
            item_index=0;
            testItemTitleArr = nil;
            testItemValueArr = nil;
            testResultArr = nil;
            
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
                NSString *str1 = [NSString stringWithFormat:@"%@___%@__%@",importSN.stringValue,testResultStr,[[GetTimeDay shareInstance] getCurrentTime]];
                NSString *str2 = SN_Collector.string;
                SN_Collector.string = [str2 stringByAppendingString:[NSString stringWithFormat:@"%@\n",str1]];
                [SN_Collector setTextColor:[NSColor blueColor]];
                
//                if ([testResult.stringValue isEqualToString:@"PASS"])
//                {
//                    [SN_Collector setTextColor:[NSColor greenColor]];
//                }
//                else
//                {
//                    [SN_Collector setTextColor:[NSColor redColor]];
//                }
                
                //是否需要写入本地缓存
                importSN.stringValue = @"";
            });
            
            [self clickToStop_ReStart:_stopBtn];
            
//            //重新进入操作治具复位处
//            index = 4;
//            
//            //测试代码
//            index = 5;
            
//            isTouch=YES;
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


-(double)CALCULATE:(NSString *)str
{
    NSDictionary *dice = [NSDictionary dictionary];
    
    if ([str isEqualToString:@"POSFWDVOLTAGE_DIFF"])
    {
       dic = [self getItemBytes:itemArr WithTestName:@"POSFWDVOLTAGE"];
        
        NSString *FW_valuestr = [dic objectForKey:@"Value"];
        double FW_value = [FW_valuestr doubleValue];
        return (FW_value-1.5);
    }
    else if ([str isEqualToString:@"NEGFWDVOLTAGE_DIFF"])
    {
        dic = [self getItemBytes:itemArr WithTestName:@"NEGFWDVOLTAGE"];
        
        NSString *FW_valuestr = [dic objectForKey:@"Value"];
        double FW_value = [FW_valuestr doubleValue];
        return (FW_value+1.5);
    }
    else if ([str isEqualToString:@"RIN"])
    {
        dic = [self getItemBytes:itemArr WithTestName:@"RIN_VOUT"];
        
        NSString *FW_valuestr = [dic objectForKey:@"Value"];
        double FW_value = [FW_valuestr doubleValue];
        return (10.0*FW_value/(0.8-FW_value));
    }
    else if ([str isEqualToString:@"ZIN"])
    {
        dic = [self getItemBytes:itemArr WithTestName:@"ZIN_VOUT"];
        
        NSString *FW_valuestr = [dic objectForKey:@"Value"];
        double FW_value = [FW_valuestr doubleValue];
        return (10*FW_value/(0.565-FW_value));
    }
    else if ([str isEqualToString:@"SAFETYR"])
    {
        dic = [self getItemBytes:itemArr WithTestName:@"DCIN2V_CURR"];
        NSString *FW_valuestr1 = [dic objectForKey:@"Value"];
        double FW_value1 = [FW_valuestr1 doubleValue];
        
        dic = [self getItemBytes:itemArr WithTestName:@"DCIN3V_CURR"];
        NSString *FW_valuestr2 = [dic objectForKey:@"Value"];
        double FW_value2 = [FW_valuestr2 doubleValue];
        
        return 1.0/(1000.0*(FW_value2-FW_value1));
    }
    
    else
    {
        [self getItemBytes:itemArr WithTestName:@""];
        return 0;
    }
}



//calculate
-(NSDictionary *)getItemBytes:(NSArray *)testNameArr WithTestName:(NSString *)testName
{
    NSDictionary *dic = [NSDictionary dictionary];
    
    for(int count = 0; count < testNameArr.count; count++)
    {
        dic = testNameArr[count];
        if ([[dic objectForKey:@"POSFWDVOLTAGE"] isEqualToString: testName])
        {
            return dic;
        }
    }
    return nil;
}


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
    
#pragma mark--------具体测试指令执行流程
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
            sleep(0.7);
            
            int indexTime=0;
            
            while (YES)
            {
                if ([[[fixtureSerial ReadExisting] uppercaseString ]containsString:@"RESET_OK"]||indexTime==[testitem.retryTimes intValue])
                {
                    sleep(3);
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
                [agilent33210A SetMessureMode:MODE_Square andCommunicateType:Agilent33210A_USB_Type andFREQuency:@"5" andVOLTage:@"1.8" andOFFSet:@"0"];

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
            
            sleep(1);
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
                if ([testitem.testName containsString:@"_CURR"]) //设备
                {
                    int indexTime=0;
                    
                    while (YES)
                    {
                        [agilent3458A WriteLine:@"END"];
                        agilentReadString=[agilent3458A ReadData:16];
                        
                        if (param.isDebug)
                        {
                            //测试代码
                            agilentReadString = @"3000";
                        }
                        
                        //大于1，直接跳出，并发送reset指令
                        if (agilentReadString.length>0&&[agilentReadString floatValue]>=1)
                        {
                            [fixtureSerial WriteLine:@"reset"];
                            
                            break;
                        }
                        if ([agilentReadString floatValue]<1)//读取3次，3次后等待15秒再发送
                        {
                            indexTime++;
                            
                            if (indexTime >= [testitem.retryTimes intValue]-1)
                            {
                                sleep(13.5);
                                [agilent3458A WriteLine:@"END"];
                                agilentReadString=[agilent3458A ReadData:16];
                                
                                if (param.isDebug)
                                {
                                    //测试代码
                                    agilentReadString = @"3000";
                                }
                                
                                break;
                            }
                        }
                    }
                    num = [agilentReadString floatValue];
                }
                
                //其它正常读取情况
                else
                {
                    [agilent3458A WriteLine:@"END"];
                    agilentReadString=[agilent3458A ReadData:16];
                    
                    if (param.isDebug)
                    {
                        //测试代码
                        agilentReadString = @"2000";
                    }
                }
                
                num = [agilentReadString floatValue];
            }
        }
    }
    
#pragma mark--------最终显示在 table 的测试项值
    
    //-------------------------------------------------------
    
    if ([testItem.testName isEqualToString:@"POSFWDVOLTAGE_DIFF"])
    {
        testitem.value = [NSString stringWithFormat:@"%f",(POSFWDVOLTAGE_value-1.2)];
    }
    else if ([testItem.testName isEqualToString:@"POSFWDVOLTAGE"])
    {
        POSFWDVOLTAGE_value = num;
        testitem.value = [NSString stringWithFormat:@"%f",POSFWDVOLTAGE_value];
    }
    
    else if ([testItem.testName isEqualToString:@"NEGFWDVOLTAGE_DIFF"])
    {
        testitem.value = [NSString stringWithFormat:@"%f",NEGFWDVOLTAGE_value+1.2];
    }
    else if ([testItem.testName isEqualToString:@"NEGFWDVOLTAGE"])
    {
        NEGFWDVOLTAGE_value = num;
        testitem.value = [NSString stringWithFormat:@"%f",NEGFWDVOLTAGE_value];
    }
    
    else if ([testItem.testName isEqualToString:@"RIN"])
    {
        testitem.value = [NSString stringWithFormat:@"%f",(10.0*RIN_VOUT_value/(0.8-RIN_VOUT_value))];
    }
    else if ([testItem.testName isEqualToString:@"RIN_VOUT"])
    {
        RIN_VOUT_value = num;
        testitem.value = [NSString stringWithFormat:@"%f",RIN_VOUT_value];
    }
    
    else if ([testItem.testName isEqualToString:@"ZIN"])
    {
        testitem.value = [NSString stringWithFormat:@"%f",(10*ZIN_VOUT_value/(0.565-ZIN_VOUT_value))];
    }
    else if ([testItem.testName isEqualToString:@"ZIN_VOUT"])
    {
        ZIN_VOUT_value = num;
        testitem.value = [NSString stringWithFormat:@"%f",ZIN_VOUT_value];
    }
    
    else if ([testItem.testName isEqualToString:@"DCIN2V_CURR"])
    {
        DCIN2V_CURR_value = num;
        testitem.value = [NSString stringWithFormat:@"%f",DCIN2V_CURR_value];
    }
    
    else if ([testItem.testName isEqualToString:@"DCIN3V_CURR"])
    {
        DCIN3V_CURR_value = num;
        testitem.value = [NSString stringWithFormat:@"%f",DCIN3V_CURR_value];
    }
    
    else if ([testItem.testName isEqualToString:@"SAFETYR"])
    {
        testitem.value = [NSString stringWithFormat:@"%f",1.0/(1000.0*(DCIN3V_CURR_value - DCIN2V_CURR_value))];
    }
    //-------------------------------------------------
    else
    {
        testitem.value = [NSString stringWithFormat:@"%.3f",num];
    }
    
 
    //单位换算
    if ([testitem.units isEqualToString: @"mV"])
    {
        testitem.value = [NSString stringWithFormat:@"%.3f",[testitem.value floatValue]*1000];
    }
    
    if ([testitem.units isEqualToString:@"uA"])
    {
        testitem.value = [NSString stringWithFormat:@"%.3f",num*1000000];
    }
    
    if ([testitem.units isEqualToString:@"A"] || [testitem.units isEqualToString:@"V"] || [testitem.units isEqualToString:@"Ω"])
    {
        testitem.value = [NSString stringWithFormat:@"%.3f",num];
    }
    
    
    if([SonTestDevice isEqualToString:@"SW"])
    {
        //延迟时间
        NSLog(@"延迟时间**************%@",SonTestDevice);
        sleep(delayTime);
    }

    
    
    //上下限值对比
    if (([testitem.value floatValue]>=[testitem.min floatValue]&&[testitem.value floatValue]<=[testitem.max floatValue]) || ([testitem.max isEqualToString:@"--"]&&[testitem.value floatValue]>=[testitem.min floatValue]) || ([testitem.max isEqualToString:@"--"] && [testitem.min isEqualToString:@"--"])  || ([testitem.min isEqualToString:@"--"]&&[testitem.value floatValue]<=[testitem.max floatValue]) )
    {
        testitem.result = @"PASS";
        testItem.messageError=nil;
        [passItemsArr addObject: @"PASS"];
        ispass = YES;
    }
    else
    {
        testitem.result = @"FAIL";
        testItem.messageError=[NSString stringWithFormat:@"%@Fail",testitem.testName];
        [failItemsArr addObject:@"FAIL"];
        ispass = NO;
    }
    
    NSLog(@"%@",testitem.value);
    
    //每次的测试项与测试标题存入可变数组中
    [testItemValueArr addObject:testItem.value];
    [testItemTitleArr addObject: testItem.testName];
    
//    [cfailItems addObject:[NSNumber numberWithBool:ispass]];
   
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

#pragma mark-----Button action
- (IBAction)clickToRefreshInfoBox:(NSButton *)sender
{
    [self refreshTheInfoBox];
}


//停止线程
- (IBAction)clickToStop_ReStart:(NSButton *)sender
{
    NSLog(@"stop the action!!");
    PDCA_Btn.enabled = NO;
    SFC_Btn.enabled = NO;
    
    sleep(0.5);
    if (myThrad!=nil)
    {
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
    }
    
//    if ([NSMenu menuBarVisible]==NO)
//    {
//        [NSMenu setMenuBarVisible:YES];
//    }
    
    [_startBtn setEnabled:YES];
    [_startBtn setTitle:@"Start"];
}


//开始按钮
- (IBAction)start_Button_Action:(NSButton *)sender
{
    if ([sender.title isEqualToString:@"Start"]) {
        
        [sender setTitle:@"Testing"];
        
        NSLog(@"start the action!!");
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
        [sender setEnabled:NO];
    }
    
    else
    {
        [sender setEnabled:NO];
        [sender setTitle:@"Start"];
        NSLog(@"Start again");
        index = 7;
    }
}


- (IBAction)ClickUploadPDCAAction:(NSButton *)sender
{
    NSLog(@"点击上传 PDCA");
}

- (IBAction)clickUpLoadSFCAction:(NSButton *)sender
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

#pragma mark----PDCA相关
//================================================
//上传pdca
//================================================
-(NSString *)GetSpecStr:(NSString *)Original thestartStr:(NSString *)startStr theendStr:(NSString *)endStr
{
    if([startStr length]>0 && [Original rangeOfString:startStr].length)
    {
        int sP=(int)[Original rangeOfString:startStr].location;
        sP= sP + (int)[startStr length];
        Original=[Original substringFromIndex:sP];
    }
    if([endStr length]>0 && [Original rangeOfString:endStr].length)
    {
        int eL=(int)[Original rangeOfString:endStr].location;
        return [Original substringToIndex:eL];
    }
    
    return Original;
}

BOOL stringisnumber(NSString *stringvalues){
    
    NSString *temp;
    if ([stringvalues length]) {
        for(int i=0;i<[stringvalues length];i++){
            temp=[[stringvalues substringFromIndex:i] substringToIndex:1];
            if (![@"-1234567890." rangeOfString:temp].length) {
                return FALSE;
            }
        }
    }else {
        return FALSE;
    }
    return TRUE;
}


void handleReply( IP_API_Reply reply )
{
    if ( !IP_success( reply ) )
    {
        NSRunAlertPanel(@"Confirm",@"Upload PDCA data error", @"YES", nil,nil);
        NSLog(@"Upload PDCA data error");
        //exit(-1);
    }
    IP_reply_destroy(reply);
}


-(void)uploadPDCA_Feicui_2
{
    /**
     * info :
     *  cfailItems     ----->    all the failItems
     *  param.sw_ver   ------>  we can get the param infomation form the (Param.plist) file, like this: param.sw_ver, param.isDebug...
     *  theSN   =   importSN.stringValue
     *  itemArr ---------> All test Items  , the way to get , itemArr = [plist PlistRead:@"Station_0" Key:@"AllItems"];
     *  testItem -------->  form Item class  ,  testItem = [itemArr objectAtIndex:i],we can get different testItem ; than we have all the item infomation like this : testItem.testName/ testItem.units / testItem.min / testItem.value /testItem.max / testItem.result
     *
     */
    
//------------------------------- nothing to change --------------------------------------------------
    
        //------------ json ------------ to  get the Station_Type = (ReStaName)
        NSString *restoreinfoPath = @"/vault/data_collection/test_station_config/gh_station_info.json";
        if (![[NSFileManager defaultManager] fileExistsAtPath:restoreinfoPath])
        {
            NSLog(@"Can't find /vault/data_collection/test_station_config/gh_station_info.json !");
            //return;
        }
        else
        {
            NSData *filecontent=[[NSFileManager defaultManager] contentsAtPath:restoreinfoPath];
            NSString *info=[[NSString alloc]initWithData:filecontent encoding:1];
            NSArray * lineArray=[info componentsSeparatedByString:@"\n"];
    
            for(int i=0;i<[lineArray count];i++)
            {
                NSString *linestring=[lineArray objectAtIndex:i];
                NSLog(@"json linestring is ============ %@ ==========", linestring);
    
                //ReStaName
                if ([linestring rangeOfString:@"\"STATION_TYPE\" :"].length>0)
                {
                    NSString *STATION_TYPE=@"";
                    STATION_TYPE=[self GetSpecStr:linestring thestartStr:@": \"" theendStr:@"\","];
                    STATION_TYPE=[STATION_TYPE stringByReplacingOccurrencesOfString:@" " withString:@""];
                    STATION_TYPE=[STATION_TYPE stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                    STATION_TYPE=[STATION_TYPE stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    ReStaName=[[NSString alloc] initWithString:STATION_TYPE];
                    NSLog(@"%@",ReStaName);
                }
            }
        }
        //------------------------
    
    
    NSMutableArray *cfailItems=[[NSMutableArray alloc] initWithArray:failItemsArr];
    NSString *theSN=[[NSString alloc] initWithString:importSN.stringValue];
    
//------------------------------- nothing to change --------------------------------------------------

//    if([theSN length]!=SN_LENGTH){
//        
//        NSRunAlertPanel(@"Confirm", @"SN is Error!", @"YES", nil,nil);
//        return;
//    }
    
    IP_UUTHandle UID;
    Boolean APIcheck;
    IP_TestSpecHandle testSpec;
    
    IP_API_Reply reply = IP_UUTStart(&UID);
    if(!IP_success(reply))
    {
        NSRunAlertPanel(@"Confirm", [NSString stringWithCString:IP_reply_getError(reply) encoding:1], @"YES", nil,nil);
    }
    
    IP_reply_destroy(reply);
    
    handleReply(IP_addAttribute( UID, IP_ATTRIBUTE_STATIONSOFTWAREVERSION, [ [NSString stringWithFormat:@"%@",param.sw_ver] cStringUsingEncoding:1]  ));
    handleReply(IP_addAttribute( UID, IP_ATTRIBUTE_STATIONSOFTWARENAME, [ReStaName cStringUsingEncoding:1]  ));
    handleReply(IP_addAttribute( UID, IP_ATTRIBUTE_STATIONLIMITSVERSION, [[NSString stringWithFormat:@"%@",param.sw_ver] cStringUsingEncoding:1]));
    
    handleReply(IP_addAttribute( UID, IP_ATTRIBUTE_SERIALNUMBER, [theSN cStringUsingEncoding:1] ));
    
//==========================================================================================
//----------------------- change the loop 2017.5.25 _MK ------------------------------------
    for(int i=0;i<[itemArr count];i++)
    {
        testItem = [itemArr objectAtIndex:i];
        
        testSpec=IP_testSpec_create();
        
        //--------------------- title---------------------------
        NSString *Title = testItem.testName;
        APIcheck=IP_testSpec_setTestName(testSpec, [Title cStringUsingEncoding:1], [Title length]);
        
        NSString *theUpperLimit = testItem.max;
        if(theUpperLimit==nil || [theUpperLimit isEqualToString:@"--"])
        {
            theUpperLimit=@"N/A";
        }
        
        NSString *theLowerLimit = testItem.min;
        if(theLowerLimit==nil || [theLowerLimit isEqualToString:@"--"])
        {
            theLowerLimit=@"N/A";
        }
    
        //----------------- setLimits ------------------------------
        APIcheck=IP_testSpec_setLimits(testSpec, [theLowerLimit cStringUsingEncoding:1], [theLowerLimit length], [theUpperLimit cStringUsingEncoding:1], [theUpperLimit length]);
        
        //--------------------- unit -------------------------------------
        NSString *theMeasurementUnit = testItem.units;
        if(theMeasurementUnit!=nil)
        {
            APIcheck=IP_testSpec_setUnits(testSpec, [theMeasurementUnit cStringUsingEncoding:1], [theMeasurementUnit length]);
        }
    
        APIcheck=IP_testSpec_setPriority(testSpec, IP_PRIORITY_REALTIME);
    
        IP_TestResultHandle puddingResult=IP_testResult_create();
        
        
        NSString *valueStr = testItem.value;
        
        if(NSOrderedSame==[valueStr compare:@"Pass" options:NSCaseInsensitiveSearch] || NSOrderedSame==[valueStr compare:@"Fail" options:NSCaseInsensitiveSearch])
        {
            valueStr=@"";
        }
        
        const char *value=[valueStr cStringUsingEncoding:1];
        
        int valueLength=[valueStr length];
        
        int result=IP_FAIL;
        
        NSString *resultStr=testItem.result;
        
        if([resultStr isEqualToString:@"PASS"])
        {
            result=IP_PASS;
        }
    
        if (stringisnumber(valueStr))
        {
            APIcheck=IP_testResult_setValue(puddingResult, value,valueLength);
        }
        
        APIcheck=IP_testResult_setResult(puddingResult, result);
        
        if(!result)
        {
            NSString *failDes=@"";
            
            //==========errorcode@errormessage================
            if([testItem.result length]==0)
            {
                failDes=[failDes stringByAppendingString:@"N/A" ];
            }
            
            else
            {
                failDes=[failDes stringByAppendingString:testItem.result];
            }
            
            failDes=[failDes stringByAppendingString:@"@"];
            
            APIcheck=IP_testResult_setMessage(puddingResult, [failDes cStringUsingEncoding:1], [failDes length]);
        }
        
        reply=IP_addResult(UID, testSpec, puddingResult);
        
        if(!IP_success(reply))
        {
            NSRunAlertPanel(@"Confirm", [NSString stringWithCString:IP_reply_getError(reply) encoding:1], @"YES", nil,nil);
        }
        
        IP_reply_destroy(reply);
        
        IP_testResult_destroy(puddingResult);
        
        IP_testSpec_destroy(testSpec);
    }
    
    
//------------------------ nothing change --------------------------------------
    IP_API_Reply doneReply=IP_UUTDone(UID);
    if(!IP_success(doneReply)){
        //NSRunAlertPanel(@"Confirm", [NSString stringWithCString:IP_reply_getError(doneReply) encoding:1], @"YES", nil,nil);
        //exit(-1);
    }
    IP_reply_destroy(doneReply);
    IP_API_Reply commitReply;
    if([cfailItems count]>0){
        commitReply=IP_UUTCommit(UID, IP_FAIL);
    }
    else{
        commitReply=IP_UUTCommit(UID, IP_PASS);
    }
    if(!IP_success(commitReply)){
        ;
    }
    IP_reply_destroy(commitReply);
    IP_UID_destroy(UID);
}


#pragma mark--------------温湿度窗口
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

//更新温度窗体
-(void)TimerUpdateWindow
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //执行耗时操作
        [humitureSerial WriteLine:@"AUTO"];
        
        sleep(2);
        
        NSString * humStr=[humitureSerial ReadExisting];
        
        //Debug Mode
        if (param.isDebug)
        {
            humStr = @"12℃,45%";
        }
        
        humStr = [humStr stringByReplacingOccurrencesOfString:@"," withString:@"/"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (humStr.length>0)
            {
                if (humStr.length>10)
                {
                    [HumitureTF setStringValue:[humStr substringToIndex:11]];
                    humitString=[humStr substringToIndex:11];
                }
                else
                {
                    [HumitureTF setStringValue:humStr];
                    humitString=humStr;
                }
            }
            else
            {
                [HumitureTF setStringValue:humitString];
            }
        });
    });
}


#pragma mark--------释放所有设备
-(void)closeAllDevice
{
    //主动释放掉
    [humitureSerial Close];
    [fixtureSerial Close];
    [agilent33210A CloseDevice];
    [agilent3458A CloseDevice];
    
//    if ([NSMenu menuBarVisible] == YES)
//    {
//        [NSMenu setMenuBarVisible:NO];
//    }
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}

@end
