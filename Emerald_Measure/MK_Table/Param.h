//
//  Param.h
//  BT_MIC_SPK
//
//  Created by h on 16/5/29.
//  Copyright © 2016年 h. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Param : NSObject
//=============================================
@property(readwrite,copy)NSString*   csv_path;
@property(readwrite,copy)NSString*   dut_type;
@property(readwrite,copy)NSString*   ui_title;
@property(readwrite,copy)NSString*   tester_version;

@property(readwrite,copy)NSString*   station;
@property(readwrite,copy)NSString*   stationID;
@property(readwrite,copy)NSString*   fixtureID;
@property(readwrite,copy)NSString*   lineNo;

@property(readwrite,copy)NSString*  sw_name;
@property(readwrite,copy)NSString*  sw_ver;

//治具相关
@property(readwrite,copy)NSString*  fixture_uart_port_name;
@property(readwrite)NSInteger       fixture_uart_baud;

@property(readwrite,copy)NSString*  pcb_uart_port_name;
@property(readwrite)NSInteger       pcb_uart_baud;

//温湿度传感器相关
@property(readwrite,copy)NSString*  humiture_uart_port_name;
@property(readwrite)NSInteger       humiture_uart_baud;
//跟读数有关
@property(nonatomic,strong)NSString * number;
@property(nonatomic,strong)NSString * sleepTime;


//文件路径
@property(nonatomic,strong)NSString * file_path;

//是否需要波形发生器
@property(nonatomic,assign)BOOL isWaveNeed;
@property(nonatomic,assign)BOOL isDebug;
@property(nonatomic,strong)NSString * waveFrequence;//频率
@property(nonatomic,strong)NSString * waveVolt;//电压
@property(nonatomic,strong)NSString * waveOffset;//偏移




//sbuid
@property(nonatomic,strong)NSString * s_build;
//特别的SN
@property(nonatomic,strong)NSArray  * differentSNArray;



@property(readwrite)BOOL            pdca_is_upload;

//=============================================
- (void)ParamRead:(NSString*)filename;
- (void)ParamWrite:(NSString*)filename;
-(void)ParamWrite:(NSString *)filename Content:(NSString *)content Key:(NSString *)key;
//- (void)TmConfigWrite:(NSString *)filename Content:(NSString *)content Key:(NSString *)key;
//=============================================
@end
