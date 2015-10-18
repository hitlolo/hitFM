//
//  FMLyricParser.m
//  hitFM
//
//  Created by Lolo on 15/9/29.
//  Copyright © 2015年 Lolo. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "FMLyricParser.h"
#import "FMSong.h"
#import "FMConstants.h"
#import "LXMLyricsLabel.h"
#import "FMLyricCell.h"

@interface FMLyricParser(){
    
    UILabel*  noLyricLabel;
    NSString* base_url;
    AFHTTPRequestOperationManager *httpManager;
    
}
@end

@implementation FMLyricParser


- (instancetype)init{
    self = [super init];
    if (self) {
        base_url = URL_LYRIC;
        httpManager = [AFHTTPRequestOperationManager manager];
        _lyricType = LyricError;
    }
    return self;
}


- (void)getLyric:(FMSong*)song WithSuccess:(void(^)(LyricType type)) handler{
    
    self.currentSong = song;
    
    NSDictionary *parameters = @{
                                 @"ssid":song.songSSID,
                                 @"sid":song.songID,
                                 };
    [httpManager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [httpManager GET:base_url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         //NSLog(@"%@",responseObject);
         NSDictionary* lyricDic = [self parseLyric:responseObject];
         if (lyricDic == nil || self.lyricType == LyricEmpty) {
             self.timeArray = nil;
             self.lyricArray = nil;
             self.timeLyricDic = nil;
             self.startIndex = -1; //means empty
            
         }
         else{
             self.timeArray = lyricDic[@"time"];         // 时间戳
             self.lyricArray = lyricDic[@"lyric"];       // 时间戳对应歌词句
             self.timeLyricDic = lyricDic[@"timeLyric"]; // 以time-lyric为键值的字典
             self.startIndex = 0; //reset search index start to 0;

         }
        
        handler(self.lyricType);
     }
    failure:nil];

}

/**
 *  歌词解析
 *
 *  @param responseData 获取的响应数据
 *
 *  @return 解析后的字典
 */
