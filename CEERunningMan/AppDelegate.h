//
//  AppDelegate.h
//  CEERunningMan
//
//  Created by 纵使寂寞开成海 on 15/12/31.
//  Copyright © 2015年 Cee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/** 判断 app 是否是第一次启动 */
@property (nonatomic, assign) BOOL isNotFirst;

@property (nonatomic, strong) BMKMapManager *manager;

- (void) setupNavigationController;

@end

