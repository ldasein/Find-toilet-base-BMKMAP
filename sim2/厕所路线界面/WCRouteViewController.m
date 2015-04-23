//
//  WCRouteViewController.m
//  厕所路线界面
//
//  Created by dasein on 15/4/1.
//  Copyright (c) 2015年 dasein. All rights reserved.
//

#import "wcInfo.h"
#import "ModelHandle.h"
#import <MessageUI/MessageUI.h>


@interface WCRouteViewController ()<MFMessageComposeViewControllerDelegate>
@end

@implementation WCRouteViewController

- (void)viewWillAppear:(BOOL)animated
{
    CGRect selfFrame = CGRectMake(0, 0, ([UIScreen mainScreen].bounds.size.width), ([UIScreen mainScreen].bounds.size.height -70));
    self.tableView = [[UITableView alloc] initWithFrame:selfFrame style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsSelection = NO;
    
    [[ModelHandle shareHandle] addObserver:self forKeyPath:@"routeId" options:NSKeyValueObservingOptionNew context:nil];
//    NSLog(@"sdf");

    [self.view addSubview:self.tableView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self.tableView reloadData];
    [[ModelHandle shareHandle] removeObserver:self forKeyPath:@"routeId"];
}

- (void)reloadLine
{
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    backButton.frame = CGRectMake(self.view.bounds.origin.x + 16, self.view.bounds.size.height - 18 - 35, 77, 42);
    backButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    backButton.backgroundColor = [UIColor grayColor];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [self.view addSubview:backButton];
    
    UIButton *sosButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sosButton.frame = CGRectMake(self.view.bounds.size.width - 77 - 16, self.view.bounds.size.height - 18 - 39, 77, 42);
//    sosButton.imageView.image = [UIImage imageNamed:@"sos.png"];
    [sosButton setImage:[UIImage imageNamed:@"sos.png"] forState:UIControlStateNormal];
    [sosButton addTarget:self action:@selector(showSMSPicker) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sosButton];
    

    
}

- (void)back
{
    [ModelHandle shareHandle].routeId = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark dataSouce


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else{
        NSInteger i = [ModelHandle shareHandle].walkRouteLine.steps.count;
        return i + 1;
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        infoCell *InfoCell = [tableView dequeueReusableCellWithIdentifier:@"infoCell_id"];
        if (!InfoCell) {
            [tableView registerNib:[UINib nibWithNibName:@"infoCell" bundle:nil] forCellReuseIdentifier:@"infoCell_id"];
            InfoCell = [tableView dequeueReusableCellWithIdentifier:@"infoCell_id"];
        }

        NSString *time = [NSString stringWithFormat:@"%@",[NSNumber numberWithInt:([ModelHandle shareHandle].walkRouteLine.duration.minutes)]];
        
        NSString *distance = [NSString stringWithFormat:@"%@",[NSNumber numberWithInt:([ModelHandle shareHandle].walkRouteLine.distance)]];
        
        InfoCell.timeLabel.text = [NSString stringWithFormat:@"%@米 %@分钟",distance,time];
        InfoCell.terLabel.text = [ModelHandle shareHandle].endName;
        InfoCell.infoCell.image = [UIImage imageNamed:@"WC.png"];

        return InfoCell;
        
    }else{
        if (indexPath.row == 0) {
            RouteCell *startCell = [tableView dequeueReusableCellWithIdentifier:@"startCell_id"];
            if (!startCell) {
                [tableView registerNib:[UINib nibWithNibName:@"RouteCell" bundle:nil] forCellReuseIdentifier:@"startCell_id"];
                startCell = [tableView dequeueReusableCellWithIdentifier:@"startCell_id"];
            }
            startCell.routeLabel.text = @"起点（当前位置）";
            startCell.myImageView.image = [UIImage imageNamed:@"start.png"];
            return startCell;
        }else{
        RouteCell *routeC = [tableView dequeueReusableCellWithIdentifier:@"routeCell_id"];
        if (!routeC) {
            [tableView registerNib:[UINib nibWithNibName:@"RouteCell" bundle:nil] forCellReuseIdentifier:@"routeCell_id"];
            routeC = [tableView dequeueReusableCellWithIdentifier:@"routeCell_id"];
        }
        BMKWalkingStep *step = [ModelHandle shareHandle].walkRouteLine.steps[indexPath.row - 1];
            NSLog(@"adf%@",step.instruction);
            NSLog(@"qwe%@",step.exitInstruction);
        routeC.routeLabel.text = step.instruction;
        if ([step.instruction containsString:@"右"]) {
            routeC.myImageView.image = [UIImage imageNamed:@"turnright.png"];
        }else if([step.instruction containsString:@"左"]){
            routeC.myImageView.image = [UIImage imageNamed:@"turnleft.png"];
        }else if ([step.instruction containsString:@"终"]){
            routeC.myImageView.image = [UIImage imageNamed:@"1end.png"];
        }else if([step.instruction containsString:@"后"]){
            routeC.myImageView.image = [UIImage imageNamed:@"down.png"];
        }else{
            routeC.myImageView.image = [UIImage imageNamed:@"up.png"];
        }
        
        
        return routeC;
    }
    }
    
//    infoCell *cell = [[infoCell alloc] init];
//    return cell;
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 90;
    }else{
        return 80;
    }
}

#pragma mark 发短信

//短信

-(void)showSMSPicker{
    
    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
    
    
    
    if (messageClass != nil) {
        
        // Check whether the current device is configured for sending SMS messages
        
        
        [self displaySMSComposerSheet];
        
        
        
        
    }
    
    else {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"该设备不支持发短信" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [errorAlert show];
    }
    
}

-(void)displaySMSComposerSheet

{
    
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    
    picker.messageComposeDelegate =self;
    NSString *endNameSend = [ModelHandle shareHandle].endName;
    NSString *addressSend = [ModelHandle shareHandle].address;
    
    NSString *smsBody =[NSString stringWithFormat:@"请给我送点纸吧，我在%@的%@",addressSend,endNameSend] ;
    
    picker.body=smsBody;
    
    [self presentViewController:picker animated:YES completion:nil];
    
    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    UIAlertView *resultAlert = [[UIAlertView alloc] initWithTitle:@"发送成功" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    if (result == MessageComposeResultSent) {
        [resultAlert show];
    }if (result == MessageComposeResultFailed) {
        UIAlertView *failed = [[UIAlertView alloc] initWithTitle:@"发送失败，请重新发送" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [failed show];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
