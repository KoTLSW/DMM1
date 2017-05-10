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


@implementation ViewController
{
    SerialPort          * fixtureSerial;//治具串口
    
    SerialPort          * humitureSerial; //温湿度串口
    
    KeithleyDevice      * keithleySerial; //泰克调试
    
    AgilentDevice       * agilent;//安捷伦万用表
    
    
    Table *mk_table;                       // table类
    Plist *plist;                       // plist类
    AlertWindowController  * alertwindowController;

    
    NSMutableArray *itemArr;            // plist文件测试项数组
    Item *testItem ;
    NSString *itemResult; //每一个测试项的结果
    NSMutableArray *testResultArr; // 返回的结果数组
    
    int index;                          // 测试流程下标
    int item_index;                     // 测试项下标
    int row_index;                      // table 每一行下标
    
    NSString *start_time;               //启动测试的时间
    NSString *end_time;                 //结束测试的时间
    int testNum;                        //测试次数
    int passNum;                        //通过次数
    
    NSThread *myThrad;                  // 自定义线程
    
    __weak IBOutlet NSView *tab_View;               // 与storyboard 关联的 outline_Tab
    __weak IBOutlet NSTextField *importSN;          //输入的sn
    __weak IBOutlet NSTextField *currentStateMsg;   //当前的状态信息
    __weak IBOutlet NSTextField *currentStateMsgBG;
    
    __weak IBOutlet NSTextField *testResult;        //测试结果
                    NSString    *testResultStr;     //测试结果
    
    __weak IBOutlet NSTextField *testFieldTimes;         //测试时间
    __weak IBOutlet NSTextField *testCount;         //测试次数
    
    __weak IBOutlet NSButton *PDCA_Btn;
    __weak IBOutlet NSButton *SFC_Btn;
    
    __unsafe_unretained IBOutlet NSTextView *logView_Info; //log_View 中显示的信息
    
    MKTimer *mkTimer;               //MK 定时器对象
    int      ct_cnt;           //记录cycle time定时器中断的次数
    
    SerialPort *serialPort;
    
    //************ testItems ************
    NSString        *agilentReadString;
    NSDictionary    *dic;
    NSString        *SonTestDevice;
    NSString        *SonTestCommand;
    NSString        *SonTestName;
    int             delayTime;
    
    //************ InfoBox *************
    __weak IBOutlet NSTextField *passNumInfoTF;
    __weak IBOutlet NSTextField *passNumCalculateTF;
    __weak IBOutlet NSTextField *failNumInfoTF;
    __weak IBOutlet NSTextField *failNumCalculateTF;
    __weak IBOutlet NSTextField *totalNumInfo;
    __weak IBOutlet NSTextField *fixtureID_TF;
    __weak IBOutlet NSTextField *stationID_TF;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    
    //初始化对象
    serialPort = [[SerialPort alloc] init];
    
    fixtureSerial=[[SerialPort alloc] init];
    
    keithleySerial=[[KeithleyDevice alloc] init];
    
    [self redirectSTD:STDOUT_FILENO];  //冲定向log
    [self redirectSTD:STDERR_FILENO];
    
    mkTimer = [[MKTimer alloc] init];
    plist = [[Plist alloc] init];
    mk_table = [[Table alloc] init];
    
    item_index = 0;
    row_index = 0;
    index=3;
    logView_Info.editable = NO;
    testNum = 0;
    passNum = 0;
    itemArr = [NSMutableArray array];
    PDCA_Btn.enabled = NO;
    SFC_Btn.enabled = NO;
    
    _stopBtn.title = @"Start";
    
    //进来就判断读取哪个配置文件
    [self selectStationNoti:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectStationNoti:) name:@"changePlistFileNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectPDCA_SFC_LimitNoti:) name:@"PDCAButtonLimit_Notification" object:nil];
}

