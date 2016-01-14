//
//  CEESportCircleVC.m
//  CEERunningMan
//
//  Created by 纵使寂寞开成海 on 16/1/13.
//  Copyright © 2016年 Cee. All rights reserved.
//

#import "CEESportCircleVC.h"
#import "CEEMyCircleCell.h"
#import "UIImageView+CEERoundImageView.h"
#import "AFNetworking.h"
#import "CEEUserInfo.h"
#import "CEEXMPPTool.h"
#import "CEESportTopic.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD+KR.h"
#import "XMPPJID.h"


@interface CEESportCircleVC()<CEEMyCircleCellProtocol>
@property (nonatomic, strong) NSMutableArray *topicArray;
@end

@implementation CEESportCircleVC

- (void) viewDidLoad
{
    /** 自动适应布局 */
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 125.0;
    self.topicArray = [NSMutableArray array];

    [self loadData];
}

- (void) loadData
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *url = [NSString stringWithFormat:@"http://%@:8080/allRunServerNew/queryTopic.jsp",
                                                                        CEEXMPPHOSTNAME];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"username"] = [CEEUserInfo sharedCEEUserInfo].userNmae;
    parameters[@"md5password"] = [CEEUserInfo sharedCEEUserInfo].userPassword;
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        MYLog(@"___________%@",responseObject[@"data"]);
        NSArray *dataArr = responseObject[@"data"];
        for (int i = 0; i < dataArr.count; i++)
        {
            CEESportTopic *topic = [[CEESportTopic alloc] init];
            [topic setValuesForKeysWithDictionary:dataArr[i]];
            [self.topicArray addObject:topic];
        }
        
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MYLog(@"error_________%@",error);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.topicArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CEEMyCircleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mytopiccell"];
    cell.delegate = self;
    cell.headImageView.image = [UIImage imageNamed:@"placehoder"];
    [cell.headImageView setRoundLayer];
    [cell setDataWithTopic:self.topicArray[indexPath.row]];
    cell.addConcatBtn.tag = indexPath.row;
    
    return cell;
}




- (IBAction)backBtn:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
