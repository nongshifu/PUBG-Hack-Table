//
//  PUBGDrawDataFactory.h
//  ChatsNinja
//
//  Created by yiming on 2022/10/2.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <vector>
#include <mach/mach.h>
#include <mach/vm_map.h>
#include <mach-o/dyld.h>
#include <mach-o/getsect.h>
#include <mach-o/dyld_images.h>
#include <sys/sysctl.h>
#include <dlfcn.h>

#import "PUBGTypeHeader.h"

#define kAddrMax 0xFFFFFFFFF

NS_ASSUME_NONNULL_BEGIN
int getProcesses(NSString *Name);
mach_port_t getTask(int pid);
vm_map_offset_t getBaseAddress(mach_port_t task);
extern bool 绘制总开关,物资功能,枪械物资开关,防具物资开关,药品物资开关,车辆物资开关;
extern bool 附近人数开关,射线开关,骨骼开关,血条开关,名字开关,距离开关,方框开关;
extern bool 枪械功能,手持开关,无后座开关,聚点开关,追踪开关,防抖开关;
extern bool 物资功能,枪械物资开关,防具物资开关,药品物资开关,车辆物资开关;

bool getGame();

@interface GameVV : NSObject
- (void)getNSArray;
- (NSMutableArray*)getData;
- (NSMutableArray*)getwzData;
+ (instancetype)factory;


@end

NS_ASSUME_NONNULL_END
