//
//  FMUser.h
//  hitFM
//
//  Created by Lolo on 15/9/24.
//  Copyright © 2015年 Lolo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMUser : NSObject
<NSCoding>

@property(strong, nonatomic)NSString*     userAvatarURL;
@property(strong, nonatomic)NSString*     userID;
@property(strong, nonatomic)NSString*     userName;
@property(strong, nonatomic)NSDictionary* playRecord;


- (instancetype)initWithDictionary:(NSDictionary*)dic;


@end


//登陆成功 返回信息
//login {
//    r = 0;
//    "user_info" =     {
//        ck = L3zp;
//        id = 1831044;
//        "is_dj" = 0;
//        "is_new_user" = 0;
//        "is_pro" = 0;
//        name = Lolo;
//        "play_record" =         {
//            banned = 7;
//            "fav_chls_count" = 0;
//            liked = 85;
//            played = 7606;
//        };
//        "third_party_info" = "<null>";
//        uid = hitlolo;
//        url = "http://www.douban.com/people/hitlolo/";
//    };
//}