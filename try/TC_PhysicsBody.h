//
//  TC_PhysicsBody.h
//  try
//
//  Created by tanshuo on 7/26/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "physics_set.h"
#import "TC_BufferInfo.h"

typedef enum shape{
    BOX_CIRCLE,
    BOX_RECT,
    BOX_TRI,
} TC_SHAPE;

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

@property unsigned int buffer_index_left;
@property unsigned int buffer_index_right;
@property unsigned int buffer_index_top;
@property unsigned int buffer_index_bot;

@property (strong,nonatomic) NSMutableArray* contact_points;
@property (strong,nonatomic) NSMutableArray* hinges;

- (void)move; //move to a new place and register collide buffer.
- (int)writeBufferWithWidth:(float) w WithHeight: (float) h;

+ (NSMutableArray*)searchBufferInfoAtX:(int)x AtY:(int)y;
+ (int)searchBufferInfoIndexFrom:(NSMutableArray*)entry By:(TC_PhysicsBody*) target;
@end
