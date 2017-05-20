//
//  Param.m
//  BT_MIC_SPK
//
//  Created by h on 16/5/29.
//  Copyright © 2016年 h. All rights reserved.
//

#import "Param.h"
//=============================================
@interface Param()
{
    NSString* _csv_path;
    NSString* _dut_type;
    NSString* _ui_title;
    NSString* _tester_version;
    NSString* _station;
    NSString* _stationID;
    NSString* _fixtureID;
    NSString* _lineNo;
    NSString* _sw_name;
    NSString* _sw_ver;
    
    NSString* _fixture_uart_port_name;
    NSInteger _fixture_uart_baud;
    
    NSString* _humiture_uart_port_name;
    NSInteger _humiture_uart_baud;
    
    
    NSString* _pcb_uart_port_name;
    NSInteger _pcb_uart_baud;
    
    NSString* _pcb_spi_port_name;
    NSInteger _pcb_spi_baud;
    
    NSString* _fixture_id;
    
    NSString* _file_path;
    
    NSInteger _thdn;
    
    NSInteger _spkvol;
    NSInteger _spkcale;
    
    NSInteger _out_rate;
    NSInteger _in_rate;
    
    NSString* _micl_calibration_time;
    CGFloat   _micl_calibration_db;
    CGFloat   _micl_calibration_v_pa;
    
    NSString*  _micr_calibration_time;
    CGFloat   _micr_calibration_db;
    CGFloat   _micr_calibration_v_pa;
    
    NSString* _mics_calibration_time;
    CGFloat   _mics_calibration_db;
    CGFloat   _mics_calibration_v_pa;
    
    NSString* _spk_calibration_time;
    CGFloat   _spk_calibration_db1;
    CGFloat   _spk_calibration_db1_v;
    CGFloat   _spk_calibration_db2;
    CGFloat   _spk_calibration_db2_v;
    
    BOOL      _pdca_is_upload;
    
    //波形发生器类
    BOOL        _isWaveNeed;
    BOOL        _isDebug;
    NSString * _s_build;
    NSString * _waveOffset;
    NSString * _waveFrequence;
    NSString * _waveVolt;
    
}
@end
//=============================================
@implementation Param
//=============================================
@synthesize csv_path               = _csv_path;
@synthesize dut_type               = _dut_type;
@synthesize ui_title               = _ui_title;
@synthesize tester_version         = _tester_version;
@synthesize station                = _station;
@synthesize stationID              =_stationID;
@synthesize fixtureID              =_fixtureID;
@synthesize lineNo                 =_lineNo;
@synthesize sw_name                = _sw_name;
@synthesize sw_ver                 = _sw_ver;
@synthesize fixture_uart_port_name = _fixture_uart_port_name;
@synthesize fixture_uart_baud      = _fixture_uart_baud;
@synthesize humiture_uart_port_name = humiture_uart_port_name;
@synthesize humiture_uart_baud      = _humiture_uart_baud;
@synthesize pcb_uart_port_name     = _pcb_uart_port_name;
@synthesize pcb_uart_baud          = _pcb_uart_baud;
@synthesize pcb_spi_port_name      = _pcb_spi_port_name;
@synthesize pcb_spi_baud           = _pcb_spi_baud;
@synthesize fixture_id             = _fixture_id;
@synthesize file_path              = _file_path;
@synthesize isWaveNeed             = _isWaveNeed;
@synthesize isDebug                = _isDebug;
@synthesize s_build                = _s_build;
@synthesize waveVolt               = _waveVolt;
@synthesize waveOffset             = _waveOffset;
@synthesize waveFrequence          = _waveFrequence;





