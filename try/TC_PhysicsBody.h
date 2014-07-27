//
//  TC_PhysicsBody.h
//  try
//
//  Created by tanshuo on 7/26/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "physics_set.h"

@interface TC_PhysicsBody : NSObject
@property BOOL freeze; // if the body is affected by weak net force, or very slow speed the flag will on;
@property BOOL dynamic; // whether the body can move or not;
@property BOOL alive;
@property unsigned int layer;// which layer is this body in;
@property float position_x;
@property float position_y;
@property float rotation;
@property float vx;
@property float vy;
@property float w;

@property TC_SHAPE shape;
@property float r;
@property float vetex_a_x;
@property float vetex_a_y;
@property float vetex_b_x;
@property float vetex_b_y;
@property float vetex_c_x;
@property float vetex_c_y;
@property float vetex_d_x;
@property float vetex_d_y;

@property unsigned int buffer_index_left_top;
@property unsigned int buffer_index_left_bot;
@property unsigned int buffer_index_right_top;
@property unsigned int buffer_index_right_bot;

@property (strong,nonatomic) NSMutableArray* contact_points;
@property (strong,nonatomic) NSMutableArray* hinges;

- (void)move; //move to a new place and register collide buffer.
- (void)cleanBuffer;
- (void)writeBuffer;
@end
