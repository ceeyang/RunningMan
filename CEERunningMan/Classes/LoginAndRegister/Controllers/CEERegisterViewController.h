//
//  CEERegisterViewController.h
//  CEERunningMan
//
//  Created by 纵使寂寞开成海 on 16/1/4.
//  Copyright © 2016年 Cee. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
框架  完成注册
1. 对 XMPPStream 这个最核心的类,进行初始化,设置代理
2.链接服务器(openfire):
    2.1设置服务器的名字
    2.2设置端口
    2.3设置 JID  用户名@域名
3.代理方法获取是否链接成功:
    3.1成功:发送注册密码
    3.2失败
4.密码正确,注册成功
注册失败的代理方法;
*/


@interface CEERegisterViewController : UIViewController

@end
