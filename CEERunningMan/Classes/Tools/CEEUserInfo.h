//
//  CEEUserInfo.h
//  CEEBaseProject
//
//  Created by 纵使寂寞开成海 on 15/12/31.
//  Copyright © 2015年 Cee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"


@interface CEEUserInfo : NSObject
singleton_interface(CEEUserInfo)

/** 用户的姓名和密码 */
@property (nonatomic, copy) NSString *userNmae;
@property (nonatomic, copy) NSString *userPassword;
@property (nonatomic, assign, getter=isRegisterType) BOOL registerType;


/** 用户注册信息 */
@property (nonatomic, copy) NSString *registerName;
@property (nonatomic, copy) NSString *registerPassword;
/** 获取用户对应的 jidStr */
@property (nonatomic, strong) NSString *jidStr;


/** 新浪登陆 */
@property (nonatomic, copy) NSString *sinaToken;
@property (nonatomic, assign,getter=isSinaLogin) BOOL sinaLogin;



/** 用户数据的沙盒读写 */
- (void) saveCEEUserInfoToSandBox;
- (void) loadCEEUserInfoFromSandBox;



@end
