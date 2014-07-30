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
#import "TC_ContactInfo.h"
#import "phy_math.h"

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
@property float ww;
@property float wh;
@property float rotation;
@property float vx;
@property float vy;
@property float w;
@property float e;

@property TC_SHAPE shape;
@property float r;
@property float* vetex_x;
@property float* vetex_y;
@property VECTOR2D* normal;
@property int vetex_count;

@property unsigned int buffer_index_left;
@property unsigned int buffer_index_right;
@property unsigned int buffer_index_top;
@property unsigned int buffer_index_bot;

@property (strong,nonatomic) NSMutableArray* contact_points;
@property (strong,nonatomic) NSMutableArray* hinges;

- (void)initWithX:(float)x WithY:(float)y WithWidth:(float)w WithHeight:(float)h WithProperty:(BOOL)dynamic WithRotation:(float)rotation WithShape:(TC_SHAPE) shape  WithRadius:(float)r WithCoefficient:(float)e WithWorldWidth:(float)ww WithWorldHeight:(float)wh;

- (void)updateWithwidth:(float)w Height:(float)h; //move to a new place and register collide buffer.
- (int)writeBufferWithWidth:(float) w WithHeight: (float) h;
- (void)collideDetectWith: (TC_PhysicsBody*) box;
- (BOOL)isPossibleCollideWith: (TC_PhysicsBody*) box;
- (void)genCollide;

- (float)maxSeperationDistanceBetween:(TC_PhysicsBody*)box1 And:(TC_PhysicsBody*)box2 From: (int*)edge To: (int*) vetex;
- (float)seperationByEdgeNormal:(VECTOR2D*)normal ByEdge:(int)edge WithBox:(TC_PhysicsBody*)box1 WithBox:(TC_PhysicsBody*)box2 At:(int*) vetex;
- (void) update;

+ (NSMutableArray*)searchBufferInfoAtX:(int)x AtY:(int)y;
+ (int)searchBufferInfoIndexFrom:(NSMutableArray*)entry By:(TC_PhysicsBody*) target;

-(void)dealloc;
@end
