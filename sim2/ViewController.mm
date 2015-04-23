//
//  ViewController.m
//  sim2
//
//  Created by dasein on 15/3/25.
//  Copyright (c) 2015年 dasein. All rights reserved.
//

#import "ViewController.h"
#import "ListViewController.h"
#import "ModelHandle.h"
#import "wcInfo.h"


@interface RouteAnnotation : BMKPointAnnotation
{
    int _type; //<0:起点 1：终点 2：公交 3：地铁 4:驾乘 5:途经点
    int _degree;
}


@property (nonatomic) int type;
@property (nonatomic) int degree;
@end



@implementation RouteAnnotation

@synthesize type = _type;
@synthesize degree = _degree;
@end



@interface ViewController ()<BMKMapViewDelegate,BMKPoiSearchDelegate,BMKLocationServiceDelegate,BMKPoiSearchDelegate,BMKRouteSearchDelegate,UIAlertViewDelegate>
{
    
    BMKPoiSearch *_poiSearch;
    BMKPoiResult *_poiResult;
    BMKNearbySearchOption *_searchOption;
    BMKRouteSearch *_walkSearch;
    BMKMapView *_my;
}

@property (nonatomic,strong) NSString *endName;

@property (nonatomic,strong) NSMutableArray *arrCount;

@property (nonatomic,assign) NSUInteger times;

@end

@implementation ViewController

- (IBAction)relocAction:(id)sender {
    [ModelHandle clean];
    _searchOption = nil;
    _times = 0;
    [self p_reloc];
}

- (IBAction)wcInfoAction:(id)sender {
    [ModelHandle clean];
    [self p_moreWC];
}


//进入厕所详情页面的方法
- (void)p_wcInfo
{
    if ([ModelHandle shareHandle].walkRouteLine == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"正在生成路线" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        WCRouteViewController *wcVC = [[WCRouteViewController alloc] init];
        [self presentViewController:wcVC animated:YES completion:nil];
    }
}

- (IBAction)listAction:(id)sender {
    if ([ModelHandle shareHandle].infoArray == nil) {
        UIAlertView *waring = [[UIAlertView alloc] initWithTitle:@"请等待搜索" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [waring show];
    }else{
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ListViewController *listVC = [sb instantiateViewControllerWithIdentifier:@"ListVC"];
        listVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:listVC animated:YES completion:nil];
    }
}


#pragma mark 更多厕所
- (void)p_moreWC
{
    _searchOption = nil;
    [self p_reloc];
    _searchOption = [[BMKNearbySearchOption alloc] init];
    _searchOption.pageIndex = 0;
    _searchOption.keyword = @"厕所";
    _searchOption.pageCapacity = 50;
    _times ++;
    _searchOption.radius = int(500 + _times * 100);
    NSLog(@"%d",_searchOption.radius);
    _searchOption.location = _locService.userLocation.location.coordinate;
    BOOL flag = [_poiSearch poiSearchNearBy:_searchOption];
    if (flag) {
        //        NSLog(@"重新搜索");
    }else{
        //        NSLog(@"本地搜索失败");
    }
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _my = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 70)];
    
    _times = 0;
    
    _locService = [[BMKLocationService alloc]init];
    [_locService startUserLocationService];
    
    [self p_setupMap];

    _my.delegate = self;
    _locService.delegate = self;
    
    [self.view addSubview:_my];
    
    //通知中心
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startSearch) name:@"routeId" object:nil];
    //重新寻找
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(relocationNtification) name:@"reLo" object:nil];
    //更多厕所
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_moreWC) name:@"more" object:nil];
}

#pragma mark 重新本地搜索
- (void)relocationNtification
{
    _searchOption = nil;
    [self p_reloc];
    _times = 0;
    _searchOption = [[BMKNearbySearchOption alloc] init];
    _searchOption.pageIndex = 0;
    _searchOption.pageCapacity= 50;
    _searchOption.keyword = @"厕所";
    _searchOption.radius = 500;
    _searchOption.location = _locService.userLocation.location.coordinate;
    BOOL flag = [_poiSearch poiSearchNearBy:_searchOption];
    if (flag) {
//        NSLog(@"重新搜索");
    }else{
//        NSLog(@"本地搜索失败");
    }
}

