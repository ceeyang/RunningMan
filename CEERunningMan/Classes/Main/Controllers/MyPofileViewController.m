//
//  MyPofileViewController.m
//  CEERunningMan
//
//  Created by 纵使寂寞开成海 on 16/1/5.
//  Copyright © 2016年 Cee. All rights reserved.
//

#import "MyPofileViewController.h"
#import "CEEUserInfo.h"
#import "CEEXMPPTool.h"
#import "XMPPvCardTemp.h"
#import "UIImageView+CEERoundImageView.h"
#import "CEEEditMyPofileVC.h"


@interface MyPofileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nikeNameLabel;

@end

@implementation MyPofileViewController

/** 显示个人信息 */
- (void)viewWillAppear:(BOOL)animated
{
    XMPPvCardTemp *vCardTemp = [CEEXMPPTool sharedCEEXMPPTool] .xmppvCard.myvCardTemp;
    self.userNameLabel.text = [CEEUserInfo sharedCEEUserInfo].userNmae;
    self.nikeNameLabel.text = vCardTemp.nickname;
    
    if (vCardTemp.photo)
    {
        self.headerImageView.image = [UIImage imageWithData:vCardTemp.photo];
    }
    else
    {
        self.headerImageView.image = [UIImage imageNamed:@"KR@3x"];
        /** 如果用户没有头像,将本地的 KR@3X 作为该用户的头像并储存 */
        vCardTemp.photo = UIImagePNGRepresentation(self.headerImageView.image);
    }
    
    [self.headerImageView setRoundLayer];
    
}

/** 退出登录 */
- (IBAction)logoutButton:(id)sender {
    [[CEEUserInfo sharedCEEUserInfo] saveCEEUserInfoToSandBox];
    [[CEEXMPPTool sharedCEEXMPPTool] sedOffLine];
    [CEEUserInfo sharedCEEUserInfo].jidStr = nil;
    
    if ([CEEUserInfo sharedCEEUserInfo].sinaLogin)
    {
        [CEEUserInfo sharedCEEUserInfo].sinaLogin = NO;
        [CEEUserInfo sharedCEEUserInfo].userNmae = nil;
    }
    
    UIStoryboard *LoginSB = [UIStoryboard storyboardWithName:@"LoginAndRegister" bundle:nil];
    UIViewController *vc = [LoginSB instantiateInitialViewController];
    [UIApplication sharedApplication].keyWindow.rootViewController = vc;
    
    return;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/** 跳转界面之前做的事儿 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destVC = segue.destinationViewController;
    if ([destVC isKindOfClass:[CEEEditMyPofileVC class]])
    {
        CEEEditMyPofileVC *editVC = (CEEEditMyPofileVC *)destVC;
        editVC.myPofile = [CEEXMPPTool sharedCEEXMPPTool].xmppvCard.myvCardTemp;
    }
}




@end
