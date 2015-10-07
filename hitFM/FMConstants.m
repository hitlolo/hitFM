//
//  FMConstants.m
//  hitFM
//
//  Created by Lolo on 15/9/13.
//  Copyright (c) 2015年 Lolo. All rights reserved.
//

#import "FMConstants.h"


#pragma mark -LOGIN
NSString* const URL_LOGIN = @"http://douban.fm/j/login";

/// LOGIN PARAMETERS;
//NSDictionary *paramter = @{
//                           @"source":@"radio",
//                           @"alias":username,
//                           @"form_password":password,
//                           @"captcha_id":Captcha.captchaID,
//                           @"captcha_solution":solution,
//                           @"remember":@"off"
//                           };

//response

//Response
//
//Success:
//r
//value 0 , represent for succeed
//user_info
//the user info details
//Fail
//err_msg
//the error message
//err_no
//the error number
//r
//value 1 , represent for failed

/*
 登录
 
 API
 
 http://douban.fm/j/login
 Request:
 
 Method:POST
 Content-Type:application/x-www-form-urlencoded
 POST Params:
 
 remember:on/off
 source:radio
 captcha_solution:cheese
 alias:xxxx%40gmail.com
 form_password:password
 captcha_id:jOtEZsPFiDVRR9ldW3ELsy57%3en
 Response：
 
 Content-Type:application/json; charset=utf-8
 set-Cookie:bid="U6ALTWjZexM";ck="bPhq"; dbcl2="69077079:hXADDW6guJg";
 
 OK_Body:
 {
 "r": 0,
 "user_info": {
 "ck": "10se",
 "id": "69077079",
 "is_dj": false,
 "is_new_user": 0,
 "is_pro": false,
 "name": "hijack",
 "play_record": {
 "banned": 44,
 "fav_chls_count": 2,
 "liked": 58,
 "played": 1715
 },
 "third_party_info": null,
 "uid": "69077079",
 "url": "http://www.douban.com/people/69077079/"
 }
 }
 
 
 Failed_Body:s
 {"err_no":1011,"r":1,"err_msg":"验证码不正确|xxx|xxx"}
 
 
 */

#pragma mark -captcha

NSString* const URL_LOGIN_CAPTCHA_ID = @"http://douban.fm/j/new_captcha";
NSString* const URL_LOGIN_CAPTCHA_IMAGE = @"http://douban.fm/misc/captcha?size=m&id=%@";
/*
获取验证码id

API:

http://douban.fm/j/new_captcha
Request:

Method:GET
Content-Type:application/x-www-form-urlencoded
Response:

Server:nginx
Content-Type:application/json; charset=utf-8
Set-Cookie:bid="3O4V/vRO+uE"; domain=.douban.fm; path=/; expires=Mon, 24-Nov-2014 14:25:20 GMT,ac="1385303119"; path=/; domain=.douban.fm
Body:
"8Z9w6tODHEukHkAmBz52dWg4:en"
*/

/*
获取验证码图片

API:

http://douban.fm/misc/captcha
Request:

Method:GET
Content-Type:application/x-www-form-urlencoded
Cookie：ac="1385303119"; bid="3O4V/vRO+uE"; ck="deleted"; dbcl2="deleted"; flag="ok"; start=
GET Params:

size:m
id:获取到的验证码id
Response：

Content-Type:image/jpeg
*/

#pragma mark -playlist

NSString* const URL_PLAYLIST = @"http://douban.fm/j/mine/playlist";



/**
 *  parameter:
 *  ssid
 *  sid
 */
NSString* const URL_LYRIC = @"http://api.douban.com/v2/fm/lyric";


