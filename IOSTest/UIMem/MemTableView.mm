
#import <UIKit/UIKit.h>
#import "Mem.h"
#import "MemTableView.h"
#import "WX_NongShiFu123.h"
#import "GameVV.h"
#import "ImGuiMem.h"
#import "YMUIWindow.h"
#import "NSTask.h"
@interface MemTableView ()

@property (nonatomic, strong) dispatch_source_t timer;

@end
float 顶头间隔=30;
static bool 展开状态[100];
static NSArray * Title[10];//每个分组的标题
static NSArray * FZTitle;//分组的标题
@implementation MemTableView

+ (instancetype)sharedInstance {
    static MemTableView *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MemTableView alloc] initWithStyle:UITableViewStylePlain];
        
    });
    return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化分组的开关文字
    Title[0]=@[@"机器码:",@"到期时间:",@"验证状态:",@"绘制总开关"];
    Title[1]=@[@"绘制功能",@"附近人数开关",@"射线开关",@"骨骼开关",@"血条开关",@"名字开关",@"距离开关",@"方框开关",@"手持开关"];
    Title[2]=@[@"枪械功能",@"无后座开关",@"聚点开关",@"追踪开关",@"防抖开关",@"自瞄开关",@"追踪半径",@"追踪位置",@"追踪距离",@"自瞄速度"];
    Title[3]=@[@"物资绘制",@"物资总开关",@"枪械物资开关",@"防具物资开关",@"药品物资开关",@"车辆物资开关"];
    Title[4]=@[@"其他功能",@"过直播开关",@"注销设备"];
    FZTitle=@[@"验证设备信息",@"基础绘制功能",@"枪械功能",@"物质绘制功能",@"其他功能"];
    展开状态[0]=YES;
    // 设置代理
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    // 设置圆角半径
    self.tableView.layer.cornerRadius = 10; // 设置圆角半径
    self.tableView.layer.masksToBounds = YES; // 剪裁超出边界的部分
    self.tableView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];//表格背景设置透明
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    // 设置分组标题不悬浮置顶
    self.tableView.sectionHeaderHeight = 顶头间隔;
    
    self.tableView.showsVerticalScrollIndicator = NO;//删除滚动条
    self.tableView.separatorInset = UIEdgeInsetsZero;//分割线
    
    开关[41]=YES;//设置过直播状态
    自瞄速度=[[NSUserDefaults standardUserDefaults] integerForKey:@"自瞄速度"];
    追踪距离=[[NSUserDefaults standardUserDefaults] floatForKey:@"追踪距离"];
    追踪圆圈半径=[[NSUserDefaults standardUserDefaults] floatForKey:@"追踪圆圈半径"];
    追踪位置=6;
    //读取绘制开关的储存状态
    for (int selectedIndex = 10; selectedIndex<20; selectedIndex++) {
        NSString*kgstr=[NSString stringWithFormat:@"开关%d",selectedIndex];
        开关[selectedIndex]=[[NSUserDefaults standardUserDefaults] boolForKey:kgstr];
        if (selectedIndex==11) {
            附近人数开关=开关[selectedIndex];
        }
        if (selectedIndex==12) {
            射线开关=开关[selectedIndex];
        }
        if (selectedIndex==13) {
            骨骼开关=开关[selectedIndex];
        }
        if (selectedIndex==14) {
            血条开关=开关[selectedIndex];
        }
        if (selectedIndex==15) {
            名字开关=开关[selectedIndex];
        }
        if (selectedIndex==16) {
            距离开关=开关[selectedIndex];
        }
        if (selectedIndex==17) {
            方框开关=开关[selectedIndex];
        }
        if (selectedIndex==18) {
            手持开关=开关[selectedIndex];
        }
    }
    //读取物资默认状态
    for (int selectedIndex = 30; selectedIndex < 40; selectedIndex++) {
        NSString*kgstr=[NSString stringWithFormat:@"开关%d",selectedIndex];
        开关[selectedIndex]=[[NSUserDefaults standardUserDefaults] boolForKey:kgstr];
        if (selectedIndex==31) {
            物资总开关=开关[selectedIndex];
        }
        if (selectedIndex==32) {
            枪械物资开关=开关[selectedIndex];
        }
        if (selectedIndex==33) {
            防具物资开关=开关[selectedIndex];
        }
        if (selectedIndex==34) {
            药品物资开关=开关[selectedIndex];
        }
        if (selectedIndex==35) {
            车辆物资开关=开关[selectedIndex];
        }
    }
    
}

