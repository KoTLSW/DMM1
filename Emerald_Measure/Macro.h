//
//  Macro.h
//  TestResistance
//
//  Created by TOD on 6/26/14.
//  Copyright (c) 2014 CeWay. All rights reserved.
//

#ifndef FCMTest_Macro_h
#define FCMTest_Macro_h


//定义测试点
#define     SCRIPT_TEST_VOLTAGE                 @"TestVoltage"
#define     SCRIPT_TEST_CURRENT                 @"TestCurrent"
#define     SCRIPT_TEST_CHAGECUREENT            @"TestChargeCurrent"
#define     SCRIPT_TEST_BUTTON                  @"TestButton"
#define     SCRIPT_TEST_CHECK_CRITICAL_ERROR    @"CheckCriticalError"
#define     SCRIPT_TEST_CHECK_ENUMERATION       @"CheckEnumeration+WriteMLBSN"
#define     SCRIPT_TEST_UPDATE_CHECK_ST_FW      @"Update&Check_ST_FW"
#define     SCRIPT_TEST_UPDATE_CHECK_BT_FW      @"Update&Check_BT_FW"
#define     SCRIPT_TEST_TRISTAR_GASGAUGE_I2C    @"Tristar&GasGauge_I2C"
#define     SCRIPT_TEST_THERMISTOR              @"Thermistor"
#define     SCRIPT_TEST_WRITESN                 @"TestWriteSN"

/******2016.8.13日新增和改变的测试点********/
#define     SCRIPT_TEST_CHECK_ENUMERATION_AND_WRITESN       @"CheckEnumeration+WriteMLBSN"
#define     SCRIPT_TEST_HARDVESION                          @"TestHardVesion"
#define     SCRIPT_TEST_FLASH_BDA                           @"TestFlashBDA"
#define     SCRIPT_TEST_TestBindBDA                         @"TestBindBDA"











//发送指令的具体步骤
#define     SCRIPT_TEST_TESTPOINT               @"TestPoint_"
#define     SCRIPT_NEED_SEND_CMD_ITEM           @"AllNeedSendCommandItem"

//fixture治具动作列表
#define     FIXTURE_ACTION                      @"FixtureAction"
#define     FIXTURE_HOLD_IN                     @"HoldIn"
#define     FIXTURE_HOLD_OUT                    @"HoldOut"
#define     FIXTURE_PROBE_LINK                  @"ProbeLink"
#define     FIXTURE_PROBE_DISLINK               @"ProbeDislink"
#define     FIXTURE_RESET                       @"Reset"
#define     FIXTURE_SCRAM_STOP                  @"ScramStop"
#define     FIXTURE_OPEN_USB                    @"OpenUSB"
#define     FIXTURE_CLOSE_USB                   @"CloseUSB"
#define     FIXTURE_OPEN_4V2                    @"Open4V2"
#define     FIXTURE_CLOSE_4V2                   @"Close4V2"
#define     FIXTURE_OPEN_PWR                    @"OpenPWR"
#define     FIXTURE_CLOSE_PWR                   @"ClosePWR"

//命令项键值
#define     COMMAND_TEST_NAME                   @"TestName"
#define     COMMAND_TEST_DEVICE_NAME            @"TestDeviceName"
#define     COMMAND_TEST_OPERATE_TYPE           @"TestOperateType"
#define     COMMAND_TEST_COMMAND                @"TestCommand"
#define     COMMAND_TEST_DELAY_TIME             @"TestDelayTime"
#define     COMMAND_TEST_RESULT_IS_DIGITAL      @"TestResultIsDigital"
#define     COMMAND_TEST_RESULT_DISPLAY         @"TestResultDisplay"
#define     COMMAND_TEST_UPPER_LIMIT            @"TestUpperLimit"
#define     COMMAND_TEST_LOWER_LIMIT            @"TestLowerLimit"
#define     COMMAND_TEST_UNIT                   @"TestUnit"
#define     COMMAND_TEST_BACK_VALUE_SIGN        @"TestBackValueSign"
#define     COMMAND_TEST_BACK_VALUE_REGEX       @"TestBackValueRegex"



//定义view的列头
#define     VIEW_COLUMN_HEADER_ITEM             @"TestItem"
#define     VIEW_COLUMN_HEADER_TESTPOINTNAME    @"TestPointName"
#define     VIEW_COLUMN_HEADER_ISTEST           @"IsTest"
#define     VIEW_COLUMN_HEADER_UPPSERLIMIT      @"TestUpperLimit"
#define     VIEW_COLUMN_HEADER_LOWERLIMIT       @"TestLowerLimit"
#define     VIEW_COLUMN_HEADER_VALUE            @"TestValue"
#define     VIEW_COLUMN_HEADER_UNIT             @"TestUnit"
#define     VIEW_COLUMN_HEADER_RESULT           @"TestResult"
#define     VIEW_NODE_PARENT                    @"parent"
#define     VIEW_NODE_CHILDREN                  @"children"


//治具端口配置信息
#define     FIXTURE_PORT                        @"FixturePort"
#define     MBL_PORT                            @"MBLPort"
#define     AGILENT_PORT                        @"AgilentPort"

