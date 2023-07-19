//
//  PUBGDrawDataFactory.m
//  ChatsNinja
//
//  Created by yiming on 2022/10/2.
//

#import "GameVV.h"
#include "string"
#import "PUBGTypeHeader.h"
#include <vector>
@interface GameVV()

@property (nonatomic,  assign) FVector2D canvas;

@end

@implementation GameVV

static mach_port_t task;
bool wzkg;
static FMinimalViewInfo POV;
+ (instancetype)factory
{
    static GameVV *fact;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fact = [[GameVV alloc] init];
    });
    return fact;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if ([UIScreen mainScreen].bounds.size.width<[UIScreen mainScreen].bounds.size.height) {
            _canvas.X = [UIScreen mainScreen].bounds.size.height;
            _canvas.Y = [UIScreen mainScreen].bounds.size.width;
        }else{
            _canvas.X = [UIScreen mainScreen].bounds.size.width;
            _canvas.Y = [UIScreen mainScreen].bounds.size.height;
        }
        
    }
    return self;
}

#pragma mark - 内存读写 声明

extern "C" kern_return_t
mach_vm_region_recurse(
                       vm_map_t                 map,
                       mach_vm_address_t        *address,
                       mach_vm_size_t           *size,
                       uint32_t                 *depth,
                       vm_region_recurse_info_t info,
                       mach_msg_type_number_t   *infoCnt);

extern "C" kern_return_t
mach_vm_read_overwrite(
                       vm_map_t           target_task,
                       mach_vm_address_t  address,
                       mach_vm_size_t     size,
                       mach_vm_address_t  data,
                       mach_vm_size_t     *outsize);


#pragma mark - 进程相关=============
#pragma mark - 读取进程pid
int getProcesses(NSString *Name)
{
    size_t length = 0;
    static const int mib[] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    int err = sysctl((int *)mib, (sizeof(mib) / sizeof(*mib)) - 1, NULL, &length, NULL, 0);
    if (err == -1) {
        err = errno;
    }
    
    if (err == 0) {
        struct kinfo_proc *procBuffer = (struct kinfo_proc *)malloc(length);
        if(procBuffer == NULL) {
            return -1;
        }
        
        sysctl( (int *)mib, (sizeof(mib) / sizeof(*mib)) - 1, procBuffer, &length, NULL, 0);
        
        int count = (int)length / sizeof(struct kinfo_proc);
        for (int i = 0; i < count; ++i) {
            const char *procname = procBuffer[i].kp_proc.p_comm;
            if (strstr(procname, Name.UTF8String)) {
                return procBuffer[i].kp_proc.p_pid;
            }
        }
    }
    return -1;
}
#pragma mark - 读取进程Task
mach_port_t getTask(int pid)
{
    
    task_for_pid(mach_task_self(), pid, &task);
    return task;
}
#pragma mark - 读取进程BaseAddress
vm_map_offset_t getBaseAddress(mach_port_t task)
{
    vm_map_offset_t vmoffset = 0;
    vm_map_size_t vmsize = 0;
    uint32_t nesting_depth = 0;
    struct vm_region_submap_info_64 vbr;
    mach_msg_type_number_t vbrcount = 16;
    kern_return_t kret = mach_vm_region_recurse(task, &vmoffset, &vmsize, &nesting_depth, (vm_region_recurse_info_t)&vbr, &vbrcount);
    if (kret == KERN_SUCCESS) {
        NSLog(@"[yiming] %s : %016llX %lld bytes.", __func__, vmoffset, vmsize);
    } else {
        NSLog(@"[yiming] %s : FAIL.", __func__);
    }
    
    return vmoffset;
}
#pragma mark - 内存封装============
static BOOL isValidAddress(uintptr_t address)
{
    if (address && address > 0x100000000 && address < kAddrMax) {
        return YES;
    }
    return NO;
}
static BOOL readMemory(uintptr_t address, size_t size ,void *buffer )
{
    mach_vm_size_t otu_size = 0;
    kern_return_t error = mach_vm_read_overwrite((vm_map_t)task, (mach_vm_address_t)address, (mach_vm_size_t)size, (mach_vm_address_t)buffer, &otu_size);
    if (error != KERN_SUCCESS || otu_size != size) {
        return NO;
    }
    return YES;
}
static kern_return_t read_mem(vm_map_offset_t address, mach_vm_size_t size, void *buffer)
{
    kern_return_t kert = mach_vm_read_overwrite(task, address, size, (mach_vm_address_t)(buffer), &size); // AAR in Kernel
    return kert;
}
template<typename T> T Read(long address)
{
    T data;
    read_mem(address, sizeof(T), reinterpret_cast<void *>(&data));
    return data;
}


