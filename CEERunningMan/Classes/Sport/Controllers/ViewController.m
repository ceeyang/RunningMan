
//
//  ViewController.m
//  CEERunningMan
//
//  Created by 纵使寂寞开成海 on 15/12/31.
//  Copyright © 2015年 Cee. All rights reserved.
//

#import "ViewController.h"
#import <UIKit/UIKit.h>
#import "UIViewController+MMDrawerController.h"
#import "BMapKit.h"
#import "AFNetworking.h"
#import "CEEUserInfo.h"
#import "NSString+md5.h"
#import "MBProgressHUD+KR.h"
#import "sportType.h"


/** 控制开始跑步,及画线还是不画线 */
typedef enum
{
    TrailStart  = 1,
    TrailEnd   = 2
}Trail;

@interface ViewController ()< BMKMapViewDelegate,
                                             BMKLocationServiceDelegate>

@property (weak, nonatomic) IBOutlet UIButton       *startSportBtn;
@property (weak, nonatomic) IBOutlet UIButton       *pauseSportBtn;
@property (weak, nonatomic) IBOutlet UIButton       *continueSportBtn;
@property (weak, nonatomic) IBOutlet UIButton       *finishSportBtn;
@property (weak, nonatomic) IBOutlet UIView          *pauseSportView;
@property (weak, nonatomic) IBOutlet UIView          *finishSportView;

/** 导航栏右边按钮弹出的视图 */
@property (weak, nonatomic) IBOutlet UIView          *changeSportStyleView;

@property (nonatomic, strong) BMKMapView            *mapView;
/** 百度地图位置服务 */
@property (nonatomic, strong) BMKLocationService *locationService;
/** 控制开始还是没开始跑步的属性 */
@property (nonatomic, assign) Trail                           trail;
/** 起点 和 终点 大头针 */
@property (nonatomic, strong) BMKPointAnnotation  *startPointAnnotation;
@property (nonatomic, strong) BMKPointAnnotation  *endPointAnnotation;
/** 运动轨迹(遮盖线) */
@property (nonatomic, strong) BMKPolyline               *polyLine;
/** 储存用户位置的数组 */
@property (nonatomic, strong) NSMutableArray         *locationMutableArr;
/** 保存用户上一个位置 */
@property (nonatomic, strong) CLLocation                 *preLocation;
/** 运动的总距离 */
@property (nonatomic, assign) double                        sumDistance;
/** 运动的总时间 */
@property (nonatomic, assign) double                        sumSportTime;
/** 运动的总热量 */
@property (nonatomic, assign) double                        sumHeat;
/** 导航栏右边按钮 */
@property (nonatomic, strong) UIBarButtonItem        *rightItem;

/** 用来表示现在的运动模式 */
@property (nonatomic, assign) enum SportType sportType;

@end



@implementation ViewController
#pragma mark - 懒加载
- (NSMutableArray *)locationMutableArr
{
    if ( !_locationMutableArr)
    {
        _locationMutableArr = [NSMutableArray array];
    }
    return _locationMutableArr;
}

#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.view.alpha = 1.0;
    
    
    self.mapView = [BMKMapView new];
    self.mapView.frame = self.view.bounds;
    /** 将该视图作为底层视图 */
    [self.view insertSubview:self.mapView atIndex:0];
    
    [self setLocationService];
    [self setMapViewProperty];
    self.mapView.delegate          = self;
    self.locationService.delegate = self;
    self.finishSportView.hidden  = YES;
    
    /** 启动定位服务 */
    [self.locationService startUserLocationService];
    
    /** 跑步的起始状态为停止 */
    self.trail = TrailEnd;
    self.pauseSportBtn.hidden   = YES;
    self.pauseSportView.hidden  = YES;
    
    /** 给暂停按钮添加手势识别 */
    UISwipeGestureRecognizer *swipeGR =[[UISwipeGestureRecognizer alloc]
                                                                 initWithTarget:self action:@selector(pauseSportBtnSwipe)];
    /** 指定手势方向 */
    swipeGR.direction = UISwipeGestureRecognizerDirectionDown;
    [self.pauseSportBtn addGestureRecognizer:swipeGR];
    
    /** 设置导航栏右边按钮 */
    [self setupRightBarItem];
    
    self.changeSportStyleView.hidden = YES;
    
    /** 初始运动状态 */
    self.sportType = SportTypeRun;
}
/** 滑动暂停按钮的逻辑 */
- (void) pauseSportBtnSwipe
{
    /** 停止定位服务 */
    [self.locationService stopUserLocationService];
    self.pauseSportView.hidden  = NO;
    self.pauseSportBtn.hidden    = YES;
    
}

