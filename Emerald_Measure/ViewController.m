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


@implementation ViewController
{
    Table *mk_table;                       // table类
    Plist *plist;                       // plist类
    
    NSMutableArray *itemArr;            // plist文件测试项数组
    
    int index;                          // 测试流程下标
    int item_index;                     // 测试项下标
    int row_index;                      // table 每一行下标
    int pause;                          // 暂停下标
    
    NSString *start_time;               //启动测试的时间
    NSString *end_time;                 //结束测试的时间
    int testNum;                        //测试次数
    int passNum;                        //通过次数
    
    NSThread *myThrad;                  // 自定义线程
    
    __weak IBOutlet NSView *tab_View;               // 与storyboard 关联的 outline_Tab
    __weak IBOutlet NSTextField *importSN;          //输入的sn
    __weak IBOutlet NSTextField *currentStateMsg;   //当前的状态信息
    
    __weak IBOutlet NSTextField *testResult;        //测试结果
                    NSString    *testResultStr;     //测试结果
    
    __weak IBOutlet NSTextField *testFieldTimes;         //测试时间
    __weak IBOutlet NSTextField *testCount;         //测试次数
    __weak IBOutlet NSButton *pressBtn;             //按钮开关
    
    __unsafe_unretained IBOutlet NSTextView *logView_Info; //log_View 中显示的信息
    
    MKTimer *mkTimer;               //MK 定时器对象
    int      ct_cnt;           //记录cycle time定时器中断的次数
    
    SerialPort *serialPort;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    
    //初始化对象
    serialPort = [[SerialPort alloc] init];
    mkTimer = [[MKTimer alloc] init];
    plist = [[Plist alloc] init];
    
    item_index = 0;
    row_index = 0;
    pressBtn.enabled = NO;
    logView_Info.editable = NO;
    testNum = 0;
    passNum = 0;
    
    //读取 plist 文件
    itemArr = [plist PlistRead:@"TestItems" Key:nil];
    
    //通过 table 类自定义方法来创建 tableView
    mk_table = [[Table alloc] init:tab_View DisplayData:itemArr];
    
    //启动线程,进入测试流程
    myThrad = [[NSThread alloc] initWithTarget:self selector:@selector(Working) object:nil];
    [myThrad start];
}

- (IBAction)pressButtonToControlThread:(id)sender
{
    if([pressBtn.title isEqualToString:@"Pause"])
    {
        pause = index;  //记录当前的 index
        index = 2000; //当前的index 跳出
        
        //定时器暂停
        [mkTimer stopTimer];
        [pressBtn setTitle:@"Continue"];
    }
    else
    {
        index = pause;
        
        //定时器继续
        [mkTimer continueTimer];
        [pressBtn setTitle:@"Pause"];
    }
}




//sn = 123456
//================================================
//测试动作流程
//================================================
-(void)Working
{
    pressBtn.enabled = YES;
    Item *testitem = [[Item alloc] init];
    NSMutableArray *testResultArr = [NSMutableArray arrayWithCapacity:0];
    NSString *itemResult; //每一个测试项的结果
    
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
                
                //设备连接完后,发送测试温度(热敏电阻)的指令
//                [mk_agilent SetMessureMode:MODE_RES];
              
//                 [mk_agilent SetMessureMode:MODE_TEMPERATURE];
                index = 2;
            }
            else
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    currentStateMsg.stringValue=@"安捷伦连接失败!";
                    currentStateMsg.backgroundColor = [NSColor redColor];
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
                    return ;
                }
                if ([importSN.stringValue isEqualToString:@"123456"])
                {
                    index = 3;
                }
                else
                {
                    currentStateMsg.stringValue = @"sn 错误!!";
                    currentStateMsg.backgroundColor = [NSColor redColor];
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
            
            testitem = itemArr[item_index];
            NSLog(@"%@=========%@========%@",testitem.testItems, testitem.value, itemArr[item_index]);
            
            //加载测试项
            BOOL boolResult = [self TestItem:testitem];
            
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
            
            [mk_table flushTableRow:testitem RowIndex:row_index];
            
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
            });
            sleep(1);
            
            testitem = nil;
            plist = nil;
            row_index=0;
            item_index=0;
            pressBtn.enabled = YES;
            
            //每次结束测试都刷新主界面
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([testResult.stringValue isEqualToString:@"PASS"])
                {
                    passNum++;
                }
                testCount.stringValue = [NSString stringWithFormat:@"%d/%d",passNum,testNum];
                importSN.stringValue = @"";
            });
            
            index = 0;
        }
    }
}



