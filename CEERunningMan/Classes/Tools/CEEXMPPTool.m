//
//  CEEXMPPTool.m
//  CEEBaseProject
//
//  Created by 纵使寂寞开成海 on 15/12/31.
//  Copyright © 2015年 Cee. All rights reserved.
//

#import "CEEXMPPTool.h"
#import "CEEUserInfo.h"

/** 底层功能: 日志头文件 */
//#import "DDLog.h"
//#import "DDTTYLogger.h"

@interface CEEXMPPTool ()<XMPPStreamDelegate,XMPPRosterDelegate>//<XMPPStreamDelegate>
{
    CEEResultBlock  _resultBlock;
}
/** 好友请求的用户的 Jid */
@property (nonatomic, strong) XMPPJID *fJid;
@end

@implementation CEEXMPPTool
singleton_implementation(CEEXMPPTool)


/** 设置 XMPP 流  */
- (void) setXmpp
{
    /** 开启底层发送数据的日志 */
//    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    self.xmppStream = [[XMPPStream alloc]init];
   [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    /** 给头像电子名片模块和头像模块赋值 */
    self.xmppvCardStore = [XMPPvCardCoreDataStorage sharedInstance];
    self.xmppvCard = [[XMPPvCardTempModule alloc] initWithvCardStorage:self.xmppvCardStore];
    self.xmppvCardAvar = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:self.xmppvCard];;
    /** 激活电子名片模块和头像模块 */
    [self.xmppvCard         activate:self.xmppStream];
    [self.xmppvCardAvar  activate:self.xmppStream];
    
    /** 设置好友列表模块 */
    self.xmppRosterStore = [XMPPRosterCoreDataStorage sharedInstance];
    self.xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:self.xmppRosterStore];
    [self.xmppRoster activate:self.xmppStream];
    
    /** 设置聊天消息模块 */
    self.xmppMsgArchStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    self.xmppMsgArch = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:self.xmppMsgArchStorage];
    [self.xmppMsgArch activate:self.xmppStream];
    
}

/** 链接服务器 */
- (void) connectHost
{
    if ( !self.xmppStream )
    {
        [self setXmpp];
    }
    
    /** 给 xmppStream 做一些属性设置 */
    self.xmppStream.hostName = CEEXMPPHOSTNAME;
    self.xmppStream.hostPort = CEEXMPPPOST;
    
    /** 构建一个 GID ,设置中间变量,判断是登陆还是注册*/
    NSString *uname = nil;
    if ([[CEEUserInfo sharedCEEUserInfo] isRegisterType])
    {
        uname = [CEEUserInfo sharedCEEUserInfo].registerName;
    }
    else
    {
        uname = [CEEUserInfo sharedCEEUserInfo].userNmae;
    }
    XMPPJID *myJid = [XMPPJID jidWithUser:uname domain:CEEXMPPDOMAIN resource:@"iphone"];
    self.xmppStream.myJID = myJid;
    
    /** 链接服务器 */
    NSError *error = nil;
    [self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    if (error)
    {
        MYLog(@"链接服务器出错:%@",error);
    }
}

/** 授权成功后,发送密码 */
- (void) sendPasswordToHost
{
    NSString *pwd = nil;
    NSError *error = nil;
    
    if ([CEEUserInfo sharedCEEUserInfo].isRegisterType)
    {
        /** 利用用户输入的密码进行注册 */
        pwd = [CEEUserInfo sharedCEEUserInfo].registerPassword;
        [self.xmppStream  registerWithPassword:pwd error:&error];
    }
    else
    {
        /** 利用用户密码进行登陆 */
        pwd = [CEEUserInfo sharedCEEUserInfo].userPassword;
        [self.xmppStream authenticateWithPassword:pwd error:&error];
    }
    if (error)
    {
        MYLog(@"%@",error);
    }
}

/** 链接成功后,发送在线消息 */
- (void) sendOnLine
{
    /** 默认代表在线 */
    XMPPPresence *presence = [XMPPPresence presence];
    [self.xmppStream sendElement:presence];
}

/** 退出时,发送离线消息 */
- (void)sedOffLine
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [self.xmppStream sendElement:presence];
}

#pragma mark - XMPPStreamDelegate
/** 链接服务器成功 */
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    /** 发送密码 */
    [self sendPasswordToHost];
}

/** 链接服务器失败 */
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    if (error /** && _resultBlock */)
    {
        MYLog(@"链接服务器失败:%@",error);
        _resultBlock(CEEXMPPResultTypeNetError);
    }
    
    /** 链接服务器失败,就调用代理的成功方法
    if ([self.delegate respondsToSelector:@selector(krNetError)])
    {
        [self.delegate krNetError];
    }
     */
}

/** 授权成功的方法 */
- (void) xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    _resultBlock(CEEXMPPResultTypeLoginSuccess);
    
    /** 授权成功,就调用代理的成功方法
    if ([self.delegate respondsToSelector:@selector(krLoginSuccess)])
    {
        [self.delegate krLoginSuccess];
    }
    */
    
    /** 发送在线消息 */
    [self sendOnLine];
}

