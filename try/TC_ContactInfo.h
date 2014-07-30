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
@property float p1_x; //contact points
@property float p1_y;
@property float p2_x;
@property float p2_y;

@property float normal_x; // nomal direction
@property float normal_y;

@property float depth; // impact intensity
@property float folder; // net displacement;

@property BOOL break_in; 

@property id owner;
@end
