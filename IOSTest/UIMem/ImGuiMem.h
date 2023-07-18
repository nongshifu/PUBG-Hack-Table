//
//  ImGuiDrawView.h
//  ImGuiTest
//
//  Created by 十三哥 on 2023/6/27.
//

#import <UIKit/UIKit.h>

#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define 菜单宽度 350
#define 菜单高度 400
#define 控件高度 40
#define 默认搜书 40

NS_ASSUME_NONNULL_BEGIN

@interface ImGuiMem : UITextField <UITextFieldDelegate>

+ (instancetype)sharedInstance;
@end

NS_ASSUME_NONNULL_END
