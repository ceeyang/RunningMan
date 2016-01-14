//
//  CEEChatViewController.m
//  CEERunningMan
//
//  Created by 纵使寂寞开成海 on 16/1/7.
//  Copyright © 2016年 Cee. All rights reserved.
//

#import "CEEChatViewController.h"
#import "CEEXMPPTool.h"
#import "CEEUserInfo.h"
#import "CEEMyMsgTableViewCell.h"
#import "UIImageView+CEERoundImageView.h"
#import "XMPPvCardAvatarModule.h"

@interface CEEChatViewController ()<UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightForBottom;
@property (weak, nonatomic) IBOutlet UITextField *sendTextField;
/** 创建一个结果集控制器 */
@property (nonatomic, strong) NSFetchedResultsController *fetchController;

@property (strong,nonatomic) UIImage *meImage;
@property (strong,nonatomic) UIImage *friendImage;

@end

@implementation CEEChatViewController

/** 加载聊天记录的方法 */
- (void) loadMsg
{
    /** 获取上下文对象 */
    NSManagedObjectContext *context = [[CEEXMPPTool sharedCEEXMPPTool].xmppMsgArchStorage
                                                              mainThreadManagedObjectContext];
    /** 关联实体 */
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    /** 设置条件 */
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ and bareJidStr = %@",
                                           [CEEUserInfo sharedCEEUserInfo].jidStr, self.friendJid.bare];
    
    request.predicate = predicate;
    
    /** 设置聊天窗口的排序,以时间为准 */
    NSSortDescriptor *sortDes = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[sortDes];
    
    /** 获取数据 */
    self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest: request
                                                                                         managedObjectContext: context
                                                                                             sectionNameKeyPath: nil
                                                                                                           cacheName: nil];
    
    self.fetchController.delegate = self;
    
    NSError *error = nil;
    [self.fetchController performFetch:&error];
    if (error)
    {
        MYLog(@"聊天记录加载失败:%@",error);
    }
}

#pragma mark - 键盘弹起和隐藏的相关方法
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /** 监听当键盘弹起和隐藏时, 并创建一个事件 */
    [[NSNotificationCenter defaultCenter] addObserver: self
                                                                     selector: @selector(openKeyboard:)
                                                                        name: UIKeyboardWillShowNotification
                                                                        object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                                                     selector: @selector(clostKeyboard:)
                                                                         name: UIKeyboardWillHideNotification
                                                                        object: nil];
    
}

- (void) openKeyboard:(NSNotification *) notification
{
    /** 利用通知消息,得到键盘弹起时的高度 */
    CGRect keyboardFrame = [notification.userInfo [
                                            UIKeyboardFrameEndUserInfoKey]
                                            CGRectValue];
    /** 动画时间 */
    NSTimeInterval durations = [notification.userInfo
                                               [UIKeyboardAnimationDurationUserInfoKey]
                                               doubleValue];
    /** 更多选项,属性 */
    UIViewAnimationOptions options = [notification.userInfo [
                                                           UIKeyboardAnimationCurveUserInfoKey]
                                                           intValue];
    
    /** 设置输入框高度 */
    self.heightForBottom.constant = keyboardFrame.size.height;
    [UIImageView animateWithDuration:durations delay:0 options:options animations:^{
        [self.tableView layoutIfNeeded];
    } completion:^(BOOL finished) {
        //
    }];
    
    [self scrollTable];
}

