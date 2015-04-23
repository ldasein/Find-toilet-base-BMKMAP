//
//  AppDelegate.h
//  sim2
//
//  Created by dasein on 15/3/25.
//  Copyright (c) 2015年 dasein. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI/BMapKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

{
    BMKMapManager* _mapManager;
}

@property (strong,nonatomic) UIWindow *window;

+ (void)_keepAtLinkTime;

@end

