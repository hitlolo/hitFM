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



@property (strong, nonatomic)FMPlayer* player;

- (void)revealChannel;
@end