#pragma mark - 打开抽屉按钮
- (IBAction)MyPofileButton:(id)sender
{
    [[self mm_drawerController] toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

#pragma mark -
/** 自定义位置服务初始化 */
- (void) setLocationService
{
    self.locationService = [[BMKLocationService alloc]init];
    /** 过滤器,几米定位一次 */
    [BMKLocationService setLocationDistanceFilter:5];
    /** 设置精确度 */
    [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyBest];
}
/** 百度地图 View 的属性设置 */
- (void) setMapViewProperty
{
    /** 最重要的几个属性 */
    self.mapView.showsUserLocation       = YES;
    self.mapView.userTrackingMode        = BMKUserTrackingModeNone;
    self.mapView.rotateEnabled               = NO;
    self.mapView.showMapScaleBar        = YES;
    self.mapView.mapScaleBarPosition    = CGPointMake(self.view.frame.size.width - 100,
                                                                                      self.view.frame.size.height - 100);
    
    /** 定位图层的自定义设置 */
    BMKLocationViewDisplayParam *displayPara = [BMKLocationViewDisplayParam new];
    displayPara.isAccuracyCircleShow     = NO;
    displayPara.isRotateAngleValid          = YES;
    displayPara.locationViewOffsetX        = 0;
    displayPara.locationViewOffsetX        = 0;
    
    [self.mapView updateLocationViewWithParam:displayPara];
    
}
/** 用户位置更新 */
- (void) didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    MYLog(@": %lf:%lf",userLocation.location.coordinate.latitude,
          userLocation.location.coordinate.longitude);
    
    [self.mapView updateLocationData:userLocation];
    /** 以用户目前的位置,作为地图中心点,并设置显示的扇区 */
    if ( self.trail == TrailEnd)
    {
        BMKCoordinateRegion adjustRegion = [self.mapView regionThatFits:
                                                                    BMKCoordinateRegionMake(userLocation.location.coordinate,
                                                                    BMKCoordinateSpanMake(0.02, 0.02))];
        [self.mapView setRegion:adjustRegion animated:YES];
    }
    
    /** 判断用户是否在户外:       */
    /** 根据用户的水平精确度判断,如果大于十米,用户可能使用基站或者 WiFi 定位,判定为室内 */
    if ( userLocation.location.horizontalAccuracy > kCLLocationAccuracyNearestTenMeters)
    {
        return;
    }
    
    /** 开始运动,并记录用户的合法位置 */
    if (self.trail == TrailStart)
    {
        [ self startTrailRouterWithUserLocation:userLocation];
        [ self.mapView setRegion:BMKCoordinateRegionMake(userLocation.location.coordinate,
                                               BMKCoordinateSpanMake(0.002, 0.002)) animated:YES];
    }
}
- (void) startTrailRouterWithUserLocation:(BMKUserLocation *)userlocation
{
    if ( self.preLocation)
    {
        /** 计算当前点  和  前一个点得距离 */
        double distance = [userlocation.location distanceFromLocation:self.preLocation];
        self.sumDistance += distance;
    }
    self.preLocation = userlocation.location;
    [self.locationMutableArr addObject:userlocation.location];
    
    /** 根据数组中的位置绘制遮盖物到地图上 */
    [self drawWalkLine];
}
/** 画线 */
- (void) drawWalkLine
{
    NSInteger count = self.locationMutableArr.count;
    BMKMapPoint *points = malloc(sizeof(BMKMapPoint) *count);
    /** 把locationMutableArr数组中的位置转换成 BMKMapPoint, 并存入 points对应的堆内存里 */
    [self.locationMutableArr enumerateObjectsUsingBlock:^(CLLocation *obj,
                                                                                           NSUInteger idx,
                                                                                           BOOL * _Nonnull stop) {
        /** 根据位置,转换成一个点 */
        BMKMapPoint point = BMKMapPointForCoordinate(obj.coordinate);
        points[idx] = point;
    }];
    
    /** 移除原有的折线 */
    if (self.polyLine)
    {
        [self.mapView removeOverlay:self.polyLine];
    }
    
    self.polyLine = [BMKPolyline polylineWithPoints:points count:count];
    [self.mapView addOverlay:self.polyLine];

    /** 释放堆内存 */
    free(points);
}
/** 折线应该如何显示 */
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolyline class]])
    {
        BMKPolylineView *polyLineView = [[ BMKPolylineView alloc] initWithPolyline:overlay];
        polyLineView.lineWidth    = 5.0;
        polyLineView.strokeColor = [UIColor blueColor];
        return polyLineView;
    }
    return nil;
}

