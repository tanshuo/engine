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
    int buffer_size;
    buffer_size = COLLIDE_DETECTOR_BUFFER_HEIGHT * COLLIDE_DETECTOR_BUFFER_WIDTH;
    _time = 0;
    collide_buffer = [NSMutableArray arrayWithCapacity:buffer_size];
    for(i = 0; i < buffer_size; i ++)
    {
        NSMutableArray* temp;
        temp = [NSMutableArray arrayWithCapacity:10];
        [collide_buffer addObject:temp];
    }
}

- (void)update
{
    _time ++;
}
@end
