//
//  AgilentTools.h
//  Emerald_Measure
//
//  Created by mac on 2017/8/17.
//  Copyright © 2017年 michael. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "visa.h"

@interface AgilentTools : NSObject

@property(nonatomic,strong)NSString   *  multimeter;

+ (AgilentTools *)Instance; //创建单例

//返回USB的外设对象
-(NSArray *)getUsbArray;

//返回TCP网口通信的对象数组
-(NSArray *)getTcpArray;

//返回GPIB通信的外设对象
-(NSArray *)getGPIBArray;



@end
