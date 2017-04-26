//
//  Common.h
//  HowToWorks
//
//  Created by h on 17/4/10.
//  Copyright © 2017年 bill. All rights reserved.
//
//此头文件，定义消息，用户信息。

#ifndef Common_h
#define Common_h

//消息
#define kNotificationPreferenceChange       @"PreferenceConfigChange"

//Login
#define kLoginUserName                  @"Login_UserName"
#define kLoginUserPassword              @"Login_Password"
#define kLoginUserAuthority             @"Login_Authority"


typedef enum  __USER_AUTHORITY{
    AUTHORITY_ADMIN = 0,
    AUTHORITY_ENGINEER = 1,
    AUTHORITY_OPERATOR = 2,
}USER_AUTHORITY;

typedef struct __USER_INFOR {
    char szName[32];
    char szPassword[32];
    USER_AUTHORITY Authority;
}USER_INFOR;



#endif /* Common_h */
