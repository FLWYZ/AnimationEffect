//
//  AEParam.m
//  AnimationEffect
//
//  Created by fanglei on 2017/6/28.
//  Copyright © 2017年 FangLei. All rights reserved.
//

#import "AEParam.h"

@interface AEParam()

@property (assign, nonatomic, readwrite) CGFloat initialValue;
@property (assign, nonatomic, readwrite) CGFloat terminalValue;
@property (assign, nonatomic, readwrite) CGFloat deltaPerSec;

@end

@implementation AEParam

- (void)prepareValues {
    if (_initialValue < 0 ||
        _terminalValue < 0) {
        CGFloat initial = 0.0;
        CGFloat terminal = 0.0;
        switch (self.type) {
            case AEType_FadeIn: // 渐显
            case AEType_FadeOut: // 渐隐
            {
                initial = self.type == AEType_FadeIn ? 0 : 1;
                terminal = self.type == AEType_FadeIn ? 0 : 1;
                if (self.fromValue != nil) {
                    initial = self.fromValue.floatValue;
                }
                if (self.toValue != nil) {
                    terminal = self.toValue.floatValue;
                } else if (self.byValue != nil) {
                    terminal = initial + self.byValue.floatValue * (self.type == AEType_FadeIn ? 1 : -1);
                } else {
                    terminal = self.type == AEType_FadeIn ? 1 : 0;
                }
            }
                break;
            case AEType_Wipe: // 擦出
            {
                initial = 0;
                terminal = 0;
                if (self.fromValue != nil) {
                    initial = self.fromValue.floatValue;
                }
                if (self.toValue != nil) {
                    terminal = self.toValue.floatValue;
                } else if (self.byValue != nil) {
                    terminal = initial + self.byValue.floatValue;
                } else {
                    terminal = 1;
                }
            }
                break;
            case AEType_ZoomIn: // 放大
            case AEType_ZoomOut: // 缩小
            {
                initial = 1;
                terminal = 1;
                if (self.fromValue != nil) {
                    initial = self.fromValue.floatValue;
                }
                if (self.toValue != nil) {
                    terminal = self.toValue.floatValue;
                } else if (self.byValue != nil) {
                    terminal = initial + self.byValue.floatValue * (self.type == AEType_FadeIn ? 1 : -1);
                } else {
                    terminal = self.type == AEType_FadeIn ? kAEMaximumScaling : kAEMinimumScaling;
                }
            }
                break;
            case AEType_Zoom: // 缩放
            {
                initial = 1;
                terminal = 1;
                if (self.fromValue != nil) {
                    initial = self.fromValue.floatValue;
                }
                if (self.toValue != nil) {
                    terminal = self.toValue.floatValue;
                } else if (self.byValue != nil) {
                    terminal = initial + self.byValue.floatValue;
                } else {
                    terminal = kAEMaximumScaling;
                }
            }
                break;
            case AEType_Rotate: // 旋转
            {
                initial = 0;
                terminal = 0;
                if (self.fromValue != nil) {
                    initial = self.fromValue.floatValue;
                }
                if (self.toValue != nil) {
                    terminal = self.toValue.floatValue;
                } else if (self.byValue != nil) {
                    terminal = initial + self.byValue.floatValue;
                } else {
                    terminal = kAERotationDegree;
                }
            }
                break;
            case AEType_Spark: // 闪烁
            {
                initial = 1;
                terminal = 1;
                if (self.fromValue != nil) {
                    initial = self.fromValue.floatValue;
                }
                if (self.toValue != nil) {
                    terminal = self.toValue.floatValue;
                } else if (self.byValue != nil) {
                    terminal = initial - self.byValue.floatValue;
                } else {
                    terminal = kAEMinimumOpacity;
                }
            }
                break;
            default:
                break;
        }
        _initialValue = initial;
        _terminalValue = terminal;
        _deltaPerSec = (_terminalValue - _initialValue) / self.duration;
        if (self.type == AEType_Zoom ||
            self.type == AEType_Spark) {
            _deltaPerSec *= 2;
        }
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%lu-%.2f-%.2f-%i-%@-%@-%@",(unsigned long)self.type,self.beginTimeStamp,self.duration,self.removeEffectOnComplete,self.fromValue,self.toValue,self.byValue];
}

@end

@implementation AEWipeParam

- (NSString *)description {
    NSString *description = [super description];
    return [description stringByAppendingFormat:@"-Direction-%lu",(unsigned long)self.direction];
}

@end

@implementation AERotateParam

- (NSString *)description {
    NSString *description = [super description];
    return [description stringByAppendingFormat:@"-Axis-%lu",(unsigned long)self.axis];
}

@end

@implementation AETextSeriesParam

- (NSString *)description {
    NSString *description = [super description];
    return [description stringByAppendingFormat:@"-TypingMode-%lu-EffectRange-%@-TextColor-%@-TextBgColor-%@-TextUnderlineColor-%@",(unsigned long)self.typingMode,NSStringFromRange(self.effectRange),self.textColor,self.textBgColor,self.textUnderlineColor];
}

@end
