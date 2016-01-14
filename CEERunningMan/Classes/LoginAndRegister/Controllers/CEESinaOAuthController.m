//
//  CEESinaOAuthController.m
//  CEERunningMan
//
//  Created by 纵使寂寞开成海 on 16/1/4.
//  Copyright © 2016年 Cee. All rights reserved.
//

#import "CEESinaOAuthController.h"
#import "AFNetworking.h"
#import "CEEUserInfo.h"
#import "CEEXMPPTool.h"
#import "MBProgressHUD+KR.h"
#import "NSString+md5.h"

#define  APPKEY             @"3562333159"
#define  REDIRECT_URI  @"http://www.baidu.com"
#define  APPSECRET       @"d59b60576d9d948bb1ab3ed3f04000c5"


@interface CEESinaOAuthController()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end


@implementation CEESinaOAuthController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.delegate = self;
    
    /** 按照新浪官方要求,加载 URL */
    NSString  *urlStr = [NSString stringWithFormat:@"https://api.weibo.com/oauth2/authorize?client_id=%@&redirect_uri=%@"
                         ,APPKEY,REDIRECT_URI];
    NSURL *url = [NSURL URLWithString:urlStr];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlPath = request.URL.absoluteString;
    MYLog(@"urlPath = %@",urlPath);
    
    /** 截取返回的字符串中的 code 值 */
//    NSRange *range = [urlPath rangeOfString:@"?code="];   //同下
    NSRange range = [urlPath rangeOfString:[NSString stringWithFormat:@"%@%@",REDIRECT_URI,@"/?code="]];
    NSString *code = nil;
    if (range.length >0)
    {
        code = [urlPath substringFromIndex:range.length];
        MYLog(@"%@",code);
        [self accesTokenWithCode:code];
        return NO;
    }
    return YES;
}

- (void) accesTokenWithCode:(NSString *) code
{
    /** 导入AFN  发请求 获得access_token */
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *urlStr = @"https://api.weibo.com/oauth2/access_token";
    
    /** 设置参数 */
    NSMutableDictionary *paramerters = [NSMutableDictionary dictionary];
    paramerters[@"client_id"]        = APPKEY;
    paramerters[@"client_secret"]  = APPSECRET;
    paramerters[@"grant_type"]     = @"authorization_code";
    paramerters[@"code"]              = code;
    paramerters[@"redirect_uri"]   = REDIRECT_URI;

    /** 发送请求 */
    [manager POST:urlStr parameters:paramerters success:^(AFHTTPRequestOperation *operation, id responseObject) {
    
        MYLog(@"获取 token 成功");
        /** 根据返回数据的 uid 生成系统内部的账号,之前生成过的账号就是用账号登陆 */
        MYLog(@"%@",responseObject);
        NSString *innerName = [NSString stringWithFormat:@"sina%@",responseObject[@"uid"]];
        [CEEUserInfo sharedCEEUserInfo].registerName        = innerName;
        [CEEUserInfo sharedCEEUserInfo].registerPassword  = responseObject[@"access_token"];
        [CEEUserInfo sharedCEEUserInfo].registerType         = YES;
        
        /** 赋值成功后, token */
        [CEEUserInfo sharedCEEUserInfo].sinaToken = responseObject[@"access_token"];
        
        __weak typeof(self) sinaVC = self;
        [[CEEXMPPTool sharedCEEXMPPTool] userRegister:^(CEEXMPPResultType type) {
            [sinaVC handleRegisterResult:type];
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MYLog(@"获取 token 失败");
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

/** 处理注册逻辑 */
- (void) handleRegisterResult:(CEEXMPPResultType ) type
{
    switch (type) {
        case CEEXMPPResultTypeRegisterSuccess:
            /** 如果需要 web 账号,也应该注册一个 */
            [self registerUserForWebServer];
            break;
            
        case CEEXMPPResultTypeRegisterFailure:
        {
            /** 无论内部注册成功还是失败,都直接登录 */
            [CEEUserInfo sharedCEEUserInfo].registerType = NO;
            [CEEUserInfo sharedCEEUserInfo].userNmae = [CEEUserInfo sharedCEEUserInfo].registerName;
            [CEEUserInfo sharedCEEUserInfo].userPassword = [CEEUserInfo sharedCEEUserInfo].registerPassword;
            /** 当上面传了 __weak, 此处,可以调用 self,下面一行可以省略,调用self */
            __weak typeof(self) selfVC = self;
            [[CEEXMPPTool sharedCEEXMPPTool] userLogin:^(CEEXMPPResultType type) {
                [selfVC handleLoginResult:type];
            }];
            break;
        }
            
        case CEEXMPPResultTypeNetError:
            MYLog(@"注册失败,网络错误!");
            break;
        default:
            break;
    }
}

/** 处理登录的返回 */
- (void) handleLoginResult:( CEEXMPPResultType) type
{
    switch (type) {
        case CEEXMPPResultTypeLoginSuccess:
        {
            [CEEUserInfo sharedCEEUserInfo].sinaLogin = YES;
            [self dismissViewControllerAnimated:YES completion:nil];
            
            /** 切换到主视图控制器 */
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            [UIApplication sharedApplication].keyWindow.rootViewController = storyboard.instantiateInitialViewController;
            break;
        }
        case CEEXMPPResultTypeRegisterFailure:
            [MBProgressHUD showMessage:@"登录失败"];
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
    parameters[@"username"]       = userInfo.registerName;
    parameters[@"md5password"] = [userInfo.registerPassword md5StrXor];/** 将密码加密 */
    parameters[@"nickname"]       = userInfo.registerName;
    
    /** 发送请求 */
    [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        UIImage *image = [UIImage imageNamed:@"icon1"];
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


- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