- (void)didFailToLocateUserWithError:(NSError *)error
{
    UIAlertView *localError = [[UIAlertView alloc] initWithTitle:@"定位失败，请重新定位" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [localError show];
}

#pragma mark 建立地图的方法
- (void)p_setupMap
{
    _my.mapType = BMKMapTypeStandard;
    _my.rotation = 90;
    _my.overlooking = -45;
    _my.compassPosition = CGPointMake(10, 10);
    _my.ChangeWithTouchPointCenterEnabled = YES;
    _my.showMapScaleBar = YES;
    _my.mapScaleBarPosition = CGPointMake(self.view.frame.size.width - 80, self.view.frame.size.height - 100);
    _my.showsUserLocation = NO;
    _my.userTrackingMode = BMKUserTrackingModeFollow;
    _my.showsUserLocation = YES;
    _poiSearch = [[BMKPoiSearch alloc] init];
    _poiSearch.delegate = self;
    
    _my.zoomLevel = 17;
}

#pragma mark 通知中心的方法
- (void)startSearch
{
    BMKPlanNode *pFrom = [[BMKPlanNode alloc] init];
    pFrom.pt = _searchOption.location;
    BMKPlanNode *pTo = [[BMKPlanNode alloc] init];
    
    [ModelHandle shareHandle].walkRouteLine = nil;
    
    pTo.pt = [ModelHandle shareHandle].poiInfo.pt;
    
    BMKWalkingRoutePlanOption *walkPlan = [[BMKWalkingRoutePlanOption alloc] init];
    walkPlan.from = pFrom;
    walkPlan.to = pTo;
    _walkSearch = [[BMKRouteSearch alloc] init];
    _walkSearch.delegate = self;
    BOOL i = [_walkSearch walkingSearch:(walkPlan)];
    if (i == true) {
//        NSLog(@"路径搜索开始");
    }
    
    
}


#pragma mark 重新定位的方法
- (void)p_reloc
{
    _my.showsUserLocation = NO;
    NSArray* array = [NSArray arrayWithArray:_my.annotations];
    [_my removeAnnotations:array];
    array = [NSArray arrayWithArray:_my.overlays];
    [_my removeOverlays:array];
    
    [self p_setupMap];

}

#pragma mark 视图将要显示
- (void)viewWillAppear:(BOOL)animated
{
    [_my viewWillAppear];


}
#pragma mark 视图将要消失
- (void)viewWillDisappear:(BOOL)animated
{
    [_my viewWillDisappear];
//    NSArray *disArr = _my.annotations;
//    for (int i = 0; i < disArr.count; i++) {
//        NSString *str = ((BMKPointAnnotation *)disArr[i]).title;
//        if ([str isEqualToString:[ModelHandle shareHandle].endName]) {
//            [_my removeAnnotation:disArr[i]];
//            NSLog(@"%@",str);
//        }
//    }
}

- (void)onGetPoiResult:(NSArray*)poiResultList searchType:(int)type errorCode:(int)error
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)willStartLocatingUser
{
//    NSLog(@"start locate");
    
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [_my updateLocationData:userLocation];
//    NSLog(@"heading is %@",userLocation.heading);
    
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
//        NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    if(_searchOption == nil){
        _times = 0;
        _searchOption = [[BMKNearbySearchOption alloc] init];
        _searchOption.pageIndex = 0;
        _searchOption.pageCapacity= 50;
        _searchOption.keyword = @"厕所";
        _searchOption.radius = 500;
        _searchOption.location = userLocation.location.coordinate;
        BOOL flag = [_poiSearch poiSearchNearBy:_searchOption];
    if (flag) {
//        NSLog(@"本地搜索成功");
    }else{
//        NSLog(@"本地搜索失败");
    }
    }
    
    [_my updateLocationData:userLocation];
}

- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult *)poiResult errorCode:(BMKSearchErrorCode)errorCode
{
//    NSLog(@"总共有%lu间厕所",(unsigned long)poiResult.poiInfoList.count);
//    for (BMKPoiInfo *a in poiResult.poiInfoList) {
//        NSLog(@"%@",a.name);
//        NSLog(@"%f",a.pt.latitude);
//        NSLog(@"%f",a.pt.longitude);
//
//    }
    
//    NSLog(@"搜索到了%ld检测所",poiResult.poiInfoList.count);

    NSArray *array = [NSArray arrayWithArray:_my.annotations];
    [_my removeAnnotations:array];
    
    
    [ModelHandle shareHandle].infoArray = [NSMutableArray arrayWithArray:poiResult.poiInfoList];
        
    
//    BMKMapPoint fr = BMKMapPointForCoordinate(_searchOption.location);
    
//    NSMutableArray *distanceArr = [NSMutableArray array];
    
//    for (BMKPoiInfo *info in poiResult.poiInfoList) {
//        BMKMapPoint to = BMKMapPointForCoordinate(info.pt);
//        CGFloat meter = BMKMetersBetweenMapPoints(fr, to);
//        NSNumber *distance = [NSNumber numberWithFloat:meter];
//        [distanceArr addObject:distance];
//    }
    
//    [ModelHandle shareHandle].distanceArray = [NSMutableArray arrayWithArray: distanceArr];
    
    
    for (int i = 0; i < poiResult.poiInfoList.count; i++) {
        BMKPoiInfo* poi = [poiResult.poiInfoList objectAtIndex:i];
        BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
        item.coordinate = poi.pt;
        item.title = poi.name;
        item.subtitle = poi.address;
        [_my addAnnotation:item];
        if(i == 0) {
            _my.centerCoordinate = poi.pt;
        }
    }
}



- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
{
//    NSLog(@"更改厕所图标");
    
    static NSString *AnnotationViewID = @"xidanMark";
    static NSString *RouteAnnotatiomViewID = @"routeMark";
    if ([annotation isKindOfClass:[RouteAnnotation class]]) {
        BMKAnnotationView* annotationView = [view dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
        if (annotationView == nil) {
            annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
            ((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorGreen;
            ((BMKPinAnnotationView*)annotationView).animatesDrop = YES;
        }
        annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
        annotationView.annotation = annotation;
        annotationView.canShowCallout = NO;
        annotationView.draggable = NO;
        return annotationView;
    }else{
        BMKAnnotationView* annotationView = [view dequeueReusableAnnotationViewWithIdentifier:RouteAnnotatiomViewID];
        if (annotationView == nil) {
            annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:RouteAnnotatiomViewID];
            ((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorRed;
            annotationView.image = [UIImage imageNamed:@"chat_location_annotation_someone.png"];
//            annotationView.alpha = 0.2;
            
            ((BMKPinAnnotationView*)annotationView).animatesDrop = YES;
        }
        annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
        annotationView.annotation = annotation;
        annotationView.canShowCallout = YES;
        annotationView.draggable = NO;
        return annotationView;
    }

}

//paopaoView被选中后执行的方法
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view
{
    [ModelHandle shareHandle].endName = view.annotation.title;
    [ModelHandle shareHandle].address = view.annotation.subtitle;
    
    [self p_wcInfo];
    
}



- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    [mapView bringSubviewToFront:view];
    [mapView setNeedsDisplay];
    _my.userTrackingMode = BMKUserTrackingModeFollowWithHeading;
    
    NSString *RouteAnnotatiomViewID = @"routeMark";
    
    if ([view.reuseIdentifier isEqualToString:RouteAnnotatiomViewID]) {
        
        BMKPlanNode *pFrom = [[BMKPlanNode alloc] init];
        
        pFrom.pt = _locService.userLocation.location.coordinate;
        BMKPlanNode *pTo = [[BMKPlanNode alloc] init];
        pTo.pt = ((BMKPointAnnotation *)view.annotation).coordinate;
        
        BMKWalkingRoutePlanOption *walkPlan = [[BMKWalkingRoutePlanOption alloc] init];
        walkPlan.from = pFrom;
        walkPlan.to = pTo;
        
//        BMKMapPoint fr = BMKMapPointForCoordinate(walkPlan.from.pt);
//        BMKMapPoint to = BMKMapPointForCoordinate(walkPlan.to.pt);
//        CGFloat meter = BMKMetersBetweenMapPoints(fr, to);
//        NSLog(@"%f米",meter);
        [ModelHandle shareHandle].walkRouteLine = nil;
        
        _walkSearch = [[BMKRouteSearch alloc] init];
        _walkSearch.delegate = self;
        BOOL i = [_walkSearch walkingSearch:(walkPlan)];
        if (i == true) {
//            NSLog(@"路径搜索开始");
        }
    }
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)onGetWalkingRouteResult:(BMKRouteSearch*)searcher result:(BMKWalkingRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
//    NSLog(@"步行结果返回成功");

    NSArray* array = [NSArray arrayWithArray:_my.annotations];
    for (int i = 0; i < [array count]; i ++) {
        if ([array[i] isKindOfClass:[RouteAnnotation class]]) {
            [_my removeAnnotation:array[i]];
        }
    }
//    [_my removeAnnotations:array];
    array = [NSArray arrayWithArray:_my.overlays];
    [_my removeOverlays:array];
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKWalkingRouteLine* plan = (BMKWalkingRouteLine*)[result.routes objectAtIndex:0];
        
        [ModelHandle shareHandle].walkRouteLine = plan;
        [ModelHandle shareHandle].routeId = @"yes";
        
        NSUInteger size = [plan.steps count];
        int planPointCounts = 0;
        for (int i = 0; i < size; i++) {
            BMKWalkingStep* transitStep = [plan.steps objectAtIndex:i];
            if(i==0){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.starting.location;
                item.title = @"起点";
                item.type = 0;
//                [_my addAnnotation:item]; // 添加起点标注
                
            }else if(i==size-1){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.terminal.location;
                item.title = @"终点";
                item.type = 1;
//                [_my addAnnotation:item]; // 添加起点标注
            }
            //添加annotation节点
            RouteAnnotation* item = [[RouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            item.title = transitStep.entraceInstruction;
            item.degree = transitStep.direction * 30;
            item.type = 4;
//            [_my addAnnotation:item];
            
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKWalkingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
            
        }
        // 通过points构建BMKPolyline
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [_my addOverlay:polyLine]; // 添加路线overlay
        delete []temppoints;
        
        
    }
    
}



- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:1];
        polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        polylineView.lineWidth = 3.0;
        return polylineView;
    }
    return nil;
}




@end
