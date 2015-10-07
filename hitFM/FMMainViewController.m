//
//  FMMainViewController.m
//  hitFM
//
//  Created by Lolo on 15/9/12.
//  Copyright © 2015年 Lolo. All rights reserved.
//

#import "FMMainViewController.h"
#import "SWRevealViewController.h"
#import <UIImageView+AFNetworking.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AFNetworking/AFNetworking.h>
#import "DOUAudioVisualizer.h"
#import "FMPlayer.h"
#import "RTSpinKitView.h"


static void *SongKeyKVO = &SongKeyKVO;
static void *ChannelKeyKVO = &ChannelKeyKVO;

@interface FMMainViewController (){
    
    NSTimer        *progressTimer;
    NSTimer        *lyricTimer;
    FMLyricParser  *lyrciParser;
    RTSpinKitView  *lyricSpiner;
    
}
@end

@implementation FMMainViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //SWRevealView
    [self initSWReveal];
    [self initControls];
    [self initDouVisualizer];
    [self initNetwokingErrorHandler];
    [self initLyricView];
    [self initNetwokingGetLyricSuccessHandler ];
    //player
    _player = [[FMPlayer alloc]init];
    [_player addObserver:self forKeyPath:@"currentSong" options:NSKeyValueObservingOptionNew context:SongKeyKVO];
    [_player addObserver:self forKeyPath:@"currentChannel" options:NSKeyValueObservingOptionNew context:ChannelKeyKVO];
    [_player startAfterLauchWithErrorHandler:self.networkFailHandler];
    
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];

}

- (void)viewDidAppear:(BOOL)animated
{
    //远程控制中心
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication]beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [progressTimer invalidate];

    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    [super viewWillDisappear:animated];

    
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - SWRevealView setting

- (void)initSWReveal{

    [self.revealViewController setRightViewRevealDisplacement:20.0f];
    [self.revealViewController setRightViewRevealOverdraw:0.0f];
    [self.revealViewController setRightViewRevealWidth:180.0f];
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
}

- (void)revealChannel{
    [self.revealViewController rightRevealToggleAnimated:YES];
}

#pragma mark - init Controls

- (void)initControls{
    
    self.albumCover.clipsToBounds = YES;
    self.albumCover.layer.cornerRadius = self.albumCover.bounds.size.height/2.0f;
    self.albumCover.layer.borderWidth = 2.0f;
    self.unpauseButton.layer.cornerRadius = self.unpauseButton.bounds.size.height/2.0;
    
    [self initAlbumCoverAction];

}

- (void)initAlbumCoverAction{
    
    [self.albumCover setUserInteractionEnabled:YES];
    UITapGestureRecognizer *oneTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(albumCoverTapped)];
    [oneTap setNumberOfTapsRequired:1];
    [self.albumCover addGestureRecognizer:oneTap];
    
}

- (void)albumCoverTapped{
    if ([_player isPaused]) {
        return;
    }
    else{
        [self pause];
    }
}


- (void)initDouVisualizer{

    DOUAudioVisualizer *visualizer = [[DOUAudioVisualizer alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth([self.douVisualizer bounds]), CGRectGetHeight([self.douVisualizer bounds]))];
    [visualizer setBackgroundColor:[UIColor colorWithRed:239.0 / 255.0 green:244.0 / 255.0 blue:240.0 / 255.0 alpha:0.2]];
   // visualizer.center = self.douVisualizer.center;
    [self.douVisualizer addSubview:visualizer];
}

- (void)initLyricView{

    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.lyricTable.frame;
    
    //blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.lyricTable.backgroundView = blurEffectView;
    
    UITapGestureRecognizer *oneTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideLyric)];
    [oneTap setNumberOfTapsRequired:1];
    [self.lyricTable addGestureRecognizer:oneTap];
    
    //
    UIEdgeInsets contentInset = self.lyricTable.contentInset;
    contentInset.top = 50;
    [self.lyricTable setContentInset:contentInset];
    
    //lyric parser
    if (lyrciParser == nil) {
        lyrciParser = [[FMLyricParser alloc]init];
        lyricTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateLyric) userInfo:nil repeats:YES];
        [lyricTimer setFireDate:[NSDate distantFuture]];
    }
    
    
    self.lyricTable.delegate = lyrciParser;
    self.lyricTable.dataSource = lyrciParser;

}


#pragma mark - background playing

- (void)setupBackgroundSession{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    
}

#pragma mark - Network handle