#pragma mark - 坐标转换===============
static FVector3D minusTheVector(FVector3D first, FVector3D second)
{
    static FVector3D ret;
    ret.X = first.X - second.X;
    ret.Y = first.Y - second.Y;
    ret.Z = first.Z - second.Z;
    return ret;
}

static float theDot(FVector3D v1, FVector3D v2)
{
    return v1.X * v2.X + v1.Y * v2.Y + v1.Z * v2.Z;
}

static float getDistance(FVector3D a, FVector3D b)
{
    static FVector3D ret;
    ret.X = a.X - b.X;
    ret.Y = a.Y - b.Y;
    ret.Z = a.Z - b.Z;
    return sqrt(ret.X * ret.X + ret.Y * ret.Y + ret.Z * ret.Z);
}

static D3DXMATRIX toMATRIX(FRotator rot)
{
    static float RadPitch, RadYaw, RadRoll, SP, CP, SY, CY, SR, CR;
    D3DXMATRIX M;
    
    RadPitch = rot.Pitch * M_PI / 180;
    RadYaw = rot.Yaw * M_PI / 180;
    RadRoll = rot.Roll * M_PI / 180;
    
    SP = sin(RadPitch);
    CP = cos(RadPitch);
    SY = sin(RadYaw);
    CY = cos(RadYaw);
    SR = sin(RadRoll);
    CR = cos(RadRoll);
    
    M._11 = CP * CY;
    M._12 = CP * SY;
    M._13 = SP;
    M._14 = 0.f;
    
    M._21 = SR * SP * CY - CR * SY;
    M._22 = SR * SP * SY + CR * CY;
    M._23 = -SR * CP;
    M._24 = 0.f;
    
    M._31 = -(CR * SP * CY + SR * SY);
    M._32 = CY * SR - CR * SP * SY;
    M._33 = CR * CP;
    M._34 = 0.f;
    
    M._41 = 0.f;
    M._42 = 0.f;
    M._43 = 0.f;
    M._44 = 1.f;
    
    return M;
}

#pragma mark - 地址判断
static bool IsValidAddress(uintptr_t address) {
    return address && address > 0x100000000 && address < 0x2000000000;
}

#pragma mark - 世界坐标转屏幕2D坐标
static void getTheAxes(FRotator rot, FVector3D *x, FVector3D *y, FVector3D *z){
    D3DXMATRIX M = toMATRIX(rot);
    
    x->X = M._11;
    x->Y = M._12;
    x->Z = M._13;
    
    y->X = M._21;
    y->Y = M._22;
    y->Z = M._23;
    
    z->X = M._31;
    z->Y = M._32;
    z->Z = M._33;
}

static FVector2D worldToScreen(FVector3D worldLocation, FMinimalViewInfo camViewInfo, FVector2D canvas){
    static FVector2D Screenlocation;
    
    FVector3D vAxisX, vAxisY, vAxisZ;
    getTheAxes(camViewInfo.Rotation, &vAxisX, &vAxisY, &vAxisZ);
    
    FVector3D vDelta = minusTheVector(worldLocation, camViewInfo.Location);
    FVector3D vTransformed;
    
    vTransformed.X = theDot(vDelta, vAxisY);
    vTransformed.Y = theDot(vDelta, vAxisZ);
    vTransformed.Z = theDot(vDelta, vAxisX);
    
    if (vTransformed.Z < 1.0f) {
        vTransformed.Z = 1.0f;
    }
    
    float FOV = camViewInfo.FOV;
    float ScreenCenterX = canvas.X / 2;
    float ScreenCenterY = canvas.Y / 2;
    float BonesX=ScreenCenterX + vTransformed.X * (ScreenCenterX / tanf(FOV * (float)M_PI / 360.f)) / vTransformed.Z;
    float BonesY=ScreenCenterY - vTransformed.Y * (ScreenCenterX / tanf(FOV * (float)M_PI / 360.f)) / vTransformed.Z;
    
    
    Screenlocation.X = BonesX;
    Screenlocation.Y = BonesY;
    
    return Screenlocation;
}


