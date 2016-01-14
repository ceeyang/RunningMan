//
//  CEEMyCircleCell.m
//  CEERunningMan
//
//  Created by 纵使寂寞开成海 on 16/1/13.
//  Copyright © 2016年 Cee. All rights reserved.
//

#import "CEEMyCircleCell.h"
#import "CEEXMPPTool.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD+KR.h"

@implementation CEEMyCircleCell

- (void) setDataWithTopic:(CEESportTopic *)topic
{
    self.topicLabel.text = topic.content;
    if (topic.imageUrl)
    {
        NSString *imageUrl = [NSString stringWithFormat:@"http://%@:8080/%@",CEEXMPPHOSTNAME,topic.imageUrl];
        MYLog(@"图片地址:%@",imageUrl);
        
        [self.myTopicView setImageWithURL: [NSURL URLWithString:imageUrl]
                                     placeholderImage: [UIImage imageNamed:@"mapplaceholder"]
                                                completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            //
        }];
        
        self.topicLabel.text = topic.content;
        self.nikeNameLabel.text = topic.username;
        
        [self.addConcatBtn addTarget:self action:@selector(addFriend) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void) addFriend
{
    [MBProgressHUD showSuccess:@"发送请求成功,等待用户同意..."];
    if ([self.delegate respondsToSelector:@selector(addConcatp:)]) {
        [self.delegate addConcatp:self.nikeNameLabel.text];
    }
}

@end
