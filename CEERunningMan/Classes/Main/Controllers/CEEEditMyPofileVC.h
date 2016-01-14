//
//  CEEEditMyPofileVC.h
//  CEERunningMan
//
//  Created by 纵使寂寞开成海 on 16/1/6.
//  Copyright © 2016年 Cee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPvCardTemp.h"


@interface CEEEditMyPofileVC : UIViewController

/** 用来存储用户个人信息 */
@property (nonatomic, strong) XMPPvCardTemp *myPofile;

@end