- (void)initNetwokingErrorHandler{
    
    __weak __typeof__(self) weakSelf = self;
    self.networkFailHandler = ^void(AFHTTPRequestOperation *operation, NSError *error){
        
        NSString* message = [NSString stringWithFormat:@"错误码:%d,%@",[error code],[error localizedDescription]];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"失败" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        [weakSelf presentViewController:alert animated:YES completion:nil];
        
//        if(weakSelf.player.currentSong == nil){
//            [weakSelf.unpauseButton setHidden:NO];
//        }
        if (![weakSelf.player isPlaying] ) {
            NSLog(@"is playing");
           [weakSelf.unpauseButton setHidden:NO];
        }
        

    };
    
    
}


- (void)initNetwokingGetLyricSuccessHandler{
    
    __weak __typeof__(self) weakSelf = self;
    self.getLyricSuccessHandler = ^void(LyricType type){
        
        [weakSelf.lyricTable reloadData];
        [weakSelf hideLyricLoadingSpinner];
        if (type == LyricNormal) {
            [weakSelf startLyricScrolling];
        }
    };

}

#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}
*/


#pragma mark - button actions


- (void)restartAnotherSongWhenPaused{
    [self.unpauseButton setHidden:YES];
    [progressTimer setFireDate:[NSDate date]];
    [lyricTimer setFireDate:[NSDate date]];
}


- (void)pause{
    [self.unpauseButton setHidden:NO];
    [progressTimer setFireDate:[NSDate distantFuture]];
    [lyricTimer setFireDate:[NSDate distantFuture]];
    [_player pause];
    self.paused = YES;
}

- (IBAction)unPause:(id)sender {
    
    if (self.player.currentSong == nil) {
        [self.player retryConnection];
        [self.unpauseButton setHidden:YES];
    }
    else{
        [self.unpauseButton setHidden:YES];
        [progressTimer setFireDate:[NSDate date]];
        [lyricTimer setFireDate:[NSDate date]];
        NSDictionary * dict = [[MPNowPlayingInfoCenter defaultCenter] nowPlayingInfo];
        NSMutableDictionary *mutableDict = [dict mutableCopy];
        [mutableDict setObject:[NSNumber numberWithFloat:[_player currentTime]] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mutableDict];
        
        [_player play];
        self.paused = NO;
    }

}

- (IBAction)banSong:(id)sender {
    if (self.paused) {
        [self restartAnotherSongWhenPaused];
    }
    [_player banSong];
}

- (IBAction)nextSong:(id)sender {
    if (self.paused) {
        [self restartAnotherSongWhenPaused];
    }
    [_player skipSong];
}

- (IBAction)heartSong:(id)sender {
    
    if (_player.user == nil) {
        [self showAlert];
    }
    else{
        BOOL isSelected = [self.heartButton isSelected];
        [self.heartButton setSelected:!isSelected];
    }
}
- (IBAction)showLyric:(id)sender {
    
    
    if (lyrciParser.currentSong == nil || lyrciParser.currentSong != _player.currentSong){
        [self getNewLyric];
        [self.lyricTable setHidden:NO];

    }
    else{
        [self.lyricTable setHidden:NO];
        [self startLyricScrolling];
        
    }
    
}

- (void)hideLyric{
    [self.lyricTable setHidden:YES];
    [self pauseLyricScrolling];
    
}


- (void)getNewLyric{
    
    [self showLyricLoadingSpinner];
    [self pauseLyricScrolling];
    
    [lyrciParser getLyric:_player.currentSong WithSuccess:self.getLyricSuccessHandler];
    
    
    
}

- (void)startLyricScrolling{
    [lyricTimer setFireDate:[NSDate date]];
}

- (void)pauseLyricScrolling{
    [lyricTimer setFireDate:[NSDate distantFuture]];
}

- (void)showLyricLoadingSpinner{
    
    if (lyricSpiner == nil) {
        lyricSpiner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWave color:[UIColor colorWithRed:207/255.0 green:169/255.0 blue:114/255.0 alpha:1.0]];
        lyricSpiner.center = [[[self lyricTable]backgroundView ]center];

    }
   
    [lyricSpiner startAnimating];
    [[self lyricTable] addSubview:lyricSpiner];
}

- (void)hideLyricLoadingSpinner{
    if (lyricSpiner != nil) {
        [lyricSpiner stopAnimating];
        [lyricSpiner removeFromSuperview];
    }
}

- (void)switchChannel{
    [_player nextSong];
    [[self revealViewController]revealToggleAnimated:YES];
}



