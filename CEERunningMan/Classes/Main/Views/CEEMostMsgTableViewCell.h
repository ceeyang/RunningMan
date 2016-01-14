//
//  CEEMostMsgTableViewCell.h
//  CEERunningMan
//
//  Created by 纵使寂寞开成海 on 16/1/8.
//  Copyright © 2016年 Cee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CEEMostMsgTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headerImage;
@property (weak, nonatomic) IBOutlet UILabel *nikeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMsgLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
