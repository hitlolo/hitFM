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
    FMLyricParser  *lyricParser;
    RTSpinKitView  *lyricSpiner;
    
}

@property (strong, nonatomic) IBOutlet UILabel        *channelLabel;
@property (strong, nonatomic) IBOutlet UILabel        *songLabel;
@property (strong, nonatomic) IBOutlet UILabel        *singerLabel;
@property (strong, nonatomic) IBOutlet UIImageView    *albumCover;

@property (strong, nonatomic) IBOutlet UIButton       *heartButton;
@property (strong, nonatomic) IBOutlet UIButton       *unpauseButton;
@property (strong, nonatomic) IBOutlet UIProgressView *playProgress;

@property (strong, nonatomic) IBOutlet UIView         *douVisualizer;
@property (strong, nonatomic) IBOutlet UIButton       *lyricButton;

@property (strong, nonatomic) IBOutlet UITableView    *lyricTable;

@property (unsafe_unretained,nonatomic, getter=isPaused)BOOL           paused;

@property (strong, nonatomic) void (^networkFailHandler)(AFHTTPRequestOperation*,NSError*);
@property (strong, nonatomic) void (^fetchLyricSuccessHandler)(LyricType type);

@end

@implementation FMMainViewController


#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //SWRevealView
    [self initSWReveal];
    [self initControls];
    [self initDouVisualizer];
    [self initLyricView];
    
    //改成了在getter里初始化
    //[self initNetwokingErrorHandler];
    //[self initNetwokingGetLyricSuccessHandler];
    
    //init player and play
    [self initPlayerAndStartPlaying];
    
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // 设置更新歌曲进度的Timer
    progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                     target:self
                                                   selector:@selector(updateProgress)
                                                   userInfo:nil
                                                    repeats:YES];
    //远程控制中心
    [[UIApplication sharedApplication]beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];

}

- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // 取消更新歌曲进度的Timer
    [progressTimer invalidate];
    // 停止接受远程控制事件
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


#pragma mark - background playing

- (void)setupBackgroundSession{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    
}

#pragma mark - 播放器

- (void)initPlayerAndStartPlaying{
    
    _player = [[FMPlayer alloc]init];
    // 观察当前歌曲和当前频道
    // 发生改变时切换播放
    [_player addObserver:self
              forKeyPath:@"currentSong"
                 options:NSKeyValueObservingOptionNew
                 context:SongKeyKVO];
    
    [_player addObserver:self
              forKeyPath:@"currentChannel"
                 options:NSKeyValueObservingOptionNew
                 context:ChannelKeyKVO];
    
    // 开始播放
    // 如果出现网络错误，根据 networkFailHandler 处理
    [_player startAfterLauchWithErrorHandler:self.networkFailHandler];
}


#pragma mark - 右边抽屉设置 SWRevealView setting

/**
 *  设置右边抽屉大小 和 宽度
 *  添加打开和关闭右边抽屉的手势
 */
- (void)initSWReveal{

    [self.revealViewController setRightViewRevealDisplacement:20.0f];
    [self.revealViewController setRightViewRevealOverdraw:0.0f];
    [self.revealViewController setRightViewRevealWidth:180.0f];
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
}

- (void)revealChannel{
    [self.revealViewController rightRevealToggleAnimated:YES];
}

#pragma mark - 控件初始化 init Controls

/**
 *  初始化各控件
 */
- (void)initControls{
    
    // 唱片封面 外观设置
    self.albumCover.clipsToBounds = YES;
    self.albumCover.layer.cornerRadius = self.albumCover.bounds.size.height/2.0f;
    self.albumCover.layer.borderWidth = 2.0f;
    
    // 为唱片封面添加一个单击事件
    // 当单击后，播放暂停，显示继续播放按钮
    [self.albumCover setUserInteractionEnabled:YES];
    UITapGestureRecognizer *oneTap = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self
                                              action:@selector(albumCoverTapped)];
    [oneTap setNumberOfTapsRequired:1];
    [self.albumCover addGestureRecognizer:oneTap];

    // unpauseButton是覆盖在唱片封面上的一个按钮
    // 当播放暂停时显示 提供继续播放的动作
    self.unpauseButton.layer.cornerRadius = self.unpauseButton.bounds.size.height/2.0;
    
}