#pragma mark - Table view data source
#pragma mark - 每个分组的文字信息
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return FZTitle[section];
}
#pragma mark - 每个分组显示的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (展开状态[section]) {
        // 如果这个section是展开的，返回实际的行数
        return Title[section].count;
    } else {
        // 否则，返回0
        return 1;
    }
    
    return 1;
}
#pragma mark - 分割线
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.separatorInset = UIEdgeInsetsZero;
}
#pragma mark - 分组头部
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 顶头间隔)];
    headerView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7];//顶部分组背景设置为透明
//    headerView.layer.cornerRadius = 10;
//    headerView.layer.masksToBounds = YES;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, headerView.frame.size.width - 15, headerView.frame.size.height)];
    titleLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];//颜色
    titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    titleLabel.text = [self tableView:tableView titleForHeaderInSection:section];

    [headerView addSubview:titleLabel];
    
    // 设置圆角半径等相关属性
    
    CGFloat cornerRadius = 10;
    UIRectCorner corners = UIRectCornerTopLeft | UIRectCornerTopRight;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:headerView.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = headerView.bounds;
    maskLayer.path = maskPath.CGPath;
    headerView.layer.mask = maskLayer;
    


    return headerView;
}
#pragma mark - 分组底部
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 10)];
    footerView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7];//底部分组背景
    CGFloat cornerRadius = 10;
    UIRectCorner corners = UIRectCornerBottomLeft | UIRectCornerBottomRight;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:footerView.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = footerView.bounds;
    maskLayer.path = maskPath.CGPath;
    footerView.layer.mask = maskLayer;
    return footerView;
}
#pragma mark - 表格行高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40; // 使用默认行高
}
#pragma mark - 几个分组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