/** 授权失败的方法 */
- (void) xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    MYLog(@"授权失败:%@",error);
    
    if (error && _resultBlock)
    {
        _resultBlock (CEEXMPPResultTypeLoginFaild);
    }
    
    /** 授权失败,就调用代理的成功方法
    if ([self.delegate respondsToSelector:@selector( krLoginFailed)])
    {
        [self.delegate krLoginFailed];
    }
    */
}


#pragma mark - 用户注册
/** 注册成功 */
- (void) xmppStreamDidRegister:(XMPPStream *)sender
{
    if (_resultBlock)
    {
        _resultBlock(CEEXMPPResultTypeRegisterSuccess);
    }
}

/** 注册失败 */
- (void) xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    if (_resultBlock)
    {
        _resultBlock(CEEXMPPResultTypeRegisterFailure);
    }
}

/** 用户登陆 */
- (void)userLogin: (CEEResultBlock) block
{
    /** 利用 block 保存传进来的 block 代码 */
    _resultBlock = block;

    /** 无论有没有登录过,都断开一次连接 */
    [self.xmppStream disconnect];
    [self connectHost];
    
    
}

/** 用户注册 */
- (void)userRegister:(CEEResultBlock) block
{
    _resultBlock = block;
    /** 断开之前的链接 */
    [self.xmppStream disconnect];
    [self connectHost];
}

#pragma mark - 释放资源
- (void) dealloc
{
    [self cleanResource];
}
- (void) cleanResource
{
    /** 移除代理 */
    [_xmppStream removeDelegate:self];
    /** 停止激活 */
    [_xmppMsgArch deactivate];
    [_xmppvCardAvar deactivate];
    [_xmppRoster deactivate];
    /** 断开连接 */
    [_xmppStream disconnect];
    _xmppStream               = nil;
    _xmppMsgArch             = nil;
    _xmppMsgArchStorage  = nil;
    _xmppRoster                 = nil;
    _xmppRosterStore         = nil;
    _xmppvCardAvar           = nil;
    _xmppvCardStore          = nil;
    
}

//处理加好友
#pragma mark 处理加好友回调,加好友

- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    //取得好友状态
    NSString *presenceType = [NSString stringWithFormat:@"%@", [presence type]];
    //请求的用户
    NSString *presenceFromUser =[NSString stringWithFormat:@"%@", [[presence from] user]];
    NSLog(@"-----presenceType:%@",presenceType);
    
    NSLog(@"-----presence2:%@  sender2:%@",presence,sender);
    NSLog(@"-----fromUser:%@",presenceFromUser);
    NSString *jidStr = [NSString stringWithFormat:@"%@@%@",presenceFromUser,CEEXMPPDOMAIN];
    XMPPJID *jid = [XMPPJID jidWithString:jidStr];
    self.fJid = jid;
    NSString *title = [NSString stringWithFormat:@"%@想申请加好友",jidStr];
    UIActionSheet *actionSheet =[[UIActionSheet alloc]initWithTitle: title
                                                                                        delegate: self
                                                                         cancelButtonTitle: @"取消"
                                                                  destructiveButtonTitle: @"同意"
                                                                         otherButtonTitles: @"同意并添加对方为好友", nil];
    
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
    
}
- (void)xmppStream:(XMPPStream *)sender didFailToSendPresence:(XMPPPresence *)presence error:(NSError *)error
{
    //取得好友状态
    NSString *presenceType = [NSString stringWithFormat:@"%@", [presence type]];
    //请求的用户
    NSString *presenceFromUser =[NSString stringWithFormat:@"%@", [[presence from] user]];
    NSLog(@"-----presenceType:%@",presenceType);
    
    NSLog(@"-----presence2:%@  sender2:%@",presence,sender);
    NSLog(@"-----fromUser:%@",presenceFromUser);
    NSString *jidStr = [NSString stringWithFormat:@"%@@%@",presenceFromUser,CEEXMPPDOMAIN];
    XMPPJID *jid = [XMPPJID jidWithString:jidStr];
    self.fJid = jid;
    UIActionSheet *actionSheet =[[UIActionSheet alloc]initWithTitle:[NSString stringWithFormat:@"%@想申请加好友",jidStr] delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"同意" otherButtonTitles:@"同意并添加对方为好友", nil];
    
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"index====%ld",buttonIndex);
    if (0 == buttonIndex) {
        [self.xmppRoster acceptPresenceSubscriptionRequestFrom:self.fJid andAddToRoster:NO];
    }else if(1== buttonIndex){
        [self.xmppRoster acceptPresenceSubscriptionRequestFrom:self.fJid andAddToRoster:YES];
    }else{
        [self.xmppRoster  rejectPresenceSubscriptionRequestFrom:self.fJid];
    }
}


@end


