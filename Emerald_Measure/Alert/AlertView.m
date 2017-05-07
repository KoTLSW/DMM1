//
//  AlertView.m
//  AlertView
//
//  Created by h on 16/11/14.
//  Copyright © 2016年 h. All rights reserved.
//

#import "AlertView.h"
#import "AppDelegate.h"

//自定义登陆窗口的大小
#define AlertView_Hight   150
#define AlertView_Width   300

#define Bottom_View_X    30

@interface AlertView()
{

    NSTextField * bottom_TF; //底部View
    
    NSTextField  * username_lable; //账户标签
    
    NSTextField * username_TF;//输入账户的textField
    
    NSTextField  * pass_lable;//密码标签
    
    NSSecureTextField * pass_TF;//输入密码的textField
    
    NSButton * certianButton; //确定按钮
    
    NSButton * cancellButton;//取消按钮
    
    NSWindow * alert_window;


}

@end


@implementation AlertView




-(id)initWithFrame:(NSRect)frameRect  andWindow:(NSView *)bottomView
{
   
//    self=[super initWithFrame:CGRectMake((window.contentView.bounds.size.width-AlertView_Width)/2, window.contentView.bounds.size.height-AlertView_Hight, frameRect.size.width, frameRect.size.height)];
    
   self=[super initWithFrame:CGRectMake((bottomView.bounds.size.width-AlertView_Width)/2, bottomView.bounds.size.height-AlertView_Hight, frameRect.size.width, frameRect.size.height)];
    
    
    NSLog(@"%f===%f====%f=====%f",(bottomView.bounds.size.width-AlertView_Width)/2,bottomView.bounds.size.height-AlertView_Hight,frameRect.size.width,frameRect.size.height);
    
    bottom_TF=[[NSTextField alloc]initWithFrame:self.bounds];
    bottom_TF.backgroundColor=[NSColor grayColor];
    
    bottom_TF.enabled=NO;
    [self addSubview:bottom_TF];
    
    //账户的控件
    username_lable=[[NSTextField alloc]initWithFrame:CGRectMake(Bottom_View_X, frameRect.size.height-50, 60, 25)];
    [self addSubview:username_lable];
    
    
    username_TF=[[NSTextField alloc]initWithFrame:CGRectMake(Bottom_View_X+CGRectGetWidth(username_lable.frame), CGRectGetMaxY(username_lable.frame)-25,frameRect.size.width-120, 25)];
    [self addSubview:username_TF];
    
    
    
    //密码的控件
    pass_lable=[[NSTextField alloc]initWithFrame:CGRectMake(Bottom_View_X, CGRectGetMaxY(username_lable.frame)-60, 60, 25)];
    [self addSubview:pass_lable];
    
    
    pass_TF=[[NSSecureTextField alloc]initWithFrame:CGRectMake(Bottom_View_X+CGRectGetWidth(username_lable.frame), CGRectGetMaxY(username_lable.frame)-60,frameRect.size.width-120, 25)];
    pass_lable.alignment=NSCenterTextAlignment;
    [self addSubview:pass_TF];
    
    

    
    //按钮的控件  确定和取消
    certianButton=[[NSButton alloc]initWithFrame:CGRectMake(Bottom_View_X, CGRectGetMinY(pass_lable.frame)-45, 80, 30)];
    [self addSubview:certianButton];
    
    
    cancellButton=[[NSButton alloc]initWithFrame:CGRectMake(frameRect.size.width-80-25, CGRectGetMinY(pass_lable.frame)-45, 80, 30)];
    [self addSubview:cancellButton];
    
    
    //alert_window=[NSApplication sharedApplication].windows[0];
    
    return self;
}


//添加各种属性
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    username_lable.editable=NO;
    username_lable.stringValue=@"账  户:";
    username_lable.alignment=NSCenterTextAlignment;
    
    
    username_TF.alignment=NSLeftTextAlignment;
    username_TF.stringValue=@"LHDC";
    
    
    
    pass_lable.stringValue=@"密  码:";
    pass_lable.editable=NO;
    pass_lable.textColor=[NSColor blackColor];
    pass_lable.alignment=NSCenterTextAlignment;
    
    
    
    
    [certianButton setTitle:@"确定"];
    certianButton.bezelStyle=NSTokenStyleRounded;
    [certianButton setTarget:self];
    [certianButton setAction:@selector(buttonAction:)];
    certianButton.tag=0;
    
    
    cancellButton.bezelStyle=NSTokenStyleRounded;
    [cancellButton setTitle:@"取消"];
    [cancellButton setTarget:self];
    cancellButton.tag=1;
    [cancellButton setAction:@selector(buttonAction:)];

}


//点击事件
-(void)buttonAction:(NSButton *)sender
{

    if (sender.tag==0)
    {
        
        if ([username_TF.stringValue isEqualToString:@"LHDC"]&&[pass_TF.stringValue isEqualToString:@"123456"])
        {
            
            self.hidden=YES;
            
            self.backBlock(YES);
            
        }
        else
        {
            
            
            NSAlert  * alert=[[NSAlert alloc]init];
            
            alert.messageText=@"ERROR";
            alert.informativeText=@"输入有误,请重新输入";
            [alert addButtonWithTitle:@"取消"];
            NSLog(@"===========%@",alert.buttons);
            [alert beginSheetModalForWindow:alert.window completionHandler:^(NSModalResponse returnCode) {
                
                pass_TF.stringValue=@"";
                
            }];
    
        
        }
        
    }
    else
    {
           self.hidden=YES;
           self.backBlock(NO);
        
        //AppDelegate  * app=[NSApplication sharedApplication].delegate;
        //app.isShow=NO;
        
        NSLog(@"================%@",[self superview].subviews[0]);
       
    }
    
    
    


}


@end
