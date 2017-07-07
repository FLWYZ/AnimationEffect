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
#import "AERunInfo.h"

dispatch_queue_t __AEBuilderConfigureAnimationQueue() {
    static dispatch_queue_t AEConfigureAnimationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AEConfigureAnimationQueue = dispatch_queue_create(NULL, NULL);
    });
    return AEConfigureAnimationQueue;
}

static inline void __AERunConfigure(void(^configureBLock)(void)) {
    dispatch_async(__AEBuilderConfigureAnimationQueue(), configureBLock);
}

static inline AERunInfo *__AECreateAERunInfo(UIView *animationView, CALayer *animationLayer,CAAnimation *animation,AEParam *param) {
    animation.removedOnCompletion = param.removAnimationOnCompletion;
    animation.fillMode = param.fillMode;
    AERunInfo *runInfo = [[AERunInfo alloc] initWithAnimation:animation layer:animationLayer view:animationView param:param];
    return runInfo;
}

static inline AEPartialTextEffectRunInfo *____AECreateAEPartialTextEffectRunInfo(UIView *view,AEParam *param) {
    if ([view isKindOfClass:[UILabel class]] == NO) {
        return nil;
    }
    AEPartialTextEffectRunInfo *textRunInfo = [[AEPartialTextEffectRunInfo alloc] initWithParam:param];
    textRunInfo.label = (UILabel *)view;
    return textRunInfo;
}

static inline BOOL __AEIsPartialTextEffect(UIView *view,AEParam *param) {
    if ([view isKindOfClass:[UILabel class]] == NO) {
        return NO;
    }
    NSAttributedString *attributeString = ((UILabel *)view).attributedText;
    return param.partialTextEffectRange.length != attributeString.length;
}

@implementation UIView (AEBuilder)

#pragma mark - public

- (AERunInfo *)buildAnimationEffectWithParam:(AEParam *)param {
    AERunInfo *runInfo = nil;
    switch (param.animationType) {
        case AEType_ZoomIn:
        case AEType_ZoomOut:
            runInfo = [self buildZoomAnimationEffect:param];
            break;
        case AEType_Wipe:
            runInfo = [self buildWipeAnimationEffect:param];
            break;
        case AEType_Rotate:
            runInfo = [self buildRotateAnimationEffect:param];
            break;
        case AEType_FadeIn:
        case AEType_FadeOut:
            runInfo = [self buildFadeAnimationEffect:param];
            break;
        case AEType_Spark:
            runInfo = [self buildSparkAnimationEffect:param];
            break;
        case AEType_Typing:
            runInfo = [self buildTypingAnimationEffect:param];
            break;
        case AEType_Underlining:
            runInfo = [self buildUnderliningAnimationEffect:param];
            break;
        case AEType_ChangeTextBgColor:
            runInfo = [self buildTextHighlightAnimationEffect:param];
            break;
        case AEType_ChangeTextColor:
            runInfo = [self buildTextChangeColorAnimationEffect:param];
            break;
        default:
            break;
    }
    if (runInfo != nil) {
        runInfo.animationKey = param.description;
    }
    return runInfo;
}

- (void)applyTextSeriesAnimationEffect:(NSTimeInterval)timeOffset mode:(AEMode)mode {
    __AERunConfigure(^{
        @autoreleasepool {
            NSMutableArray <__kindof AEPartialTextEffectRunInfo *> *textSeriesEffectArray = [NSMutableArray arrayWithArray:self.typingRunInfoArray];
            [textSeriesEffectArray addObjectsFromArray:self.partialTextEffectRunInfoArray];
            if (textSeriesEffectArray.count) { // 需要执行文本类动效
                UILabel *label = textSeriesEffectArray.firstObject.label;
                NSAttributedString *currentDisplayAtributeString = [self buildTextSeriesAnimationEffect:label.originalAttributeString timeOffset:timeOffset mode:mode];
                
            }
        }
    });
}

#pragma mark - private

- (AERunInfo *)buildZoomAnimationEffect:(AEParam *)param {
    CABasicAnimation *zoomAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    if (param.animationType == AEType_ZoomIn) { // 缩放
        zoomAnimation.autoreverses = YES;
        zoomAnimation.byValue = @(param.maximumScaling - 1);
        zoomAnimation.duration = param.duration / 2;
    } else { // 缩小
        zoomAnimation.fromValue = @(1);
        zoomAnimation.toValue = @(param.minimumScaling);
        zoomAnimation.duration = param.duration;
    }
    return __AECreateAERunInfo(self, self.layer, zoomAnimation, param);
}

