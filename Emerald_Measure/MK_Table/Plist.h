//
//  Plist.h
//  MKPlist_Sample
//
//  Created by Michael on 16/11/7.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"

@interface Plist : NSObject
//=============================================
-(NSMutableArray *)PlistRead:(NSString *)fileName Key:(NSString *)key;
-(void)PlistWrite:(NSString *)fileName Item:(NSString *)item;
-(NSDictionary *)PlistRead:(NSString *)fileName;
//=============================================


@end