// 唱片封面单击事件
- (void)albumCoverTapped{
    if ([_player isPaused]) {
        return;
    }
    else{
        [self pause];
    }
}

#pragma mark - Douban的音波视图
/**
 *  douVisualizer是一个UIView 在xib中添加 
 *  用来作为douban音波视图的父视图显示
 */
- (void)initDouVisualizer{

    DOUAudioVisualizer *visualizer = [[DOUAudioVisualizer alloc]initWithFrame:
                                      CGRectMake(0,
                                                 0,
                                                 CGRectGetWidth([self.douVisualizer bounds]),
                                                 CGRectGetHeight([self.douVisualizer bounds]))];
    
    [visualizer setBackgroundColor:[UIColor colorWithRed:239.0 / 255.0
                                                   green:244.0 / 255.0
                                                    blue:240.0 / 255.0
                                                   alpha:0.2]];
    [self.douVisualizer addSubview:visualizer];
}


#pragma mark - 歌词显示视图 初始化以及其他

/**
 *  歌词视图
 *  提供歌词显示 
 *  点击歌词Button后显示
 *  点击视图背景后关闭
 */
- (void)initLyricView{

    // 1.添加一个模糊背景
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.lyricTable.frame;
    
    //blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.lyricTable.backgroundView = blurEffectView;
    
    
    // 2.添加一个单击关闭的手势动作
    UITapGestureRecognizer *oneTap = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                            action:@selector(hideLyric)];
    [oneTap setNumberOfTapsRequired:1];
    [self.lyricTable addGestureRecognizer:oneTap];
    
    // 3.外观设置
    UIEdgeInsets contentInset = self.lyricTable.contentInset;
    contentInset.top = 50;
    [self.lyricTable setContentInset:contentInset];
    
    // lyric parser
    // 歌词解析器
    // 歌词解析器 负责：
    //    1. 请求歌词
    //    2. 解析歌词
    //    3. 为当前歌词视图提供数据和代理
    if (lyricParser == nil) {
        lyricParser = [[FMLyricParser alloc]init];
    
        // 歌词滚动Timer设置
        // 这个Timer负责更新歌词显示
        lyricTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                      target:self
                                                    selector:@selector(updateLyric)
                                                    userInfo:nil
                                                     repeats:YES];
        [lyricTimer setFireDate:[NSDate distantFuture]];
        
        self.lyricTable.delegate = lyricParser;
        self.lyricTable.dataSource = lyricParser;
    }
    
    
    
}


/**
 *  <#Description#>
 */
- (void)initGetLyricSuccessHandler{
    
    
}


/**
 *  更新当前歌词
 *  每句歌词都有一个时间戳 存放于FMLyricParser的timeArray中
 *  通过播放器获取当前播放时间
 *  通过播放时间查询时间戳，如果当前播放时间 > timeArray[index]的时间 且< timeArray[nextIndex]的时间
 *  即为当前应显示的歌词
 */
- (void)updateLyric{
    
    //播放暂停则返回
    if ([self.player isPaused]) {
        return;
    }
    
    NSTimeInterval currentTime = self.player.currentTime;
    
    // 歌词解析器中提供了一个 startIndex的属性
    // 以标示当前阶段开始查询的索引 以避免每次都重新迭代
    // 初始化为0
    for (NSInteger index = [lyricParser startIndex]; index < [[lyricParser timeArray]count]; index++) {
        
        
        // 下一个时间戳索引
        NSInteger nextIndex = index+1;
        // 索引未越界 但是当前时间大于下一个时间戳
        // 即下一句歌词的时间戳也已过时
        // 这种情况出现在，用户在播放了很久才开始查看歌词，或者查看歌词过程中关闭又重新点开
        if (nextIndex < [lyricParser.timeArray count] && currentTime >= [[lyricParser timeArray][nextIndex]doubleValue]) {
            continue;
        }
        
        
        // 找到匹配时间戳
        if (currentTime >= [[lyricParser timeArray][index]doubleValue]) {
            
            // 如果是第一次尝试就成功，将下一次的开始索引设置为当前索引的后一位
            if (lyricParser.startIndex == index) {
                lyricParser.startIndex = index+1;
            }
            // 否则下次的开始索引为当前索引
            else{
                [lyricParser setStartIndex:index];
            }
            
            // 高亮歌词视图的当前索引值的歌词
            [lyricParser setHighlightIndex:index];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.lyricTable reloadData];
            [self.lyricTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            
            break;
        }
    }
    
}

