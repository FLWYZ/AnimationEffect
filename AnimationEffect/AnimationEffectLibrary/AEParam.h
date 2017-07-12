//
//  AEParam.h
//  AnimationEffect
//
//  Created by fanglei on 2017/6/28.
//  Copyright © 2017年 FangLei. All rights reserved.
//  动效参数

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AEConstants.h"

@interface AEParam : NSObject

@property (assign, nonatomic) AEType type;
@property (assign, nonatomic) NSTimeInterval duration;

/**
 动效开始生效时间戳
 */
@property (assign, nonatomic) NSTimeInterval beginTimeStamp;

/**
 如果设置为 yes，那么动效立刻生效
 如果设置为 no，那么动效在到达 beginTimeStamp 的时候生效
 */
@property (assign, nonatomic, getter = isRunDirectly) BOOL runDirectly;

/**
 default is NO
 */
@property (assign, nonatomic) BOOL removeEffectOnComplete;

@property (copy, nonatomic) NSNumber* fromValue;
@property (copy, nonatomic) NSNumber* toValue;
@property (copy, nonatomic) NSNumber* byValue;

@property (assign, nonatomic, readonly) CGFloat initialValue;
@property (assign, nonatomic, readonly) CGFloat terminalValue;
@property (assign, nonatomic, readonly) CGFloat deltaPerSec;

- (void)prepareValues;

@end

@interface AEWipeParam : AEParam

@property (assign, nonatomic) AEWipeDirection direction;

@end

@interface AERotateParam : AEParam

@property (assign, nonatomic) AERotateAxis axis;

@end

@interface AETextSeriesParam : AEParam

@property (assign, nonatomic) AETypingMode typingMode;
@property (assign, nonatomic) NSRange effectRange;
@property (copy, nonatomic) UIColor *textColor;
@property (copy, nonatomic) UIColor *textBgColor;
@property (copy, nonatomic) UIColor *textUnderlineColor;

@end
