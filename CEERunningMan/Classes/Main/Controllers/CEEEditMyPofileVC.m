//
//  CEEEditMyPofileVC.m
//  CEERunningMan
//
//  Created by 纵使寂寞开成海 on 16/1/6.
//  Copyright © 2016年 Cee. All rights reserved.
//

#import "CEEEditMyPofileVC.h"
#import "CEEXMPPTool.h"
#import "MBProgressHUD+KR.h"
#import "UIImageView+CEERoundImageView.h"

@interface CEEEditMyPofileVC()<UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UITextField *nikeNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;


@end

@implementation CEEEditMyPofileVC

- (void) viewDidLoad{
    [super viewDidLoad];

    if (self.myPofile.photo)
    {
        self.headImageView.image = [UIImage imageWithData:self.myPofile.photo];
    }
    else
    {
        self.headImageView.image = [UIImage imageNamed:@"icon1"];
    }
    
    self.nikeNameTextField.text = self.myPofile.nickname;
    self.emailTextField.text = self.myPofile.mailer;
    [self.headImageView setRoundLayer];
    
    /** 给头像添加允许用户点击,并增加手势和事件 */
    self.headImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeHeaderImage)];
    [self.headImageView addGestureRecognizer:tapGR];
}

- (IBAction)editButton:(id)sender {
    self.myPofile.nickname = self.nikeNameTextField.text;
    self.myPofile.mailer = self.emailTextField.text;

//    UIImage *image = [UIImage imageNamed:@"icon1"];
//    self.myPofile.photo = UIImagePNGRepresentation(image);
    
    /** 使用 xmppvCard 更新服务器数据 */
    [[CEEXMPPTool sharedCEEXMPPTool].xmppvCard updateMyvCardTemp:self.myPofile];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)returnButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) changeHeaderImage
{
    /** 创建底部提示 */
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle: @"选择图片"
                                                                                delegate: self
                                                                  cancelButtonTitle: @"取消"
                                                           destructiveButtonTitle: @"相机"
                                                                  otherButtonTitles: @"相册", nil];
    [sheet showInView:self.view];
}

#pragma  mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    /** 获取相册选择器 */
    UIImagePickerController *imagePC = [[UIImagePickerController alloc] init];
    imagePC.allowsEditing = YES;
    imagePC.delegate = self;
    
    if (buttonIndex == 2)
    {
        MYLog(@"取消");
    }
    else if (buttonIndex == 1)
    {
        MYLog(@"相册");
        
        imagePC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePC animated:YES completion:nil];
    }
    else
    {
        MYLog(@"相机");
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            imagePC.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePC animated:YES completion:nil];
        }
        else
        {
            [MBProgressHUD showError:@"该设备不支持相机"];
        }
        
    }
}
/** 通过 imagePickerController 的代理选择图片 */
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    self.headImageView.image = image;
    self.myPofile.photo = UIImagePNGRepresentation(image);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