/**
 *  点击歌词按钮后显示歌词视图
 *
 *  @param sender <#sender description#>
 */
- (IBAction)showLyric:(id)sender {
    
    
    if (lyricParser.currentSong == nil || lyricParser.currentSong != _player.currentSong){
        [self getNewLyric];
        [self.lyricTable setHidden:NO];
        
    }
    else{
        [self.lyricTable setHidden:NO];
        [self startLyricScrolling];
        
    }
    
}

/**
 *  获取新歌词
 */
- (void)getNewLyric{
    
    [self showLyricLoadingSpinner];
    [self pauseLyricScrolling];
    
    [lyricParser getLyric:_player.currentSong WithSuccess:self.fetchLyricSuccessHandler];
    
}

- (void)startLyricScrolling{
    [lyricTimer setFireDate:[NSDate date]];
}

- (void)pauseLyricScrolling{
    [lyricTimer setFireDate:[NSDate distantFuture]];
}

- (void)showLyricLoadingSpinner{
    
    if (lyricSpiner == nil) {
        lyricSpiner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWave
                                                     color:[UIColor colorWithRed:207/255.0
                                                                           green:169/255.0
                                                                            blue:114/255.0
                                                                           alpha:1.0]];
        lyricSpiner.center = [[[self lyricTable]backgroundView ]center];
        [[self lyricTable] addSubview:lyricSpiner];
        [lyricSpiner setHidesWhenStopped:YES];
    }
    
    [lyricSpiner startAnimating];
    
}

- (void)hideLyricLoadingSpinner{
    
    [lyricSpiner stopAnimating];
}


- (void)hideLyric{
    [self.lyricTable setHidden:YES];
    [self pauseLyricScrolling];
    
}





#pragma mark - Network handle

- (void (^)(LyricType))fetchLyricSuccessHandler{
    if (_fetchLyricSuccessHandler== nil) {
        
        __weak __typeof__(self) weakSelf = self;
        _fetchLyricSuccessHandler = ^void(LyricType type){
            
            [weakSelf.lyricTable reloadData];
            [weakSelf hideLyricLoadingSpinner];
            //type：normal 有时间戳 可滚动
            //type: no time line 无时间戳 不可滚动 直接显示
            if (type == LyricNormal) {
                [weakSelf startLyricScrolling];
            }
        };

    }
    
    return _fetchLyricSuccessHandler;
}

- (void (^)(AFHTTPRequestOperation *, NSError *))networkFailHandler{
    if (_networkFailHandler == nil) {
        
        /**
         *  初始化网络错误的处理块
         *  出现网络请求失败则present一个UIAlertController给出提示信息
         */
        __weak __typeof__(self) weakSelf = self;
        self.networkFailHandler = ^void(AFHTTPRequestOperation *operation, NSError *error){
            
            NSString* message = [NSString stringWithFormat:@"错误码:%ld,%@",(long)[error code],[error localizedDescription]];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"失败" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:cancelAction];
            [weakSelf presentViewController:alert animated:YES completion:nil];
            
            //        if(weakSelf.player.currentSong == nil){
            //            [weakSelf.unpauseButton setHidden:NO];
            //        }
            if (![weakSelf.player isPlaying] ) {
                [weakSelf.unpauseButton setHidden:NO];
            }
            
            
        };
    }
    return _networkFailHandler;
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
        //继续播放
        //重新设置播放中心的播放进度时间条
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


- (void)switchChannel{
    [_player nextSong];
    [[self revealViewController]revealToggleAnimated:YES];
}



- (void)showAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"红心"
                                                                   message:@"需要登录以使用添加红心功能。"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"暂不登录"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^void(UIAlertAction * _Nonnull action){
                                                       NSLog(@"%@ handled",action);
                                                   }];
    [alert addAction:cancel];
    
    UIAlertAction *login = [UIAlertAction actionWithTitle:@"去登录"
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * _Nonnull action){
            //handler
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