-(void)selectPDCA_SFC_LimitNoti:(NSNotification *)noti
{
    PDCA_Btn.enabled = YES;
    SFC_Btn.enabled = YES;
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
    }
    if ([noti.object isEqualToString:@"Station_1"]|| [[[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentStationStatus"] isEqualToString:@"Station_1"])
    {
        NSLog(@"进入 Station_1 工站");
        stationID_TF.stringValue = @"Crown Flex";
        
        //读取 plist 文件
        itemArr = [plist PlistRead:@"Station_1" Key:@"AllItems"];
        mk_table = [mk_table init:tab_View DisplayData:itemArr];
    }
    if ([noti.object isEqualToString:@"Station_2"]|| [[[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentStationStatus"] isEqualToString:@"Station_2"])
    {
        NSLog(@"进入 Station_2 工站");
        stationID_TF.stringValue = @"Sensor Flex Sub Assembly";
        
        //读取 plist 文件
        itemArr = [plist PlistRead:@"Station_2" Key:@"AllItems"];
        mk_table = [mk_table init:tab_View DisplayData:itemArr];
    }
    if ([noti.object isEqualToString:@"Station_3"]|| [[[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentStationStatus"] isEqualToString:@"Station_3"])
    {
        NSLog(@"进入 Station_3 工站");
        stationID_TF.stringValue = @"Crown Rotation Sub Assembly";
        
        //读取 plist 文件
        itemArr = [plist PlistRead:@"Station_3" Key:@"AllItems"];
        mk_table = [mk_table init:tab_View DisplayData:itemArr];
    }
    
    fixtureID_TF.stringValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentStationStatus"];
    
    if (myThrad != nil)
    {
        return;
    }
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
        
#pragma mark index=0
//------------------------------------------------------------
//index=0 打开安捷伦万用表---USB通信
//------------------------------------------------------------
        if (index == 0)
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                currentStateMsg.stringValue=@"连接治具...";
            });
            sleep(1);
            NSLog(@"连接治具...");
            
            if ([serialPort IsOpen])
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    currentStateMsg.stringValue=@"index=0,治具已经连接";
                });
                sleep(1);
                NSLog(@"index=0,治具已经连接");
                index = 1;
            }
            
            else
            {
                //========================test Code============================
//                BOOL uartConnect=[serialPort Open:param.fixture_uart_port_name BaudRate:BAUD_115200 DataBit:DATA_BITS_8 StopBit:StopBitsOne Parity:PARITY_NONE FlowControl:FLOW_CONTROL_NONE];
                
                BOOL uartConnect = YES;//测试
                //========================test Code============================
                
                if (uartConnect)
                {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        currentStateMsg.stringValue=@"index=0,治具已经连接";
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
                    sleep(1);
                    NSLog(@"index=0,治具还未连接");
                    return;
                }
            }
        }
        
#pragma mark index=1
//------------------------------------------------------------
//index=1 打开安捷伦万用表---LAN通信
//------------------------------------------------------------
        if (index==1)
        {
            //========================test Code============================
            BOOL testBool = YES;
            if (testBool)
//            if (([mk_agilent Find:nil] && [mk_agilent OpenDevice:nil]) == YES)
                //========================test Code============================
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                     currentStateMsg.stringValue=@"index=1,安捷伦已经连接";
                });
                sleep(1);
                NSLog(@"index=1,安捷伦已经连接");
                
//                设备连接完后,发送测试温度(热敏电阻)的指令
//                [mk_agilent SetMessureMode:MODE_RES];
              
//                 [mk_agilent SetMessureMode:MODE_TEMPERATURE];
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
                index = 2000;
            }
        }
        
#pragma mark index=2
//------------------------------------------------------------
//index=2  输入产品sn
//------------------------------------------------------------
        if (index == 2)
        {
            NSLog(@"输入产品sn");
            sleep(1);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"============%@",importSN.stringValue);
                
                if ([importSN.stringValue isEqualToString:@" "] || importSN.stringValue == nil || [importSN.stringValue  isEqual: @""])
                {
                    currentStateMsg.stringValue = @"index=2 请输入 sn!";
                    currentStateMsg.backgroundColor = [NSColor yellowColor];
                    currentStateMsgBG.backgroundColor = currentStateMsg.backgroundColor;
                    return ;
                }
                if ([importSN.stringValue isEqualToString:@"123456"])
                {
                    //赋值SN
                    [[BYDSFCManager Instance] setStrSN:importSN.stringValue];
                    
                    //根据SFC状态，检验SN是否过站
//                    if (SFCState==1) {//上传SFC,检验SN的产品是否已经过站
//                        if ([[TestStep Instance]StepSFC_CheckUploadSN:SFCState]) {
//                            
//                            NSLog(@"已经过站");
//                        }
//                        else
//                        {
//                            index = 3;
//                            
//                        }
//                        
//                    }
                    
                    index = 3;
                }
                else
                {
                    currentStateMsg.stringValue = @"sn 错误!!";
                    currentStateMsg.backgroundColor = [NSColor redColor];
                    currentStateMsgBG.backgroundColor = currentStateMsg.backgroundColor;
                }
                
                //cycle_test,开始测试前清空tableView
                [mk_table ClearTable];
                ct_cnt = 0;
            });
        }
    