- (AERunInfo *)buildWipeAnimationEffect:(AEParam *)param {
    CAShapeLayer *wipeShapeLayer = [CAShapeLayer layer];
    wipeShapeLayer.frame = self.bounds;
    wipeShapeLayer.fillColor = [UIColor clearColor].CGColor;
    wipeShapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    wipeShapeLayer.strokeEnd = 0;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    bezierPath.lineWidth = 1;
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    switch (param.wipeDirection) {
        case AEWipe_TopToBottom:
        case AEWipe_BottomToTop:
            [bezierPath moveToPoint:CGPointMake(width/2, height)];
            [bezierPath addLineToPoint:CGPointMake(width/2, 0)];
            wipeShapeLayer.lineWidth = width;
            if (param.wipeDirection == AEWipe_TopToBottom) {
                wipeShapeLayer.transform = CATransform3DRotate(wipeShapeLayer.transform, M_PI, 0, 0, 1);
            }
            break;
        case AEWipe_LeadingToTrialing:
        case AEWipe_TrialingToLeading:
            [bezierPath moveToPoint:CGPointMake(0, height / 2 - 0.5)];
            [bezierPath addLineToPoint:CGPointMake(width, height / 2 - 0.5)];
            wipeShapeLayer.lineWidth = height;
            if (param.wipeDirection == AEWipe_TrialingToLeading) {
                wipeShapeLayer.transform = CATransform3DRotate(wipeShapeLayer.transform, M_PI, 0, 0, 1);
            }
            break;
        case AEWipe_Clockwise:
        case AEWipe_Anticlockwise:
        {
            CGFloat radius = sqrt(pow(width, 2) + pow(height, 2));
            wipeShapeLayer.lineWidth = radius;
            wipeShapeLayer.transform = CATransform3DRotate(wipeShapeLayer.transform, -M_PI_2, 0, 0, 1);
            bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width/2, height/2) radius:radius/2 startAngle:0 endAngle:M_PI * 2 clockwise:param.wipeDirection == AEWipe_Clockwise ? YES : NO];
        }
            break;
        default:
            break;
    }
    CABasicAnimation *wipeAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    wipeAnimation.toValue = @(1);
    wipeAnimation.duration = param.duration;
    wipeShapeLayer.path = bezierPath.CGPath;
    AERunInfo *wipeRunInfo = __AECreateAERunInfo(self, wipeShapeLayer, wipeAnimation, param);
    __weak typeof(wipeRunInfo) weakWipeRunInfo = wipeRunInfo;
    wipeRunInfo.animationRunBlock = ^(NSTimeInterval timeInterval, AEMode mode) {
        __strong typeof(weakWipeRunInfo) strongWipeRunInfo = weakWipeRunInfo;
        if (strongWipeRunInfo.animationLayer != nil) {
            [strongWipeRunInfo adjustAnimationPassedTimeOffset:timeInterval mode:mode];
            if (strongWipeRunInfo.animationView.layer.mask != strongWipeRunInfo.animationLayer) {
                strongWipeRunInfo.animationView.layer.mask = strongWipeRunInfo.animationLayer;
            }
            if (strongWipeRunInfo.animationLayer.timeOffset != strongWipeRunInfo.animationPassedTime) {
                strongWipeRunInfo.animationView.layer.timeOffset = strongWipeRunInfo.animationPassedTime;
            }
        }
    };
    return __AECreateAERunInfo(self, wipeShapeLayer, wipeAnimation, param);
}

- (AERunInfo *)buildRotateAnimationEffect:(AEParam *)param {
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.byValue = @(param.rotationDegree);
    rotateAnimation.duration = param.duration;
    return __AECreateAERunInfo(self, self.layer, rotateAnimation, param);
}