#pragma mark - 开始运动
- (IBAction)startSportBtn:(id)sender
{
    /** 相关状态设置 */
    self.rightItem.enabled = NO;
    self.startSportBtn.hidden = YES;
    self.pauseSportBtn.hidden = NO;
     self.trail = TrailStart;
    
    [self.locationService startUserLocationService];
    
    /** 产生一个大头针,代表运动开始的起点 */
    self.startPointAnnotation = [self creatPointAnnotation: self.locationService.userLocation.location title:@"起点"];
    
    /** 将用户当前位置放入数组 */
    [self.locationMutableArr addObject:self.locationService.userLocation.location];
}
/** 自定义一个方法,用来产生大头针 */
- (BMKPointAnnotation *) creatPointAnnotation: (CLLocation *) location title: (NSString *)title
{
    BMKPointAnnotation *point = [[BMKPointAnnotation alloc] init];
    point.coordinate = location.coordinate;
    point.title = title;
    [self.mapView addAnnotation:point];
    return point;
}
/** 显示大头针 */
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]])
    {
        BMKPinAnnotationView *annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        /** 是起点,就设置起点图片,否则设置为终点图片 */
        if (self.startPointAnnotation )
        {
            annotationView.image = [UIImage imageNamed:@"end"];
        }
        else
        {
            annotationView.image = [UIImage imageNamed:@"start"];
        }
        annotationView.animatesDrop  = YES;
        annotationView.draggable        = YES;
        return annotationView;
    }
    return nil;
}

#pragma mark - 暂停运动
- (IBAction)pauseSportBtn:(id)sender
{
}

#pragma mark - 继续运动
- (IBAction)continueSportBtn:(id)sender
{
    self.pauseSportView.hidden = YES;
    self.pauseSportBtn.hidden = NO;
    [self.locationService startUserLocationService];
}

#pragma mark - 完成运动
/**************************************************************************************************************************
    点击完成按钮: 隐藏暂停视图,停止定位服务;
    1.把用户位置的点,都显示到地图的显示范围内;
    2.出现一个视图:
        2.1取消本地运动;
        2.2保存本地运动数据;
        2.3分享本地运动数据: 运动圈; sina 第三方登录与分享;
 ************************************************************************************************************************/
- (IBAction)finishSportBtn:(id)sender
{
    
    [self.locationService stopUserLocationService];
    
    self.rightItem.enabled          = YES;
    self.pauseSportView.hidden = YES;
    self.trail                               =  TrailEnd;
    
    /** 计算显示的地图大小 */
    [self mapViewFitRectForPolyLine];
    
    self.endPointAnnotation = [self creatPointAnnotation:[self. locationMutableArr lastObject] title:@"终点"];
    
    /** 完成后,计算总运动的总时间,热量等 */
    CLLocation *firstLocation = [self.locationMutableArr firstObject];
    CLLocation *lastLocation = [self.locationMutableArr lastObject];
    self.sumSportTime = lastLocation.timestamp.timeIntervalSince1970 -
                                    firstLocation.timestamp.timeIntervalSince1970;
    self.sumHeat          = ((self.sumSportTime/3600.0) * [self getHeatOnHourForSportType:self.sportType]);
    
    
    /** 显示保存与分享界面 */
    self.finishSportView.hidden = NO;
}

/** 根据运动模式,得到一小时消耗的热量 */
- (double) getHeatOnHourForSportType: (enum SportType) type
{
    switch (type) {
        case SportTypeRun:
            return 700.0;
        case SportTypeBike:
            return 500.0;
        case SportTypeSking:
            return 450.0;
        case SportTypeFree:
            return 300.0;
    }
}

/** 根据折线对象中点,算出显示范围 */
- (void) mapViewFitRectForPolyLine
{
    CGFloat ltX, ltY, maxX, maxY;
    if ( _polyLine.pointCount < 2)
    {
        return;
    }
    BMKMapPoint point = self.polyLine.points[0];
    ltX      = point.x;
    maxX  = point.x;
    ltY      = point.y;
    maxY  = point.y;
    
    for (int i = 1; i<_polyLine.pointCount; i++)
    {
        BMKMapPoint temp = self.polyLine.points[i];
        if (temp.x < ltX)
        {
            ltX = temp.x;
        }
        if (temp.y < ltY)
        {
            ltY = temp.y;
        }
        if (temp.x > maxX)
        {
            maxX = temp.x;
        }
        if (temp.y > maxY)
        {
            maxY = temp.y;
        }
    }
    /** 得到一个矩形 */
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(ltX - 40, ltY - 60);
    rect.size    = BMKMapSizeMake((maxX - ltX) + 80, (maxY - ltY) + 120);
    
    [self.mapView setVisibleMapRect:rect];
}

