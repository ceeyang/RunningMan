//
//  CEERegisterViewController.m
//  CEERunningMan
//
//  Created by 纵使寂寞开成海 on 16/1/4.
//  Copyright © 2016年 Cee. All rights reserved.
//

#import "CEERegisterViewController.h"
#import "CEEXMPPTool.h"
#import "MBProgressHUD+KR.h"
#import "CEEUserInfo.h"
#import "AFNetworking.h"
#import "NSString+md5.h"

@interface CEERegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *registerName;
@property (weak, nonatomic) IBOutlet UITextField *registerPassword;

@end

@implementation CEERegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    self.registerName.leftView  = nameLabel;
    self.registerName.leftViewMode = UITextFieldViewModeAlways;
    
    /** 设置密码输入框的左视图 */
    UILabel *passwordLabel = [UILabel new];
    passwordLabel.text = @"密码";
    passwordLabel.textAlignment = NSTextAlignmentCenter;
    passwordLabel.frame = CGRectMake(0, 0, 55, 20);
    passwordLabel.contentMode = UIViewContentModeCenter;
    self.registerPassword.leftView = passwordLabel;
    self.registerPassword.leftViewMode = UITextFieldViewModeAlways;
}

/** 注册按钮 */
- (IBAction)registerButton:(id)sender
{
    /** 判断是否是注册, */
    [CEEUserInfo sharedCEEUserInfo].registerType = YES;
    [CEEUserInfo sharedCEEUserInfo].registerName = self.registerName.text;
    [CEEUserInfo sharedCEEUserInfo].registerPassword = self.registerPassword.text;
    
    if (self.registerName.text.length == 0 &&
        self.registerPassword.text.length == 0)
    {
        [MBProgressHUD showError:@"用户名或者密码不能为空"];
        return;
    }
    
    /** 调用工具类的方法,完成注册 */
    __weak typeof (self) myVC = self;
    [[CEEXMPPTool sharedCEEXMPPTool] userRegister:^(CEEXMPPResultType type) {
        /** 处理注册状态 */
        [myVC handleXMPPResultType:type];
    }];
    
}

/** 监听注册状态 */
- (void)handleXMPPResultType:(CEEXMPPResultType) type
{
    switch (type) {
        case CEEXMPPResultTypeRegisterSuccess:
            [MBProgressHUD showSuccess:@"注册成功"];
            [self dismissViewControllerAnimated:YES completion:nil];
            [CEEUserInfo sharedCEEUserInfo].registerType = NO;
            /** 发起一个 web请求,生成 web 账号 */
            [self registerUserForWebServer];
            break;
            
        case CEEXMPPResultTypeRegisterFailure:
            [MBProgressHUD showError:@"注册失败"];
            break;
            
        case CEEXMPPResultTypeNetError:
            [MBProgressHUD showError:@"网络错误"];
            break;
            
        default:
            break;
    }
}

#pragma makr - 新增 web 服务器账号访问;
/** 发送注册信息到 web 服务器,生成 web 账号 */
- (void) registerUserForWebServer
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *url = [NSString stringWithFormat:@"http://%@:8080/allRunServerNew/register.jsp",CEEXMPPHOSTNAME];

    /** 设置参数 */
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    CEEUserInfo *userInfo = [CEEUserInfo sharedCEEUserInfo];
    parameters[@"username"] = userInfo.registerName;
    parameters[@"md5password"] = [userInfo.registerPassword md5StrXor];/** 将密码加密 */
    parameters[@"nickname"] = userInfo.registerName;

    /** 发送请求 */
    [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    
        UIImage *image = [UIImage imageNamed:@"KR@3x"];
        NSData *data = UIImagePNGRepresentation(image);
        [formData appendPartWithFileData: data
                                                      name: @"pic"
                                                 fileName: @"headerImage.png"
                                               mimeType: @"image/jpg"];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        MYLog(@"Web register success!%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MYLog(@"Web register failed!%@",error);
    }];
}

- (IBAction)returnButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