- (void)showAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"红心" message:@"需要登录以使用添加红心功能。" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"暂不登录" style:UIAlertActionStyleCancel handler:^void(UIAlertAction * _Nonnull action)
    {
        NSLog(@"%@ handled",action);
    }];
    [alert addAction:cancel];
    
    UIAlertAction *login = [UIAlertAction actionWithTitle:@"去登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
    {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"test"];
        [self presentViewController:vc animated:YES completion:nil];
    }];
    [alert addAction:login];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 界面更新&KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if (context == SongKeyKVO) {
        FMSong* newSong = change[@"new"];
        [self updateInterfaceWithNewSong:newSong];
        [self updateLockScreenWithNewSong:newSong];
        if ( ![self.lyricTable isHidden]) {
            [self getNewLyric];
        }
    }
    else if (context == ChannelKeyKVO){
        FMChannelDetail* newChannel = change[@"new"];
        self.channelLabel.text = [NSString stringWithFormat:@"%@Mhz", newChannel.channelName];
        [self switchChannel];
    }
    
}

- (void)updateInterfaceWithNewSong:(FMSong*)song{
    
    self.songLabel.text = song.songTitle;
    self.singerLabel.text = song.songArtist;
    [self.heartButton setSelected:song.songLiked.boolValue];
    
    __weak typeof(self) weakerSelf = self;
    [self.albumCover setImageWithURLRequest: [NSURLRequest requestWithURL:[NSURL URLWithString:song.songAlbum]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
    {
        
        if (NSClassFromString(@"MPNowPlayingInfoCenter"))
        {
            
            if (song != nil && song == _player.currentSong && image != nil)
            {
                NSDictionary * dict = [[MPNowPlayingInfoCenter defaultCenter] nowPlayingInfo];
                NSMutableDictionary *mutableDict = [dict mutableCopy];
                [mutableDict setObject:[[MPMediaItemArtwork alloc]initWithImage:image] forKey:MPMediaItemPropertyArtwork];
                [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mutableDict];
            }
        }
        weakerSelf.albumCover.image = image;

    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"error %@",error);
    }];
}

- (void)updateProgress{
       
    self.playProgress.progress = _player.currentTime / _player.currentSong.songInterval.doubleValue;
    //NSLog(@"%f",_player.currentTime);
}


- (void)updateLyric{
    
    if ([self.player isPaused]) {
        return;
    }
    
    NSTimeInterval newTime = self.player.streamer.currentTime;
    
    for (int index = [lyrciParser startIndex]; index < [[lyrciParser timeArray]count]; index++) {
        
        
        NSInteger nextIndex = index+1;
        if (nextIndex < [lyrciParser.timeArray count] && newTime >= [[lyrciParser timeArray][nextIndex]doubleValue]) {
            continue;
        }
        
        
        if (newTime >= [[lyrciParser timeArray][index]doubleValue]) {
            
           
            if (lyrciParser.startIndex == index) {
                lyrciParser.startIndex = index+1;
            }else{
                 [lyrciParser setStartIndex:index];
            }
            
            [lyrciParser setHighlightIndex:index];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.lyricTable reloadData];
            [self.lyricTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            
            break;
        }
    }
    
}

#pragma mark - Lyric Table View delegate and datasource


#pragma mark - remote controll & info center

- (void)updateLockScreenWithNewSong:(FMSong*)song
{
    if (NSClassFromString(@"MPNowPlayingInfoCenter"))
    {
   
        if (song != nil && song == _player.currentSong)
        {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];

            [dict setObject:song.songTitle forKey:MPMediaItemPropertyTitle];
            [dict setObject:song.songArtist forKey:MPMediaItemPropertyArtist];
            [dict setObject:[NSNumber numberWithFloat:_player.currentTime] forKey:MPMediaItemPropertyPlaybackDuration]; //音乐当前已经播放时间
            [dict setObject:[NSNumber numberWithFloat:1.0] forKey:MPNowPlayingInfoPropertyPlaybackRate];//进度光标的速度 （这个随 自己的播放速率调整，我默认是原速播放）
            [dict setObject:[NSNumber numberWithFloat:[song.songInterval floatValue]]forKey:MPMediaItemPropertyPlaybackDuration];
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
        }
    }
}


//响应远程音乐播放控制消息
- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent
{
    
    if (receivedEvent.type == UIEventTypeRemoteControl)
    {
        
        switch (receivedEvent.subtype)
        {
                
            case UIEventSubtypeRemoteControlPlay:
                [self unPause:nil];
                break;
            case UIEventSubtypeRemoteControlPause:
                [self pause];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [self nextSong:nil];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                break;
            default:
                break;
        }
    }
}


@end