#pragma makr - 结束运动
- (IBAction)cancelSportBtn:(id)sender
{
    /** 清理状态 */
    [self cleanState];
    
    /** 调整显示区域 */
    BMKCoordinateRegion adjuestRegion = [self.mapView regionThatFits:
                                                                  BMKCoordinateRegionMake
                                                                  (self.locationService.userLocation.location.coordinate,
                                                                  BMKCoordinateSpanMake(0.002, 0.002))];

    [self.mapView setRegion:adjuestRegion];

}
/** 清理状态 */
- (void) cleanState
{
    [self.locationService stopUserLocationService];
    self.startSportBtn.hidden    =  NO;
    self.finishSportView.hidden =  YES;
    self.sumDistance                 =  0.0;
    self.sumHeat                       =  0.0;
    self.sumSportTime              = 0.0;


    /** 运动总时间清零,消耗总热量,运动模式等恢复起始状态 */

    /** 清空位置数组 */
    [self.locationMutableArr removeAllObjects];
    
    if (self.startPointAnnotation)
    {
        [self.mapView removeAnnotation:self.startPointAnnotation];
        self.startPointAnnotation = nil;
    }
    if (self.endPointAnnotation)
    {
        [self.mapView removeAnnotation:self.endPointAnnotation];
        self.endPointAnnotation  = nil;
    }
    if (self.polyLine)
    {
        [self.mapView removeOverlay:self.polyLine];
    }
}

/** 点击保存按钮,把数据保存到服务器 */
- (IBAction)saveSportBtn:(id)sender
{
    [self saveSportDataToServer];
    [self cancelSportBtn:nil];
}

- (void) saveSportDataToServer
{
    /** 请求的 URL */
    NSString *url = [NSString stringWithFormat:@"http://%@:8080/allRunServerNew/addSportData.jsp",
                            CEEXMPPHOSTNAME];
    /** 请求的参数 */
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"username"]      = [CEEUserInfo sharedCEEUserInfo].userNmae;
    parameters[@"md5passwor"]  = [[CEEUserInfo sharedCEEUserInfo].userPassword md5StrXor];
    parameters[@"sportType"]      = @(self.sportType);
    
    /** Data 参数 */
    CLLocation *firstLocation       = [self.locationMutableArr firstObject];
    CLLocation *lastLocation        = [self.locationMutableArr lastObject];
    NSString *datStr                    = [NSString stringWithFormat:@"%lf|%lf|%lf|@%lf|%lf|%lf",
                                                     firstLocation.timestamp.timeIntervalSince1970,
                                                     firstLocation.coordinate.latitude,
                                                     firstLocation.coordinate.longitude,
                                                     lastLocation.timestamp.timeIntervalSince1970,
                                                     lastLocation.coordinate.latitude,
                                                     lastLocation.coordinate.longitude];
    parameters[@"data"]              = datStr;
    /** 运动的其他参数: 总距离,总热量,总时间等 */
    parameters[@"sportDistance"]  = @(self.sumDistance);
    parameters[@"sportTimeLen"]  = @(self.sumSportTime);
    parameters[@"sportHeat"]        = @(self.sumHeat);
    parameters[@"sportStartTime"]= @(firstLocation.timestamp.timeIntervalSince1970);
    
    /** 发送请求 */
    AFHTTPRequestOperationManager *manager =[AFHTTPRequestOperationManager manager];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MBProgressHUD showSuccess:@"发送成功"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD showError:@"发送失败"];
    }];
}



#pragma mark - 分享运动数据到朋友圈
/** 获得截图 */
- (UIImage *) takeImage
{
    UIImage *image = [self.mapView takeSnapshot];
    return image;
}

