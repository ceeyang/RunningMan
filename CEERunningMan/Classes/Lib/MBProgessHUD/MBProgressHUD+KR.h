//
//  MBProgressHUD+KR.h
//  酷跑
//
//  Created by guoaj on 15/10/23.
//  Copyright © 2015年 tarena. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (KR)
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;
+ (void)showError:(NSString *)error toView:(UIView *)view;

+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view;


+ (void)showSuccess:(NSString *)success;
+ (void)showError:(NSString *)error;

+ (MBProgressHUD *)showMessage:(NSString *)message;

+ (void)hideHUDForView:(UIView *)view;
+ (void)hideHUD;
@end
