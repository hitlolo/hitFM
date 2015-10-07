//
//  FMSong.h
//  hitFM
//
//  Created by Lolo on 15/9/14.
//  Copyright (c) 2015年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DOUAudioFile.h"
@interface FMSong : NSObject
<DOUAudioFile>



@property (strong, nonatomic) NSString *songTitle;    //歌曲名
@property (strong, nonatomic) NSString *songArtist;   //歌手
@property (strong, nonatomic) NSString *songAlbum;    //唱片图片
@property (strong, nonatomic) NSString *songInterval; //歌曲时长
@property (strong, nonatomic) NSString *songLiked;    //是否加心
@property (strong, nonatomic) NSString *songUrl;      //歌曲url
@property (strong, nonatomic) NSString *songID;       //歌曲id
@property (strong, nonatomic) NSString *songSSID;     //歌曲ssid



- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

- (NSURL *)audioFileURL;
@end
