//
//  CEESportRecordCell.h
//  CEERunningMan
//
//  Created by 纵使寂寞开成海 on 16/1/13.
//  Copyright © 2016年 Cee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CEESportRecord.h"

@interface CEESportRecordCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *sportRecordType;
@property (weak, nonatomic) IBOutlet UILabel *sportRecordDate;
@property (weak, nonatomic) IBOutlet UILabel *sprotRecordTime;
@property (weak, nonatomic) IBOutlet UILabel *sportRecordDistance;
@property (weak, nonatomic) IBOutlet UILabel *sportRecordHeat;

- (void) setSportData:(CEESportRecord *) sportData;

@end
