//
//  NSString+md5.h
//  CEERunningMan
//
//  Created by 纵使寂寞开成海 on 16/1/4.
//  Copyright © 2016年 Cee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (md5)

/** 创建一个方法,解密过后的密码 */
- (NSString *) md5Str;

/** 异或防止破解 */
- (NSString *) md5StrXor;


@end
