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
@property (assign, nonatomic) NSTimeInterval beginTimeStamp;
@property (assign, nonatomic) NSTimeInterval duration;
@property (assign, nonatomic, getter = isAutoRun) BOOL autoRun;

/**
 default is NO
 */
@property (assign, nonatomic) BOOL removeEffectOnComplete;

/**
 default is 1
 */
@property (assign, nonatomic) CGFloat fromValue;

/**
 default is 1
 */
@property (assign, nonatomic) CGFloat toValue;

/**
 default is 0
 */
@property (assign, nonatomic) CGFloat byValue;

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
