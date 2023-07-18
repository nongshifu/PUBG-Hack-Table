#import "TableViewController.h"

@interface TableViewController ()

@property (nonatomic, strong) NSArray *data;

@end

@implementation TableViewController
+ (instancetype)sharedInstance {
    static TableViewController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Table View Example";
    
    // Set up data
    NSArray *group1 = @[@"Item 1", @"Item 2", @"Item 3"];
    NSArray *group2 = @[@"Item 4", @"Item 5", @"Item 6"];
    NSArray *group3 = @[@"Item 7", @"Item 8", @"Item 9"];
    NSArray *group4 = @[@"Item 10", @"Item 11", @"Item 12"];
    NSArray *group5 = @[@"Item 13", @"Item 14", @"Item 15"];
    self.data = @[group1, group2, group3, group4, group5];
    
    // Register cell class
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.data.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *groupData = self.data[section];
    return groupData.count;
}
static bool 展开状态[100];
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSArray *groupData = self.data[indexPath.section];
    NSString *item = groupData[indexPath.row];
    cell.textLabel.text = item;
    //每个分组第一行表为标题
    if (indexPath.row==0) {
        //设置分组右边的箭头标志
        if(!展开状态[indexPath.section]){
            //右箭头
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else{
            //打勾
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.tintColor=[UIColor systemRedColor];
        }
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //第三个分组
    NSLog(@"点击了表格section=%ld row=%ld",indexPath.section,indexPath.row);
    //点击了分组第一个 展开或者关闭
    if(indexPath.row==0){
        // 切换section的状态
        展开状态[indexPath.section] =!展开状态[indexPath.section];
        // 刷新section
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    }
    
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"Group %ld", section + 1];
}

@end