- (AERunInfo *)buildFadeAnimationEffect:(AEParam *)param {
    if (__AEIsPartialTextEffect(self, param)) {
        AEPartialTextEffectRunInfo *textRunInfo = ____AECreateAEPartialTextEffectRunInfo(self, param);
        __weak typeof(textRunInfo) weakTextRunInfo = textRunInfo;
        textRunInfo.runtimeTextAttributeBlock = ^NSMutableDictionary *(NSTimeInterval timeOffset,NSMutableDictionary *attribute, AEMode mode) {
            __strong typeof(weakTextRunInfo) strongTextRunInfo = weakTextRunInfo;
            [strongTextRunInfo adjustAnimationPassedTimeOffset:timeOffset mode:mode];
            NSTimeInterval animationTimeOffset = strongTextRunInfo.animationPassedTime - param.startTimeStamp;
            CGFloat alphaChangePerSecond = 1.0 / param.duration;
            CGFloat currentAlpha = param.animationType == AEType_FadeIn ? (animationTimeOffset * alphaChangePerSecond) : (1 - animationTimeOffset * alphaChangePerSecond);
            UIColor *textColor = attribute[NSForegroundColorAttributeName];
            UIColor *textBgColor = attribute[NSBackgroundColorAttributeName];
            if (textColor) {
                textColor = [textColor colorWithAlphaComponent:currentAlpha];
                attribute[NSForegroundColorAttributeName] = textColor;
            }
            if (textBgColor) {
                textBgColor = [textBgColor colorWithAlphaComponent:currentAlpha];
                attribute[NSBackgroundColorAttributeName] = textBgColor;
            }
            return attribute;
        };
        return textRunInfo;
    } else {
        CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        if (param.animationType == AEType_FadeIn) {
            fadeAnimation.fromValue = @(0);
            fadeAnimation.toValue = @(self.layer.opacity);
        } else {
            fadeAnimation.fromValue = @(self.layer.opacity);
            fadeAnimation.toValue = @(0);
        }
        fadeAnimation.duration = param.duration;
        return __AECreateAERunInfo(self, self.layer, fadeAnimation, param);
    }
}

- (AERunInfo *)buildSparkAnimationEffect:(AEParam *)param {
    if (__AEIsPartialTextEffect(self, param)) {
        AEPartialTextEffectRunInfo *textRunInfo = ____AECreateAEPartialTextEffectRunInfo(self, param);
        __weak typeof(textRunInfo) weakTextRunInfo = textRunInfo;
        textRunInfo.runtimeTextAttributeBlock = ^NSMutableDictionary *(NSTimeInterval timeOffset, NSMutableDictionary *attribute, AEMode mode) {
            __strong typeof(weakTextRunInfo) strongTextRunInfo = weakTextRunInfo;
            [strongTextRunInfo adjustAnimationPassedTimeOffset:timeOffset mode:mode];
            NSTimeInterval animationTimeOffset = strongTextRunInfo.animationPassedTime - param.startTimeStamp;
            CGFloat alphaChangePerSecond = (2 * (1 - param.minimumOpacity)) / param.duration;
            CGFloat currentAlpha = alphaChangePerSecond > param.duration / 2.0 ? param.minimumOpacity + (animationTimeOffset - param.duration / 2.0) * alphaChangePerSecond : 1 - animationTimeOffset * alphaChangePerSecond;
            UIColor *textColor = attribute[NSForegroundColorAttributeName];
            UIColor *textBgColor = attribute[NSBackgroundColorAttributeName];
            if (textColor) {
                textColor = [textColor colorWithAlphaComponent:currentAlpha];
                attribute[NSForegroundColorAttributeName] = textColor;
            }
            if (textBgColor) {
                textBgColor = [textBgColor colorWithAlphaComponent:currentAlpha];
                attribute[NSBackgroundColorAttributeName] = textBgColor;
            }
            return attribute;
        };
        return textRunInfo;
    } else {
        CABasicAnimation *sparkAniamtion = [CABasicAnimation animationWithKeyPath:@"opacity"];
        sparkAniamtion.fromValue = @(self.layer.opacity);
        sparkAniamtion.toValue = @(param.minimumOpacity);
        sparkAniamtion.autoreverses = YES;
        sparkAniamtion.duration = param.duration;
        return __AECreateAERunInfo(self, self.layer, sparkAniamtion, param);
    }
}

- (AERunInfo *)buildUnderliningAnimationEffect:(AEParam *)param {
    if ([self isKindOfClass:[UILabel class]] == NO) {
        return nil;
    }
    AEPartialTextEffectRunInfo *textRunInfo = ____AECreateAEPartialTextEffectRunInfo(self, param);
    textRunInfo.runtimeTextAttributeBlock = ^NSMutableDictionary *(NSTimeInterval currentTimeOffset, NSMutableDictionary *attribute, AEMode mode) {
        attribute[NSUnderlineStyleAttributeName] = @(NSUnderlineStyleSingle);
        return attribute;
    };
    return textRunInfo;
}

