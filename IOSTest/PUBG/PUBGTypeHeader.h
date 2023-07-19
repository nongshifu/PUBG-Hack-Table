//
//  PUBGTypeHeader.h
//  ChatsNinja
//
//  Created by TianCgg on 2022/10/2.
//

#ifndef PUBGTypeHeader_h
#define PUBGTypeHeader_h

typedef struct GameInfo {
    NSString *name;
    pid_t pid;
    mach_port_t task;
    uintptr_t base;
    int wztime;
} GameInfo;

typedef struct FVector2D {
    int X;
    int Y;
} FVector2D;

typedef struct FVector3D {
    float X;
    float Y;
    float Z;
} FVector3D;

typedef struct FVector4D {
    float X;
    float Y;
    float Z;
    float W;
} FVector4D;

typedef struct FVectorRect {
    float X;
    float Y;
    float W;
    float H;
} FVectorRect;

typedef struct FRotator {
    float Pitch;
    float Yaw;
    float Roll;
} FRotator;

typedef struct FMinimalViewInfo {
    FVector3D Location;
    FVector3D LocationLocalSpace;
    FRotator Rotation;
    float FOV;
} FMinimalViewInfo;

typedef struct FCameraCacheEntry {
    float TimeStamp;
    FMinimalViewInfo POV;
} FCameraCacheEntry;

typedef struct D3DXMATRIX {
    float _11, _12, _13, _14;
    float _21, _22, _23, _24;
    float _31, _32, _33, _34;
    float _41, _42, _43, _44;
} D3DXMATRIX;

typedef struct BonesStruct {
    FVector3D BonePos[22];
    FVector2D DrawPos[22];
    bool Visibles[22];
    bool Visible;
} BonesStruct;

typedef struct FTransform {
    FVector4D Rotation;
    FVector3D Translation;
    FVector3D Scale3D;
} FTransform;
struct PlayerData{
    int TeamID;
    
    NSString *PlayerName;
    // 距离
    CGFloat  Distance;
    // 血量
    CGFloat  Health;
    CGFloat MaxHealth;
    //人机
    BOOL isAI;
    //地图坐标
    CGFloat  X;
    CGFloat  Y;
    CGFloat  Z;
    //骨骼
    FVector2D gg[17];
    FVector2D  _0;
    FVector2D  _1;
    FVector2D  _2;
    FVector2D  _3;
    FVector2D  _4;
    FVector2D  _5;
    FVector2D  _6;
    FVector2D  _7;
    FVector2D  _8;
    FVector2D  _9;
    FVector2D  _10;
    FVector2D  _11;
    FVector2D  _12;
    FVector2D  _13;
    FVector2D  _14;
    FVector2D  _15;
    FVector2D  _16;
    FVector2D  _17;
    
};

#endif /* PUBGTypeHeader_h */