#pragma mark index=3
//------------------------------------------------------------
//index=3  开始产品测试
//------------------------------------------------------------
        if (index == 3)
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                currentStateMsg.stringValue = @"index=3 sn 正确!";
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
//              [pdca PDCA_GetStartTime];                        //记录pcda的起始测试时间
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
            if (item_index >= itemArr.count)
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
                
                index = 4;
            }
        }

#pragma mark index=4
//------------------------------------------------------------
//index=4  上传pdca，生成本地数据报表
//------------------------------------------------------------
        if (index == 4)
        {
            //========定时器结束========
            [mkTimer endTimer];
            ct_cnt = 0;
            //========================
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                currentStateMsg.stringValue = @"index=4 生成数据文件";
                currentStateMsg.backgroundColor = [NSColor greenColor];
                currentStateMsgBG.backgroundColor = currentStateMsg.backgroundColor;
            });
            sleep(1);
            
            if([MK_FileCSV shareInstance]!= nil)       //生成本地数据报表
            {
                testNum++; //测试
                
                //文件夹路径
                NSString *currentPath=@"/Users/michael/Desktop/";
        
                //测试结束并创建文件的时间
                end_time = [[GetTimeDay shareInstance] getFileTime];
        
                //产品 sn __此处需要发指令通过 uart 获取
                NSString *currentSN = [NSString stringWithFormat:@"00223344%d",testNum];

                //uart 回传的字符信息,通过 uart 指令获取
                
                
                //测试项内容,把每一项测试的内容重新拼接,并写入csv/txt文件中
                NSString *testContent = [NSString stringWithFormat:@"array ,array ,array =================== %d",testNum];
                
                //创建文件夹
                [[MK_FileFolder shareInstance] createOrFlowFolderWithCurrentPath:currentPath SubjectName:@"Emerald_Log"];
                
                //csv文件列表头
                NSString *csvTitle = @"sn,testResult,testItemStartTime,testItemEndTime,testItemContent";
                
                //创建 csv 文件,并写入数据
                [[MK_FileCSV shareInstance] createOrFlowCSVFileWithFolderPath:[MK_FileFolder shareInstance].folderPath Sn:currentSN TestItemStartTime:start_time TestItemEndTime:end_time TestItemContent:testContent TestItemTitle:csvTitle TestResult:testResultStr];
                
                //创建 txt 文件,并写入数据
                [[MK_FileTXT shareInstance] createOrFlowTXTFileWithFolderPath:[MK_FileFolder shareInstance].folderPath Sn:currentSN TestItemStartTime:start_time TestItemEndTime:end_time TestItemContent:testContent TestResult:testResultStr];
               
                index = 5;
            }
        }
        
#pragma mark index=5
//------------------------------------------------------------
//index=5  结束测试
//------------------------------------------------------------
        if (index == 5)
        {
            
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                currentStateMsg.stringValue = @"index=5 结束测试";
                currentStateMsg.backgroundColor = [NSColor greenColor];
                currentStateMsgBG.backgroundColor = currentStateMsg.backgroundColor;
            });
            sleep(1);
            
            testItem = nil;
            plist = nil;
            row_index=0;
            item_index=0;
            
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
                
                importSN.stringValue = @"";
            });
            
            index = 0;
            
