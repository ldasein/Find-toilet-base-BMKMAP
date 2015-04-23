//
//  ListViewController.h
//  sim2
//
//  Created by 张关涛 on 15/3/31.
//  Copyright (c) 2015年 dasein. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ListTableViewCell;
@class BMKPoiInfo;

@interface ListViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *listTable;

@property (nonatomic,strong)NSMutableArray *dataArray;

@property (nonatomic,strong)ListTableViewCell *listCell;

@property (nonatomic,strong)NSString *name;

@property (nonatomic,strong)NSString *adress;

@property (nonatomic,strong)NSNumber *distance;


@end