#pragma mark - 游戏数据
static char g_nameBuf[128];
static NSString* getFNameFromID(uintptr_t gnamePtr, int classId){
    
    if (classId > 0 && classId < 2000000) {
        int page = classId / 16384;
        int index = classId % 16384;
        uintptr_t pageAddr = Read<uintptr_t>(gnamePtr + page * sizeof(uintptr_t));
        uintptr_t nameAddr = Read<uintptr_t>(pageAddr + index * sizeof(uintptr_t)) + 0xE;
        
        readMemory(nameAddr, sizeof(g_nameBuf), g_nameBuf);
        return [NSString stringWithUTF8String:g_nameBuf];
    }
    return nil;
}

static NSString* getPlayerName(uintptr_t player){
    char Name[128];
    unsigned short buf16[16] = {0};
    uintptr_t PlayerName = Read<uintptr_t>(player + 0x9d0);
    if (!isValidAddress(PlayerName)) return @"";
    if (!readMemory(PlayerName, 28, buf16)) return @"";
    
    unsigned short *tempbuf16 = buf16;
    char *tempbuf8 = Name;
    char *buf8 = tempbuf8 + 32;
    for (int i = 0; i < 28 && tempbuf8 + 3 < buf8; i++) {
        if (*tempbuf16 <= 0x007F) {
            *tempbuf8++ = (char) *tempbuf16;
        } else if (*tempbuf16 <= 0x07FF) {
            *tempbuf8++ = (*tempbuf16 >> 6) | 0xC0;
            *tempbuf8++ = (*tempbuf16 & 0x3F) | 0x80;
        } else {
            *tempbuf8++ = (*tempbuf16 >> 12) | 0xE0;
            *tempbuf8++ = ((*tempbuf16 >> 6) & 0x3F) | 0x80;
            *tempbuf8++ = (*tempbuf16 & 0x3F) | 0x80;
        }
        tempbuf16++;
    }
    *tempbuf8 = '\0';
    
    return [NSString stringWithUTF8String:Name];
}

#pragma mark - 玩家骨骼相关=========
static D3DXMATRIX toMatrixWithScale(FVector4D rotation, FVector3D translation, FVector3D scale3D){
    static D3DXMATRIX ret;
    
    float x2, y2, z2, xx2, yy2, zz2, yz2, wx2, xy2, wz2, xz2, wy2 = 0.f;
    ret._41 = translation.X;
    ret._42 = translation.Y;
    ret._43 = translation.Z;
    
    x2 = rotation.X * 2;
    y2 = rotation.Y * 2;
    z2 = rotation.Z * 2;
    
    xx2 = rotation.X * x2;
    yy2 = rotation.Y * y2;
    zz2 = rotation.Z * z2;
    
    ret._11 = (1 - (yy2 + zz2)) * scale3D.X;
    ret._22 = (1 - (xx2 + zz2)) * scale3D.Y;
    ret._33 = (1 - (xx2 + yy2)) * scale3D.Z;
    
    yz2 = rotation.Y * z2;
    wx2 = rotation.W * x2;
    ret._32 = (yz2 - wx2) * scale3D.Z;
    ret._23 = (yz2 + wx2) * scale3D.Y;
    
    xy2 = rotation.X * y2;
    wz2 = rotation.W * z2;
    ret._21 = (xy2 - wz2) * scale3D.Y;
    ret._12 = (xy2 + wz2) * scale3D.X;
    
    xz2 = rotation.X * z2;
    wy2 = rotation.W * y2;
    ret._31 = (xz2 + wy2) * scale3D.Z;
    ret._13 = (xz2 - wy2) * scale3D.X;
    
    ret._14 = 0.f;
    ret._24 = 0.f;
    ret._34 = 0.f;
    ret._44 = 1.f;
    
    return ret;
}

