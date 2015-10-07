//
//  FMChannelDetail.m
//  hitFM
//
//  Created by Lolo on 15/9/22.
//  Copyright © 2015年 Lolo. All rights reserved.
//

#import "FMChannelDetail.h"

@implementation FMChannelDetail


- (instancetype)init{
    
    self = [super init];
    if (self) {
        self.channelID = @"0";
        self.channelName = @"公共兆赫";
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary*)dic{
    
    self = [super init];
    if (self) {
        self.channelID     = [dic objectForKey:@"id"];
        self.channelName   = [dic objectForKey:@"name"];
        self.channelInfo   = [dic objectForKey:@"intro"];
        self.channelBanner = [dic objectForKey:@"banner"];
        self.channelCover  = [dic objectForKey:@"cover"];
    }
    return self;
}

/**
 *  -3 是红心兆赫的默认id
 *
 *  @return 当前频道是否是红心频道
 */
- (BOOL)isRedheartChannel{
    int new = self.channelID.intValue;
    int old = -3;
    return new==old;
}
@end



//"channels": [
//             {
//                 "banner": "http://img3.douban.com/img/fmadmin/chlBanner/27675.jpg",
//                 "cover": "http://img3.douban.com/img/fmadmin/icon/27675.jpg",
//                 "creator": {
//                     "id": 48254923,
//                     "name": "Bin's",
//                     "url": "http://www.douban.com/people/48254923/"
//                 },
//                 "hot_songs": [
//                               "\u539f\u8c05",
//                               "Better Me (\u56fd\u8bed)",
//                               "\u9b54\u9b3c\u4e2d\u7684\u5929\u4f7f"
//                               ],
//                 "id": 1000382,
//                 "intro": "\u7ec6\u542c\u7740\u522b\u4eba\u7684\u6b4c\u58f0\uff0c\u8bc9\u8bf4\u7740\u81ea\u5df1\u7684\u6545\u4e8b\u3002",
//                 "name": "\u4f60\u7684\u6b4c\u8bcd\u6211\u7684\u6545\u4e8b",
//                 "song_num": 384
//             }
//             ],
//"total": 23743
//},
//"status": true
//}