/** 运动数据和图片分享到RunningMan朋友圈 */
- (IBAction)sharedSportToRMBtn:(id)sender
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *urlStr =[NSString stringWithFormat:@"http://%@:8080/allRunServerNew/addTopic.jsp",
                                                                            CEEXMPPHOSTNAME];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"username"] = [CEEUserInfo sharedCEEUserInfo].userNmae;
    parameters[@"md5password"] = [[CEEUserInfo sharedCEEUserInfo].userPassword md5StrXor];
    
    if (self.sumDistance <= 0.0)
    {
        return;
    }
    
    NSString *statusStr = [NSString stringWithFormat:@"本次运动了%.1lf米,共用时%1lf,消耗总热量%4lf卡",
                                      self.sumDistance,self.sumSportTime,self.sumHeat];
    parameters[@"content"] = statusStr;
    parameters[@"address"] = @"游子四海为家";
    
    CLLocation *lastLocation = [self.locationMutableArr lastObject];
    parameters[@"latitude"]   = @(lastLocation.coordinate.latitude);
    parameters[@"longitude"] = @(lastLocation.coordinate.longitude);
    
    /** 压缩图片 */
    UIImage *image = [self takeImage];
    UIImage *newImage = [self thumbnaiWithImage: image
                                                                       size: CGSizeMake(200.0, (200.0 /image.size.width) * image.size.height)];
    NSData *imageData = UIImagePNGRepresentation(newImage);
    
    [manager POST:urlStr parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {

        /** 随着时间的更改创建新的文件名 */
        NSDate *date = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *dataStr = [dateFormatter stringFromDate:date];
        NSString *fileName = [NSString stringWithFormat:@"%@%@.png",
                                         [CEEUserInfo sharedCEEUserInfo].userNmae,dataStr];
        
        [formData appendPartWithFileData: imageData
                                                     name: @"pic"
                                                fileName: fileName
                                              mimeType: @"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [MBProgressHUD showSuccess:@"分享成功!"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [MBProgressHUD showError:@"分享失败,请稍后再试!"];
        MYLog(@"分享失败:%s\n%@",__FUNCTION__,error);
    }];
    
    [self cancelSportBtn:nil];
}

/** 运动数据和图片分享到新浪微博 */
- (IBAction)sharedSportToSinaBtn:(id)sender
{
    if ([CEEUserInfo sharedCEEUserInfo].isSinaLogin)
    {
        [self saveSportDataToSina];
        [self cancelSportBtn:nil];
    }
    else
    {
        [MBProgressHUD showError:@"分享失败,请使用新浪登录..."];
    }
}
/** 分享数据到新浪微博 */
- (void) saveSportDataToSina
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *url = @"https://upload.api.weibo.com/2/statuses/upload.json";
    NSString *statusStr = [NSString stringWithFormat:@"本次运动了%.1lf米,共用时%1lf,消耗总热量%4lf卡",
                                      self.sumDistance,self.sumSportTime,self.sumHeat];
   
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"access_token"]  = [CEEUserInfo sharedCEEUserInfo].registerPassword;
    parameters[@"status"]             = statusStr;
    
    /** 发送参数 */
    [manager POST:url parameters:parameters constructingBodyWithBlock: ^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData: UIImagePNGRepresentation([self takeImage])
                                                     name: @"pic"
                                                fileName: @"Sport.png"
                                              mimeType: @"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {

        [MBProgressHUD showSuccess:@"发送成功"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [MBProgressHUD showError:@"发送失败,请稍后再试"];
        MYLog(@"分享失败:%@\n%s",error,__FUNCTION__);
    }];
}


/** 运动数据和图片分享到人人网 */
- (IBAction)sharedSportToRRBtn:(id)sender
{
    
}


/** 生成缩略图 */
- (UIImage *) thumbnaiWithImage:(UIImage *)image size:(CGSize )size
{
    UIImage *newImage = nil;
    if (image == nil)
    {
        newImage = image;
    }
    else
    {
        /** 开启绘制图片 */
        UIGraphicsBeginImageContext(size);
        /** 编辑缩略图大小 */
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        /** 将编辑得到了缩略图赋值 */
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        /** 结束绘制图片 */
        UIGraphicsEndImageContext();
    }
    return newImage;
}

#pragma mark - 更改运动模式类
- (void) setupRightBarItem
{
    self.rightItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"select1"]
                                                                                style: UIBarButtonItemStyleDone
                                                                              target: self
                                                                             action: @selector(changeSportStyle:)];
    self.navigationItem.rightBarButtonItem = self.rightItem;
}
- (void) changeSportStyle:(NSString *) style
{
    self.changeSportStyleView.hidden = !self.changeSportStyleView.hidden ? :NO;
    
    
    
    
}


- (IBAction)walkStyleBtn:(UIButton *)sender
{
    self.rightItem.image = [UIImage imageNamed:@"select4"];
    
    /** 给现在的运动模式赋值 */
    self.sportType = SportTypeFree;
}
- (IBAction)bikeStyleBtn:(id)sender
{
    self.rightItem.image = [UIImage imageNamed:@"select2"];
    
    self.sportType = SportTypeBike;
}
- (IBAction)skingStyleBtn:(id)sender
{
    self.rightItem.image = [UIImage imageNamed:@"select3"];
    
    self.sportType = SportTypeSking;
}
- (IBAction)runStyleBtn:(id)sender
{
    self.rightItem.image = [UIImage imageNamed:@"select1"];
    
    self.sportType = SportTypeRun;
}


@end
