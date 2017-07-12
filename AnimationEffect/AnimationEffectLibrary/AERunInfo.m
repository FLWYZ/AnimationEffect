//
//  AERunInfo.m
//  AnimationEffect
//
//  Created by fanglei on 2017/6/28.
//  Copyright © 2017年 FangLei. All rights reserved.
//

#import "AERunInfo.h"
#import "AEParam.h"
#import "AEViewParam.h"

@interface AERunInfo()

@property (strong, nonatomic, readwrite) AEParam *param;
@property (assign, nonatomic, readwrite) NSTimeInterval animationPassedTime;

@end

@implementation AERunInfo

- (instancetype)initWithParam:(AEParam *)param {
    if (self = [super init]) {
        self.param = param;
    }
    return self;
}

- (void)configuratePassedTime:(NSTimeInterval)timeOffset
                 timeInterval:(NSTimeInterval)timeInterval {
    if (self.animationPaused == YES) {
        return;
    }
    if (self.param.isRunDirectly) {
        self.animationPassedTime += timeInterval;
    } else {
        if (timeOffset < self.animationBeginTime) {
            self.animationPassedTime = 0;
        } else if (timeOffset > self.animationCompleteTime) {
            self.animationPassedTime = self.param.duration;
        } else {
            self.animationPassedTime = timeOffset;
        }
    }
}

- (NSString *)description {
    return self.param.description;
}

#pragma mark - setter / getter

- (NSTimeInterval)animationBeginTime {
    return self.param.beginTimeStamp;
}

- (NSTimeInterval)animationDuration {
    return self.param.duration;
}

- (NSTimeInterval)animationCompleteTime {
    return self.param.beginTimeStamp + self.param.duration;
}

@end

@implementation AETextRunInfo

- (void (^)(NSTimeInterval, NSTimeInterval, AEViewParam *))animationRunBlock {
    return ^(NSTimeInterval timeOffset, NSTimeInterval timeInterval, AEViewParam *viewParam){
        NSRange effectRange = self.runtimeEffectRangBlock(timeOffset, timeInterval);
        if (effectRange.length > 0) {
            NSMutableAttributedString *applyAttributeString = [[NSMutableAttributedString alloc] initWithString:@""];
            NSAttributedString *subAttributeString = [viewParam.makeupAttributeString attributedSubstringFromRange:effectRange];
            for (NSInteger index = 0; index < subAttributeString.length; index++) {
                NSAttributedString *attributeString = [subAttributeString attributedSubstringFromRange:NSMakeRange(index, 1)];
                NSMutableDictionary *attribute = [[attributeString attributesAtIndex:0 effectiveRange:nil] mutableCopy];
                attribute = self.runtimeAttributeBlock(attribute);
                [applyAttributeString appendAttributedString:[[NSAttributedString alloc] initWithString:attributeString.string attributes:attribute]];
            }
            [viewParam.makeupAttributeString replaceCharactersInRange:effectRange withAttributedString:applyAttributeString];
        }
    };
}

- (NSRange)effectRange {
    return ((AETextSeriesParam *)self.param).effectRange;
}

@end