static D3DXMATRIX matrixMultiplication(D3DXMATRIX M1, D3DXMATRIX M2)
{
    static D3DXMATRIX ret;
    ret._11 = M1._11 * M2._11 + M1._12 * M2._21 + M1._13 * M2._31 + M1._14 * M2._41;
    ret._12 = M1._11 * M2._12 + M1._12 * M2._22 + M1._13 * M2._32 + M1._14 * M2._42;
    ret._13 = M1._11 * M2._13 + M1._12 * M2._23 + M1._13 * M2._33 + M1._14 * M2._43;
    ret._14 = M1._11 * M2._14 + M1._12 * M2._24 + M1._13 * M2._34 + M1._14 * M2._44;
    ret._21 = M1._21 * M2._11 + M1._22 * M2._21 + M1._23 * M2._31 + M1._24 * M2._41;
    ret._22 = M1._21 * M2._12 + M1._22 * M2._22 + M1._23 * M2._32 + M1._24 * M2._42;
    ret._23 = M1._21 * M2._13 + M1._22 * M2._23 + M1._23 * M2._33 + M1._24 * M2._43;
    ret._24 = M1._21 * M2._14 + M1._22 * M2._24 + M1._23 * M2._34 + M1._24 * M2._44;
    ret._31 = M1._31 * M2._11 + M1._32 * M2._21 + M1._33 * M2._31 + M1._34 * M2._41;
    ret._32 = M1._31 * M2._12 + M1._32 * M2._22 + M1._33 * M2._32 + M1._34 * M2._42;
    ret._33 = M1._31 * M2._13 + M1._32 * M2._23 + M1._33 * M2._33 + M1._34 * M2._43;
    ret._34 = M1._31 * M2._14 + M1._32 * M2._24 + M1._33 * M2._34 + M1._34 * M2._44;
    ret._41 = M1._41 * M2._11 + M1._42 * M2._21 + M1._43 * M2._31 + M1._44 * M2._41;
    ret._42 = M1._41 * M2._12 + M1._42 * M2._22 + M1._43 * M2._32 + M1._44 * M2._42;
    ret._43 = M1._41 * M2._13 + M1._42 * M2._23 + M1._43 * M2._33 + M1._44 * M2._43;
    ret._44 = M1._41 * M2._14 + M1._42 * M2._24 + M1._43 * M2._34 + M1._44 * M2._44;
    return ret;
}

static FTransform getMatrixConversion(uintptr_t address){
    static FTransform ret;
    readMemory(address, sizeof(float), &ret.Rotation.X);
    readMemory(address+4, sizeof(float), &ret.Rotation.Y);
    readMemory(address+8, sizeof(float), &ret.Rotation.Z);
    readMemory(address+12, sizeof(float), &ret.Rotation.W);
    
    readMemory(address+16, sizeof(float), &ret.Translation.X);
    readMemory(address+20, sizeof(float), &ret.Translation.Y);
    readMemory(address+24, sizeof(float), &ret.Translation.Z);
    
    readMemory(address+32, sizeof(float), &ret.Scale3D.X);
    readMemory(address+36, sizeof(float), &ret.Scale3D.Y);
    readMemory(address+40, sizeof(float), &ret.Scale3D.Z);
    
    return ret;
}

static FVector3D getBoneWithRotation(uintptr_t mesh, int Id, FTransform publicObj){
    static FTransform BoneMatrix;
    static FVector3D output = {0, 0, 0};
    
    uintptr_t addr;
    if (!readMemory(mesh + 0x6c0, sizeof(uintptr_t), &addr)) {
        return output;
    }
    BoneMatrix = getMatrixConversion(addr + Id * 0x30);
    
    D3DXMATRIX LocalSkeletonMatrix =toMatrixWithScale(BoneMatrix.Rotation, BoneMatrix.Translation, BoneMatrix.Scale3D);
    
    D3DXMATRIX PartTotheWorld = toMatrixWithScale(publicObj.Rotation, publicObj.Translation, publicObj.Scale3D);
    
    D3DXMATRIX NewMatrix = matrixMultiplication(LocalSkeletonMatrix, PartTotheWorld);
    
    FVector3D BoneCoordinates;
    BoneCoordinates.X = NewMatrix._41;
    BoneCoordinates.Y = NewMatrix._42;
    BoneCoordinates.Z = NewMatrix._43;
    
    return BoneCoordinates;
}

static FVector3D getRelativeLocation(uintptr_t actor){
    uintptr_t RootComponent = Read<uintptr_t>(actor + 0x268);
    static FVector3D value;
    readMemory(RootComponent + 0x1b0, sizeof(FVector3D), &value);
    return value;
}

