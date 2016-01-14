//
//  CEESportRecord.h
//  CEERunningMan
//
//  Created by 纵使寂寞开成海 on 16/1/13.
//  Copyright © 2016年 Cee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sportType.h"

@interface CEESportRecord : NSObject

@property (nonatomic,assign) enum SportType sportType;
@property (nonatomic,copy)  NSString * sportTimeLen;
@property (copy, nonatomic) NSString *sportDistance;
@property (copy, nonatomic) NSString *sportHeat;
@property (nonatomic,copy) NSString *username;
@property (nonatomic,copy) NSString *sportStartTime;

@end