//================================================
//测试项指令解析
//================================================
-(BOOL)TestItem:(Item*)testitem
{
    sleep(1);
    BOOL ispass=NO;
    NSString *logViewText;//logView信息
    
    //-----------0-------------
    //------------------------
    if([testitem.testItems isEqualToString:@"RF-1a"])
    {
        //第一项测试项的时候清空 logView 界面
        [logView_Info setString:@""];

        if([testitem.testItems length]!=0)
        {
            testitem.value  = @"michael_1";
            testitem.result = @"PASS";
            
            ispass = YES;
        }
        else
        {
            testitem.value  = @"NULL";
            testitem.result = @"FAIL";
            
            //信息汇总
            logViewText = [NSString stringWithFormat:@"\n%@,%@,%@",testitem.testItems,testitem.value,testitem.result];
            
            //主线程刷新 log_View 的信息
            dispatch_async(dispatch_get_main_queue(), ^{
                //追加字符串信息
                [logView_Info setTextColor:[NSColor redColor]];
                [[[logView_Info textStorage] mutableString] appendString:logViewText];
            });
            ispass = NO;
        }
    }
    //------------1------------
    //------------------------
    else if([testitem.testItems isEqualToString:@"RF-1b"])
    {
        
        if([testitem.testItems length] !=0)
        {
            testitem.value  = @"michael_2";
            testitem.result = @"PASS";
            
            ispass = YES;
        }
        else
        {
            testitem.value  = @"NULL";
            testitem.result = @"FAIL";
            
            //信息汇总
            logViewText = [NSString stringWithFormat:@"\n%@,%@,%@",testitem.testItems,testitem.value,testitem.result];
            
            //主线程刷新 log_View 的信息
            dispatch_async(dispatch_get_main_queue(), ^{
                //追加字符串信息
                [logView_Info setTextColor:[NSColor redColor]];
                [[[logView_Info textStorage] mutableString] appendString:logViewText];
            });
            ispass = NO;
        }
    }
    //-------------2-------------
    //------------------------
    else if([testitem.testItems isEqualToString:@"RF-1c"])
    {
        if([testitem.testItems length]==0)
        {
            testitem.value  = @"michael_3";
            testitem.result = @"PASS";
            
            ispass = YES;
        }
        else
        {
            testitem.value  = @"NULL";
            testitem.result = @"FAIL";
            
            //信息汇总
            logViewText = [NSString stringWithFormat:@"\n%@,%@,%@",testitem.testItems,testitem.value,testitem.result];
            
            //主线程刷新 log_View 的信息
            dispatch_async(dispatch_get_main_queue(), ^{
                //追加字符串信息
                [logView_Info setTextColor:[NSColor redColor]];
                [[[logView_Info textStorage] mutableString] appendString:logViewText];
            });
            ispass = NO;
        }
    }
    //-----------3---------------
    //------------------------
    else if([testitem.testItems isEqualToString:@"RF-2a"])
    {
        if([testitem.testItems length]==0)
        {
            testitem.value  = @"michael_4";
            testitem.result = @"PASS";
            
            ispass = YES;
        }
        else
        {
            testitem.value  = @"NULL";
            testitem.result = @"FAIL";
            
            //信息汇总
            logViewText = [NSString stringWithFormat:@"\n%@,%@,%@",testitem.testItems,testitem.value,testitem.result];
            
            //主线程刷新 log_View 的信息
            dispatch_async(dispatch_get_main_queue(), ^{
                //追加字符串信息
                [logView_Info setTextColor:[NSColor redColor]];
                [[[logView_Info textStorage] mutableString] appendString:logViewText];
            });
            ispass = NO;
        }
    }
    //------------4--------------
    //------------------------
    else if([testitem.testItems isEqualToString:@"RF-2b"])
    {
        
        if([testitem.testItems length]!=0)
        {
            testitem.value  = @"michael_5";
            testitem.result = @"PASS";
            
            ispass = YES;
        }
        else
        {
            testitem.value  = @"NULL";
            testitem.result = @"FAIL";
            
            //信息汇总
            logViewText = [NSString stringWithFormat:@"\n%@,%@,%@",testitem.testItems,testitem.value,testitem.result];
            
            //主线程刷新 log_View 的信息
            dispatch_async(dispatch_get_main_queue(), ^{
                //追加字符串信息
                [logView_Info setTextColor:[NSColor redColor]];
                [[[logView_Info textStorage] mutableString] appendString:logViewText];
            });
            ispass = NO;
        }
    }
    //------------5--------------
    //------------------------
    else if([testitem.testItems isEqualToString:@"RF-3a"])
    {
        if([testitem.testItems length]!=0)
        {
            testitem.value  = @"michael_6";
            testitem.result = @"PASS";
            
            ispass = YES;
        }
        else
        {
            testitem.value  = @"NULL";
            testitem.result = @"FAIL";
            
            //信息汇总
            logViewText = [NSString stringWithFormat:@"\n%@,%@,%@",testitem.testItems,testitem.value,testitem.result];
            
            //主线程刷新 log_View 的信息
            dispatch_async(dispatch_get_main_queue(), ^{
                //追加字符串信息
                [logView_Info setTextColor:[NSColor redColor]];
                [[[logView_Info textStorage] mutableString] appendString:logViewText];
            });
            ispass = NO;
        }
    }
    //-----------6---------------
    //------------------------
    else if([testitem.testItems isEqualToString:@"RF-3b"])
    {
        if([testitem.testItems length]!=0)
        {
            testitem.value  = @"michael_7";
            testitem.result = @"PASS";
            
            ispass = YES;
        }
        else
        {
            testitem.value  = @"My_NULL";
            testitem.result = @"FAIL";
            
            //信息汇总
            logViewText = [NSString stringWithFormat:@"\n%@,%@,%@",testitem.testItems,testitem.value,testitem.result];
            
            //主线程刷新 log_View 的信息
            dispatch_async(dispatch_get_main_queue(), ^{
                //追加字符串信息
                [logView_Info setTextColor:[NSColor redColor]];
                [[[logView_Info textStorage] mutableString] appendString:logViewText];
            });
            ispass = NO;
        }
    }
    //--------------------------
    //--------------------------

    NSLog(@"\a");
    
    return ispass;
}


/**
 *  必须要清除本地的存储数据,否则可能导致文件创建失败
 */
//界面消失后取消线程
-(void)viewWillDisappear
{
    //清除所有的本地的存储数据
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    
    for (id key in dic)
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //=================
    [myThrad cancel];
    myThrad = nil;
}

//界面消失后取消线程
-(void)viewDidDisappear
{
    //清除所有的本地的存储数据
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    
    for (id key in dic)
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //=================
    [myThrad cancel];
    myThrad = nil;

}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
