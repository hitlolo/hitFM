//
//  FMChannel.h
//  hitFM
//
//  Created by Lolo on 15/9/22.
//  Copyright © 2015年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMChannelDetail.h"

@protocol LoadDataDelegate <NSObject>

- (void)reloadData;
- (void)reloadDataFail:(NSString*)message;

@end

enum
{
    MINE = 0,
    RECOMMAND,
    UPTREND,
    HOT
};
@interface FMChannel : NSObject

@property (weak, nonatomic) id<LoadDataDelegate>     delegate;
@property (strong, nonatomic) NSMutableArray        *channelSections;
@property (strong, nonatomic) NSArray<NSString*>    *channelSectionTitles;

@property (strong, readonly, getter=defaultChannel) FMChannelDetail* defaultChannel;

- (FMChannelDetail*)getChannelWithIndexPath:(NSIndexPath*)selectedChannelIndex;

- (void)refreshAllChannels;
@end
