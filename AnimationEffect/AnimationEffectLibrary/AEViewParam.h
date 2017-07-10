//
//  AEViewParam.h
//  AnimationEffect
//
//  Created by fanglei on 2017/7/10.
//  Copyright © 2017年 FangLei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AEViewParam : NSObject <NSCopying>

@property (assign, nonatomic) CATransform3D transform;
@property (assign, nonatomic) CGFloat opacity;
@property (copy, nonatomic) NSMutableAttributedString *originalAttributeString;
@property (strong, nonatomic) NSMutableAttributedString *makeupAttributeString;
@property (strong, nonatomic) NSMutableAttributedString *actualDisplayAttributeString;

@end
