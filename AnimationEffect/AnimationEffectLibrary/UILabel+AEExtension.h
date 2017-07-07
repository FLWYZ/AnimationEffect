//
//  UILabel+AEExtension.h
//  AnimationEffect
//
//  Created by fanglei on 2017/6/28.
//  Copyright © 2017年 FangLei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (AEExtension)

@property (strong, nonatomic, readonly) NSMutableArray<__kindof NSNumber *> *wordsWidthArray;

@property (copy, nonatomic, readonly) NSAttributedString *originalAttributeString;

- (void)bindOringinalAtrributeString;

@end
