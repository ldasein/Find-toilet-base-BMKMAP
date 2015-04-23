//
//  ListTableViewCell.h
//  sim2
//
//  Created by 张关涛 on 15/3/31.
//  Copyright (c) 2015年 dasein. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@property (weak, nonatomic) IBOutlet UIImageView *listImage;


@end
