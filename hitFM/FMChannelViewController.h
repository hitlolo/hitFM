//
//  FMChannelViewController.h
//  hitFM
//
//  Created by Lolo on 15/9/13.
//  Copyright (c) 2015年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMChannel.h"
@class FMPlayer;
@class FMChannel;
@class FMMainViewController;
@interface FMChannelViewController : UITableViewController
<DataReload>

@property (strong, nonatomic)FMChannel* channel;
@property (weak, nonatomic)FMPlayer *player;
@property (weak, nonatomic)FMMainViewController *mainVC;

@end
