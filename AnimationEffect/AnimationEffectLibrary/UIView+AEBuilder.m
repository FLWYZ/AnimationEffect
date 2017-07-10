//
//  UIView+AEBuilder.m
//  AnimationEffect
//
//  Created by fanglei on 2017/6/28.
//  Copyright © 2017年 FangLei. All rights reserved.
//

#import "UIView+AEBuilder.h"
#import "UIView+AnimationEffect.h"
#import "UILabel+AEExtension.h"
#import "AEParam.h"
#import "AEViewParam.h"
#import "AERunInfo.h"

static inline BOOL __AESupportPartialTextAnimation(UIView *view, AEParam *param) {
    if ([view isKindOfClass:[UILabel class]] == NO ||
        [param isKindOfClass:[AETextSeriesParam class]] == NO) {
        return NO;
    }
    UILabel *label = (UILabel *)view;
    return ((AETextSeriesParam *)param).effectRange.length != label.attributedText.length;
}

static inline AETextRunInfo *__AECreateTextRunInfo(UIView *view ,AEParam *param) {
    AETextRunInfo *textRunInfo = [[AETextRunInfo alloc] initWithParam:param];
    textRunInfo.animationView = view;
    return textRunInfo;
}

static inline AERunInfo *__AECreateRunInfo(UIView *view ,AEParam *param) {
    AERunInfo *runInfo = [[AERunInfo alloc] initWithParam:param];
    runInfo.animationView = view;
    return runInfo;
}

@implementation UIView (AEBuilder)

- (AERunInfo *)buildAnimationEffectWithParam:(AEParam *)param {
    AERunInfo *runInfo = nil;
    switch (param.type) {
        case AEType_Default:
        {
            runInfo = [[AERunInfo alloc] initWithParam:param];
            runInfo.animationView = self;
        }
            break;
        case AEType_FadeIn:
        case AEType_FadeOut:
            runInfo = [self buildFadeAnimationEffect:param];
            break;
        case AEType_Zoom:
        case AEType_ZoomIn:
        case AEType_ZoomOut:
            runInfo = [self buildZoomAnimationEffect:param];
            break;
        case AEType_Rotate:
            runInfo = [self buildRotateAnimationEffect:param];
            break;
        case AEType_Spark:
            runInfo = [self buildSparkAnimationEffect:param];
            break;
        case AEType_Wipe:
            runInfo = [self buildWipeAnimationEffect:param];
            break;
        case AEType_Typing:
            runInfo = [self buildTypingAnimationEffect:param];
            break;
        case AEType_ChangeTextColor:
            runInfo = [self buildChangeTextColorAnimationEffect:param];
            break;
        case AEType_ChangeTextBgColor:
            runInfo = [self buildChangeTextBgColorAnimationEffect:param];
            break;
        case AEType_Underlining:
            runInfo = [self buildUnderliningAnimationEffect:param];
            break;
        default:
            break;
    }
    return runInfo;
}

#pragma mark - private

- (AERunInfo *)buildFadeAnimationEffect:(AEParam *)param {
    CGFloat (^opacity)(AERunInfo *runInfo) = ^CGFloat(AERunInfo *runInfo){
        CGFloat opacityPerSec = 1.0 / runInfo.animationDuration;
        CGFloat currentOpacity = runInfo.param.type == AEType_FadeIn ? (opacityPerSec * runInfo.animationPassedTime) : (1 - opacityPerSec * runInfo.animationPassedTime);
        return currentOpacity;
    };
    if (__AESupportPartialTextAnimation(self, param)) { // 支持局部文本动效
        AETextRunInfo *textRunInfo = __AECreateTextRunInfo(self, param);
        __weak typeof(textRunInfo) weakTextRunInfo = textRunInfo;
        textRunInfo.runtimeEffectRangBlock = [self runtimeTextRangType1:textRunInfo];
        textRunInfo.runtimeTextAttributeBlock = ^NSMutableDictionary *(NSMutableDictionary *attribute) {
            __strong typeof(weakTextRunInfo) strongTextRunInfo = weakTextRunInfo;
            UIColor *textColor = attribute[NSForegroundColorAttributeName];
            UIColor *textBgColor = attribute[NSBackgroundColorAttributeName];
            CGFloat currentOpacity = opacity(strongTextRunInfo);
            if (textColor) {
                textColor = [textColor colorWithAlphaComponent:currentOpacity];
                attribute[NSForegroundColorAttributeName] = textColor;
            }
            if (textBgColor) {
                textBgColor = [textBgColor colorWithAlphaComponent:currentOpacity];
                attribute[NSBackgroundColorAttributeName] = textBgColor;
            }
            return attribute;
        };
        return textRunInfo;
    } else { // 不支持局部文本动效
        AERunInfo *runInfo = __AECreateRunInfo(self, param);
        __weak typeof(runInfo) weakRunInfo = runInfo;
        runInfo.animationRunBlock = ^(NSTimeInterval timeOffset, AEViewParam *viewParam) {
            __strong typeof(weakRunInfo) strongRunInfo = weakRunInfo;
            [strongRunInfo configuratePassedTime:timeOffset];
            viewParam.opacity = opacity(strongRunInfo);
        };
        return runInfo;
    }
}

