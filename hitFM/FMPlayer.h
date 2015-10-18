//
//  FMPlayer.h
//  hitFM
//
//  Created by Lolo on 15/9/22.
//  Copyright © 2015年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMSong.h"
#import "FMPlaylist.h"
#import "FMChannelDetail.h"
#import "DOUAudioStreamer.h"
#import "FMUser.h"


@interface FMPlayer : NSObject

@property (strong, nonatomic) FMUser                     *user;
@property (strong, nonatomic) FMPlaylist                 *playlist;
@property (strong, nonatomic) FMSong                     *currentSong;
@property (strong, nonatomic) FMChannelDetail            *currentChannel;
@property (unsafe_unretained, nonatomic)NSTimeInterval   currentTime;


//action
- (void)startAfterLauchWithErrorHandler:(void (^)(AFHTTPRequestOperation *operation, NSError *error))erroHandler;
- (void)retryConnection;
- (void)pause;
- (void)play;
- (void)banSong;
- (void)skipSong;
- (void)nextSong;
//state
- (BOOL)isPaused;
- (BOOL)isPlaying;
//user
- (void)archiverUser;
- (void)loadArchiveredUser;


@end
