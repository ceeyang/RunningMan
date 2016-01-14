//
//  AppDelegate.m
//  CEERunningMan
//
//  Created by 纵使寂寞开成海 on 15/12/31.
//  Copyright © 2015年 Cee. All rights reserved.
//

#import "AppDelegate.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "MyPofileViewController.h"
#import "ViewController.h"
#import "CEELoginViewController.h"
#import "MMDrawerController.h"  /** 侧滑三方 */


@interface AppDelegate ()<BMKGeneralDelegate>
@property (nonatomic, strong) MMDrawerController *drawerController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options{
    return [TencentOAuth HandleOpenURL:url];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    _window = [[UIWindow alloc] initWithFrame: [UIScreen mainScreen].bounds];
    _window.backgroundColor = [UIColor whiteColor];
    [_window makeKeyAndVisible];
    
    _isNotFirst = [[NSUserDefaults standardUserDefaults] boolForKey:@"isNotFirst"];

    if (_isNotFirst)
    {
        [self setupNavigationController];
    }
    else
    {
        UIStoryboard *LoginSB = [UIStoryboard storyboardWithName:@"LoginAndRegister" bundle:nil];
        CEELoginViewController *LoginVC = [LoginSB instantiateInitialViewController];
        _window.rootViewController = LoginVC;
//#warning 程序调试状态,直接跳过登录界面
//        UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        ViewController *mainVC = [mainSB instantiateInitialViewController];
//        _window.rootViewController = mainVC;
    
    }
    
    
    /** 统一导航栏风格 */
    [self setThem];
    
    _manager = [[BMKMapManager alloc]init];
    [_manager start:@"2mzXGZnNcV98dd8Mg4pNslRr" generalDelegate:self];
    
    return YES;
}

#pragma mark -
- (void) onGetNetworkState:(int)iError
{
    if (iError == 0 )
    {
        MYLog(@"联网成功!");
    }
    else
    {
        MYLog(@"联网失败:%d\t%s",iError,__FUNCTION__);
    }
}
- (void)onGetPermissionState:(int)iError
{
    if (iError == 0)
    {
        MYLog(@"授权成功!");
    }
    else
    {
        MYLog(@"授权失败:%d\t%s",iError,__FUNCTION__);
    }
}



- (void)setupNavigationController
{
    /** 主视图实例对象 */
    UIStoryboard *MainSB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *mainVC = [MainSB instantiateInitialViewController];
    
    /** 左边视图实例对象 */
    UIStoryboard *myPofileSB = [UIStoryboard storyboardWithName:@"MyPofile" bundle:nil];
    MyPofileViewController *myPofileVC = [myPofileSB instantiateInitialViewController];
    
    /** 使用抽屉第三方框架绑定视图控制器 */
    self.drawerController = [[MMDrawerController alloc]initWithCenterViewController:mainVC leftDrawerViewController:myPofileVC];
    [self.drawerController setShowsShadow:NO];
    
    /** 设置滑动边距大小 */
    self.drawerController.maximumLeftDrawerWidth = 280;
    self.drawerController.statusBarViewBackgroundColor = [UIColor redColor];
    
    /** 设置抽屉模式打开和关闭的手势监听模式 */
    self.drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeNone;
    self.drawerController.closeDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
    
    _window.rootViewController = _drawerController;
}

/** 统一导航栏风格 */
- (void) setThem
{
    UINavigationBar *bar = [UINavigationBar appearance];
    [bar setBackgroundImage:[UIImage imageNamed:@"矩形"] forBarMetrics:UIBarMetricsDefault];
    bar.barStyle = UIBarStyleBlack;
    bar.tintColor = [UIColor whiteColor];
    
}

@end