/*
 根据频道获取歌曲列表
 
 API
 
 http://douban.fm/j/mine/playlist
 Request:
 
 Method:GET
 Request headers
 User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.57 Safari/537.36
 Content-Type: text/plain; charset=utf-8
 
Accept: 
Accept-Encoding: gzip,deflate,sdch
Accept-Language: en-US,en;q=0.8
Get Params:

from=mainsite&channel=1&kbps=128&type=n
Response:

Server: nginx
Content-Type: application/json; charset=utf-8
Body:
{"r":0,"warning":"user_is_ananymous",
    "song":[
            {"album":"\/subject\/1427374\/","picture":"http:\/\/img3.douban.com\/mpic\/s1441645.jpg","ssid":"6eae","artist":"陈绮贞","url":"http:\/\/mr3.douban.com\/201311260130\/5b668f132f85c33265963e21db190b76\/view\/song\/small\/p191887.mp3","company":"Avex","title":"旅行的意义","rating_avg":4.47197,"length":258,"subtype":"","public_time":"2005","sid":"191887","aid":"1427374","sha256":"1fde4cd188ed5e26e7d2165d74061a74feadf0264160f666ff937b56de89e35d","kbps":"64","albumtitle":"华丽的冒险","like":0},
            {"album":"\/subject\/2142526\/","picture":"http:\/\/img3.douban.com\/mpic\/s4698431.jpg","ssid":"19ab","artist":"卢巧音 \/ 王力宏","url":"http:\/\/mr4.douban.com\/201311260130\/388359d544874dae23510dcbd8b0676e\/view\/song\/small\/p479453.mp3","company":"EMI","title":"好心分手 – DUET WITH 王力宏","rating_avg":4.30213,"length":181,"subtype":"","public_time":"2007","sid":"479453","aid":"2142526","sha256":"967129b2724ca3bdfcc4a16c22f362ef7c01a1b69351e4481ebced0b08b7a32d","kbps":"64","albumtitle":"不能不愛... 盧巧...","like":0}
            ]
}
 
 
 */



//Request
//
//GET: /j/mine/playlist
//
//Usage
//
//Get new playlist when player status change.
//
//Parameters
//
//type
//n : None. Used for get a song list only.
//e : Ended a song normally.
//u : Unlike a hearted song.
//r : Like a song.
//s : Skip a song.
//b : Trash a song.
//p : Use to get a song list when the song in playlist was all played.
//sid
//the song's id
//pt
//how long the song has passed when operated
//channel
//channel id
//pb
//for the normal user(not pro) , value 64
//from
//value mainsite
//r
//a 10 digits 16 hex random number
//Resopnse
//
//e : the operate status
//others : a playlist



// url "http://douban.fm/j/mine/playlist?type=%@&sid=%@&pt=%f&channel=%@&from=mainsite"



#pragma mark -channels

NSString* const URL_CHANNELS_HOT = @"http://douban.fm/j/explore/hot_channels";
NSString* const URL_CHANNELS_UP_TRENDING = @"http://douban.fm/j/explore/up_trending_channels";
NSString* const URL_CHANNELS_RECOMMEND = @"http://douban.fm/j/explore/get_recommend_chl";
/*
******* 热门兆赫：
 
 API
 
 /j/explore/hot_channels
 GET:
 
 start=1&limit=6
 
 Body:
 {
 "data": {
 "channels": [
 {
 "banner": "http://img3.douban.com/img/fmadmin/chlBanner/27675.jpg",
 "cover": "http://img3.douban.com/img/fmadmin/icon/27675.jpg",
 "creator": {
 "id": 48254923,
 "name": "Bin's",
 "url": "http://www.douban.com/people/48254923/"
 },
 "hot_songs": [
 "\u539f\u8c05",
 "Better Me (\u56fd\u8bed)",
 "\u9b54\u9b3c\u4e2d\u7684\u5929\u4f7f"
 ],
 "id": 1000382,
 "intro": "\u7ec6\u542c\u7740\u522b\u4eba\u7684\u6b4c\u58f0\uff0c\u8bc9\u8bf4\u7740\u81ea\u5df1\u7684\u6545\u4e8b\u3002",
 "name": "\u4f60\u7684\u6b4c\u8bcd\u6211\u7684\u6545\u4e8b",
 "song_num": 384
 }
 ],
 "total": 23743
 },
 "status": true
 }
 
 
 
******* 上升最快
 
 API
 
 /j/explore/up_trending_channels
 GET:
 
 start=1&limit=6
 
 Body:
 {
 "data": {
 "channels": [
 {
 "banner": "http://img3.douban.com/img/fmadmin/chlBanner/27675.jpg",
 "cover": "http://img3.douban.com/img/fmadmin/icon/27675.jpg",
 "creator": {
 "id": 48254923,
 "name": "Bin's",
 "url": "http://www.douban.com/people/48254923/"
 },
 "hot_songs": [
 "\u539f\u8c05",
 "Better Me (\u56fd\u8bed)",
 "\u9b54\u9b3c\u4e2d\u7684\u5929\u4f7f"
 ],
 "id": 1000382,
 "intro": "\u7ec6\u542c\u7740\u522b\u4eba\u7684\u6b4c\u58f0\uff0c\u8bc9\u8bf4\u7740\u81ea\u5df1\u7684\u6545\u4e8b\u3002",
 "name": "\u4f60\u7684\u6b4c\u8bcd\u6211\u7684\u6545\u4e8b",
 "song_num": 384
 }
 ],
 "total": 23743
 },
 "status": true
 }
 */