#pragma mark - 读取游戏数据-OC
static uintptr_t Gworld;
static uintptr_t GName;
static uintptr_t GBase;
//读取进程
bool getGame(){
    NSString*gameName = @"ShadowTrackerExt";
    pid_t gamePid = getProcesses(gameName);
    if (gamePid != -1) {
        task = getTask(gamePid);
        if (task) {
            GBase = getBaseAddress(task);
            if (GBase) {
                // 读取世界
                Gworld = Read<uintptr_t>(GBase + 0xB064888);
                GName = Read<uintptr_t>(GBase + 0xACBF728);
                return YES;
            }
        }
    }
    
    return NO;
}
//读取玩家数组
static NSArray *drArray;
static NSArray *wzArray;
- (void)getNSArray {
    NSMutableArray *drtempArr = [NSMutableArray array];
    NSMutableArray *wztempArr = [NSMutableArray array];
    Gworld = Read<uintptr_t>(GBase + 0xB064888);
    GName = Read<uintptr_t>(GBase + 0xACBF728);
    if (!isValidAddress(Gworld))return;
    
    const float hpValues[] = {100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200};
    const int hpValueCount = sizeof(hpValues) / sizeof(float);
    
    uint64_t level = Read<uintptr_t>(Gworld + 0x90);
    uint64_t actorArray = Read<uintptr_t>(level + 0xA0);
    int actorCount = Read<int>(level + 0xA8);
    
    for (int i = 0; i < actorCount; i++) {
        uintptr_t actor = Read<uintptr_t>(actorArray + i * 8);
        if (!actor) continue;
        int FNameID = Read<int>(actor + 0x18);
        NSString* ClassName = getFNameFromID(GName, FNameID);
        if (![ClassName containsString:@"PlayerPawn"]) {
            [wztempArr addObject:@(actor)];//存储玩家数组
        }else{
            bool bDead = Read<bool>(actor + 0xdc8) & 1;
            if (bDead) continue;
            float hpmax = Read<float>(actor + 0xd68);
            for (int j = 0; j < hpValueCount; j++) {
                if (hpmax == hpValues[j]) {
                    [drtempArr addObject:@(actor)];//存储玩家数组
                }
                
            }
        }
    }
    drArray = [drtempArr copy];
    wzArray = [wztempArr copy];
    
    
}
//读取玩家
NSString* MyName;
- (NSMutableString *)getData {
    static int Bones[18] = {6,5,4,3,2,1,12,13,14,33,34,35,53,54,55,57,58,59};
    static FVector2D Bones_Pos[18];
    static NSMutableString *敌人数据 =[NSMutableString stringWithCapacity:1024];
    int paixu=1;
    int myTeam = 0;
    [敌人数据 setString:@""];
    
    // 获取视角信息
    uintptr_t NetDriver = Read<uintptr_t>(Gworld + 0x98);
    if (!isValidAddress(NetDriver))return 敌人数据;
    uintptr_t ServerConnection = Read<uintptr_t>(NetDriver + 0x88);
    if (!isValidAddress(ServerConnection))return 敌人数据;
    uintptr_t PlayerController = Read<uintptr_t>(ServerConnection + 0x30);
    uintptr_t MyTeamID = Read<uintptr_t>(PlayerController + 0x9a8);
    uintptr_t PlayerCameraManager = Read<uintptr_t>(PlayerController + 0x5c0);
    if (!isValidAddress(PlayerCameraManager))return 敌人数据;
    readMemory(PlayerCameraManager + 0x1140 + 0x10, sizeof(FMinimalViewInfo), &POV);
    
    for (int i = 0; i < drArray.count; i++) {
        uintptr_t player = [drArray[i] unsignedLongLongValue];
        if (!isValidAddress(player))continue;
        bool bDead = Read<bool>(player + 0xdc8) & 1;
        if (bDead) continue;
        
        // 读取玩家模型数据
        PlayerData modelItem;
        modelItem.PlayerName = getPlayerName(player);
        if (modelItem.PlayerName.length < 1) continue;
        modelItem.TeamID = Read<int>(player + 0xa48);
        modelItem.isAI = Read<BOOL>(player + 0xa64) != 0;
        modelItem.Health = Read<float>(player + 0xd60) / Read<float>(player + 0xd68) * 100;
        if (modelItem.isAI) modelItem.PlayerName = @"Ai_人机";
        
        // 计算距离
        FVector3D WorldLocation = getRelativeLocation(player);
        if (WorldLocation.X<0 || WorldLocation.Y<0) continue;
        modelItem.X = WorldLocation.X;
        modelItem.Y = WorldLocation.Y;
        modelItem.Z = WorldLocation.Z;
        modelItem.Distance = getDistance(WorldLocation, POV.Location) / 100;
        
        // 判断自己和队友
        int MyTeamID = Read<int>(PlayerController + 0x9a8);
        if (modelItem.TeamID == MyTeamID || MyName == nil ) {
            MyName = modelItem.PlayerName;

        }
       
        if([modelItem.PlayerName isEqual:MyName]){
            myTeam = modelItem.TeamID;
        }
        if (modelItem.TeamID == myTeam) modelItem.PlayerName = [NSString stringWithFormat:@"自己队友%d", paixu++];
        [敌人数据 appendFormat:@"%ld,%@,%.0f,%.2f,%.2f,%.2f,%.1f",(long)modelItem.TeamID, modelItem.PlayerName, modelItem.Health, modelItem.X / 100, modelItem.Y / 100, modelItem.Z / 100, modelItem.Distance];
        // 计算骨骼位置
        uintptr_t Mesh = Read<uintptr_t>(player + 0x5b8);
        FTransform RelativeScale3D = getMatrixConversion(Mesh + 0x194 +0xC);
        for (int j = 0; j < 18; j++) {
            FVector3D boneWorldLocation = getBoneWithRotation(Mesh, Bones[j], RelativeScale3D);
            Bones_Pos[j] = worldToScreen(boneWorldLocation, POV, self.canvas);
            modelItem.gg[j]=Bones_Pos[j];
            [敌人数据 appendFormat:@",%.d,%.d", modelItem.gg[j].X, modelItem.gg[j].Y];
        }
        [敌人数据 appendFormat:@"\n"];
        
    }
    
    return 敌人数据;
}
// 读取物资数据
- (NSMutableString *)getwzData {
    static NSMutableString *物资数据 =[NSMutableString stringWithCapacity:1024];
    [物资数据 setString:@""];
    //分配一次静态变量
    static NSString *NewName = @"";
    static NSString *ClassName = @"";
    @autoreleasepool {
        for (int i = 0; i < wzArray.count; i++) {
            uintptr_t player = [wzArray[i] unsignedLongLongValue];
            if (!player) continue;
            int FNameID = Read<int>(player + 0x18);
            ClassName = getFNameFromID(GName, FNameID);
            if (![ClassName containsString:@"PlayerPawn"]) {
                NewName = [self reName:ClassName];
                if (NewName.length<2) continue;
                FVector3D WorldLocation = getRelativeLocation(player);
                [物资数据 appendFormat:@"%@,%.1f,%.1f,%.1f\n", NewName, (WorldLocation.X) / 100, (WorldLocation.Y) / 100, (WorldLocation.Z) / 100];
            }
        }
    }
    
    return 物资数据;
}


