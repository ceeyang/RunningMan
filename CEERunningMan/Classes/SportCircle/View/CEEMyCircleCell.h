//
//  CEEMyCircleCell.h
//  CEERunningMan
//
//  Created by 纵使寂寞开成海 on 16/1/13.
//  Copyright © 2016年 Cee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CEESportTopic.h"

@protocol CEEMyCircleCellProtocol <NSObject>

- (void) addConcatp: (NSString *) jidStr;

@end


@interface CEEMyCircleCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nikeNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *guanZhuLabel;
@property (weak, nonatomic) IBOutlet UILabel *topicLabel;

@property (weak, nonatomic) IBOutlet UIImageView *myTopicView;

@property (weak, nonatomic) IBOutlet UIButton *addConcatBtn;

@property (strong, nonatomic) id<CEEMyCircleCellProtocol> delegate;

- (void) setDataWithTopic:(CEESportTopic *) topic;

@end
