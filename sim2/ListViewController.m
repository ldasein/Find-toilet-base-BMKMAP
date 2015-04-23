//
//  ListViewController.m
//  sim2
//
//  Created by 张关涛 on 15/3/31.
//  Copyright (c) 2015年 dasein. All rights reserved.
//

#import "ListViewController.h"
#import "ListTableViewCell.h"
#import "wcInfo.h"
#import "ModelHandle.h"
#import <BaiduMapAPI/BMapKit.h>
#import "MJRefresh.h"

#define kRandomColor  arc4random() % 256 / 255.0

@interface ListViewController () <UITableViewDataSource,UITableViewDelegate>

@end

@implementation ListViewController



- (IBAction)pop:(id)sender {
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"sdf");
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.listTable.dataSource = self;
    self.listTable.delegate = self;
//    NSLog(@"%@",self.name);
    self.dataArray = [ModelHandle shareHandle].infoArray;
    [self p_reload];
    [self p_moreWC];
}


#pragma mark 下拉刷新的方法
- (void)p_reload
{
    [self.listTable addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(p_reSearchRouteNotificationCenter)];
    
    [self.listTable.header setTitle:@"重新寻找厕所中" forState:MJRefreshHeaderStatePulling];
    [self.listTable.header setTitle:@"厕所会有的" forState:MJRefreshHeaderStateRefreshing];
    
    // 设置字体
    self.listTable.header.font = [UIFont systemFontOfSize:15];
    
    // 设置颜色
    self.listTable.header.textColor = [UIColor blackColor];
    
}


#pragma mark 上拉加载更多厕所的方法
- (void)p_moreWC
{
    [self.listTable addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(p_moreNotificationCenter)];
    
    // 设置文字
    [self.listTable.footer setTitle:@"更多的厕所" forState:MJRefreshFooterStateIdle];
    [self.listTable.footer setTitle:@"厕所会有的" forState:MJRefreshFooterStateRefreshing];
    
    // 设置字体
    self.listTable.footer.font = [UIFont systemFontOfSize:15];
    
    // 设置颜色
    self.listTable.footer.textColor = [UIColor blackColor];
    

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- dataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    _listCell  = [tableView dequeueReusableCellWithIdentifier:@"cell_id"];
    BMKPoiInfo *bmkInfo = self.dataArray[indexPath.row];
    _listCell.nameLabel.text = bmkInfo.name;
//    _listCell.DistanceLabel.text = bmkInfo.address;
    _listCell.detailLabel.text = bmkInfo.address;
    
//    NSNumber *d = [ModelHandle shareHandle].distanceArray[indexPath.row];
//    NSInteger distanceWC = [d floatValue];
//    NSString *dist = [NSString stringWithFormat:@"约%d米",(NSInteger)distanceWC % 100 + 100];
//    _listCell.DistanceLabel.text = dist;
    _listCell.listImage.image = [UIImage imageNamed:@"chat_location_detail_disclosure.png"];
    
    
    return _listCell;
    
    
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 70;
//}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WCRouteViewController *wcVC = [[WCRouteViewController alloc] init];
    
    
    
    [ModelHandle shareHandle].poiInfo = [ModelHandle shareHandle].infoArray[indexPath.row];
    [ModelHandle shareHandle].endName = [ModelHandle shareHandle].poiInfo.name;
    [ModelHandle shareHandle].address = [ModelHandle shareHandle].poiInfo.address;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"routeId" object:nil];
    
    wcVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:wcVC animated:YES completion:nil];
}

#pragma mark 调用通知中心的方法



- (void)p_reSearchRouteNotificationCenter
{
    [ModelHandle clean];
    //对单例添加观察者
    [[ModelHandle shareHandle] addObserver:self forKeyPath:@"infoArray" options:NSKeyValueObservingOptionNew context:nil];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reLo" object:nil];

}

- (void)p_moreNotificationCenter
{
    [ModelHandle clean];
    [[ModelHandle shareHandle] addObserver:self forKeyPath:@"infoArray" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"more" object:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    _dataArray = [ModelHandle shareHandle].infoArray;
    [self.listTable reloadData];
    
    [self.listTable.header endRefreshing];
    [self.listTable.footer endRefreshing];
    
    //移除观察者
    [[ModelHandle shareHandle] removeObserver:self forKeyPath:@"infoArray"];

    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