//物资名字优化
static NSDictionary *vehicleNames = nil;

-(NSString*)reName:(NSString*)NameStr
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        vehicleNames = @{
            //枪械
            @"MG3BP_Other_MG3_C" : @"[好东西]MG3",
            @"BP_Rifle_HoneyBadger_C" : @"蜜獾步枪",
            @"BP_ShotGun_S12K_C" : @"S12K",
            @"BP_ShotGun_S686_C" : @"S686",
            @"BP_Sniper_MK12_C" : @"MK12",
            @"BP_MachineGun_PP19_C" : @"野牛冲锋枪",
            @"BP_MachineGun_UMP9_C" : @"UMP9",
            @"BP_MachineGun_P90CG17_C" : @"[好东西]P90",
            @"BP_MachineGun_Vector_C" : @"维克托",
            @"BP_MachineGun_Uzi_C" : @"Uzi",
            @"BP_Other_DP28_C" : @"大盘鸡",
            @"BP_Other_HuntingBow_C" : @"爆炸烈弓",
            @"BP_Other_M249_C" : @"大菠萝",
            @"BP_Rifle_AKM_C" : @"AKM",
            @"BP_Rifle_AUG_C" : @"AUG",
            @"BP_Rifle_Groza_C" : @"[好东西]Groza",
            @"BP_Rifle_M416_C" : @"M416",
            @"BP_Rifle_M417_C" : @"M417",
            @"BP_Rifle_Mk47_C" : @"Mk47",
            @"BP_Rifle_QBZ_C" : @"QBZ",
            @"BP_Rifle_SCAR_C" : @"SCAR-L",
            @"BP_Sniper_AWM_C" : @"[好东西]AWM",
            @"BP_Sniper_Kar98k_C" : @"Kar98k",
            @"BP_Sniper_M200_C" : @"M200",
            @"BP_Sniper_M24_C" : @"M24",
            @"BP_Sniper_Mk14_C" : @"Mk14",
            @"BP_Sniper_SKS_C" : @"SKS",
            @"BP_Sniper_VSS_C" : @"VSS",
            @"BP_Rifle_M16A4_C" : @"M16A4",
            @"BP_Rifle_M762_C" : @"M762",
            @"BP_Rifle_VAL_C" : @"VAL",
            @"BP_WEP_Mk14_Pickup_C" : @"Mk14",
            @"MovingTargetRoom_1574_AWM_Wrapper1_CA" : @"[好东西]AWM",
            @"BP_Other_PKM_C" : @"PKM轻机枪",
            //倍镜
            @"BP_MZJ_HD_Pickup_C" : @"红点",
            @"BP_MZJ_QX_Pickup_C" : @"全息",
            @"BP_MZJ_2X_Pickup_C" : @"2倍瞄准镜",
            @"BP_MZJ_3X_Pickup_C" : @"3倍瞄准镜",
            @"BP_MZJ_4X_Pickup_C" : @"4倍瞄准镜",
            @"BP_MZJ_6X_Pickup_C" : @"[好东西]6倍瞄准镜",
            @"BP_MZJ_8X_Ballistics_Pickup_C" : @"[好东西]8倍瞄准镜",
            
            //背包
            @"PickUp_BP_Bag_Lv1_C" : @"一级包",
            @"PickUp_BP_Bag_Lv1_B_C" : @"一级包",
            @"PickUp_BP_Bag_Lv2_C" : @"二级包",
            @"PickUp_BP_Bag_Lv2_B_C" : @"二级包",
            @"PickUp_BP_Bag_Lv3_C" : @"[好东西]三级包",
            @"PickUp_BP_Bag_Lv3_B_C" : @"[好东西]三级包",
            
            //头盔
            @"PickUp_BP_Helmet_Lv1_C" : @"一级头",
            @"PickUp_BP_Helmet_Lv1_B_C" : @"一级头",
            @"PickUp_BP_Helmet_Lv2_C" : @"二级头",
            @"PickUp_BP_Helmet_Lv2_B_C" : @"二级头",
            @"PickUp_BP_Helmet_Lv3_C" : @"[好东西]三级头",
            @"PickUp_BP_Helmet_Lv3_B_C" : @"[好东西]三级头",
            
            //护甲
            @"PickUp_BP_Armor_Lv1_C" : @"一级甲",
            @"PickUp_BP_Armor_Lv2_C" : @"二级甲",
            @"PickUp_BP_Armor_Lv3_C" : @"[好东西]三级甲",
            
            //载具
            @"VH_BRDM_C" : @"装甲车",
            @"VH_CoupeRB_1_C" : @"双座跑车",
            @"VH_Dacia_New_C" : @"轿车",
            @"VH_Mountainbike_Training_C" : @"自行车",
            @"PickUp_BP_Mountainbike1_C" : @"自行车",
            @"Skill_Spawn_Mountaibike_C" : @"自行车",
            @"VH_Mountainbike_C" : @"自行车",
            @"VH_StationWagon_C" : @"旅行车",
            @"VH_Dacia_3_New_" : @"轿车",
            
            @"VH_PG117_C" : @"大船",
            @"VH_Scooter_C" : @"小绵羊",
            @"VH_UAZ01_New_C" : @"吉普",
            @"VH_Dacia_3_New_C" : @"吉普",
            
            @"BP_VH_Buggy_C" : @"蹦蹦",
            @"BP_VH_Buggy_3_C" : @"蹦蹦",
            @"BP_VH_Buggy_2_C" : @"蹦蹦",
            
            @"AquaRail_1_C" : @"冲锋艇",
            @"BP_VH_Bigfoot_C" : @"大脚车",
            @"Rony_01_C" : @"皮卡",
            @"Rony_3_C" : @"皮卡",
            @"Rony_2_C" : @"皮卡",
            @"VH_Motorcycle_C" : @"摩托车",
            @"PickUp_BP_VH_SplicedTrain_C" : @"磁吸小火车",
            @"GasCanBattery_Destructible_Pickup_C" : @"汽油桶",
            
            
            //药品
            @"Bandage_Pickup_C" : @"绷带",
            @"Skill_Bandage_BP_C" : @"绷带",
            @"Skill_Painkiller_BP_C" : @"止疼药",
            @"Injection_Pickup_C" : @"肾上腺素",
            @"Skill_AdrenalineSyringe_BP_C" : @"肾上腺素",
            @"Firstaid_Pickup_C" : @"急救包",
            @"FirstAidbox_Pickup_C" : @"医疗箱",
            @"BP_revivalAED_Pickup_C" : @"[好东西]自救器",
            
            @"Drink_Pickup_C" : @"能量饮料",
            @"Skill_EnergyDrink_BP_C" : @"能量饮料",
            @"AttachActor_EnergyDrink_BP_C" : @"能量饮料",
            //子弹
            @"BP_Ammo_556mm_Pickup_C" : @"[子弹]556",
            @"BP_Ammo_762mm_Pickup_C" : @"[子弹]762",
            @"BP_Ammo_9mm_Pickup_C" : @"[子弹]9毫米",
            @"BP_Ammo_300Magnum_Pickup_C" : @"[子弹]ARM子弹",
            @"BP_Ammo_50BMG_Pickup_C" : @"[子弹].50子弹",
            @"BP_Ammo_45ACP_Pickup_C" : @"[子弹].45子弹",
            
            //配件
            @"BP_DJ_Large_E_Pickup_C" : @"步枪扩容",
            @"BP_DJ_Large_Q_Pickup_C" : @"步枪快速弹夹",
            @"BP_QK_Large_Compensator_Pickup_C" : @"步枪补偿器",
            @"BP_QK_Large_FlashHider_Pickup_C" : @"步枪消焰器",
            @"BP_WB_Angled_Pickup_C" : @"直角前握把",
            @"BP_WB_HalfGrip_Pickup_C" : @"半截红握把",
            @"BP_WB_LightGrip_Pickup_C" : @"轻型握把",
            @"BP_WB_Vertical_Pickup_C" : @"垂直握把",
            @"BP_WB_ThumbGrip_Pickup_C" : @"拇指握把",
            @"BP_QT_ZH_Pickup_C" : @"撞火枪托",
            @"BP_QT_A_Pickup_C" : @"战术枪托",
            @"BP_QT_Sniper_Pickup_C" : @"托腮板",
            @"BP_QK_DuckBill_Pickup_C" : @"鸭嘴",
            @"BP_QK_Large_Suppressor_Pickup_C" : @"狙击消音器",
            @"BP_QK_Sniper_FlashHider_Pickup_C" : @"狙击消焰器",
            @"BP_DJ_Sniper_Q_Pickup_C" : @"狙击快速弹夹",
            @"QK_Sniper_Compensator" : @"狙击补偿",
            @"BP_QK_Sniper_Compensator_Pickup_C" : @"狙击补偿",
            
            
            @"BP_QK_Mid_Compensator_Pickup_C" : @"冲锋枪补偿器",
            @"BP_QK_Mid_Suppressor_Pickup_C" : @"冲锋枪消音器",
            @"BP_QK_Mid_FlashHider_Pickup_C" : @"冲锋枪消焰器",
            @"BP_QT_UZI_Pickup_C" : @"UZI枪托",
            
            //其他物品
            @"BP_AirDropBox_C" : @"空投箱",
            @"BP_Pistol_Flaregun_Wrapper_C" : @"信号枪",
            @"AirDropListWrapperActor" : @"空投箱",
            @"BP_AirDropPlane_C" : @"空投飞机",
            @"BP_Grenade_EmergencyCall_Weapon_C" : @"紧急呼救器",
            @"BP_EmergencyCall_ChildActor_C" : @"紧急呼救器",
            @"BP_WEP_Sickle_Pickup_C" : @"镰刀",
            @"BP_WEP_Pan_C" : @"平底锅",
            
            
            @"BP_Grenade_Shoulei_Weapon_Wrapper_C" : @"手雷",
            @"BP_Grenade_Burn_Weapon_Wrapper_C" : @"手雷",
            @"BP_Grenade_Smoke_Weapon_Wrapper_C" : @"烟雾弹",
            
            @"BP_Grenade_Stun_Weapon_C" : @"手雷",
            @"BP_Grenade_Burn_Weapon_C" : @"手雷",
            @"ProjGrenade_BP_C" : @"手雷",
            @"CharacterDeadInventoryBox_C" : @"骨灰盒",
            @"BP_RevivalTower_CG22_C" : @"复活基站"
            
        };
    });
//    if ([vehicleNames objectForKey:NameStr]==nil) {
//        return NameStr;
//    }
    return [vehicleNames objectForKey:NameStr];
}

@end
