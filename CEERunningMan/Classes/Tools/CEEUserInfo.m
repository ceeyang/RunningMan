//
//  CEEUserInfo.m
//  CEEBaseProject
//
//  Created by 纵使寂寞开成海 on 15/12/31.
//  Copyright © 2015年 Cee. All rights reserved.
//

#import "CEEUserInfo.h"


@implementation CEEUserInfo
singleton_implementation(CEEUserInfo)

/** 读取用户沙盒中的数据 */
- (void) saveCEEUserInfoToSandBox
{
    [[NSUserDefaults standardUserDefaults] setValue:self.userNmae forKey:@"userName"];
    [[NSUserDefaults standardUserDefaults] setValue:self.userPassword forKey:@"userPassword"];
}

- (void) loadCEEUserInfoFromSandBox
{
    self.userNmae = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    self.userPassword = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPassword"];
}

- (NSString *)jidStr
{
    return [NSString stringWithFormat:@"%@@%@",self.userNmae,CEEXMPPDOMAIN];
}

@end