- (AERunInfo *)buildZoomAnimationEffect:(AEParam *)param {
    AERunInfo *runInfo = __AECreateRunInfo(self, param);
    CGFloat (^scale)(AERunInfo *runInfo) = ^CGFloat(AERunInfo *runInfo){
        
    };
}

- (AERunInfo *)buildRotateAnimationEffect:(AEParam *)param {
    
}

- (AERunInfo *)buildSparkAnimationEffect:(AEParam *)param {
    
}

- (AERunInfo *)buildWipeAnimationEffect:(AEParam *)param {
    
}

- (AERunInfo *)buildTypingAnimationEffect:(AEParam *)param {
    
}

- (AERunInfo *)buildChangeTextColorAnimationEffect:(AEParam *)param {
    
}

- (AERunInfo *)buildChangeTextBgColorAnimationEffect:(AEParam *)param {
    
}

- (AERunInfo *)buildUnderliningAnimationEffect:(AEParam *)param {
    
}

#pragma mark - effect range block
/**
 动画效果直接起效：文字渐隐，文字渐显，文字闪烁
 */
- (NSRange (^)(NSTimeInterval))runtimeTextRangType1:(AETextRunInfo *)textRunInfo {
    __weak typeof(textRunInfo) weakTextRunInfo = textRunInfo;
    return ^NSRange(NSTimeInterval timeOffset){
        __strong typeof(weakTextRunInfo) strongTextRunInfo = weakTextRunInfo;
        [strongTextRunInfo configuratePassedTime:timeOffset];
        if (strongTextRunInfo.param.isAutoRun) {
            return strongTextRunInfo.effectRange;
        } else {
            if (strongTextRunInfo.animationPassedTime > strongTextRunInfo.animationBeginTime) {
                return strongTextRunInfo.effectRange;
            }
        }
        return NSMakeRange(0, 0);
    };
}

/**
 动画效果逐渐起效：文字变色， 文字变背景色，下划线
 */
- (NSRange (^)(NSTimeInterval))runtimeTextRangType2:(AETextRunInfo *)textRunInfo {
    __weak typeof(textRunInfo) weakTextRunInfo = textRunInfo;
    return ^NSRange(NSTimeInterval timeOffset){
        __strong typeof(weakTextRunInfo) strongTextRunInfo = weakTextRunInfo;
        [strongTextRunInfo configuratePassedTime:timeOffset];
        if (strongTextRunInfo.param.isAutoRun ||
            strongTextRunInfo.animationPassedTime > strongTextRunInfo.animationBeginTime) {
            if (strongTextRunInfo.animationPassedTime >= strongTextRunInfo.animationCompleteTime) {
                return strongTextRunInfo.effectRange;
            } else if (strongTextRunInfo.animationPassedTime <= 0) {
                return NSMakeRange(0, 0);
            } else {
                NSInteger letterSummary = strongTextRunInfo.effectRange.length;
                CGFloat speed = (letterSummary * 1.0) / (strongTextRunInfo.animationDuration);
                NSInteger effectLength = (NSInteger)(speed * strongTextRunInfo.animationPassedTime);
                return NSMakeRange(strongTextRunInfo.effectRange.location, effectLength);
            }
        }
        return NSMakeRange(0, 0);
    };
}


@end

