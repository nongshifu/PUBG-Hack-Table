//
//  ZhuMemTableViewController.h
//  NEW
//
//  Created by 十三哥 on 2023/7/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZhuBiaoGe : UITableViewController<UITableViewDelegate,UITableViewDataSource>
+ (instancetype)sharedInstance;
extern float 顶头间隔;
@end

NS_ASSUME_NONNULL_END
