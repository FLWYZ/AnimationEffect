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
        case AEType_Custom:
        {
            runInfo = [[AERunInfo alloc] initWithParam:param];
            runInfo.animationView = self;
        }
            break;
        case AEType_FadeIn:
        case AEType_FadeOut:
        case AEType_Spark:
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
    CGFloat (^opacity)(AERunInfo *) = ^CGFloat(AERunInfo *runInfo){
        if (param.type == AEType_Spark && runInfo.animationPassedTime >= runInfo.animationDuration/2) {
            return param.terminalValue - (runInfo.animationPassedTime - runInfo.animationDuration / 2) * param.deltaPerSec;
        } else {
            return (param.initialValue + param.deltaPerSec * runInfo.animationPassedTime);
        }
    };
    if (__AESupportPartialTextAnimation(self, param)) { // 支持局部文本动效
        AETextRunInfo *textRunInfo = __AECreateTextRunInfo(self, param);
        textRunInfo.runtimeEffectRangBlock = [self runtimeTextRangType1:textRunInfo];
        __weak typeof(textRunInfo) weakTextRunInfo = textRunInfo;
        textRunInfo.runtimeAttributeBlock = ^NSMutableDictionary *(NSMutableDictionary *attribute) {
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
        runInfo.animationRunBlock = ^(NSTimeInterval timeOffset, NSTimeInterval timeInterval, AEViewParam *viewParam) {
            __strong typeof(weakRunInfo) strongRunInfo = weakRunInfo;
            [strongRunInfo configuratePassedTime:timeOffset timeInterval:timeInterval];
            viewParam.opacity = opacity(strongRunInfo);
        };
        return runInfo;
    }
}

- (AERunInfo *)buildZoomAnimationEffect:(AEParam *)param {
    AERunInfo *runInfo = __AECreateRunInfo(self, param);
    __weak typeof(runInfo) weakRunInfo = runInfo;
    runInfo.animationRunBlock = ^(NSTimeInterval timeOffset,NSTimeInterval timeInterval, AEViewParam *viewParam) {
        __strong typeof(weakRunInfo) strongRunInfo = weakRunInfo;
        [strongRunInfo configuratePassedTime:timeOffset timeInterval:timeInterval];
        CGFloat scale = 0;
        if (param.type == AEType_Zoom && strongRunInfo.animationPassedTime >= strongRunInfo.animationDuration / 2) {
            scale = param.terminalValue - (strongRunInfo.animationPassedTime - strongRunInfo.animationDuration / 2) * param.deltaPerSec;
        } else {
            scale = param.initialValue + (param.deltaPerSec * strongRunInfo.animationPassedTime);
        }
        viewParam.transform = CATransform3DScale(viewParam.transform, scale, scale, 1);
    };
    return runInfo;
}

- (AERunInfo *)buildRotateAnimationEffect:(AEParam *)param {
    if ([param isKindOfClass:[AERotateParam class]] == NO) {
        return nil;
    }
    AERunInfo *runInfo = __AECreateRunInfo(self, param);
    __weak typeof(runInfo) weakRunInfo = runInfo;
    runInfo.animationRunBlock = ^(NSTimeInterval timeOffset,NSTimeInterval timeInterval, AEViewParam *viewParam) {
        __strong typeof(weakRunInfo) strongRunInfo = weakRunInfo;
        [strongRunInfo configuratePassedTime:timeOffset timeInterval:timeInterval];
        CATransform3D transform = viewParam.transform;
        CGFloat rotateAngle = param.initialValue + param.deltaPerSec * strongRunInfo.animationPassedTime;
        switch (((AERotateParam *)param).axis) {
            case AERotate_X:
                transform = CATransform3DRotate(transform, rotateAngle, 1, 0, 0);
                break;
            case AERotate_Y:
                transform = CATransform3DRotate(transform, rotateAngle, 0, 1, 0);
                break;
            case AERotate_Z:
                transform = CATransform3DRotate(transform, rotateAngle, 0, 0, 1);
                break;
            default:
                break;
        }
        transform.m34 = 1.0 / 1000;
        viewParam.transform = transform;
    };
    return runInfo;
}

