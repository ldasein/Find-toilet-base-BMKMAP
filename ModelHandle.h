//
//  ModelHandle.h
//  sim2
//
//  Created by dasein on 15/3/31.
//  Copyright (c) 2015年 dasein. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BMKWalkingRouteLine;
@class BMKPoiInfo;

@interface ModelHandle : NSObject

@property (nonatomic,strong) NSMutableArray *infoArray;
@property (nonatomic,strong) BMKWalkingRouteLine *walkRouteLine;
@property (nonatomic,strong) NSMutableArray *distanceArray;
@property (nonatomic,strong) BMKPoiInfo *poiInfo;
@property (nonatomic,strong) NSString *routeId;
@property (nonatomic,strong) NSString *endName;
@property (nonatomic,strong) NSString *address;

+ (instancetype)shareHandle;
+ (void)clean;

@end
