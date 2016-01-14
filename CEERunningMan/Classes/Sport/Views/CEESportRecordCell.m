//
//  CEESportRecordCell.m
//  CEERunningMan
//
//  Created by 纵使寂寞开成海 on 16/1/13.
//  Copyright © 2016年 Cee. All rights reserved.
//

#import "CEESportRecordCell.h"

@implementation CEESportRecordCell


/** 给 cell 赋值的方法 */
- (void)setSportData:(CEESportRecord *)sportData
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[sportData.sportStartTime doubleValue]];
    NSDateFormatter *format =[[NSDateFormatter alloc]init];
    format.dateFormat = @"yyyy-MM-dd";
    NSString *dateStr = [format stringFromDate:date];
    
    self.sportRecordDate.text        = dateStr;
    self.sportRecordDistance.text = [[sportData.sportDistance substringToIndex:
                                                      [sportData.sportDistance rangeOfString:@"."].location]
                                                      stringByAppendingString:@"米"];
    if ([sportData.sportHeat isEqualToString:@"0.0"])
    {
        self.sportRecordHeat.text = @"0K卡";
    }
    else
    {
        self.sportRecordHeat.text =  [[sportData.sportHeat substringToIndex:
                                                    [sportData.sportHeat rangeOfString:@"."].location+4 ]
                                                     stringByAppendingString:@"K卡"];
    }
    
    self.sportRecordType.image = [UIImage imageNamed:[self getImageNameByModel:sportData.sportType]];
    self.sprotRecordTime.text    = [[sportData.sportTimeLen substringToIndex:
                                                   [sportData.sportTimeLen rangeOfString:@"."].location ]
                                                   stringByAppendingString:@"秒"];
}

/**  根据枚举值获得 相应的图片名  */
- (NSString *) getImageNameByModel:(enum SportType) type
{
    NSString *imageName = nil;
    switch(type)
    {
        case SportTypeBike:
            imageName = @"cmbike";
            break;
        case SportTypeRun:
            imageName = @"cmwalk";
            break;
        case SportTypeFree:
            imageName = @"cmfree";
            break;
        case SportTypeSking:
            imageName = @"cmskiing";
            break;
    }
    return  imageName;
}


@end
