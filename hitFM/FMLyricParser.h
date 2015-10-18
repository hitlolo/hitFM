//
//  FMLyricParser.h
//  hitFM
//
//  Created by Lolo on 15/9/29.
//  Copyright © 2015年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LyricType) {    
    LyricError = 0,
    LyricEmpty,
    LyricNormal,
    LyricNoTimeline
};

@class FMSong;
@interface FMLyricParser : NSObject
<UITableViewDelegate,UITableViewDataSource>

@property(weak, nonatomic)FMSong* currentSong;
@property(strong, nonatomic)NSArray* timeArray;
@property(strong, nonatomic)NSArray* lyricArray;
@property(strong, nonatomic)NSDictionary* timeLyricDic;
@property(unsafe_unretained,nonatomic)NSInteger startIndex;
@property(unsafe_unretained,nonatomic)NSInteger highlightIndex;
@property(unsafe_unretained,nonatomic)LyricType lyricType;

- (void)getLyric:(FMSong*)song WithSuccess:(void(^)(LyricType type)) handler;
@end
