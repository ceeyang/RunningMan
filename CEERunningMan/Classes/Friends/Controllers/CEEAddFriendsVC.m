//
//  CEEAddFriendsVC.m
//  CEERunningMan
//
//  Created by 纵使寂寞开成海 on 16/1/12.
//  Copyright © 2016年 Cee. All rights reserved.
//

#import "CEEAddFriendsVC.h"
#import "XMPPJID.h"
#import "CEEXMPPTool.h"
#import "CEEUserInfo.h"
#import "MBProgressHUD+KR.h"

@interface CEEAddFriendsVC ()

@end

@implementation CEEAddFriendsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)searchFriendsBtn:(id)sender
{
    
}
- (IBAction)addFriendsBtn:(id)sender
{
    [self addConcatp:self.exactSearchTextField.text];
}

/** 添加好友的逻辑 */
- (void) addConcatp: (NSString *) jidName
{
    NSString *jidStr = [NSString stringWithFormat:@"%@@%@",jidName,CEEXMPPDOMAIN];
    XMPPJID *jid = [XMPPJID jidWithString:jidStr];
    MYLog(@"添加朋友的 Jid:%@",jid);

    if ([[CEEXMPPTool sharedCEEXMPPTool].xmppRosterStore userExistsWithJID: jid
        xmppStream:[CEEXMPPTool sharedCEEXMPPTool].xmppStream])
    {
        [MBProgressHUD showError:@"对方已经是您的好友了!"];
        return;
    }
    if ([jidStr isEqualToString:[CEEUserInfo sharedCEEUserInfo].jidStr])
    {
        [MBProgressHUD showError:@"不能添加自己为好友!"];
        return;
    }
    
    [[CEEXMPPTool sharedCEEXMPPTool].xmppRoster subscribePresenceToUser:jid];
    
    [MBProgressHUD showSuccess:@"请求成功,等待用户响应!"];
}

@end