- (AERunInfo *)buildTextHighlightAnimationEffect:(AEParam *)param {
    if ([self isKindOfClass:[UILabel class]] == NO) {
        return nil;
    }
    AEPartialTextEffectRunInfo *textRunInfo = ____AECreateAEPartialTextEffectRunInfo(self, param);
    textRunInfo.runtimeTextAttributeBlock = ^NSMutableDictionary *(NSTimeInterval currentTimeOffset, NSMutableDictionary *attribute, AEMode mode) {
        attribute[NSBackgroundColorAttributeName] = param.textNewBgColor;
        return attribute;
    };
    return textRunInfo;
}

- (AERunInfo *)buildTextChangeColorAnimationEffect:(AEParam *)param {
    if ([self isKindOfClass:[UILabel class]] == NO) {
        return nil;
    }
    AEPartialTextEffectRunInfo *textRunInfo = ____AECreateAEPartialTextEffectRunInfo(self, param);
    textRunInfo.runtimeTextAttributeBlock = ^NSMutableDictionary *(NSTimeInterval currentTimeOffset, NSMutableDictionary *attribute, AEMode mode) {
        attribute[NSForegroundColorAttributeName] = param.textNewColor;
        return attribute;
    };
    return textRunInfo;
}

- (AERunInfo *)buildTypingAnimationEffect:(AEParam *)param {
    if ([self isKindOfClass:[UILabel class]] == NO) {
        return nil;
    }
    AEPartialTextEffectRunInfo *textRunInfo = ____AECreateAEPartialTextEffectRunInfo(self, param);
    __weak typeof(textRunInfo) weakTextRunInfo = textRunInfo;
    textRunInfo.runtimeEffectRangeBlock = ^NSRange(NSTimeInterval timeOffset, AEMode mode) {
        __strong typeof(weakTextRunInfo) strongTextRunInfo = weakTextRunInfo;
        [strongTextRunInfo adjustAnimationPassedTimeOffset:timeOffset mode:mode];
        if (strongTextRunInfo.animationPassedTime < strongTextRunInfo.animationStartTimeStamp) {// 在打字动效开始前
            return NSMakeRange(0, 0);
        } else if (strongTextRunInfo.animationPassedTime > strongTextRunInfo.animationEndTimeStamp) {// 在打字动效结束后
            return strongTextRunInfo.effectRange;
        } else {// 当前进度位于打字效果的起止时间之内
            NSTimeInterval animationTimeOffset = strongTextRunInfo.animationPassedTime - param.startTimeStamp;
            CGFloat typingPerSecond = 0;
            NSUInteger typingLength = 0;
            //TODO: 是否要根据播放进度调整打字效果现实的文字？
            if (param.typingMode == AETyping_Letter) {// 逐字
                typingPerSecond = strongTextRunInfo.label.attributedText.length / (param.duration * 1.0);
                typingLength = (NSUInteger)ceil(typingPerSecond * animationTimeOffset);
            } else if (param.typingMode == AETyping_Word) {// 逐词
                typingPerSecond = strongTextRunInfo.label.wordsWidthArray.count / (param.duration * 1.0);
                NSUInteger wordWidthIndex = (NSUInteger)ceil(typingPerSecond * animationTimeOffset);
                wordWidthIndex = wordWidthIndex >= strongTextRunInfo.label.wordsWidthArray.count ? strongTextRunInfo.label.wordsWidthArray.count - 1 : wordWidthIndex;
                for (NSInteger index = 0; index <= wordWidthIndex; index++) {
                    NSNumber *wordWidth = strongTextRunInfo.label.wordsWidthArray[index];
                    typingLength += wordWidth.integerValue;
                }
            }
            typingLength = typingLength <= 0 ? 0 : typingLength;
            if (typingLength > strongTextRunInfo.label.attributedText.length) {// 防止越界
                typingLength = strongTextRunInfo.label.attributedText.length;
            }
            return NSMakeRange(0, typingLength);
        }
    };
    return textRunInfo;
}

- (NSAttributedString *)buildTextSeriesAnimationEffect:(NSAttributedString *)originalAttributeString
                                            timeOffset:(NSTimeInterval)timeOffset
                                                  mode:(AEMode)mode {
    NSMutableArray <__kindof AEPartialTextEffectRunInfo *>* typingRunInfoArray = nil;
    if (self.typingRunInfoArray.count > 0) {
        typingRunInfoArray = [NSMutableArray arrayWithCapacity:self.typingRunInfoArray.count];
        for (AEPartialTextEffectRunInfo *textRunInfo in self.typingRunInfoArray) {
            if (<#condition#>) {
                <#statements#>
            }
        }
    }
}

@end