//            if ( ![[TestStep Instance]StepSFC_CheckUploadResult:SFCState=0?NO:YES andIsTestPass: [testResult.stringValue isEqualToString:@"FAIL"]?NO:YES  andFailMessage:nil]) {
//                
//                [self UpdateLableStatus:@"SFC上传失败" andColor:[NSColor redColor]];
//                
//                
//            }
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
        if ([SonTestDevice isEqualToString:@"Fixture"]) {
            
            NSLog(@"治具发送指令%@========%@",SonTestDevice,SonTestCommand);
            
            [fixtureSerial WriteLine:SonTestCommand];
            sleep(0.2);
            
            NSString  * readString;
            int indexTime=0;
            
            while (YES) {
                
                readString=[fixtureSerial ReadExisting];
                if ([readString isEqualToString:@"OK"]||indexTime==[testitem.retryTimes intValue] )
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
                if ([SonTestName isEqualToString:@"RF-5a"]) {//设备
                    
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
                            
                            if (indexTime==[testitem.retryTimes intValue]-1)
                            {
                                
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
                
                testitem.value=@"1.5";//为获取万用表的值
                
                if ([SonTestCommand containsString:@"Read"]) {
                    
                    //1和2工站===============SF-2a&&SF-2b计算
                    if ([testitem.testName isEqualToString:@"Sensor Board SF-2a"]||[testitem.testName isEqualToString:@"Crown flex RF-2a"]||[testitem.testName isEqualToString:@"Sensor_Flex SF-1a"]) {
                        
                        float num=[agilentReadString floatValue];
                        testitem.value = [NSString stringWithFormat:@"%f%@", ((0.8 - num)/num)*10,@"G"];
                        
                    }
                    if ([testitem.testName isEqualToString:@"Sensor Board SF-2b"]||[testitem.testName isEqualToString:@"Crown flex RF-2b"]||[testitem.testName isEqualToString:@"Sensor_Flex SF-1b"])
                    {
                        float num=[agilentReadString floatValue];
                        if ([testitem.testName isEqualToString:@"Sensor_Flex SF-1b"]) {
                            testitem.value = [NSString stringWithFormat:@"%f%@", ((1.41421*0.8 - num)/num)*5,@"G"];
                        }
                        else
                        {
                            testitem.value = [NSString stringWithFormat:@"%f%@", ((1.41421*0.8 - num)/num)*10,@"G"];
                        }
                    }
                    
                    
                    NSLog(@"%f=====================%f",[testitem.min floatValue],[testitem.max floatValue]);
                    
                    if ([testitem.value floatValue]>=[testitem.min floatValue]&&[testitem.value floatValue]<=[testitem.max floatValue])
                    {
                        
                        testitem.value  = [NSString stringWithFormat:@"%@",testitem.value];
                        testitem.result = @"PASS";
                        //testitem.testMessage= @"";
                        //testitem.isPdcaValue= YES;
                        ispass = YES;
                        
                    }
                    else
                    {
                        testitem.value  = [NSString stringWithFormat:@"%@",testitem.value];
                        testitem.result = @"FAIL";
//                        testitem.testMessage= @"";
//                        testitem.isPdcaValue= YES;
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
    });
}

#pragma mark-Button action
- (IBAction)clickToRefreshInfoBox:(NSButton *)sender
{
    [self refreshTheInfoBox];
}

- (IBAction)clickToStop_ReStart:(NSButton *)sender
{
    PDCA_Btn.enabled = NO;
    SFC_Btn.enabled = NO;
    
    if ([sender.title isEqualToString:@"Stop"])
    {
        [sender setTitle:@"Restart"];
        
        [myThrad cancel];
        sleep(0.5);
         myThrad = nil;
        [mkTimer endTimer];
        index = 0;
        item_index = 0;
        row_index = 0;
        [NSMenu setMenuBarVisible:YES];
        return;
    }
    if ([sender.title isEqualToString:@"Restart"] || [sender.title isEqualToString:@"Start"])
    {
        [sender setTitle:@"Stop"];
        //启动线程,进入测试流程
        myThrad = [[NSThread alloc] initWithTarget:self selector:@selector(Working) object:nil];
        index = 0;
        item_index = 0;
        row_index = 0;
        [myThrad start];
        return;
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
//    //清除所有的本地的存储数据
//    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
//    
//    for (id key in dic)
//    {
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
//    }
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //=================
    [myThrad cancel];
    myThrad = nil;
}

//界面消失后取消线程
-(void)viewDidDisappear
{
//    //清除所有的本地的存储数据
//    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
//    
//    for (id key in dic)
//    {
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
//    }
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //=================
    [myThrad cancel];
    myThrad = nil;

}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