#pragma mark - 表格代理显示代理 设置具体表格的UI控件
static BOOL 开关[100];
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 获取重用的单元格
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // 清空单元格的子视图
    for (UIView *subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    for (UISwitch *subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    cell.accessoryType = nil;
    
    //第一个分组是验证
    if (indexPath.section==0) {
        // 根据 第一分组的图标
        float imgwidth=25;
        if (indexPath.row==0) {
            // 创建左边图标的 UIImageView
            UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, imgwidth, imgwidth-2)];
            if (@available(iOS 13.0, *)) {
                leftImageView.image = [UIImage systemImageNamed:@"iphone.homebutton"];
            } else {
                // Fallback on earlier versions
                leftImageView.image = [UIImage imageNamed:@"iphone.homebutton"];
            }
            [cell.contentView addSubview:leftImageView];

            // 创建中间文字的 UILabel
            UILabel *middleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, 100, 25)];
            middleLabel.text = @"机器码:";
            middleLabel.font = [UIFont boldSystemFontOfSize:13];
            [cell.contentView addSubview:middleLabel];

            // 创建右边文字的 UILabel
            cell.textLabel.text = [[WX_NongShiFu123 alloc] getUDID];
            cell.textLabel.textAlignment=NSTextAlignmentRight;
            // 设置单元格文本的颜色
            cell.textLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
            
            
        }
        if (indexPath.row==1) {
            // 创建左边图标的 UIImageView
            UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, imgwidth, imgwidth-2)];
            if (@available(iOS 13.0, *)) {
                leftImageView.image = [UIImage systemImageNamed:@"timer"];
            } else {
                // Fallback on earlier versions
                leftImageView.image = [UIImage imageNamed:@"timer"];
            }
            [cell.contentView addSubview:leftImageView];

            // 创建中间文字的 UILabel
            UILabel *middleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, 100, 25)];
            middleLabel.text = 验证状态?@"到期时间:":@"点击粘贴";
            middleLabel.font = [UIFont boldSystemFontOfSize:13];
            [cell.contentView addSubview:middleLabel];

            // 创建右边文字的 UILabel
            cell.textLabel.text = 验证状态?到期时间:验证信息;
            cell.textLabel.textAlignment=NSTextAlignmentRight;
            // 设置单元格文本的颜色
            cell.textLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        }
        if (indexPath.row==2) {
            // 创建左边图标的 UIImageView
            UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, imgwidth, imgwidth-2)];
            if (@available(iOS 13.0, *)) {
                leftImageView.image = [UIImage systemImageNamed:@"pencil.circle.fill"];
            } else {
                // Fallback on earlier versions
                leftImageView.image = [UIImage imageNamed:@"pencil.circle.fill"];
            }
            [cell.contentView addSubview:leftImageView];

            // 创建中间文字的 UILabel
            UILabel *middleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, 100, 25)];
            middleLabel.text = @"状态:";
            middleLabel.font = [UIFont boldSystemFontOfSize:13];
            [cell.contentView addSubview:middleLabel];

            // 创建右边文字的 UILabel
            cell.textLabel.text = 验证状态?@"已经激活":@"未激活-点击激活";
            cell.textLabel.textAlignment=NSTextAlignmentRight;
            // 设置单元格文本的颜色
            cell.textLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        }
        if (indexPath.row==3) {
            // 创建左边图标的 UIImageView
            UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, imgwidth, imgwidth-2)];
            if (@available(iOS 13.0, *)) {
                leftImageView.image = [UIImage systemImageNamed:@"gamecontroller"];
            } else {
                // Fallback on earlier versions
                leftImageView.image = [UIImage imageNamed:@"pencil.circle.fill"];
            }
            [cell.contentView addSubview:leftImageView];
            cell.textLabel.text = @"";

            // 创建中间文字的 UILabel
            UILabel *middleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, 100, 25)];
            middleLabel.text = @"绘制总开关";
            middleLabel.font = [UIFont boldSystemFontOfSize:13];
            [cell.contentView addSubview:middleLabel];

            UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width-60, 5, 60, 40)];
            
            mySwitch.tag=indexPath.section*10+indexPath.row;
            // 设置开关的状态，默认为关闭状态
            [mySwitch setOn:开关[indexPath.section*10+indexPath.row]];
            mySwitch.onTintColor = [UIColor colorWithRed:arc4random() % 256 / 255.0 green:arc4random() % 256 / 255.0 blue:arc4random() % 256 / 255.0 alpha:1];//颜色
            // 添加开关的点击事件
            [mySwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
            // 将开关添加到需要显示的视图中
            [cell.contentView addSubview:mySwitch];
        }
        
        
    }else{
        //读取标题的文字内容
        cell.textLabel.text=Title[indexPath.section][indexPath.row];
        
        // 设置圆角半径等相关属性
    //    cell.layer.cornerRadius = 10;
    //    cell.layer.masksToBounds = YES;
        //单元格背景色
        cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.9];//单元格背景色
        //单元格文字大小
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
        // 设置单元格文本的颜色
        cell.textLabel.textColor = [UIColor colorWithRed:arc4random() % 256 / 255.0 green:arc4random() % 256 / 255.0 blue:arc4random() % 256 / 255.0 alpha:1.0];
        //单元格文字居左
        cell.textLabel.textAlignment=NSTextAlignmentLeft;
        
        //设置唯一tag 绑定区分每个开关
        NSInteger tagindexPath=indexPath.section*10+indexPath.row;
        
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
        //剩下的行都是开关
        if (indexPath.row>0 && indexPath.section>0) {
            //以下是其他控件
            if (indexPath.section ==2 && indexPath.row ==6){
                // 创建滑动条
                UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(100, 0, self.tableView.frame.size.width-110, cell.contentView.frame.size.height)];

                // 设置滑动条的最小值、最大值、当前值
                slider.minimumValue = 0;
                slider.maximumValue = 1;
                slider.thumbTintColor = [UIColor colorWithRed:arc4random() % 256 / 255.0 green:arc4random() % 256 / 255.0 blue:arc4random() % 256 / 255.0 alpha:0.5];//颜色
                slider.tintColor = [UIColor colorWithRed:arc4random() % 256 / 255.0 green:arc4random() % 256 / 255.0 blue:arc4random() % 256 / 255.0 alpha:10.5];//颜色
                slider.value = [[NSUserDefaults standardUserDefaults] floatForKey:@"追踪圆圈半径"];
                
                // 添加滑动条的事件
                [slider addTarget:self action:@selector(追踪圆圈半径调用:) forControlEvents:UIControlEventValueChanged];
                
                // 将滑动条添加到视图中
                [cell.contentView addSubview:slider];
            }
            else if (indexPath.section ==2 && indexPath.row ==7){
                // 创建选项卡控件
                UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"头", @"胸", @"腰", @"脚"]];
                
                // 设置控件位置和大小
                segmentedControl.frame = CGRectMake(100, 5, self.tableView.frame.size.width-110, cell.contentView.frame.size.height-10);
                
                if (@available(iOS 13.0, *)) {
                    segmentedControl.selectedSegmentTintColor = [UIColor colorWithRed:arc4random() % 256 / 255.0 green:arc4random() % 256 / 255.0 blue:arc4random() % 256 / 255.0 alpha:0.5];
                }
                
                segmentedControl.tintColor = [UIColor colorWithRed:arc4random() % 256 / 255.0 green:arc4random() % 256 / 255.0 blue:arc4random() % 256 / 255.0 alpha:0.5];//颜色
                // 设置默认选中的选项
                segmentedControl.selectedSegmentIndex = 0;
                
                // 添加选项卡的事件
                [segmentedControl addTarget:self action:@selector(追踪位置调用:) forControlEvents:UIControlEventValueChanged];
                
                // 将选项卡添加到视图中
                [cell.contentView addSubview:segmentedControl];
            }
            else if (indexPath.section ==2 && indexPath.row ==8){
                // 创建滑动条
                UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(100, 0, self.tableView.frame.size.width-110, cell.contentView.frame.size.height)];

                // 设置滑动条的最小值、最大值、当前值
                slider.minimumValue = 0;
                slider.maximumValue = 1;
                slider.value = [[NSUserDefaults standardUserDefaults] floatForKey:@"追踪距离"];
                slider.thumbTintColor = [UIColor colorWithRed:arc4random() % 256 / 255.0 green:arc4random() % 256 / 255.0 blue:arc4random() % 256 / 255.0 alpha:0.5];//颜色
                slider.tintColor = [UIColor colorWithRed:arc4random() % 256 / 255.0 green:arc4random() % 256 / 255.0 blue:arc4random() % 256 / 255.0 alpha:0.5];//颜色

                // 添加滑动条的事件
                [slider addTarget:self action:@selector(追踪距离调用:) forControlEvents:UIControlEventValueChanged];

                // 将滑动条添加到视图中
                [cell.contentView addSubview:slider];
            }
            else if (indexPath.section ==2 && indexPath.row ==9){
                // 创建选项卡控件
                UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"慢", @"中", @"快"]];
                
                // 设置控件位置和大小
                segmentedControl.frame = CGRectMake(100, 5, self.tableView.frame.size.width-110, cell.contentView.frame.size.height-10);
                
                if (@available(iOS 13.0, *)) {
                    segmentedControl.selectedSegmentTintColor = [UIColor colorWithRed:arc4random() % 256 / 255.0 green:arc4random() % 256 / 255.0 blue:arc4random() % 256 / 255.0 alpha:0.5];
                }
                
                segmentedControl.tintColor = [UIColor colorWithRed:arc4random() % 256 / 255.0 green:arc4random() % 256 / 255.0 blue:arc4random() % 256 / 255.0 alpha:0.5];//颜色
                // 设置默认选中的选项
                segmentedControl.selectedSegmentIndex = 2;
                
                // 添加选项卡的事件
                [segmentedControl addTarget:self action:@selector(自瞄速度调用:) forControlEvents:UIControlEventValueChanged];
                
                // 将选项卡添加到视图中
                [cell.contentView addSubview:segmentedControl];
            }else{
                //初始化开关
                UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width-60, 5, 60, 40)];
                //绑定开关唯一标识符
                mySwitch.tag=tagindexPath;
               
                // 设置开关的状态，默认为关闭状态
                [mySwitch setOn:开关[tagindexPath]];
                //开关的开启状态颜色 随机色
                mySwitch.onTintColor = [UIColor colorWithRed:arc4random() % 256 / 255.0 green:arc4random() % 256 / 255.0 blue:arc4random() % 256 / 255.0 alpha:1];//颜色
                // 添加开关的点击事件
                [mySwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
                // 将开关添加到需要显示的视图中
                [cell.contentView addSubview:mySwitch];
            }
            
        }
        
    }
    
    
    return cell;
}
#pragma mark - 表格点击
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //读取单元格点击的唯一标识符唯一编号
    NSInteger tagindex=indexPath.section*10+indexPath.row;
    
    NSLog(@"点击了表格section=%ld row=%ld 唯一编号:%ld",indexPath.section,indexPath.row,tagindex);
    if (indexPath.section==0) {
        if(tagindex==1){
            if (!验证状态) {
                UIPasteboard*string=[UIPasteboard generalPasteboard];
                验证信息=string.string;
            }
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];

        }
        if(tagindex==2){
            if (!验证状态) {
                UIPasteboard*string=[UIPasteboard generalPasteboard];
                [[WX_NongShiFu123 alloc] yanzhengAndUseIt:string.string];
            }else{
                NSString*km=[[NSUserDefaults standardUserDefaults] objectForKey:@"km"];
                [[WX_NongShiFu123 alloc] yanzhengAndUseIt:km];
            }
            
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            });
        }
        
        
    }
    
    //点击了分组第一个 展开或者关闭
    if(indexPath.row==0){
        // 切换section的状态
        展开状态[indexPath.section] =!展开状态[indexPath.section];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    
    
}
#pragma mark - 滚动相关
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    CGFloat sectionHeaderHeight = 顶头间隔; // 替换为你的分组头高度值
//    if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0) {
//        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
//    } else if (scrollView.contentOffset.y >= sectionHeaderHeight) {
//        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
//    }
}
//控件调用


