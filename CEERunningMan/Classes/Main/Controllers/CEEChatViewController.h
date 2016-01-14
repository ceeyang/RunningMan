//
//  CEEChatViewController.h
//  CEERunningMan
//
//  Created by 纵使寂寞开成海 on 16/1/7.
//  Copyright © 2016年 Cee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPJID.h"


@interface CEEChatViewController : UIViewController

/** 要聊天的对象的标示 */
@property (nonatomic, strong) XMPPJID *friendJid;


@end
