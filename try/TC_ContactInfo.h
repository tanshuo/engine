//
//  TC_ContactInfo.h
//  try
//
//  Created by tanshuo on 7/26/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum right_left{
    LEFT_SHRINK,
    RIGHT_SHRINK,
} TC_SHRINK_DIRECTION;

@interface TC_ContactInfo : NSObject
@property float p1_x; //normal pushing impulse
@property float p1_y;
@property float p2_x; //tangent friction force
@property float p2_y;
@property TC_SHRINK_DIRECTION left_right;
@property id owner;
@end
