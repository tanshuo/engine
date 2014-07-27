//
//  TC_ContactInfo.h
//  try
//
//  Created by tanshuo on 7/26/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TC_PhysicsBody.h"

typedef enum right_left{
    LEFT_SHRINK,
    RIGHT_SHRINK,
} TC_SHRINK_DIRECTION;

@interface TC_ContactInfo : NSObject
@property float p1_x;
@property float p1_y;
@property float p2_x;
@property float p2_y;
@property TC_SHRINK_DIRECTION left_right;
@property id owner;
@end