- (AERunInfo *)buildWipeAnimationEffect:(AEParam *)param {
    if ([param isKindOfClass:[AEWipeParam class]] == NO) {
        return nil;
    }
    CAShapeLayer *wipeShapeLayer = [CAShapeLayer layer];
    wipeShapeLayer.frame = self.bounds;
    wipeShapeLayer.fillColor = [UIColor clearColor].CGColor;
    wipeShapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    wipeShapeLayer.strokeEnd = 0;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    bezierPath.lineWidth = 1;
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    AEWipeDirection direction = ((AEWipeParam *)param).direction;
    switch (direction) {
        case AEWipe_TopToBottom:
        case AEWipe_BottomToTop:
            [bezierPath moveToPoint:CGPointMake(width/2, height)];
            [bezierPath addLineToPoint:CGPointMake(width/2, 0)];
            wipeShapeLayer.lineWidth = width;
            if (direction == AEWipe_TopToBottom) {
                wipeShapeLayer.transform = CATransform3DRotate(wipeShapeLayer.transform, M_PI, 0, 0, 1);
            }
            break;
        case AEWipe_LeadingToTrialing:
        case AEWipe_TrialingToLeading:
            [bezierPath moveToPoint:CGPointMake(0, height / 2 - 0.5)];
            [bezierPath addLineToPoint:CGPointMake(width, height / 2 - 0.5)];
            wipeShapeLayer.lineWidth = height;
            if (direction == AEWipe_TrialingToLeading) {
                wipeShapeLayer.transform = CATransform3DRotate(wipeShapeLayer.transform, M_PI, 0, 0, 1);
            }
            break;
        case AEWipe_Clockwise:
        case AEWipe_Anticlockwise:
        {
            CGFloat radius = sqrt(pow(width, 2) + pow(height, 2));
            wipeShapeLayer.lineWidth = radius;
            wipeShapeLayer.transform = CATransform3DRotate(wipeShapeLayer.transform, -M_PI_2, 0, 0, 1);
            bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width/2, height/2) radius:radius/2 startAngle:0 endAngle:M_PI * 2 clockwise:direction == AEWipe_Clockwise ? YES : NO];
        }
            break;
        default:
            break;
    }
    wipeShapeLayer.path = bezierPath.CGPath;
    AEWipeRunInfo *wipeRunInfo = (AEWipeRunInfo *)__AECreateRunInfo(self, param);
    wipeRunInfo.wipeLayer = wipeShapeLayer;
    __weak typeof(wipeRunInfo) weakWipeRunInfo = wipeRunInfo;
    wipeRunInfo.animationRunBlock = ^(NSTimeInterval timeOffset,NSTimeInterval timeInterval, AEViewParam *viewParam) {
        __strong typeof(weakWipeRunInfo) strongWipeRunInfo = weakWipeRunInfo;
        [strongWipeRunInfo configuratePassedTime:timeOffset timeInterval:timeInterval];
        CGFloat currentStrokeEnd = param.deltaPerSec * strongWipeRunInfo.animationPassedTime;
        currentStrokeEnd = currentStrokeEnd >= 1 ? 1 : currentStrokeEnd;
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        if (strongWipeRunInfo.animationView.layer.mask != strongWipeRunInfo.wipeLayer) {
            strongWipeRunInfo.animationView.layer.mask = strongWipeRunInfo.wipeLayer;
        }
        if (strongWipeRunInfo.wipeLayer.strokeEnd != currentStrokeEnd) {
            strongWipeRunInfo.wipeLayer.strokeEnd = currentStrokeEnd;
        }
        [CATransaction setDisableActions:NO];
        [CATransaction commit];
    };
    return wipeRunInfo;
}

- (AERunInfo *)buildTypingAnimationEffect:(AEParam *)param {
    if (__AESupportPartialTextAnimation(self, param)) {
        AETextRunInfo *textRunInfo = __AECreateTextRunInfo(self, param);
        __weak typeof(textRunInfo) weakTextRunInfo = textRunInfo;
        textRunInfo.runtimeEffectRangBlock = ^NSRange(NSTimeInterval timeOffset, NSTimeInterval timeInterval) {
            __strong typeof(weakTextRunInfo) strongTextRunInfo = weakTextRunInfo;
            [strongTextRunInfo configuratePassedTime:timeOffset timeInterval:timeInterval];
            if (strongTextRunInfo.animationPassedTime >= strongTextRunInfo.animationCompleteTime) {
                return strongTextRunInfo.effectRange;
            } else if (strongTextRunInfo.animationPassedTime <= 0) {
                return NSMakeRange(0, 0);
            } else {
                CGFloat typingPerSecond = 0;
                NSUInteger typingLength = 0;
                if (((AETextSeriesParam *)param).typingMode == AETyping_Letter) {
                     typingPerSecond = ((UILabel *)strongTextRunInfo.animationView).originalAttributeString.string.length / (strongTextRunInfo.animationDuration * 1.0);
                    typingLength = (NSUInteger)ceil(typingPerSecond * strongTextRunInfo.animationPassedTime);
                } else {
                    NSArray *wordWidthsArray = ((UILabel *)strongTextRunInfo.animationView).wordsWidthArray;
                    typingPerSecond = wordWidthsArray.count / (strongTextRunInfo.animationDuration * 1.0);
                    NSInteger wordWidthIndex = (NSInteger)ceil(typingPerSecond * strongTextRunInfo.animationPassedTime);
                    for (NSInteger index = 0; index <= wordWidthIndex; index++) {
                        NSNumber *wordWidth = wordWidthsArray[index];
                        typingLength += wordWidth.integerValue;
                    }
                }
                if (typingLength <= 0) {
                    typingLength = 0;
                }
                if (typingLength > ((UILabel *)strongTextRunInfo.animationView).originalAttributeString.length) {
                    typingLength = ((UILabel *)strongTextRunInfo.animationView).originalAttributeString.length;
                }
                return NSMakeRange(0, typingLength);
            }
        };
        textRunInfo.animationRunBlock = ^(NSTimeInterval timeOffset,NSTimeInterval timeInterval, AEViewParam *viewParam) {
            __strong typeof(weakTextRunInfo) strongTextRunInfo = weakTextRunInfo;
            NSRange effectRange = strongTextRunInfo.runtimeEffectRangBlock(timeOffset, timeInterval);
            if (effectRange.length <= 0) {
                viewParam.actualDisplayAttributeString = [[NSMutableAttributedString alloc] initWithString:@""];
            } else {
                viewParam.actualDisplayAttributeString = [[viewParam.makeupAttributeString attributedSubstringFromRange:effectRange] mutableCopy];
            }
        };
        return textRunInfo;
    }
    return nil;
}

