//
//  UIView+AnimationEffect.m
//  AnimationEffect
//
//  Created by fanglei on 2017/6/28.
//  Copyright © 2017年 FangLei. All rights reserved.
//

#import "UIView+AnimationEffect.h"
#import "AEParam.h"
#import "AERunInfo.h"
#import <objc/runtime.h>
#import "UIView+AEBuilder.h"
#import "UILabel+AEExtension.h"
#import "AEController.h"
#import "AEConstants.h"

static void *kAERunInfoClusterKey = &kAERunInfoClusterKey;

@interface UIView()

@property (strong, nonatomic) AERunInfoCluster *runInfoCluster;

@end

@implementation UIView (AnimationEffect)

- (void)addAnimationEffect:(AEParam *)param identify:(NSString *)identify {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self supportPartialTextAnimationEffect:param]) {
            [((UILabel *)self) bindOringinalAtrributeString];
        }
        AERunInfo *runInfo = [self buildAnimationEffectWithParam:param];
        if (runInfo != nil) {
            if ([runInfo isKindOfClass:[AERunInfo class]]) {
                [runInfo.animationLayer addAnimation:runInfo.animation forKey:runInfo.animationKey];
            } else if ([runInfo isKindOfClass:[AEPartialTextEffectRunInfo class]]) {
                if (param.animationType == AEType_Typing) {
                    [self.typingRunInfoArray addObject:(AEPartialTextEffectRunInfo *)runInfo];
                } else {
                    [self.partialTextEffectRunInfoArray addObject:(AEPartialTextEffectRunInfo *)runInfo];
                }
            }
            [self sortAniamtionEffect];
            [[AEController controller] addAEView:self identify:identify];
        }
    });
}

- (void)removeAnimationEffect {
    self.runInfoCluster = nil;
    self.layer.mask = nil;
    [self.layer removeAllAnimations];
}

#pragma mark - setter/getter

- (void)sortAniamtionEffect {
    NSComparisonResult(^sortBlock)(id  _Nonnull obj1, id  _Nonnull obj2) = ^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        AERunInfo *info1 = (AERunInfo *)obj1;
        AERunInfo *info2 = (AERunInfo *)obj2;
        return info1.animationStartTimeStamp > info2.animationStartTimeStamp;
    };
    [self.runInfoArray sortUsingComparator:sortBlock];
    [self.partialTextEffectRunInfoArray sortUsingComparator:sortBlock];
    [self.typingRunInfoArray sortUsingComparator:sortBlock];
}

- (BOOL)supportPartialTextAnimationEffect:(AEParam *)param {
    if ([self isKindOfClass:[UILabel class]]) {
        if (param.animationType == AEType_Typing) {
            return YES;
        } else {
            if ([[self textSeriesEffect] containsObject:@(param.animationType)]) {
                NSUInteger letterLength = param.partialTextEndLetterIndex - param.partialTextStartLetterIndex + 1;
                if (letterLength != ((UILabel *)self).attributedText.length) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

/**
 需要支持局部文本动效的类型集合
 */
- (NSArray *)textSeriesEffect {
    return @[@(AEType_FadeIn),
             @(AEType_FadeOut),
             @(AEType_Spark),
             @(AEType_Typing),
             @(AEType_ChangeTextColor),
             @(AEType_ChangeTextBgColor),
             @(AEType_Underlining)];
}

#pragma mark - setter/getter

- (void)setRunInfoCluster:(AERunInfoCluster *)runInfoCluster {
    objc_setAssociatedObject(self, kAERunInfoClusterKey, runInfoCluster, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (AERunInfoCluster *)runInfoCluster {
    AERunInfoCluster *runInfoCluster = objc_getAssociatedObject(self, kAERunInfoClusterKey);
    if (runInfoCluster == nil) {
        runInfoCluster = [[AERunInfoCluster alloc] init];
        self.runInfoCluster = runInfoCluster;
    }
    return runInfoCluster;
}

- (NSMutableArray<AERunInfo *> *)runInfoArray {
    return self.runInfoCluster.runInfoArray;
}

- (NSMutableArray<AEPartialTextEffectRunInfo *> *)typingRunInfoArray {
    return self.runInfoCluster.typingRunInfoArray;
}

- (NSMutableArray<AEPartialTextEffectRunInfo *> *)partialTextEffectRunInfoArray {
    return self.runInfoCluster.partialTextEffectRunInfoArray;
}

@end