- (NSDictionary*)parseLyric:(id)responseData{

    
    if (responseData == nil ){
        return nil;
    }
    
    NSMutableArray *timeArray = [[NSMutableArray alloc]init];               //装时间戳
    NSMutableArray *lyricArray = [[NSMutableArray alloc]init];              //歌词
    NSMutableDictionary *timeLyricDic = [[NSMutableDictionary alloc]init];  //对应字典
 
    NSDictionary *lyricDic = @{
                               @"time" : timeArray,
                               @"lyric": lyricArray,
                               @"timeLyric": timeLyricDic
                               };
    
 
    NSDictionary* responseJSON = (NSDictionary*)responseData;
    
    // empty test
    NSString* lyricString = responseJSON[@"lyric"];
    // 没有歌词
    if (lyricString == nil || [lyricString isEqualToString:@""]) {
        self.lyricType = LyricEmpty;
        return nil;
    }
    //time line test
    if (![self hasTimeline:lyricString]) {
       
        self.lyricType = LyricNoTimeline;
        
        // add caution info
        [lyricArray addObject:@"(no time line)"];
        // first title
        NSString* title = responseJSON[@"name"];
        [lyricArray addObject:title];
        
        // then lyrics
        NSArray*  lyricComponents = [lyricString componentsSeparatedByString:@"\n"];
        for (NSString* lyricComponent in lyricComponents) {
            
            if ([lyricComponent length] && (![lyricComponent isEqualToString:@"\r"])) {
                
                [lyricArray addObject:lyricComponent];
            }
        
        }
        timeArray = nil;
        timeLyricDic = nil;
        return lyricDic;
    }
    
    
    
    
    // normal lyric
    self.lyricType = LyricNormal;
    // title first
    NSString* title = responseJSON[@"name"];
    NSTimeInterval time = 0;
    NSNumber* timeObject = [NSNumber numberWithDouble:time];
    [timeArray addObject:timeObject];
    [timeLyricDic setObject:title forKey:timeObject];
    
    // then lyrics

    NSArray*  lyricComponents = [lyricString componentsSeparatedByString:@"\n"];
    for (NSString* lyricComponent in lyricComponents) {
        
        if ([lyricComponent length] && [lyricComponent containsString:@"]"]) {
            
            NSArray *lyricLineComponents = [lyricComponent componentsSeparatedByString:@"]"];
            //case 1:
            //[00:46.01]一片 无垠的沙漠\r\n
            if ([lyricLineComponents count] == 2) {
                NSString* timeContent = [(NSString*)[lyricLineComponents objectAtIndex:0] substringFromIndex:1];
                NSString* lyricContent = [lyricLineComponents objectAtIndex:1];
                if (lyricContent !=nil ) {
                    
                    NSTimeInterval time = [self getTime:timeContent];
                    NSNumber* timeObject = [NSNumber numberWithDouble:time];
                    [timeArray addObject:timeObject];
                    if ([lyricContent isEqualToString:@"\r"]) {
                        [timeLyricDic setObject:@"(~~music~~)" forKey:timeObject];
                    }
                    else
                        [timeLyricDic setObject:lyricContent forKey:timeObject];
                }
         
            }
            //case 2:
            //[05:38.11][04:22.41][03:08.41][01:43.16][00:05.00]Music\r\n
            else{
                NSString* lyricContent = [lyricLineComponents objectAtIndex:[lyricLineComponents count]-1];
                if (lyricContent !=nil) {
                    for (int i = 0; i <= ([lyricLineComponents count]-2); i++) {
                        NSString* timeContent = [(NSString*)[lyricLineComponents objectAtIndex:i] substringFromIndex:1];
                        NSTimeInterval time = [self getTime:timeContent];
                        NSNumber* timeObject = [NSNumber numberWithDouble:time];
                        [timeArray addObject:timeObject];
                        if ([lyricContent isEqualToString:@"\r"]) {
                            [timeLyricDic setObject:@"(~~music~~)" forKey:timeObject];
                        }
                        else
                            [timeLyricDic setObject:lyricContent forKey:timeObject];
                    }
                }
            }
        }
        else{
            continue;        }
        
    }
    
    //排序
    [timeArray sortUsingComparator:^NSComparisonResult(NSNumber*  _Nonnull A, NSNumber*  _Nonnull B) {
        return [A doubleValue] > [B doubleValue];
    }];

    return lyricDic;

}


- (NSTimeInterval)getTime:(NSString*)timeContent{
    
    //00:00.00
    if ([timeContent length] == 8) {
        
        NSString *      regex = @"\\d{2}[:]\\d{2}[:/.]\\d{2}";
        NSPredicate *   pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        if (![pred evaluateWithObject:timeContent]) {
            return 0;
        }
        
        
        // 00:00.00
        NSString *minute = [timeContent substringWithRange:NSMakeRange(0, 2)];
        NSString *second = [timeContent substringWithRange:NSMakeRange(3, 2)];
        NSString *ms = [timeContent substringWithRange:NSMakeRange(6, 2)];
        
        NSTimeInterval time = (NSTimeInterval)([minute intValue] * 60.0 + [second intValue] + [ms intValue]/1000.0);
        
        return time;
    }
    //00:00
    else if ([timeContent length] == 5) {
        
        NSString *      regex = @"\\d{2}[:/.]\\d{2}";
        NSPredicate *   pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        if (![pred evaluateWithObject:timeContent]) {
            return 0;
        }
        
        // 00:00
        NSString *minute = [timeContent substringWithRange:NSMakeRange(0, 2)];
        NSString *second = [timeContent substringWithRange:NSMakeRange(3, 2)];
        
        NSTimeInterval time = (NSTimeInterval)([minute intValue] * 60.0 + [second intValue]);
        
        return time;

    }
    else return 0;
}



