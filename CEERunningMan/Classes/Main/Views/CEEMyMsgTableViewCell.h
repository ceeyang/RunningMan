//
//  CEEMyMsgTableViewCell.h
//  CEERunningMan
//
//  Created by 纵使寂寞开成海 on 16/1/7.
//  Copyright © 2016年 Cee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CEEMyMsgTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UIImageView *leftHeaderImage;
@property (weak, nonatomic) IBOutlet UILabel *leftNikeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftMsgLabel;
@property (weak, nonatomic) IBOutlet UIImageView *leftMsgImage;

@property (weak, nonatomic) IBOutlet UIImageView *rightHeaderImage;
@property (weak, nonatomic) IBOutlet UILabel *rightNikeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightMsgLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rightMsgImage;

@end
