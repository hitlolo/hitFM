//
//  FMPlaylist.h
//  hitFM
//
//  Created by Lolo on 15/9/22.
//  Copyright © 2015年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMSong;
@class FMChannelDetail;
@class AFHTTPRequestOperation;
@interface FMPlaylist : NSObject

@property (strong, nonatomic) FMSong* song;

- (void)getNewSongByNormalWithChannel:(FMChannelDetail*)channel
                          WithErrorhandler:(void (^)(AFHTTPRequestOperation *operation, NSError *error))erroHandler;

- (void)getNewSongByEndWithChannel:(FMChannelDetail *)channel
                       WithSong:(FMSong*)song
                       WithErrorhandler:(void (^)(AFHTTPRequestOperation *operation, NSError *error))erroHandler;

- (void)getNewSongBySkipWithChannel:(FMChannelDetail *)channel
                        WithSong:(FMSong*)song
                        WithPlaytime:(NSTimeInterval)playtime
                        WithErrorhandler:(void (^)(AFHTTPRequestOperation *operation, NSError *error))erroHandler;

- (void)getNewSongByHeartWithChannel:(FMChannelDetail *)channel
                         WithSong:(FMSong*)song
                         WithErrorhandler:(void (^)(AFHTTPRequestOperation *operation, NSError *error))erroHandler;

- (void)getNewSongByBanWithChannel:(FMChannelDetail *)channel
                       WithSong:(FMSong*)song
                       WithErrorhandler:(void (^)(AFHTTPRequestOperation *operation, NSError *error))erroHandler;
@end
