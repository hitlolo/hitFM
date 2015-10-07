//
//  FMPlaylist.m
//  hitFM
//
//  Created by Lolo on 15/9/22.
//  Copyright © 2015年 Lolo. All rights reserved.
//

#import "FMPlaylist.h"
#import "FMChannelDetail.h"
#import <AFNetworking/AFNetworking.h>
#import "FMConstants.h"
#import "FMSong.h"

@interface FMPlaylist(){
    
    NSString* base_url;
    AFHTTPRequestOperationManager *httpManager;
  

}
@end

@implementation FMPlaylist

- (instancetype)init{
    
    self = [super init];
    if (self) {
        base_url = URL_PLAYLIST;
        httpManager = [AFHTTPRequestOperationManager manager];
        _song = nil;
    }
    return self;
}



- (void)getNewSongByNormalWithChannel:(FMChannelDetail *)channel
                          WithErrorhandler:(void (^)(AFHTTPRequestOperation *operation, NSError *error))erroHandler{
    

    /**
     *  type n means get a song by normal action.
     */
    NSDictionary *parameters = @{
                                 @"from":@"mainsite",
                                 @"type":@"n",
                                 @"channel":channel.channelID
                                 };
    [httpManager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [httpManager GET:base_url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
  
        NSArray* songArr = [responseObject objectForKey:@"song"];
        self.song = [[FMSong alloc]initWithDictionary:songArr[0]];
    }
    failure:erroHandler];
}


- (void)getNewSongByEndWithChannel:(FMChannelDetail *)channel
                       WithSong:(FMSong *)song
                       WithErrorhandler:(void (^)(AFHTTPRequestOperation *operation, NSError *error))erroHandler{
    
    /**
     *  type e means get a song by normally end a song
     */
    NSDictionary *parameters = @{
                                 @"from":@"mainsite",
                                 @"type":@"n",
                                 @"channel":channel.channelID,
                                 @"sid":song.songID
                                 };
    [httpManager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [httpManager GET:base_url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSArray* songArr = [responseObject objectForKey:@"song"];
        self.song = [[FMSong alloc]initWithDictionary:songArr[0]];
    }
    failure:erroHandler];
}


- (void)getNewSongByBanWithChannel:(FMChannelDetail *)channel
                       WithSong:(FMSong *)song
                       WithErrorhandler:(void (^)(AFHTTPRequestOperation *operation, NSError *error))erroHandler{
    
    NSDictionary *parameters = @{
                                 @"from":@"mainsite",
                                 @"type":@"b",
                                 @"channel":channel.channelID,
                                 @"sid":song.songID
                                 };

    [httpManager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [httpManager GET:base_url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
        
         NSArray* songArr = [responseObject objectForKey:@"song"];
         self.song = [[FMSong alloc]initWithDictionary:songArr[0]];
     }
    failure:erroHandler];
    
}

- (void)getNewSongBySkipWithChannel:(FMChannelDetail *)channel
                        WithSong:(FMSong *)song
                        WithPlaytime:(NSTimeInterval)playtime
                        WithErrorhandler:(void (^)(AFHTTPRequestOperation *operation, NSError *error))erroHandler{
    
    NSDictionary *parameters = @{
                                 @"from":@"mainsite",
                                 @"type":@"s",
                                 @"channel":channel.channelID,
                                 @"sid":song.songID,
                                 @"pt":[NSString stringWithFormat:@"%f",playtime]
                                 };
    
    [httpManager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [httpManager GET:base_url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray* songArr = [responseObject objectForKey:@"song"];
         self.song = [[FMSong alloc]initWithDictionary:songArr[0]];
     }
    failure:erroHandler];
}




@end
