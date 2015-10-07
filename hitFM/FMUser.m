//
//  FMUser.m
//  hitFM
//
//  Created by Lolo on 15/9/24.
//  Copyright © 2015年 Lolo. All rights reserved.
//

#import "FMUser.h"

@implementation FMUser


- (instancetype)initWithDictionary:(NSDictionary*)dic{
    self = [super init];
    if (self)
    {
        self.userID   = [dic valueForKey:@"id"];
        self.userName = [dic valueForKey:@"name"];
        self.userAvatarURL = [NSString stringWithFormat:@"http://img3.douban.com/icon/ul%@-1.jpg",self.userID ];
        NSDictionary *playrecord = [dic valueForKey:@"play_record"];
        self.playRecord = playrecord;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        
        self.userID     = [aDecoder decodeObjectForKey:@"userID"];
        self.userName   = [aDecoder decodeObjectForKey:@"userName"];
        self.playRecord = [aDecoder decodeObjectForKey:@"playrecord"];
        self.userAvatarURL = [aDecoder decodeObjectForKey:@"userAvatarURL"];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_userID     forKey:@"userID"];
    [aCoder encodeObject:_userName   forKey:@"userName"];
    [aCoder encodeObject:_playRecord forKey:@"playrecord"];
    [aCoder encodeObject:_userAvatarURL forKey:@"userAvatarURL"];
}





@end
