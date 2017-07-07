//
//  AEConstants.h
//  AnimationEffect
//
//  Created by fanglei on 2017/6/28.
//  Copyright © 2017年 FangLei. All rights reserved.
//

#ifndef AEConstants_h
#define AEConstants_h

typedef NS_ENUM(NSUInteger, AEMode) {
    AEMode_TimeOffset,
    AEMode_Ordinary
};

typedef NS_ENUM(NSUInteger, AEType) {
    AEType_FadeIn,  // 淡入
    AEType_FadeOut, // 淡出
    AEType_Wipe,    // 擦出
    AEType_ZoomIn,  // 缩放
    AEType_ZoomOut, // 缩小
    AEType_Rotate,  // 旋转
    AEType_Spark,   // 闪烁
    AEType_Typing,  // 打字效果
    AEType_ChangeTextColor, // 文字变色
    AEType_ChangeTextBgColor,// 文字背景色变色
    AEType_Underlining // 下划线
};

typedef NS_ENUM(NSUInteger, AEWipeDirection) {
    AEWipe_TopToBottom,
    AEWipe_BottomToTop,
    AEWipe_LeadingToTrialing,
    AEWipe_TrialingToLeading,
    AEWipe_Clockwise,
    AEWipe_Anticlockwise,
};

typedef NS_ENUM(NSUInteger, AETypingMode) {
    AETyping_Letter,
    AETyping_Word,
};

#pragma mark - default values
#define AEMinimumScalingDefault (1/1000000.0)
#define AEMaximumScalingDefault 1.5
#define AERotationDegreeDefault (M_PI * 2)
#define AEWipeDirectionDefault AEWipe_Clockwise
#define AEMinimumOpacityDefault 0.5
#define AEDefaultTimeInterval 0.1

#endif /* AEConstants_h */
