//
//  MK_FileFolder.h
//  File
//
//  Created by Michael on 16/11/3.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MK_FileFolder : NSObject

@property(nonatomic, strong) NSString *folderPath;//文件夹路径


+(MK_FileFolder *)shareInstance;

/**
 *  currentPath     :传入当前的路径
 *  subjectName     :传入的项目名称
 */
//创建文件夹
-(BOOL)createOrFlowFolderWithCurrentPath:(NSString *)currentPath SubjectName:(NSString *)subjectName;
@end
