//
//  NSString+md5.m
//  CEERunningMan
//
//  Created by 纵使寂寞开成海 on 16/1/4.
//  Copyright © 2016年 Cee. All rights reserved.
//

#import "NSString+md5.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSString (md5)

- (NSString *) md5Str
{
    /** 使用 C 语言编码 */
    const char *myPassword =  [self UTF8String];
    
    /** 1Byte = 8bit; 4bit 可以表示一个16进制 */
    unsigned char mdc[16];
    CC_MD5(myPassword, (CC_LONG)strlen(myPassword), mdc);
    
    NSMutableString *md5String = [NSMutableString string];
    
    for (int i = 0; i<16; i++)
    {
        [md5String appendFormat:@"%02x",mdc[i]];
    }
    MYLog(@"密码:%@",md5String);
    return [md5String copy];
}

- (NSString *)md5StrXor
{
    /** 使用 C 语言编码 */
    const char *myPassword =  [self UTF8String];
    
    /** 1Byte = 8bit; 4bit 可以表示一个16进制 */
    unsigned char mdc[16];
    CC_MD5(myPassword, (CC_LONG)strlen(myPassword), mdc);
    
    NSMutableString *md5String = [NSMutableString string];
    
    [md5String appendFormat:@"%02x",mdc[0]];
    for (int i = 1; i<16; i++)
    {
        [md5String appendFormat:@"%02x",mdc[i]^mdc[0]];
    }
    MYLog(@"密码:%@",md5String);
    return [md5String copy];
}
@end