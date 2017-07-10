//
//  AEParam.m
//  AnimationEffect
//
//  Created by fanglei on 2017/6/28.
//  Copyright © 2017年 FangLei. All rights reserved.
//

#import "AEParam.h"

@implementation AEParam

- (NSString *)description {
    return [NSString stringWithFormat:@"%lu-%.2f-%.2f-%i-%.2f-%.2f-%.2f",(unsigned long)self.type,self.beginTimeStamp,self.duration,self.removeEffectOnComplete,self.fromValue,self.toValue,self.byValue];
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