- (void)switchValueChanged:(UISwitch *)Switch {
    // 获取开关选中的选项卡的索引
    NSInteger selectedIndex = Switch.tag;
    开关[selectedIndex]=Switch.on;//储存开关状态
    NSString*kgstr=[NSString stringWithFormat:@"开关%ld",selectedIndex];
    [[NSUserDefaults standardUserDefaults] setBool:开关[selectedIndex] forKey:kgstr];
    NSLog(@"点击开关编号tag=%ld",selectedIndex);
    //第1个分组
    if (selectedIndex==3) {
        绘制总开关=Switch.on;
        [[ImGuiMem sharedInstance] removeFromSuperview];
        [[YMUIWindow sharedInstance] addSubview:[ImGuiMem sharedInstance]];
    }
    //第2个分组
    if (selectedIndex==11) {
        附近人数开关=Switch.on;
    }
    if (selectedIndex==12) {
        射线开关=Switch.on;
    }
    if (selectedIndex==13) {
        骨骼开关=Switch.on;
    }
    if (selectedIndex==14) {
        血条开关=Switch.on;
    }
    if (selectedIndex==15) {
        名字开关=Switch.on;
    }
    if (selectedIndex==16) {
        距离开关=Switch.on;
    }
    if (selectedIndex==17) {
        方框开关=Switch.on;
    }
    if (selectedIndex==18) {
        手持开关=Switch.on;
    }
    
    //第3个分组
    
    if (selectedIndex==21) {
        无后座开关=Switch.on;
    }
    if (selectedIndex==22) {
        聚点开关=Switch.on;
    }
    if (selectedIndex==23) {
        追踪开关=Switch.on;
    }
    if (selectedIndex==24) {
        防抖开关=Switch.on;
    }
    if (selectedIndex==25) {
        自瞄开关=Switch.on;
    }
    
    
    //第4个分组
    
    if (selectedIndex==31) {
        物资总开关=Switch.on;
    }
    if (selectedIndex==32) {
        枪械物资开关=Switch.on;
    }
    if (selectedIndex==33) {
        防具物资开关=Switch.on;
    }
    if (selectedIndex==34) {
        药品物资开关=Switch.on;
    }
    if (selectedIndex==35) {
        车辆物资开关=Switch.on;
    }
    //第5个分组
    if (selectedIndex==41) {
        NSLog(@"点击了过直播开关");
        [Mem sharedInstance].secureTextEntry=Switch.on;
        [ImGuiMem sharedInstance].secureTextEntry=Switch.on;
        
    }
    if (selectedIndex==42) {
        NSLog(@"点击注销");
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:@"/usr/bin/killall"];
        [task setArguments:@[@"-9", @"SpringBoard"]];
        [task launch];
    }
    
    
}
- (void)追踪圆圈半径调用:(UISlider *)slider {
    // 获取滑动条的当前值
    [[NSUserDefaults standardUserDefaults] setFloat:slider.value forKey:@"追踪圆圈半径"];
    追踪圆圈半径 = slider.value;
    
    // 打印当前值
    NSLog(@"Slider value: %f", 追踪圆圈半径);
}
- (void)追踪距离调用:(UISlider *)slider {
    // 获取滑动条的当前值
    [[NSUserDefaults standardUserDefaults] setFloat:slider.value forKey:@"追踪距离"];
    追踪距离 = slider.value;
    
    // 打印当前值
    NSLog(@"Slider value: %f", 追踪距离);
}
- (void)自瞄速度调用:(UISegmentedControl *)segmentedControl {
    // 获取当前选中的选项索引
    NSInteger index = segmentedControl.selectedSegmentIndex;
    
    // 根据选项索引执行相应操作
    switch (index) {
        case 0:
            // 执行选项一的操作
            自瞄速度=1;
            break;
        case 1:
            // 执行选项二的操作
            自瞄速度=5;
            break;
        case 2:
            // 执行选项三的操作
            自瞄速度=8;
            break;
        
        default:
            break;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:自瞄速度 forKey:@"自瞄速度"];
    
}
- (void)追踪位置调用:(UISegmentedControl *)segmentedControl {
    // 获取当前选中的选项索引
    NSInteger index = segmentedControl.selectedSegmentIndex;
    
    // 根据选项索引执行相应操作
    switch (index) {
        case 0:
            // 执行选项一的操作
            追踪位置=6;
            break;
        case 1:
            // 执行选项二的操作
            追踪位置=2;
            break;
        case 2:
            // 执行选项三的操作
            追踪位置=3;
            break;
        case 3:
            // 执行选项三的操作
            追踪位置=48;
            break;
        default:
            break;
    }
    
}
@end