- (AERunInfo *)buildChangeTextColorAnimationEffect:(AEParam *)param {
    if (__AESupportPartialTextAnimation(self, param)) {
        AETextRunInfo *textRunInfo = __AECreateTextRunInfo(self, param);
        textRunInfo.runtimeEffectRangBlock = [self runtimeTextRangType2:textRunInfo];
        textRunInfo.runtimeAttributeBlock = ^NSMutableDictionary *(NSMutableDictionary *attribute) {
            UIColor *textColor = ((AETextSeriesParam *)param).textColor;
            if (textColor != nil) {
                attribute[NSForegroundColorAttributeName] = textColor;
            }
            return attribute;
        };
        return textRunInfo;
    }
    return nil;
}

- (AERunInfo *)buildChangeTextBgColorAnimationEffect:(AEParam *)param {
    if (__AESupportPartialTextAnimation(self, param)) {
        AETextRunInfo *textRunInfo = __AECreateTextRunInfo(self, param);
        textRunInfo.runtimeEffectRangBlock = [self runtimeTextRangType2:textRunInfo];
        textRunInfo.runtimeAttributeBlock = ^NSMutableDictionary *(NSMutableDictionary *attribute) {
            UIColor *textBgColor = ((AETextSeriesParam *)param).textBgColor;
            if (textBgColor != nil) {
                attribute[NSBackgroundColorAttributeName] = textBgColor;
            }
            return attribute;
        };
        return textRunInfo;
    }
    return nil;
}

- (AERunInfo *)buildUnderliningAnimationEffect:(AEParam *)param {
    if (__AESupportPartialTextAnimation(self, param)) {
        AETextRunInfo *textRunInfo = __AECreateTextRunInfo(self, param);
        textRunInfo.runtimeEffectRangBlock = [self runtimeTextRangType2:textRunInfo];
        textRunInfo.runtimeAttributeBlock = ^NSMutableDictionary *(NSMutableDictionary *attribute) {
            attribute[NSUnderlineStyleAttributeName] = @(NSUnderlineStyleSingle);
            UIColor *underlineColor = ((AETextSeriesParam *)param).textUnderlineColor;
            if (underlineColor != nil) {
                attribute[NSUnderlineColorAttributeName] = underlineColor;
            }
            return attribute;
        };
        return textRunInfo;
    }
    return nil;
}

#pragma mark - effect range block
/**
 动画效果直接起效：文字渐隐，文字渐显，文字闪烁
 */
- (NSRange (^)(NSTimeInterval, NSTimeInterval))runtimeTextRangType1:(AETextRunInfo *)textRunInfo {
    __weak typeof(textRunInfo) weakTextRunInfo = textRunInfo;
    return ^NSRange(NSTimeInterval timeOffset, NSTimeInterval timeInterval){
        __strong typeof(weakTextRunInfo) strongTextRunInfo = weakTextRunInfo;
        [strongTextRunInfo configuratePassedTime:timeOffset timeInterval:timeInterval];
        if (strongTextRunInfo.param.isRunDirectly) {
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
- (NSRange (^)(NSTimeInterval, NSTimeInterval))runtimeTextRangType2:(AETextRunInfo *)textRunInfo {
    __weak typeof(textRunInfo) weakTextRunInfo = textRunInfo;
    return ^NSRange(NSTimeInterval timeOffset, NSTimeInterval timeInterval){
        __strong typeof(weakTextRunInfo) strongTextRunInfo = weakTextRunInfo;
        [strongTextRunInfo configuratePassedTime:timeOffset timeInterval:timeInterval];
        if (strongTextRunInfo.param.isRunDirectly ||
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