#define     PORT_NAME                           @"PortName"
#define     PORT_BaudRate                       @"BaudRate"
#define     PORT_DataBits                       @"DataBits"
#define     PORT_Parity                         @"Parity"
#define     PORT_StopBits                       @"StopBits"
#define     PORT_FOUND_COMMAND                  @"FoundPortCmd"
#define     PORT_FOUND_SIGN                     @"FoundPortSign"


//Uart RS232串口配置信息
#define     UartDevice_Port                     @"UartDevicePort"

#define     PORT_NAME                           @"PortName"
#define     PORT_BaudRate                       @"BaudRate"
#define     PORT_DataBits                       @"DataBits"
#define     PORT_Parity                         @"Parity"
#define     PORT_StopBits                       @"StopBits"
#define     PORT_FOUND_COMMAND                  @"FoundPortCmd"
#define     PORT_FOUND_SIGN                     @"FoundPortSign"










//定义配置信息
#define     CONFIG_SCREEN_RESOLUTION                @"ScreenResolution"
#define     CONFIG_DEVICE_NAME                      @"DeviceName"

#define     CONFIG_DEVICE_NAME                      @"DeviceName"
#define     CONFIG_MBL_COMMAND                      @"MBLCommand"
#define     CONFIG_FIXTURE_COMMAND                  @"FixtureCommand"
#define     CONFIG_AGILENT_COMMAND                  @"AgilentCommand"
#define     CONFIG_USB1608_COMMAND                  @"USB1608_Command"
#define     CONFIG_TERMINAL_COMMAND                 @"TerminalCommand"

#define     DEBUG_FIXTURE_VIEW_IDENTIFER            @"TableView_Fixture"
#define     DEBUG_AGILENT_VIEW_IDENTIFER            @"TableView_Agilent"
#define     DEBUG_MBL_VIEW_IDENTIFER                @"TableView_MBL"
#define     DEBUG_USB1608_VIEW_IDENTIFER            @"TableView_USB1608"
#define     DEBUG_TERMINAL_VIEW_IDENTIFER           @"TableView_Terminal"

#define     VIEW_COLUMN_HEADER_ISSEND               @"IsSend"
#define     VIEW_COLUMN_HEADER_COMMAND              @"Command"

//plist文件名称
#define     PLIST_CONFIG_FILE_NAME                  @"Param"
#define     PLIST_TESTSCRIPT_FILE_NAME              @"TestScript"

//log文件
#define     CONFIG_FILE_PATH_NAME                   @"FilePathName"
#define     CONFIG_LOG_PATH                         @"LogPath"
#define     CONFIG_LOG_NAME                         @"LogName"
#define     CONFIG_TEST_LOG_PATH                    @"TestLogPath"
#define     CONFIG_TEST_LOG_NAME                    @"TestLogName"
#define     CONFIG_TEST_LOG_HEADER                  @"TestLogHeaders"
#define     CONFIG_LOG_HEADER                       @"LogHeaders"

#define     CONFIG_APP_HIDREPORT_PATH               @"HidReportTool_Path"
#define     CONFIG_APP_HIDREPORT_NAME               @"HidReportTool_Name"
#define     CONFIG_APP_NVUPDATER_PATH               @"NVUpdaterTool_Path"
#define     CONFIG_APP_NVUPDATER_NAME               @"NVUpdaterTool_Name"
#define     CONFIG_APP_GENHEADER_PATH               @"GenheaderTool_Path"
#define     CONFIG_APP_GENHEADER_NAME               @"GenheaderTool_Name"


#define     CONFIG_UPDATE_STFW_PATH                 @"UpdateSTFWBin_Path"
#define     CONFIG_UPDATE_STFW_NAME                 @"UpdateSTFWBin_Name"
#define     CONFIG_UPDATE_BTFW_PATH                 @"UpdateBTFWBin_Path"
#define     CONFIG_UPDATE_BTFW_NAME                 @"UpdateBTFWBin_Name"


//SCF upload
#define     CONFIG_SFC                              @"ServerFC"

#define     CONFIG_SFC_SERVER_IP                    @"Server_IP"
#define     CONFIG_SFC_BDA_SERVER_IP                @"BDAServer_IP"
#define     CONFIG_SFC_NET_PORT                     @"Net_Port"
#define     CONFIG_SFC_CTYPE                        @"C"
#define     CONFIG_SFC_STATION_NANE                 @"Station_Name"
#define     CONFIG_SFC_STATION_ID                   @"Station_ID"
#define     CONFIG_SFC_PRODUCT                      @"Product"
#define     CONFIG_SFC_FRONT_STATION_NAME           @"Front_StationName"
#define     CONFIG_SFC_NEXT_STATION_NAME            @"Next_StationName"


#define     KBlobPMU_FileName                       @"/tmp/pmu_cal.bin"
#define     KgenFileOut_PmuName                     @"/tmp/pmu_calout.bin"
#define     KgenHeaderPmu                           @"pmucal"

#define     KBlobDevice_FileName                    @"/tmp/deviceInfo.bin"
#define     KgenFileOut_DeviceName                  @"/tmp/deviceInfoout.bin"
#define     KgenHeaderDevice                        @"deviceinfo"

#endif
