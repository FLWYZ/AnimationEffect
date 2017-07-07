//
//  UILabel+AEExtension.m
//  AnimationEffect
//
//  Created by fanglei on 2017/6/28.
//  Copyright © 2017年 FangLei. All rights reserved.
//

#import "UILabel+AEExtension.h"
#import <objc/runtime.h>

static void* kWordsWidthArrayKey = &kWordsWidthArrayKey;
static void* kOriginalAttributeStringKey = &kOriginalAttributeStringKey;

@implementation UILabel (AEExtension)

- (void)bindOringinalAtrributeString {
    if (self.originalAttributeString.length <= 0) { // 初始的属性文本只记录一次
        self.originalAttributeString = self.attributedText;
    }
}

- (void)setWordsWidthArray:(NSMutableArray<__kindof NSNumber *> *)wordsWidthArray {
    objc_setAssociatedObject(self, kWordsWidthArrayKey, wordsWidthArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray<NSNumber *> *)wordsWidthArray{
    NSMutableArray *wordsWidthArray = objc_getAssociatedObject(self, kWordsWidthArrayKey);
    if (wordsWidthArray == nil) {
        wordsWidthArray = [NSMutableArray array];
        NSArray *wordArray = [self.text componentsSeparatedByString:@" "];
        NSInteger wordWidth = 0;
        for (NSString *word in wordArray) {
            if ([word isEqualToString:@""]) {
                wordWidth += 1;
            } else {
                wordWidth += word.length;
                [wordsWidthArray addObject:@(wordWidth)];
                wordWidth = 0;
                wordWidth += 1;
            }
        }
        if (wordWidth != 0) { // 文本是以空格结束的话
            [wordsWidthArray addObject:@(wordWidth - 1)];
        }
        self.wordsWidthArray = wordsWidthArray;
    }
    return wordsWidthArray;
}

- (void)setOriginalAttributeString:(NSAttributedString *)originalAttributeString {
    objc_setAssociatedObject(self, kOriginalAttributeStringKey, originalAttributeString, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSAttributedString *)originalAttributeString {
    return objc_getAssociatedObject(self, kOriginalAttributeStringKey);
}

@end
