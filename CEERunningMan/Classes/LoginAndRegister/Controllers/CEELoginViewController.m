//
//  CEELoginViewController.m
//  CEEBaseProject
//
//  Created by 纵使寂寞开成海 on 15/12/31.
//  Copyright © 2015年 Cee. All rights reserved.
//

#import "CEELoginViewController.h"
#import "CEEUserInfo.h"
#import "CEEXMPPTool.h"
#import "MBProgressHUD+KR.h"
#import "AppDelegate.h"
#import <TencentOpenAPI/TencentOAuth.h>


@interface CEELoginViewController ()<TencentSessionDelegate>//<KRLoginProtocol>
{
    TencentOAuth *tencentOAuth;
    NSArray *permissions;
}
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *userPasswd;
@end

@implementation CEELoginViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    /** 设置代理 */
//    [CEEXMPPTool sharedCEEXMPPTool].delegate = self;
    
    /** 调试模式,默认账号密码 */
    self.userName.text = @"test1234";
    self.userPasswd.text = @"123456";
    
    /** 1.初始化 tencentOAuth 对象 */
    tencentOAuth = [[TencentOAuth alloc]initWithAppId:@"1105056612" andDelegate:self];
    
    /** 2.设置需要的权限列表,此处使用什么用什么 */
    permissions = [NSArray arrayWithObjects:@"get_user_info",@"list_album",@"get_vip_info",@"get_info",nil];
    
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

/** 设置输入文本框左边的图标 */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /** 设置账号输入框的左视图 */
    UILabel *nameLabel = [UILabel new];
    nameLabel.text = @"账号";
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.contentMode  = UIViewContentModeCenter;
    nameLabel.frame = CGRectMake(0, 0, 55, 20);
    self.userName.leftView  = nameLabel;
    self.userName.leftViewMode = UITextFieldViewModeAlways;
    
    /** 设置密码输入框的左视图 */
    UILabel *passwordLabel = [UILabel new];
    passwordLabel.text = @"密码";
    passwordLabel.textAlignment = NSTextAlignmentCenter;
    passwordLabel.frame = CGRectMake(0, 0, 55, 20);
    passwordLabel.contentMode = UIViewContentModeCenter;
    self.userPasswd.leftView = passwordLabel;
    self.userPasswd.leftViewMode = UITextFieldViewModeAlways;
    
    if ([CEEUserInfo sharedCEEUserInfo].userNmae)
    {
        self.userName.text = [CEEUserInfo sharedCEEUserInfo].userNmae;
    }
    
}

#pragma mark - 点击登陆按钮后的事件
- (IBAction)loginButton:(UIButton *)sender
{
    CEEUserInfo *userInfo = [CEEUserInfo sharedCEEUserInfo];
    userInfo.userNmae = self.userName.text;
    userInfo.userPassword = self.userPasswd.text;
    
    /** 判断用户名或密码不能为空 */
    if ([self.userName.text isEqualToString:@""] &&
        [self.userPasswd.text isEqualToString:@""])
    {
        [MBProgressHUD showError:@"用户名和密码不能为空"];
        return;
    }
    else
    {
        [MBProgressHUD showMessage:@"登录中..."];
    }
    
    /** 点击登录按钮,调用工具类的登录方法 */
    /** 使用一个弱引用调用 self, 以防止 block 中两次强引用 self,
     导致控制器不能被销毁,照成内存泄露    */
    __weak typeof(self) vc = self;
    [[CEEXMPPTool sharedCEEXMPPTool] userLogin:^(CEEXMPPResultType type) {
        [vc handleLoginResultType:type];
    }];

    
//    [[CEEXMPPTool sharedCEEXMPPTool] userLogin:nil];
    
}

/** 处理登录的返回的状态 */
- (void) handleLoginResultType:(CEEXMPPResultType) type
{
    [MBProgressHUD hideHUD];
    switch (type)
    {
        case CEEXMPPResultTypeLoginSuccess:
        {
            MYLog(@"登录成功!");
            /** 切换到主界面 */
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            [UIApplication sharedApplication].keyWindow.rootViewController = storyBoard.instantiateInitialViewController;
            
            AppDelegate *app = [UIApplication sharedApplication].delegate;
            [app setupNavigationController];
            break;
        }
        case CEEXMPPResultTypeNetError:
            MYLog(@"网络连接失败,请检测网络设置");
            break;
        case CEEXMPPResultTypeLoginFaild:
            MYLog(@"登录失败,密码错误");
            break;
            default:
            break;
    }
}

/** 证明这个控制器释放了 */
- (void) dealloc
{
    MYLog(@"登录控制器销毁: %@",self);
}

#pragma mark - 忘记密码
- (IBAction)forgetPasswdButton:(id)sender
{
    
}


#pragma mark - KRLoginProtocol
/** 登陆成功,界面跳转 */
- (void)krLoginSuccess
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [UIApplication sharedApplication].keyWindow.rootViewController = storyboard.instantiateInitialViewController;
}
- (void)krLoginFailed
{
    
}
- (void)krNetError
{
    
}

#pragma mark - 腾讯登录
- (IBAction)QQlogionBtn:(id)sender
{
    [tencentOAuth authorize:permissions inSafari:NO];
}

- (void)tencentDidLogin
{
    [MBProgressHUD showSuccess:@"登录成功!"];
    
    if (tencentOAuth.accessToken && 0 != [tencentOAuth.accessToken length])
    {
        /** 记录用户的 OpenID,Token 以及过期时间 */
        [tencentOAuth getUserInfo];
        MYLog(@"%@",tencentOAuth.accessToken);
    }
    else
    {
        [MBProgressHUD showError:@"登录不成功,没有获取 accesstoken"];
    }
}


/** 非网络错误导致登录失败 */
- (void)tencentDidNotLogin:(BOOL)cancelled
{
    MYLog(@"%s",__func__);
    
    if (cancelled)
    {
        MYLog(@"用户取消登录");
    }
    else
    {
        MYLog(@"登录失败");
    }
}

/** 网络错误导致登录失败 */
- (void)tencentDidNotNetWork
{
    NSLog(@"%s",__func__);
    
    MYLog(@"网络连接失败,请检测网络设置");
}



- (void)getUserInfoResponse:(APIResponse *)response
{
    MYLog(@"response: %@",response.jsonResponse);
}


@end
