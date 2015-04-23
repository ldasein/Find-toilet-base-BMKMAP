//
//  ModelHandle.m
//  sim2
//
//  Created by dasein on 15/3/31.
//  Copyright (c) 2015年 dasein. All rights reserved.
//

#import "ModelHandle.h"

static ModelHandle *modelHandle = nil;




@implementation ModelHandle


+ (instancetype)shareHandle
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        modelHandle = [[ModelHandle alloc] init];
        
    });
    return modelHandle;
}


+ (void)clean
{
    modelHandle.infoArray = nil;
    modelHandle.walkRouteLine = nil;
    modelHandle.distanceArray = nil;
    modelHandle.poiInfo = nil;
    modelHandle.routeId = nil;
    modelHandle.endName = nil;
}


@end
