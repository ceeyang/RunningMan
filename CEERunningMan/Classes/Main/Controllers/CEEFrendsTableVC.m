//
//  CEEFrendsTableVC.m
//  CEERunningMan
//
//  Created by 纵使寂寞开成海 on 16/1/6.
//  Copyright © 2016年 Cee. All rights reserved.
//

#import "CEEFrendsTableVC.h"
#import "CEEFriendTableViewCell.h"
#import "CEEXMPPTool.h"
#import "CEEUserInfo.h"
#import "UIImageView+CEERoundImageView.h"
#import "CEEChatViewController.h"

/** 结果控制器代理 */
@interface CEEFrendsTableVC ()<NSFetchedResultsControllerDelegate>

/** 利用结果控制器代理处理数据,可以实现随时监听数据变更 */
@property (nonatomic, strong) NSFetchedResultsController *fetchController;

/** 好友数组: 方式一用 */
//@property (nonatomic, strong) NSArray *friends;

@end

@implementation CEEFrendsTableVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /** 加载好友列表: 方式一 */
    //[self loadFriendsOne];
    
    /** 加载好友列表: 方式二 */
    [self loadFriendsTwo];
}

//  方式一:
//- (void) loadFriendsOne
//{
//    /** 获取上下文对象 */
//    NSManagedObjectContext *context = [[CEEXMPPTool sharedCEEXMPPTool].xmppRosterStore mainThreadManagedObjectContext];
//    
//    /** 关联实体 */
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
//    
//    /** 设置过滤条件, predicate: 谓语,叙述语,断定,  此处可以当做过滤用... */
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",[CEEUserInfo sharedCEEUserInfo].jidStr];
//    
//    request.predicate = predicate;
//    
//    /** 排序 */
//    NSSortDescriptor *sortDes = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
//    request.sortDescriptors = @[sortDes];
//    
//    /** 获取数据 */
//    NSError *error = nil;
//    self.friends = [context executeFetchRequest:request error:&error];
//}


- (void) loadFriendsTwo
{
    /** 获取上下文对象 */
    NSManagedObjectContext *context = [[CEEXMPPTool sharedCEEXMPPTool].xmppRosterStore mainThreadManagedObjectContext];
    
    /** 关联实体 */
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    /** 设置过滤条件, predicate: 谓语,叙述语,断定,  此处可以当做过滤用... */
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",[CEEUserInfo sharedCEEUserInfo].jidStr];
    
    request.predicate = predicate;
    
    /** 排序 */
    NSSortDescriptor *sortDes = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sortDes];
    
    /** 获取数据 */
    self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
    self.fetchController.delegate = self;
    NSError *error = nil;
    [self.fetchController performFetch:&error];
    if (error)
    {
        MYLog(@"好友列表加载失败:%@",error);
    }
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (IBAction)returnButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //方式一:    return self.friends.count;
    return self.fetchController.fetchedObjects.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"friendCell";
    CEEFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    [cell.headerImageView setRoundLayer];

    /** 从上面得到的对象中解析出朋友数据 */
    //方式一:    XMPPUserCoreDataStorageObject *friend = self.friends[indexPath.row];
    XMPPUserCoreDataStorageObject *friend = self.fetchController.fetchedObjects[indexPath.row];
    
    NSData *ImageData = [[CEEXMPPTool sharedCEEXMPPTool].xmppvCardAvar photoDataForJID:friend.jid];
    
    if (ImageData)
    {
        cell.headerImageView.image = [UIImage imageWithData:ImageData];
    }
    else
    {
        cell.headerImageView.image = [UIImage imageNamed:@"icon1"];
    }
    
    cell.nikeNameLabel.text = friend.jidStr;
    switch ([friend.sectionNum intValue])
    {
        case 0:
            cell.onLineLabel.text = @"在线";
            break;
        case 1:
            cell.onLineLabel.text = @"离开";
            break;
        default:
            cell.onLineLabel.text = @"离线";
            break;
    }

    
    return cell;
}

/** 行高 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

/** 添加删除模式 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPUserCoreDataStorageObject *friend = self.fetchController.fetchedObjects[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        /** 删除模式下,删除好友 */
        [[CEEXMPPTool sharedCEEXMPPTool].xmppRoster removeUser:friend.jid];
    }
    else
    {
        
    }
}


/** 数据变化 */
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}

#pragma mark - 朋友界面与聊天界面之间跳转的正向传值
/** 跳转之前设置参数,设置调用哪个方法 */
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /** 用 id 类型取到目标 VC,判断是否是该类,并强制转换类型  */
    id desVC = segue.destinationViewController;
    if ([desVC isKindOfClass:[CEEChatViewController class]])
    {
        CEEChatViewController *des = (CEEChatViewController *)desVC;
        des.friendJid = sender;
    }
}

/** 选中某一行 就进行跳转 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /** 取到朋友所对应的行数 */
    XMPPUserCoreDataStorageObject *friendObject = self.fetchController.fetchedObjects[indexPath.row];
    /** 使用 storyboard 中的连线进行跳转 */
    [self performSegueWithIdentifier:@"chatSegue" sender:friendObject.jid];
}


@end
