//
//  UIView+AnimationEffect.h
//  AnimationEffect
//
//  Created by fanglei on 2017/6/28.
//  Copyright © 2017年 FangLei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AEParam;
@class AERunInfo;
@class AEPartialTextEffectRunInfo;

@interface UIView (AnimationEffect)

@property (strong, nonatomic, readonly) NSMutableArray<__kindof AERunInfo*> *runInfoArray;
@property (strong, nonatomic, readonly) NSMutableArray<__kindof AEPartialTextEffectRunInfo*> *typingRunInfoArray;
@property (strong, nonatomic, readonly) NSMutableArray<__kindof AEPartialTextEffectRunInfo*> *partialTextEffectRunInfoArray;

- (void)addAnimationEffect:(AEParam *)param identify:(NSString *)identify;

- (void)removeAnimationEffect;

@end
