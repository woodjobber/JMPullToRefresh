//
//  ViewController.m
//  JMPullToRefresh
//
//  Created by chengbin on 16/5/10.
//  Copyright © 2016年 chengbin. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+DirectionAndPullToRefresh.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupDataSource];
    __weak __typeof(self) weakSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        __strong __typeof(weakSelf) strongSelf = self;
        [strongSelf insertRowAtTop];
    } showActivityIndicatoInView:self.topTabBar];
}


- (void)setupDataSource {
    self.dataSource = [NSMutableArray array];
    for(int i=0; i<15; i++){
      [self.dataSource addObject:[NSDate dateWithTimeIntervalSinceNow:-(i*90)]];
    }
    
}

- (void)insertRowAtTop {
    __weak ViewController *weakSelf = self;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2.0f * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.tableView beginUpdates];
        [strongSelf.dataSource insertObject:[NSDate date] atIndex:0];
        [strongSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        [strongSelf.tableView endUpdates];
        
        [strongSelf.tableView.pullToRefreshView stopAnimation];
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
    NSDate *date = [self.dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle];
    return cell;
}
@end
