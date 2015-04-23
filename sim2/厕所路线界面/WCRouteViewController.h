//
//  WCRouteViewController.h
//  厕所路线界面
//
//  Created by dasein on 15/4/1.
//  Copyright (c) 2015年 dasein. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI/BMapKit.h>
@class BMKPoiInfo;



@interface WCRouteViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *tableView;



@end