- (void) clostKeyboard: (NSNotification *) notification
{
    /** 动画时间 */
    NSTimeInterval durations = [notification.userInfo [UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    /** <#注释#> */
    UIViewAnimationOptions options = [notification.userInfo [UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    /** 设置键盘高度 */
    self.heightForBottom.constant = 0;
    [UIImageView animateWithDuration: durations delay: 0 options: options animations: ^{
        [self.tableView layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
     /** 移除通知 */
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                                              name: UIKeyboardWillShowNotification
                                                                             object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                                              name: UIKeyboardWillHideNotification
                                                                             object: nil];
}

#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"好友聊天";
    
    /** 设置每行的高度 */
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 60;
    
    /** 加载聊天信息 */
    [self loadMsg];
    
    /** 设置我的头像 */
    NSData *data = [CEEXMPPTool sharedCEEXMPPTool].xmppvCard.myvCardTemp.photo;
    if (data == nil)
    {
        self.meImage = [UIImage imageNamed:@"人人"];
    }
    else
    {
        self.meImage = [UIImage imageWithData:data];
    }
    
    /** 设置朋友的头像 */
    NSData *friendData = [[CEEXMPPTool sharedCEEXMPPTool].xmppvCardAvar photoDataForJID:self.friendJid];
    if (friendData == nil)
    {
        self.friendImage = [UIImage imageNamed:@"人人"];
    }
    else
    {
        self.friendImage = [UIImage imageWithData:friendData];
    }
    
}
#pragma mark - 文本消息发送
/** UITextField对象的事件 */
- (IBAction)sendMsgMethod:(id)sender {
    NSString *msgText = self.sendTextField.text;
    /** 包装一个消息对象 */
    XMPPMessage *msg = [XMPPMessage messageWithType: @"chat" to:self.friendJid];
    /** 自定义简单的数据标准 */
    NSString *dataStr = [NSString stringWithFormat:@"text:%@",msgText];
    
    [msg addBody:dataStr];
    /** 发送消息 */
    [[CEEXMPPTool sharedCEEXMPPTool].xmppStream sendElement:msg];
    
    /** 发送完消息后,清空文本框 */
    self.sendTextField.text = nil;
    
    [self.tableView reloadData];
}

/** 结果集发生变化, */
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
    [self scrollTable];
}

/** 滚到表格最后一行 */
- (void) scrollTable
{
    NSInteger index = self.fetchController.fetchedObjects.count - 1;
    
    if (index < 0)
    {
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - 图片选择与发送
- (IBAction)ImageButton:(id)sender
{
    UIImagePickerController *imagePC = [[UIImagePickerController alloc] init];
    imagePC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePC.allowsEditing = YES;
    imagePC.delegate = self;
    [self presentViewController:imagePC animated:YES completion:nil];
}

/** 通过 imagePickerController 的代理选择图片 */
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    /** 获取图片 */
    UIImage *image0 = info[UIImagePickerControllerEditedImage];
    /** 对图片经行缩放 */
    UIImage *image1 = [self thumbnaiWithImage:image0 size:CGSizeMake(100, 100)];
//    self.headImageView.image = image;
//    self.myPofile.photo = UIImagePNGRepresentation(image);
    NSData *data = UIImageJPEGRepresentation(image1, 0.05);
    
    [self dismissViewControllerAnimated:YES completion:nil];
    /** 发送图片 */
    [self sendImageMeshod:data];
    
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
/** 发送图片信息 */
- (void) sendImageMeshod: (NSData *)data
{
    NSString *base64Str = [data base64EncodedStringWithOptions:0];
    /** 组装消息 */
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    NSString *dataStr = [NSString stringWithFormat:@"image:%@",base64Str];
    [msg addBody:dataStr];
    
    [[CEEXMPPTool sharedCEEXMPPTool].xmppStream sendElement:msg];
}


#pragma mark - UITableViewDelegate/Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.fetchController.fetchedObjects.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CEEMyMsgTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"msgCell" forIndexPath:indexPath];
    /** 设置头像圆边 */
    [cell.leftHeaderImage setRoundLayer];
    [cell.rightHeaderImage setRoundLayer];

    XMPPMessageArchiving_Message_CoreDataObject *msgObject = self.fetchController.fetchedObjects[indexPath.row];
    
    /** 设置聊天时间 */
    NSDate *msgTimeDate                    = msgObject.timestamp;
    NSDateFormatter *dateFormatter    = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat              = @"HH:mm:ss";
    NSString *msgTimeStr                    = [dateFormatter stringFromDate:msgTimeDate];
    cell.timeLabel.text                           = msgTimeStr;
    
    
    /** 文字类 */
    if ([msgObject.body hasPrefix:@"text:"])
    {
        /** 接收消息 */
        if ( !msgObject.isOutgoing)
        {
            /** 隐藏右边的控件 */
            cell.rightMsgLabel.hidden          = YES;
            cell.rightMsgImage.hidden         = YES;
            cell.rightHeaderImage.hidden     = YES;
            cell.rightNikeNameLabel.hidden = YES;
            /** 设置左边视图头像和昵称 */
            cell.leftHeaderImage.image         = self.friendImage;
            cell.leftNikeNameLabel.text         = self.friendJid.user;
            /** 设置聊天类容 */
//            NSString *base64Str = [msgObject.body substringFromIndex:5 ];
//            NSData *base64Data = [[NSData alloc] initWithBase64EncodedString:base64Str options:0];
//            cell.leftMsgLabel.text = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
            cell.leftMsgLabel.text     = [msgObject.body substringFromIndex:5];
            cell.leftMsgImage.image = nil;
            
            return cell;
        }
        else /** 发送消息 */
        {
            /** 隐藏左边控件 */
            cell.leftNikeNameLabel.hidden  = YES;
            cell.leftHeaderImage.hidden      = YES;
            cell.leftMsgImage.hidden          = YES;
            cell.leftMsgLabel.hidden           = YES;
            /** 设置右边视图的头像和昵称 */
            cell.rightHeaderImage.image    = self.meImage;
            cell.rightNikeNameLabel.text    = [CEEUserInfo sharedCEEUserInfo].userNmae;
            /** 设置聊天内容 */
//            NSString *base64Str = [msgObject.body substringFromIndex:5];
//            NSData * base64Data = [[NSData alloc]initWithBase64EncodedString:base64Str options:0];
//            cell.rightMsgLabel.text = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
            cell.rightMsgLabel.text = [msgObject.body substringFromIndex:5];
            cell.rightMsgImage.image = nil;
            
            return cell;
        }
    }
    else if ([msgObject.body hasPrefix:@"image:"])
    {
        NSString *base64Str = [msgObject.body substringFromIndex:6];
        NSData *imageData = [[NSData alloc] initWithBase64EncodedString:base64Str options:0];
        
        if ( !msgObject.isOutgoing)
        {
            /** 隐藏右边的控件 */
            cell.rightMsgLabel.hidden          = YES;
            cell.rightMsgImage.hidden         = YES;
            cell.rightHeaderImage.hidden     = YES;
            cell.rightNikeNameLabel.hidden = YES;
            /** 设置左边视图头像和昵称 */
            cell.leftHeaderImage.image         = self.friendImage;
            cell.leftNikeNameLabel.text        = self.friendJid.user;
            /** 设置聊天类容 */
            cell.leftMsgImage.image = [UIImage imageWithData:imageData];
            cell.leftMsgLabel.text = nil;
            /** 设置聊天时间 */
            NSDateFormatter *formater = [NSDateFormatter new];
            formater.dateFormat = @"yyy-MM-dd";
            cell.timeLabel.text = [formater stringFromDate:msgObject.timestamp];
            
            return cell;
        }
        else
        {
            /** 隐藏左边控件 */
            cell.leftNikeNameLabel.hidden = YES;
            cell.leftHeaderImage.hidden     = YES;
            cell.leftMsgImage.hidden          = YES;
            cell.leftMsgLabel.hidden           = YES;
            /** 设置右边视图的头像和昵称 */
            cell.rightHeaderImage.image = self.meImage;
            cell.rightNikeNameLabel.text = [CEEUserInfo sharedCEEUserInfo].userNmae;
            /** 设置聊天内容 */
            cell.rightMsgLabel.text = nil;
            cell.rightMsgImage.image = [UIImage imageWithData:imageData];
            /** 设置聊天时间 */
            NSDateFormatter *formater = [NSDateFormatter new];
            formater.dateFormat = @"yyy-MM-dd";
            cell.timeLabel.text = [formater stringFromDate:msgObject.timestamp];
            
            return cell;
        }
    }
    else
    {
        return cell;
    }
}



@end
