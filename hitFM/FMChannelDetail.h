//
//  FMChannelDetail.h
//  hitFM
//
//  Created by Lolo on 15/9/22.
//  Copyright © 2015年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMChannelDetail : NSObject

@property (strong, nonatomic)NSString* channelID;
@property (strong, nonatomic)NSString* channelName;
@property (strong, nonatomic)NSString* channelBanner;
@property (strong, nonatomic)NSString* channelCover;
@property (strong, nonatomic)NSString* channelInfo;


- (instancetype)initWithDictionary:(NSDictionary*)dic;

- (BOOL)isRedheartChannel;
@end




