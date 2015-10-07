//
//  FMChannelViewController.m
//  hitFM
//
//  Created by Lolo on 15/9/13.
//  Copyright (c) 2015年 Lolo. All rights reserved.
//

#import "FMMainViewController.h"
#import "FMChannelViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "FMPlayer.h"



@interface FMChannelViewController ()

@end

@implementation FMChannelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.channel = [[FMChannel alloc]init];
    self.channel.delegate = self;
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(loadChannel) forControlEvents:UIControlEventValueChanged];
    [self loadChannel];
    // Do any additional setup after loading the view.
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ChannelCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
 
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - channel delegate protocol
- (void)reloadData{
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)loadChannel{
   
    [self.refreshControl beginRefreshing];
    [self.channel refreshAllChannels];
 
}

- (void)reloadDataFail:(NSString*)message{
    if([self presentedViewController] != nil){
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"失败" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:^{
        [self.mainVC revealChannel];
    }];
    
//    [_mainVC networkFailHandler](nil,nil);
    [self.refreshControl endRefreshing];
}

#pragma mark - table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.channel.channelSections count];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return self.channel.channelSectionTitles[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    // Return the number of rows in the section.
    return [self.channel.channelSections[section] count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChannelCell"];
    
    // Configure the cell...
    FMChannelDetail* channel = (FMChannelDetail*)(self.channel.channelSections[indexPath.section][indexPath.row]);
    cell.textLabel.text = channel.channelName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FMChannelDetail* selected = self.channel.channelSections[indexPath.section][indexPath.row];
    if ([selected isRedheartChannel] && (self.player.user == nil)) {
        [self showRedHeartAlert];
    }
    else if (selected!=nil) {
        self.player.currentChannel = selected;
    }
  
}



- (void)showRedHeartAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"红心" message:@"需要登录以使用添加红心功能。" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"暂不登录" style:UIAlertActionStyleCancel handler:^void(UIAlertAction * _Nonnull action)
                             {
                                 NSLog(@"%@ handled",action);
                             }];
    [alert addAction:cancel];
    
    UIAlertAction *login = [UIAlertAction actionWithTitle:@"去登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                            {
                                UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                                UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"test"];
                                [self presentViewController:vc animated:YES completion:nil];
                            }];
    [alert addAction:login];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
