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

@property (assign, nonatomic) AEType animationType;
@property (assign, nonatomic) NSTimeInterval startTimeStamp;
@property (assign, nonatomic) NSTimeInterval duration;

/**
 for zooming animation, default is (1/1000000.0)
 */
@property (assign, nonatomic) CGFloat minimumScaling;

/**
 for zooming animation, default is 1.5
 */
@property (assign, nonatomic) CGFloat maximumScaling;

/**
 for rotate animation, default is 2π
 */
@property (assign, nonatomic) CGFloat rotationDegree;

/**
 for wipe animation. default is AEWipe_Clockwise
 */
@property (assign, nonatomic) AEWipeDirection wipeDirection;

/**
 for spark animation, from 0 to 1, defalut is 0.5
 */
@property (assign, nonatomic) CGFloat minimumOpacity;

/**
 for partial text animations, default is 0
 */
@property (assign, nonatomic) NSUInteger partialTextStartLetterIndex;

/**
 for partial text animations, default is the end of the string
 */
@property (assign, nonatomic) NSUInteger partialTextEndLetterIndex;

/**
 for typing aniamtion, default is AETyping_Letter
 */
@property (assign, nonatomic) AETypingMode typingMode;

/**
 for ChangeTextColor aniamtion
 */
@property (nonatomic) UIColor *textNewColor;

/**
 for ChangeTextBgColor animation
 */
@property (nonatomic) UIColor *textNewBgColor;

/**
 defalut is NO
 */
@property (assign, nonatomic) BOOL removAnimationOnCompletion;

/**
 default is kCAFillModeForwards
 */
@property (copy, nonatomic) NSString *fillMode;

@property (assign, nonatomic, readonly) NSRange partialTextEffectRange;

@end

