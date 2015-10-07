//
//  FMMainViewController.h
//  hitFM
//
//  Created by Lolo on 15/9/12.
//  Copyright © 2015年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMLyricParser.h"
@class FMPlayer;
@class AFHTTPRequestOperation;
@interface FMMainViewController : UIViewController

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
@property (strong, nonatomic) void (^getLyricSuccessHandler)(LyricType type);

@property (strong, nonatomic)FMPlayer* player;

- (void)revealChannel;
@end
