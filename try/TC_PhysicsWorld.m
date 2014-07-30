//
//  TC_PhysicsWorld.m
//  try
//
//  Created by tanshuo on 7/27/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import "TC_PhysicsWorld.h"

@implementation TC_PhysicsWorld
- (void)start
{
    int i;
    _world_height = 1000;
    _world_width = 1000;
    int buffer_size;
    buffer_size = COLLIDE_DETECTOR_BUFFER_HEIGHT * COLLIDE_DETECTOR_BUFFER_WIDTH;
    _time = 0;
    collide_buffer = [NSMutableArray arrayWithCapacity:buffer_size];
    objects = [NSMutableArray arrayWithCapacity:buffer_size];
    for(i = 0; i < buffer_size; i ++)
    {
        NSMutableArray* temp;
        temp = [NSMutableArray arrayWithCapacity:10];
        [collide_buffer addObject:temp];
    }
    
    //test
    TC_PhysicsBody* p1 = [TC_PhysicsBody alloc];
    [p1 initWithX:0 WithY:0 WithWidth:30 WithHeight:30 WithProperty:YES WithRotation:0 WithShape:BOX_RECT WithRadius:0 WithCoefficient:0 WithWorldWidth:_world_width WithWorldHeight:_world_height];
    TC_PhysicsBody* p2 = [TC_PhysicsBody alloc];
    [p2 initWithX:29.5 WithY:29 WithWidth:30 WithHeight:30 WithProperty:YES WithRotation:0 WithShape:BOX_RECT WithRadius:0 WithCoefficient:0 WithWorldWidth:_world_width WithWorldHeight:_world_height];
}

- (void)update
{
    _time ++;
    int i;
    for(i = 0; i < [objects count]; i++)
    {
        if([objects[i] freeze] == YES)
        {
            [objects removeObjectAtIndex:i];
            i --;
            continue;
        }
        else
        {
            [objects[i] updateWithwidth:_world_width Height:_world_height];
        }
    }
}
@end
