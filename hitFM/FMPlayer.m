//
//  FMPlayer.m
//  hitFM
//
//  Created by Lolo on 15/9/22.
//  Copyright © 2015年 Lolo. All rights reserved.
//

#import "FMPlayer.h"

//#import "DOUAudioVisualizer.h"



static void *kSongKVOKey           = &kSongKVOKey;
static void *kStatusKVOKey         = &kStatusKVOKey;
static void *kDurationKVOKey       = &kDurationKVOKey;
static void *kBufferingRatioKVOKey = &kBufferingRatioKVOKey;


@interface FMPlayer()

@property (strong, nonatomic) DOUAudioStreamer *streamer;
@property (copy, nonatomic) void (^networkFailHandler)(AFHTTPRequestOperation*,NSError*);

@end


@implementation FMPlayer



#pragma mark- DOU streamer start playing

- (void)startAfterLauchWithErrorHandler:(void (^)(AFHTTPRequestOperation *operation, NSError *error))erroHandler{
    
    [self loadArchiveredUser];
    self.networkFailHandler = erroHandler;
    // 频道初始化为id=0 公共频道
    self.currentChannel = [[FMChannelDetail alloc]init];
    self.playlist = [[FMPlaylist alloc]init];
    [self.playlist getNewSongByNormalWithChannel:self.currentChannel WithErrorhandler:erroHandler];
    [self.playlist addObserver:self forKeyPath:@"song" options:NSKeyValueObservingOptionNew context:kSongKVOKey];
}

- (void)retryConnection{
    [self.playlist getNewSongByNormalWithChannel:self.currentChannel WithErrorhandler:self.networkFailHandler];
}

#pragma mark- DOU streamer

- (NSTimeInterval)currentTime{
    if (_streamer == nil) {
        return 0.0f;
    }
    else
        return _streamer.currentTime;
}


- (BOOL)isPaused{
    if (_streamer == nil) {
        return YES;
    }
    else
        return ([_streamer status] == DOUAudioStreamerPaused);
    
}

- (BOOL)isPlaying{
    if(_streamer != nil && [ _streamer status] == DOUAudioStreamerPlaying){
        return YES;
    }
    else
        return NO;
}




- (void)resetStreamer
{
    if (_streamer != nil) {
        [_streamer pause];
        [_streamer removeObserver:self forKeyPath:@"status"];
        _streamer = nil;
    }
}



- (void)setupStreamerAndPlay{
    if (_streamer != nil) {
        [self resetStreamer];
    }
    _streamer = [DOUAudioStreamer streamerWithAudioFile:self.currentSong];
    [_streamer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:kStatusKVOKey];
    //NSLog(@"songid:%@,songSSID:%@",self.currentSong.songID,self.currentSong.songSSID);
    [_streamer play];
}

- (void)pause{
    [_streamer pause];
}

- (void)play{
    [_streamer play];
}

- (void)banSong{
    
    if (self.currentSong == nil) {
        [self retryConnection];
    }
    else{
        [self.playlist getNewSongByBanWithChannel:self.currentChannel WithSong:self.currentSong WithErrorhandler:self.networkFailHandler];
    }
    
}

- (void)skipSong{
    if (self.currentSong == nil) {
        [self retryConnection];
    }
    else{
        [self.playlist getNewSongBySkipWithChannel:self.currentChannel WithSong:self.currentSong WithPlaytime:self.currentTime WithErrorhandler:self.networkFailHandler];
    }
}

- (void)nextSong{
    if (self.currentSong == nil) {
        [self retryConnection];
    }
    else{
        [self.playlist getNewSongByEndWithChannel:self.currentChannel WithSong:self.currentSong WithErrorhandler:self.networkFailHandler];
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass:[FMPlaylist class]] && context == kSongKVOKey) {
        self.currentSong = [change objectForKey:@"new"];
        [self setupStreamerAndPlay];
    }
    
    if (context == kStatusKVOKey) {
        [self performSelector:@selector(updateStreamerStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    //    else if (context == kDurationKVOKey) {
    //
    //    }
    //    else if (context == kBufferingRatioKVOKey) {
    //        NSLog(@"buffering");
    //    }
    
}


- (void)updateStreamerStatus{
    
    switch ([_streamer status]) {
        case DOUAudioStreamerPlaying:
            NSLog(@"playinh");
            break;
            
        case DOUAudioStreamerPaused:
            NSLog(@"paused");
            break;
            
        case DOUAudioStreamerIdle:
            NSLog(@"idle");
            break;
            
        case DOUAudioStreamerFinished:
            NSLog(@"finished");
            [self nextSong];
            break;
            
        case DOUAudioStreamerBuffering:
            NSLog(@"buffering");
            break;
            
        case DOUAudioStreamerError:
            NSLog(@"error");
            break;
    }
    
}


#pragma mark - user

- (void)archiverUser{
    
    if (_user == nil) {
        return;
    }
    NSMutableData *data = [[NSMutableData alloc]init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:self forKey:@"userInfo"];
    [archiver finishEncoding];
    NSString *homePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *appdelegatePath = [homePath stringByAppendingPathComponent:@"appdelegate.archiver"];
    //添加储存的文件名
    if ([data writeToFile:appdelegatePath atomically:YES]) {
        NSLog(@"UesrInfo存储成功");
    }
}


- (void)loadArchiveredUser{
    
    NSString *homePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *appdelegatePath = [homePath stringByAppendingPathComponent:@"appdelegate.archiver"];
    //添加储存的文件名
    NSData *data = [[NSData alloc]initWithContentsOfFile:appdelegatePath];
    if ([data length] == 0) {
        NSLog(@"data lenght:0");
        return;
    }
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    self.user = [unarchiver decodeObjectForKey:@"userInfo"];
    if (self.user ==  nil) {
        NSLog(@"no user");
    }
    [unarchiver finishDecoding];
    
}

@end