@synthesize thdn                   = _thdn;
@synthesize spkvol                 = _spkvol;
@synthesize spkscale               = _spkscale;
@synthesize out_rate               = _out_rate;
@synthesize in_rate                = _in_rate;
@synthesize micl_calibration_time  = _micl_calibration_time;
@synthesize micl_calibration_db    = _micl_calibration_db;
@synthesize micl_calibration_v_pa  = _micl_calibration_v_pa;
@synthesize micr_calibration_time  = _micr_calibration_time;
@synthesize micr_calibration_db    = _micr_calibration_db;
@synthesize micr_calibration_v_pa  = _micr_calibration_v_pa;
@synthesize mics_calibration_time  = _mics_calibration_time;
@synthesize mics_calibration_db    = _mics_calibration_db;
@synthesize mics_calibration_v_pa  = _mics_calibration_v_pa;
@synthesize spk_calibration_time   = _spk_calibration_time;
@synthesize spk_calibration_db1    = _spk_calibration_db1;
@synthesize spk_calibration_db1_v  = _spk_calibration_db1_v;
@synthesize spk_calibration_db2    = _spk_calibration_db2;
@synthesize spk_calibration_db2_v  = _spk_calibration_db2_v;
@synthesize pdca_is_upload         = _pdca_is_upload;
//=============================================
- (void)ParamRead:(NSString*)filename
{
    //NSMutableArray *_testItems=[[NSMutableArray alloc]init];
    
    //首先读取plist中的数据
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:filename ofType:@"plist"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    self.csv_path               = [dictionary objectForKey:@"csv_path"];
    self.dut_type               = [dictionary objectForKey:@"dut_type"];
    self.ui_title               = [dictionary objectForKey:@"ui_title"];
    self.tester_version         = [dictionary objectForKey:@"ui_versiom"];
    self.station                = [dictionary objectForKey:@"station"];
    
    self.stationID              = [dictionary objectForKey:@"stationID"];
    self.fixtureID              = [dictionary objectForKey:@"fixtureID"];
    self.lineNo                 = [dictionary objectForKey:@"lineNO"];
    
    
    self.sw_name                = [dictionary objectForKey:@"sw_name"];
    self.sw_ver                 = [dictionary objectForKey:@"sw_ver"];
    
    self.fixture_uart_port_name = [dictionary objectForKey:@"fixture_uart_port_name"];
    self.fixture_uart_baud      = [[dictionary objectForKey:@"fixture_uart_baud"]integerValue];
    
    //温湿度传感器
    self.humiture_uart_port_name=[dictionary objectForKey:@"humiture_uart_port_name"];
    self.humiture_uart_baud     =[[dictionary objectForKey:@"humiture__uart_baud"] integerValue];
    
    
    //file_path
    self.file_path             =[dictionary objectForKey:@"file_path"];
    //是否需要波形发生器
    self.isWaveNeed            =[[dictionary objectForKey:@"isWaveNeed"] boolValue];
    self.isDebug               =[[dictionary objectForKey:@"isDebug"] boolValue];
    self.waveFrequence         =[dictionary objectForKey:@"waveFrequence"];
    self.waveOffset            =[dictionary objectForKey:@"waveOffset"];
    self.waveVolt              =[dictionary objectForKey:@"waveVolt"];
    
    
    
    
    //s_build
    self.s_build               =[dictionary objectForKey:@"s_build"];
    
    self.pcb_uart_port_name     = [dictionary objectForKey:@"pcb_uart_port_name"];
    self.pcb_uart_baud          = [[dictionary objectForKey:@"pcb_uart_baud"]integerValue];
    
    self.pcb_spi_port_name      = [dictionary objectForKey:@"pcb_spi_port_name"];
    self.pcb_spi_baud           = [[dictionary objectForKey:@"pcb_spi_baud"]integerValue];
    
    self.fixture_id             = [dictionary objectForKey:@"fixture_id"];
    
    self.thdn                   = [[dictionary objectForKey:@"thdn"]integerValue];
    
    self.spkvol                 = [[dictionary objectForKey:@"spkvol"]integerValue];
    self.spkscale               = [[dictionary objectForKey:@"spkscale"]integerValue];
    
    self.out_rate               = [[dictionary objectForKey:@"out_rate"]integerValue];
    self.in_rate                = [[dictionary objectForKey:@"in_rate"]integerValue];
    
    self.micl_calibration_time  = [dictionary objectForKey:@"micl_calibration_time"];
    self.micl_calibration_db    = [[dictionary objectForKey:@"micl_calibration_db"]floatValue];
    self.micl_calibration_v_pa  = [[dictionary objectForKey:@"micl_calibration_v_pa"]floatValue];
    
    self.micr_calibration_time  = [dictionary objectForKey:@"micr_calibration_time"];
    self.micr_calibration_db    = [[dictionary objectForKey:@"micr_calibration_db"]floatValue];
    self.micr_calibration_v_pa  = [[dictionary objectForKey:@"micr_calibration_v_pa"]floatValue];
    
    self.mics_calibration_time  = [dictionary objectForKey:@"mics_calibration_time"];
    self.mics_calibration_db    = [[dictionary objectForKey:@"mics_calibration_db"]floatValue];
    self.mics_calibration_v_pa  = [[dictionary objectForKey:@"mics_calibration_v_pa"]floatValue];
    
    self.spk_calibration_time   = [dictionary objectForKey:@"spk_calibration_time"];
    self.spk_calibration_db1    = [[dictionary objectForKey:@"spk_calibration_db1"]floatValue];
    self.spk_calibration_db1_v  = [[dictionary objectForKey:@"spk_calibration_db1_v"]floatValue];
    self.spk_calibration_db2    = [[dictionary objectForKey:@"spk_calibration_db2"]floatValue];
    self.spk_calibration_db2_v  = [[dictionary objectForKey:@"spk_calibration_db2_v"]floatValue];
    
    self.pdca_is_upload         = [[dictionary objectForKey:@"pdca_is_upload"]boolValue];
    
}
//=============================================
- (void)ParamWrite:(NSString*)filename
{
    //读取plist
    NSString *plistPath = [[NSBundle mainBundle]pathForResource:filename ofType:@"plist"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    //添加内容
    [dictionary setObject:_csv_path forKey:@"csv_path"];
    [dictionary setObject:_dut_type forKey:@"dut_type"];
    [dictionary setObject:_ui_title forKey:@"ui_title"];
    [dictionary setObject:_sw_name  forKey:@"sw_name"];
    [dictionary setObject:_sw_ver   forKey:@"sw_ver"];
    [dictionary setObject:_fixture_uart_port_name forKey:@"fixture_uart_port_name"];
    [dictionary setObject:[NSNumber numberWithInteger:_fixture_uart_baud] forKey:@"fixture_uart_baud"];
    //温湿度传感器
    [dictionary setObject:_humiture_uart_port_name forKey:@"humiture_uart_port_name"];
    [dictionary setObject:[NSNumber numberWithInteger:_humiture_uart_baud] forKey:@"humiture_uart_baud"];
    [dictionary setObject:_file_path forKey:@"file_path"];
    
    
    //波形发生器
    [dictionary setObject:[NSNumber numberWithBool:_isWaveNeed] forKey:@"isWaveNeed"];
    [dictionary setObject:[NSNumber numberWithBool:_isDebug] forKey:@"isDebug"];
    [dictionary setObject:_waveOffset forKey:@"waveOffset"];
    [dictionary setObject:_waveFrequence forKey:@"waveFrequence"];
    [dictionary setObject:_waveVolt forKey:@"waveVolt"];
    [dictionary setObject:@"s_build" forKey:@"s_build"];
    
    
    
    

    
    
    [dictionary setObject:_pcb_uart_port_name                                  forKey:@"pcb_uart_port_name"];
    [dictionary setObject:[NSNumber numberWithInteger:_pcb_uart_baud]          forKey:@"pcb_uart_baud"];
    
    [dictionary setObject:_pcb_spi_port_name                                   forKey:@"pcb_spi_port_name"];
    [dictionary setObject:[NSNumber numberWithInteger:_pcb_spi_baud]           forKey:@"pcb_spi_baud"];
    
    [dictionary setObject:_fixture_id                                          forKey:@"fixture_id"];
    
    [dictionary setObject:[NSNumber numberWithInteger:_thdn]                   forKey:@"thdn"];
    
    [dictionary setObject:[NSNumber numberWithInteger:_spkvol]                 forKey:@"spkvol"];
    [dictionary setObject:[NSNumber numberWithInteger:_spkscale]               forKey:@"spkscale"];
    
    [dictionary setObject:[NSNumber numberWithInteger:_out_rate]               forKey:@"out_rate"];
    [dictionary setObject:[NSNumber numberWithInteger:_in_rate]                forKey:@"in_rate"];
    
    [dictionary setObject:_micl_calibration_time                               forKey:@"micl_calibration_time"];
    [dictionary setObject:[NSNumber numberWithFloat:_micl_calibration_db]      forKey:@"micl_calibration_db"];
    [dictionary setObject:[NSNumber numberWithFloat:_micl_calibration_v_pa]    forKey:@"micl_calibration_v_pa"];
    
    [dictionary setObject:_micr_calibration_time                               forKey:@"micr_calibration_time"];
    [dictionary setObject:[NSNumber numberWithFloat:_micr_calibration_db]      forKey:@"micr_calibration_db"];
    [dictionary setObject:[NSNumber numberWithFloat:_micr_calibration_v_pa]    forKey:@"micr_calibration_v_pa"];
    
    [dictionary setObject:_mics_calibration_time                               forKey:@"mics_calibration_time"];
    [dictionary setObject:[NSNumber numberWithFloat:_mics_calibration_db]      forKey:@"mics_calibration_db"];
    [dictionary setObject:[NSNumber numberWithFloat:_mics_calibration_v_pa]    forKey:@"mics_calibration_v_pa"];
    
    [dictionary setObject:_spk_calibration_time                                forKey:@"spk_calibration_time"];
    [dictionary setObject:[NSNumber numberWithFloat:_spk_calibration_db1]      forKey:@"spk_calibration_db1"];
    [dictionary setObject:[NSNumber numberWithFloat:_spk_calibration_db1_v]    forKey:@"spk_calibration_db1_v"];
    [dictionary setObject:[NSNumber numberWithFloat:_spk_calibration_db2]      forKey:@"spk_calibration_db2"];
    [dictionary setObject:[NSNumber numberWithFloat:_spk_calibration_db2_v]    forKey:@"spk_calibration_db2_v"];
    
    [dictionary setObject:[NSNumber numberWithBool:_pdca_is_upload]            forKey:@"pdca_is_upload"];
    
    [dictionary writeToFile:plistPath atomically:YES];
}
//=============================================更改plist文件中的内容
-(void)ParamWrite:(NSString *)filename Content:(NSString *)content Key:(NSString *)key
{
    //读取plist
    NSString *plistPath = [[NSBundle mainBundle]pathForResource:filename ofType:@"plist"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    //添加内容
    [dictionary setObject:content forKey:key];
    [dictionary writeToFile:plistPath atomically:YES];
    
}

////=============================================
//- (void)TmConfigWrite:(NSString *)filename Content:(NSString *)content Key:(NSString *)key
//{
//    //读取plist
//    NSString *plistPath = [[NSBundle mainBundle]pathForResource:filename ofType:@"plist"];
//    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
//    
//    //添加内容
//    [dictionary setObject:content forKey:key];
//    
//    [dictionary writeToFile:plistPath atomically:YES];
//}
@end
//=============================================
