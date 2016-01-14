//
//  UIImageView+CEERoundImageView.m
//  CEERunningMan
//
//  Created by 纵使寂寞开成海 on 16/1/5.
//  Copyright © 2016年 Cee. All rights reserved.
//

#import "UIImageView+CEERoundImageView.h"

@implementation UIImageView (CEERoundImageView)

/** 圆头像的实现 */
- (void) setRoundLayer
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = self.bounds.size.width * 0.5;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
}

@end
