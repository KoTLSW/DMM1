//
//  PDCA.h
//  B312_BT_MIC_SPK
//
//  Created by EW on 16/5/13.
//  Copyright © 2016年 h. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InstantPudding_API.h"
#import "CBAuth_API.h"
#import "IPSFCPost_API.h"

@interface PDCA : NSObject
//==========================================
-(void)PDCA_GetStartTime;
-(void)PDCA_GetEndTime;
-(void)PDCA_Init:(NSString*)sn SW_name:(NSString*)sw_name SW_ver:(NSString*)sw_ver;
-(void)PDCA_AddAttribute:(NSString*)sbuild FixtureID:(NSString*)fixtureid;
-(void)PDCA_UploadPass:(NSString*)test_name;
-(void)PDCA_UploadFail:(NSString*)test_name Message:(NSString*)message;
-(void)PDCA_UploadValue:(NSString*)test_name Lower:(NSString*)lower Upper:(NSString*)upper Unit:(NSString*)units Value:(NSString*)value Pass_Fail:(BOOL)pass_fail;
-(void)PDCA_Upload:(BOOL)pass_fail;
-(BOOL) AddBlob:(NSString*) fileName FilePath:(NSString*) filePath;
//==========================================
@end
