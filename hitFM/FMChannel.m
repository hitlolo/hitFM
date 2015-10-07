//
//  FMChannel.m
//  hitFM
//
//  Created by Lolo on 15/9/22.
//  Copyright © 2015年 Lolo. All rights reserved.
//

#import "FMChannel.h"
#import <UIKIT/UITableView.h>
#import <AFNetworking/AFNetworking.h>
#import "FMConstants.h"

@interface FMChannel(){
    
    AFHTTPRequestOperationManager* httpManager;

}
@end

@implementation FMChannel


- (instancetype)init{
    
    self = [super init];
    if (self) {
        
        httpManager  = [AFHTTPRequestOperationManager manager];
        [self setupDefaultChannel];
    }
    return self;
}

- (void)setupDefaultChannel{
    
    self.channelSections      = [NSMutableArray array];
    self.channelSectionTitles = @[@"我的兆赫",@"今日推荐",@"热门兆赫",@"上升最快"];
    
    NSDictionary *defaultChannelDic  = @{
                                        @"id":@"0",
                                        @"name":@"公共兆赫",
                                        @"intro":[NSNull null],
                                        @"banner":[NSNull null],
                                        @"cover":[NSNull null]
                                        };
    NSDictionary *redHeartChannelDic = @{
                                         @"id":@"-3",
                                         @"name":@"红心兆赫",
                                         @"intro":[NSNull null],
                                         @"banner":[NSNull null],
                                         @"cover":[NSNull null]
                                         };
    FMChannelDetail* defaultChannel  = [[FMChannelDetail alloc]initWithDictionary:defaultChannelDic];
    FMChannelDetail* redHeartChannel = [[FMChannelDetail alloc]initWithDictionary:redHeartChannelDic];
    
    NSArray *mineChannel = [NSArray arrayWithObjects:defaultChannel,redHeartChannel, nil];
    [self.channelSections addObject:mineChannel];
    [self.channelSections addObject:[NSMutableArray array]];
    [self.channelSections addObject:[NSMutableArray array]];
    [self.channelSections addObject:[NSMutableArray array]];
   
}

- (FMChannelDetail*)defaultChannel{
    return self.channelSections[0][0];
}

- (FMChannelDetail*)getChannelWithIndexPath:(NSIndexPath *)selectedChannelIndex{
    
    int section = selectedChannelIndex.section;
    int row = selectedChannelIndex.row;
    
    return self.channelSections[section][row];
    
}



- (void)refreshAllChannels{
    
//    [self refreshChannel:RECOMMAND];
//    [self refreshChannel:HOT];
//    [self refreshChannel:UPTREND];
    
    NSArray *operations = @[
                            [self hotChannelRequest],
                            [self recommendChannelRequest],
                            [self uptrendChannelRequest]
                            ];
    NSArray *refreshOperation = [AFURLConnectionOperation batchOfRequestOperations:operations progressBlock:nil completionBlock:^(NSArray *operations) {
        [self.delegate reloadData];
    }];
    [[NSOperationQueue mainQueue] addOperations:refreshOperation waitUntilFinished:NO];

}



- (AFHTTPRequestOperation*)hotChannelRequest{
    
    NSString* str = URL_CHANNELS_HOT;
    NSURL *url = [NSURL URLWithString:str];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
//    if (![[httpManager reachabilityManager]isReachable]) {
//        [request setCachePolicy:NSURLRequestReturnCacheDataDontLoad];
//    }
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //1. remove old
        [self.channelSections[HOT] removeAllObjects];
       
        
        //2. get new
        NSDictionary *channelsDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSDictionary *channelData = [channelsDictionary objectForKey:@"data"];
        
       
        for (NSDictionary *channels in [channelData objectForKey:@"channels"])
        {
                
            FMChannelDetail *channel = [[FMChannelDetail alloc]initWithDictionary:channels];
            [self.channelSections[HOT] addObject:channel];
                //
            
        }

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString* message = [NSString stringWithFormat:@"错误码:%d,%@",[error code],[error localizedDescription]];
        [self.delegate reloadDataFail:message];
    }];
    return operation;
}

- (AFHTTPRequestOperation*)uptrendChannelRequest{
    
    NSString* str = URL_CHANNELS_UP_TRENDING;
    NSURL *url = [NSURL URLWithString:str];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval:2];
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //1. remove old
        [self.channelSections[UPTREND] removeAllObjects];
        
        
        //2. get new
        NSDictionary *channelsDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSDictionary *channelData = [channelsDictionary objectForKey:@"data"];
        
        
        for (NSDictionary *channels in [channelData objectForKey:@"channels"])
        {
            
            FMChannelDetail *channel = [[FMChannelDetail alloc]initWithDictionary:channels];
            [self.channelSections[UPTREND] addObject:channel];
            //
            
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString* message = [NSString stringWithFormat:@"错误码:%d,%@",[error code],[error localizedDescription]];
        [self.delegate reloadDataFail:message];
    }];
    return operation;
}

- (AFHTTPRequestOperation*)recommendChannelRequest{
    
    NSString* str = URL_CHANNELS_RECOMMEND;
    NSURL *url = [NSURL URLWithString:str];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval:2];
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //1. remove old
        [self.channelSections[RECOMMAND] removeAllObjects];
        
        
        //2. get new
        NSDictionary *channelsDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSDictionary *channelData = [channelsDictionary objectForKey:@"data"];
        
        
        NSDictionary *channels = [channelData objectForKey:@"res"];
        {
            FMChannelDetail *channel = [[FMChannelDetail alloc]initWithDictionary:channels];
            [self.channelSections[RECOMMAND] addObject:channel];
        }

        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString* message = [NSString stringWithFormat:@"错误码:%d,%@",[error code],[error localizedDescription]];
        [self.delegate reloadDataFail:message];
    }];
    return operation;
}


- (void)refreshChannel:(int)index
{
    NSString* url;
    switch (index)
    {
        case RECOMMAND:
            url = URL_CHANNELS_RECOMMEND;
            break;
        case HOT:
            url = URL_CHANNELS_HOT;
            break;
        case UPTREND:
            url = URL_CHANNELS_UP_TRENDING;
            break;
        default:
            break;
    }
    
    //NSLog(@"%@",url);
    
    [httpManager GET:url
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         //1.remove objects that already there
         if (index != MINE)
         {
             [self.channelSections[index] removeAllObjects];
         }
         
         //2.get new channels from url
         NSDictionary *channelsDictionary = responseObject;
         NSDictionary *channelData = [channelsDictionary objectForKey:@"data"];
         
        if (index == RECOMMAND)
         {
             NSDictionary *channels = [channelData objectForKey:@"res"];
             {
                 FMChannelDetail *channel = [[FMChannelDetail alloc]initWithDictionary:channels];
                 [self.channelSections[index] addObject:channel];
             }
             
         }
         
         if (index != RECOMMAND)
         {
            for (NSDictionary *channels in [channelData objectForKey:@"channels"])
             {
                 
                 FMChannelDetail *channel = [[FMChannelDetail alloc]initWithDictionary:channels];
                [self.channelSections[index] addObject:channel];
                 //
             }
         }
         
         if (self.delegate!=nil) {
             [self.delegate reloadData];
         }
         
     }
             failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"%@",error);
     }
     ];
    
}


@end
