//
//  FMUserViewController.m
//  hitFM
//
//  Created by Lolo on 15/9/13.
//  Copyright (c) 2015年 Lolo. All rights reserved.
//

#import "FMUserViewController.h"
#import "FMChannelViewController.h"
#import "SWRevealViewController.h"
#import "FMMainViewController.h"

@interface FMUserViewController ()

@end

@implementation FMUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    FMMainViewController* main = (FMMainViewController*)([self revealViewController].frontViewController);
    self.player = main.player;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //Get the new view controller using [segue destinationViewController].
    //Pass the selected object to the new view controller.
    FMChannelViewController* channelVC = (FMChannelViewController*)segue.destinationViewController;
    FMMainViewController* mainVC = (FMMainViewController*)([self revealViewController].frontViewController);
    
    channelVC.player = mainVC.player;
    channelVC.mainVC = mainVC;
}


#pragma mark - SHOW USER PANEL
- (IBAction)showUserPanel:(id)sender {
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"test"];
    [self presentViewController:vc animated:YES completion:nil];

    
}
@end
