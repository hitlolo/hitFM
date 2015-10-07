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

@property (strong, nonatomic) FMUser                    *user;
@property (strong, nonatomic) FMPlaylist                *playlist;


@property (strong, nonatomic) FMSong                    *currentSong;
@property (strong, nonatomic) FMChannelDetail           *currentChannel;

@property (strong, nonatomic) DOUAudioStreamer          *streamer;

@property (unsafe_unretained, nonatomic)NSTimeInterval   currentTime;

@property (unsafe_unretained, readonly, getter = isPaused)BOOL isPaused;

@property (copy, nonatomic) void (^networkFailHandler)(AFHTTPRequestOperation*,NSError*);

- (void)startAfterLauchWithErrorHandler:(void (^)(AFHTTPRequestOperation *operation, NSError *error))erroHandler;
- (void)retryConnection;
- (void)pause;
- (void)play;
- (void)banSong;
- (void)skipSong;
- (void)nextSong;
- (void)archiverUser;
- (void)loadArchiveredUser;
- (BOOL)isPlaying;

@end
