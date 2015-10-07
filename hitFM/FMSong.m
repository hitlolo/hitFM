//
//  FMSong.m
//  hitFM
//
//  Created by Lolo on 15/9/14.
//  Copyright (c) 2015年 Lolo. All rights reserved.
//

#import "FMSong.h"

@implementation FMSong


-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init])
    {
        self.songArtist   = [dictionary objectForKey:@"artist"];
        self.songTitle    = [dictionary objectForKey:@"title"];
        self.songUrl      = [dictionary objectForKey:@"url"];
        self.songAlbum    = [dictionary objectForKey:@"picture"];
        self.songInterval = [dictionary objectForKey:@"length"];
        self.songLiked    = [dictionary objectForKey:@"like"];
        self.songID       = [dictionary objectForKey:@"sid"];
        self.songSSID     = [dictionary objectForKey:@"ssid"];
    }
    return self;
}


- (NSURL *)audioFileURL{
    NSURL* songURL = [NSURL URLWithString:self.songUrl];
    return songURL;
}

@end
