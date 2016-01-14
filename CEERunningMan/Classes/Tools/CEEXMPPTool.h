//
//  CEEXMPPTool.h
//  CEEBaseProject
//
//  Created by 纵使寂寞开成海 on 15/12/31.
//  Copyright © 2015年 Cee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "XMPPFramework.h"

#import "XMPPMessageArchiving.h"
#import "XMPPMessageArchivingCoreDataStorage.h"





/** 定义一些枚举代表登录和注册的状态 */
typedef enum
{
    CEEXMPPResultTypeLoginSuccess,
    CEEXMPPResultTypeLoginFaild,
    CEEXMPPResultTypeNetError,
    CEEXMPPResultTypeRegisterSuccess,
    CEEXMPPResultTypeRegisterFailure,
}CEEXMPPResultType;

typedef void(^CEEResultBlock)
(CEEXMPPResultType type);

/** 定义一个实现登陆的协议 */
//@protocol KRLoginProtocol <NSObject>
//- (void) krLoginSuccess;
//- (void) krLoginFailed;
//- (void) krNetError;
//@end


@interface CEEXMPPTool : NSObject
singleton_interface(CEEXMPPTool)

//@property (nonatomic, weak) id<KRLoginProtocol> delegate;

#pragma mark - 链接服务器类
/** 负责和服务器经行交互的主要对象 */
@property (nonatomic, strong) XMPPStream *xmppStream;

/** 设置 XMPP 流  */
- (void) setXmpp;

/** 链接服务器 */
- (void) connectHost;

/** 授权成功后,发送密码 */
- (void) sendPasswordToHost;

/** 连接成功过会,发送在线消息 */
- (void) sendOnLine;

/** 退出登录,发送离线消息 */
- (void) sedOffLine;


#pragma mark -用户登录
/** 用户登陆 */
- (void) userLogin: (CEEResultBlock) block;
/** 用户注册 */
- (void) userRegister:(CEEResultBlock) block;
/** 清理资源 */
- (void) cleanResource;


#pragma makr - 电子名片
/** 增加电子名片模块 和 头像模块 */
@property (nonatomic, strong) XMPPvCardTempModule *xmppvCard;
@property (nonatomic, strong) XMPPvCardAvatarModule *xmppvCardAvar;
/** 对电子名片模块 和 头像模块进行管理的对象 */
@property (nonatomic, strong) XMPPvCardCoreDataStorage *xmppvCardStore;


#pragma mark - 好友列表
/** 增加好友列表模块 和 对象的存储 */
@property (nonatomic, strong) XMPPRoster *xmppRoster;
@property (nonatomic, strong) XMPPRosterCoreDataStorage *xmppRosterStore;

#pragma mark - 聊天消息
@property (nonatomic, strong) XMPPMessageArchiving *xmppMsgArch;
@property (nonatomic, strong) XMPPMessageArchivingCoreDataStorage *xmppMsgArchStorage;

@end
