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

bool getGame();
extern NSString*MyName;
@interface GameVV : NSObject
- (void)getNSArray;
- (NSMutableString*)getData;
- (NSMutableString*)getwzData;
+ (instancetype)factory;
//物资距离
@property (nonatomic,  assign) float JuLi;
//物资2D坐标系
@property (nonatomic,  assign) FVector2D WuZhi2D;
//物资
@property (nonatomic,  assign) uint64_t Player;
//物资模型名字
@property (nonatomic,  assign) NSString  * Name;

@end

NS_ASSUME_NONNULL_END
