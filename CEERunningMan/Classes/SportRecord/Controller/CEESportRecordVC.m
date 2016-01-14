//
//  CEESportRecordVC.m
//  CEERunningMan
//
//  Created by 纵使寂寞开成海 on 16/1/13.
//  Copyright © 2016年 Cee. All rights reserved.
//

#import "CEESportRecordVC.h"
#import "CEESportRecordCell.h"
#import "AFNetworking.h"
#import "CEEUserInfo.h"
#import "sportType.h"


@interface CEESportRecordVC()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *preBtn;
- (IBAction)backBtn:(id)sender;
- (IBAction)choseSportModel:(UIButton *)sender;
@property (nonatomic,weak) UIButton *selectedBtn;
@property (nonatomic,strong) NSMutableArray * sportDatas;
@end


@implementation CEESportRecordVC

- (void)viewDidLoad
{
    self.selectedBtn = self.preBtn;
    self.selectedBtn.selected = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.sportDatas = [NSMutableArray array];
    
    /** 默认加载跑步 */
    [self  loadFromWebServerWithType:SportTypeRun];
    
}

/* 从服务器上获取跑步数据 */
- (void)  loadFromWebServerWithType:(enum SportType) type
{
    NSString *url = [NSString stringWithFormat:@"http://%@:8080/allRunServerNew/queryUserDataByType.jsp",
                                                                        CEEXMPPHOSTNAME];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    CEEUserInfo *userInfo = [CEEUserInfo sharedCEEUserInfo];
    parameters[@"username"]       = userInfo.userNmae;
    parameters[@"md5password"] = userInfo.userPassword;
    parameters[@"sportType"]       = @(type);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
    
        MYLog(@"%@",responseObject[@"sportData"]);
        NSArray *array = responseObject[@"sportData"];
        [self.sportDatas removeAllObjects];
        for (int i = 0; i < array.count; i++)
        {
            CEESportRecord *rec = [[CEESportRecord alloc] init];
            [rec setValuesForKeysWithDictionary:array[i]];
            [self.sportDatas addObject:rec];
        }
        [self.tableView reloadData];
    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MYLog(@"运动记录加载失败%@",error);
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sportDatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CEESportRecordCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"sportCell" forIndexPath:indexPath];
    CEESportRecord *rec = self.sportDatas[indexPath.row];
    
    [cell setSportData:rec];
    
    return cell;
}

- (IBAction)backBtn:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)choseSportModel:(UIButton *)sender
{
    if (sender == self.selectedBtn)
    {
        return;
    }
    
    self.preBtn = self.selectedBtn;
    self.selectedBtn = sender;
    self.selectedBtn.selected = YES;
    self.preBtn.selected = NO;
    
    [self loadFromWebServerWithType:sender.tag];
}
@end