- (BOOL)hasTimeline:(NSString*)content
{
    //[00:00.00]
    //[00:00]
    NSString * str = @"\\[\\d{2}[:]\\d{2}[:/./\\]]";
    
    NSRange range = [content rangeOfString:str options:NSRegularExpressionSearch];
    if (range.location == NSNotFound) {
        return NO;
    }
    return YES;
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:str options:NSRegularExpressionCaseInsensitive error:nil];
//    NSTextCheckingResult *result = [regex firstMatchInString:content options:0 range:NSMakeRange(0, [content length])];
//    if (result) {
//        <#statements#>
//    }
//    return [pred evaluateWithObject:content];
}

#pragma mark - Lyric delegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    if (self.lyricType == LyricEmpty) {
        if (noLyricLabel == nil) {
            noLyricLabel = [[UILabel alloc]initWithFrame:tableView.bounds];
            noLyricLabel.text = @"没有歌词";
            noLyricLabel.textAlignment = NSTextAlignmentCenter;
            noLyricLabel.textColor = [UIColor darkGrayColor];
            noLyricLabel.center = tableView.center;
            [tableView.backgroundView addSubview:noLyricLabel];
        }
        [noLyricLabel setHidden:NO];
        return 0;
    }
    else {
        [noLyricLabel setHidden:YES];
        return 1;

    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.lyricType == LyricNormal) {
        return [self.timeArray count];
    }
    
    else if (self.lyricType == LyricNoTimeline){
        return [self.lyricArray count];
    }
    
    else return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"LRCCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//    }
    
    // 2. 注册自定义Cell的到TableView中，并设置cell标识符为paperCell
    static BOOL isRegNib = NO;
    if (!isRegNib) {
        [tableView registerNib:[UINib nibWithNibName:@"FMLyricCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        isRegNib = YES;
    }
    FMLyricCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;//该表格选中后没有颜色
    cell.backgroundColor = [UIColor clearColor];
        

    if (self.lyricType == LyricNormal) {
        cell.lyrciLabel.text = self.timeLyricDic[self.timeArray[indexPath.row]];
    }
    else if (self.lyricType == LyricNoTimeline){
        cell.lyrciLabel.text = self.lyricArray[indexPath.row];
    }
    
    if (indexPath.row == _highlightIndex ) {
        
        
        cell.lyrciLabel.textColor = [UIColor whiteColor];
        cell.lyrciLabel.font = [UIFont boldSystemFontOfSize:16];
        
        if (self.lyricType == LyricNormal) {
            NSTimeInterval interval;
            if (indexPath.row + 1 < [self.timeArray count]) {
                interval = [self.timeArray[indexPath.row+1]doubleValue] - [self.timeArray[indexPath.row]doubleValue];
            }else{
                interval = [self.currentSong.songInterval doubleValue] - [self.timeArray[indexPath.row]doubleValue];
            }
            
            NSArray* time = @[
                              @(0),
                              @(interval)
                              ];
            NSArray* location = @[
                                  @(0),
                                  @(1)
                                  ];
            
            [cell.lyrciLabel startLyricsAnimationWithTimeArray:time andLocationArray:location];

        }
    }
    else {
        [cell.lyrciLabel stopAnimation];
        cell.lyrciLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        cell.lyrciLabel.font = [UIFont systemFontOfSize:13];
    }
    cell.lyrciLabel.backgroundColor = [UIColor clearColor];
    cell.lyrciLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 30.0f;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//   
//}

@end


/**
 {"lyric":
 "[05:38.11][04:22.41][03:08.41][01:43.16][00:05.00]Music\r\n
 [00:45.00](口白)\r\n
 [00:46.01]一片 无垠的沙漠\r\n
 [00:53.05]一段 无法忘怀的背弃\r\n
 [01:02.21]一卷 快速飞去的云\r\n
 [01:09.46]一颗 不断追寻的痴心\r\n
 [01:16.86]这一切 全看在 一轮银色的月亮眼里\r\n
 [01:26.23]她 这样看着世界上的故事\r\n
 [01:32.95]应该已经有 几千 几万年了吧...\r\n
 [02:13.00](唱)\r\n
 [02:14.08]在那遥远的地方\r\n
 [02:20.57]有位好姑娘\r\n
 [02:26.07]人们走过她的帐房\r\n
 [02:31.37]都要回头留恋地张望\r\n
 [02:39.66]她那粉红的笑脸\r\n
 [02:46.23]好像红太阳\r\n
 [02:51.85]她那活泼动人的眼睛\r\n
 [02:56.98]好像晚上明媚的月亮\r\n
 [03:30.89]我愿抛弃了财产\r\n
 [03:37.35]跟她去放羊\r\n
 [03:43.44]每天看着那粉红的笑脸\r\n
 [03:48.15]和那美丽金边的衣裳\r\n
 [03:56.50]我愿做一只小羊\r\n
 [04:02.95]跟在她身旁\r\n
 [04:09.04]我愿她拿着细细的皮鞭\r\n
 [04:13.70]不断轻轻打在我身上\r\n
 [04:45.63]我愿做一只小羊\r\n
 [04:52.12]跟在她身旁\r\n
 [04:57.58]我愿她拿着细细的皮鞭\r\n
 [05:02.85]不断轻轻打在我身上\r\n
 [05:09.41]我愿她拿着细细的皮鞭\r\n
 [05:13.56]不断轻轻打在我身上\r\n
 [05:19.97]不断轻轻打在我身上\r\n
 [05:26.17]不断轻轻打在我身上\r\n
 [05:54.91]End\r\n
 [05:54.91]End",
 
 "name":"在那遥远的地方",
 "sid":"450288"
 }
 
 
 **/



/**
 [00:03]
 
 [00:19]女:每一天
 
 [00:20]女:我睁开眼睛
 
 [00:22]女:看着窗外的天气
 
 [00:24]女:都会问自己
 
 [00:26]女:Wooh
 
 [00:27]女:我最关心的你会在哪里
 
 [00:31]女:是不是也睡醒
 
 [00:33]女:有没有好心情
 
 [00:35]女:Wooh
 
 [01:47][00:36]男:每一次
 
 [01:48][00:38]男:我沮丧不已
 
 [01:50][00:39]男:心中复杂的情绪
 
 [01:53][00:42]男:你总能分析
 
 [01:55][00:44]男:Wooh
 
 [01:56][00:45]合:就算我沉默不语也相信
 
 [01:59][00:48]合:彼此会有默契
 
 [02:40][02:05][00:54]女:告诉我
 
 [02:41][02:06][00:55]女:什么事让你开心
 
 [02:44][02:09][00:58]女:谁让你烦心
 
 [02:46][02:11][01:00]女:让我来抚平
 
 [02:49][02:14][01:03]男:有些话
 
 [02:50][02:15][01:04]男:放在心里心有灵犀
 
 [02:53][02:18][01:07]男:不需要原因
 
 [02:55][02:20][01:09]男:我就能感应
 
 [02:23][01:12]合:能和知心朋友一起谈心
 
 [02:26][01:15]男:不在乎主题
 
 [02:29][01:17]女:感觉永远历久弥新
 
 [02:32][01:21]合:我明白全世界只有你
 
 [02:36][01:25]合:最珍惜我快乐伤心
 
 [02:58]合:好想天天这样和你谈心
 
 [03:01]男:不在乎主题
 
 [03:04]女:感觉永远历久弥新
 
 [03:08]合:我明白全世界只有你
 
 [03:11]合:最珍惜我的快乐伤心
 
 
 **/



/**
 要high要rock'n roll 
 
 被电流狂扫
 
 让屋顶都掀掉 挡不住的尖叫
 
 当这是外太空 把压力赶跑
 
 now now now
 
 要飙要飙到爆 不断的高潮
 
 像呐喊那样跳 把地球跳到摇
 
 叫现实来单挑 不怕死才屌
 
 now now now
 
 
 
 现实里 哄你 是想骗你很便宜地卖命
 
 无语 是数不清 多到爆的势利
 
 踩你 是害怕你有窜起的能力
 
 觉醒 是忍耐换不到的正义
 
 在爱情里博取激情说话只是屁屁屁
 
 讨厌怪自己就把结局推给命命命
 
 夜店的拥挤通往孤寂随你信不信
 
 死了都要爱的摇滚更给力
 
 大都市有病 传染的病
 
 把热情看成没智力或是诡计
 
 慢慢的压抑变成扑克脸疏离
 
 天天是屁屁屁
 
 讨厌怪自己就把结局推给命命命
 
 夜店的拥挤通往孤寂随你信不信
 
 死了都要爱的摇滚更给力
 
 大都市有病 传染的病
 
 把热情看成没智力或是诡计
 
 慢慢的压抑变成扑克脸疏离
 
 天天\350表情那么硬 软的心也会畸形
 
 工作生活人际关系都有问题不适应
 
 很容易痛心容易生气容易沮丧提不起劲
 
 需要一种逃避 或一种勇气 或一种野性
 
 拒绝所有指令豁出去
 
 **/


/**
 [ti:我很忙]
 
 [ar:A-Lin黄丽玲]
 
 
 
 [00:01.53]我很忙 - A-Lin黄丽玲
 
 [00:02.49]
 
 [00:06.35]
 
 [00:11.78]
 
 [00:18.90]不需要假期 我没地方可去
 
 [00:26.24]不需要狂欢 人群只是空虚
 
 [00:34.19]多数的关心 只是嘴上说说而已
 
 [00:41.39]真正懂我的人是自己
 
 [00:47.52]
 
 [00:48.61]我的眼睛一做梦就看到你
 
 [00:55.14]一闭上就想哭泣 笑容忽然间变成奢侈品
 
 [01:04.07]我的生活 充满了和你有关的记忆
 
 [01:12.77]每每靠近 满城风雨
 
 [01:19.63]
 
 [01:20.30]就让我忙的疯掉 忙的累到
 
 [01:24.69]连哭的时间都没有最好
 
 [01:28.02]就让我忙的忘掉 你的怀抱
 
 [01:32.49]他曾带给我的美好
 
 [01:35.65]
 
 [01:36.05]当有人问好不好怕伤心夺眶就咬牙说我很忙
 
 [01:43.54]这完美的话完美的伪装
 
 [01:47.32]才让我的痛没人看到
 
 [01:56.08]
 
 [02:27.27]我的眼睛一做梦就看到你
 
 [02:33.49]一闭上就想哭泣 笑容忽然间变成奢侈品
 
 [02:42.40]你在哪里 总是每天要问你的一句
 
 [02:51.16]我要戒断 这种关心
 
 [02:59.06]就让我忙的疯掉 忙的累到
 
 [03:03.02]连哭的时间都没有最好
 
 [03:06.34]就让我忙的忘掉 你的怀抱
 
 [03:10.84]他曾带给我的美好
 
 [03:14.09]
 
 [03:14.42]当有人问好不好 怕伤心夺眶就咬牙说我很忙
 
 [03:21.90]这完美的 话完美的伪装
 
 [03:25.71]才让我的痛没人看到
 
 [03:34.48]
 
 [03:38.21]当一个麻痹的人那有多好
 
 [03:42.48]心里没别的只有忙忙忙
 
 [03:45.83]工作是一种抵抗一帖解药
 
 [03:50.09]人怎能被想念打倒
 
 [03:53.56]
 
 [03:53.83]当有人问好不好 怕伤心夺眶就咬牙说我很忙
 
 [04:01.22]这完美的话 完美的伪装
 
 [04:04.92]才让我的痛没人看到
 
 [04:19.04]
 **/
