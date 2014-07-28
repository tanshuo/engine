//
//  TC_PhysicsBody.m
//  try
//
//  Created by tanshuo on 7/26/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import "TC_PhysicsBody.h"

@implementation TC_PhysicsBody

- (void)initWithX:(float)x WithY:(float)y WithProperty:(BOOL)dynamic WithRotation:(float)rotation WithShape:(TC_SHAPE) shape WithVetexAX: (float)vax WithVetexAY: (float)vay WithVetexBX: (float)vbx WithVetexBY: (float)vby WithVetexCX: (float)vcx WithVetexCY: (float)vcy WithVetexDX: (float)vdx WithVetexDY: (float)vdy WithRadius:(float)r WithCoefficient:(float)e WithWidth:(float)w WithHeight:(float)h
{
    _position_x = x;
    _position_y = y;
    _dynamic = YES;
    _freeze = NO;
    _vx = 0;
    _vy = 0;
    _w = 0;
    _e = e;
    _rotation = rotation;
    _shape = shape;
    _r = r;
    _vetex_a_x = vax;
    _vetex_a_y = vay;
    _vetex_b_x = vbx;
    _vetex_b_y = vby;
    _vetex_c_x = vcx;
    _vetex_c_y = vcy;
    _vetex_d_x = vdx;
    _vetex_d_y = vdy;
    
    float temp;
    float max_x;
    float min_x;
    float max_y;
    float min_y;
    float grid_w = (w / COLLIDE_DETECTOR_BUFFER_WIDTH);
    float grid_h = (h / COLLIDE_DETECTOR_BUFFER_HEIGHT);
    switch(_shape)
    {
        case BOX_CIRCLE:
            min_x = _position_x - _r;
            max_x = _position_x + _r;
            min_y = _position_y - _r;
            max_y = _position_y + _r;
            break;
        case BOX_TRI:
            temp = _vetex_a_x;
            if(_vetex_b_x > temp)
            {
                temp = _vetex_b_x;
            }
            if(_vetex_c_x > temp)
            {
                temp = _vetex_c_x;
            }
            max_x = temp;
            
            temp = _vetex_a_y;
            if(_vetex_b_y > temp)
            {
                temp = _vetex_b_y;
            }
            if(_vetex_c_y > temp)
            {
                temp = _vetex_c_y;
            }
            max_y = temp;
            
            temp = _vetex_a_x;
            if(_vetex_b_x < temp)
            {
                temp = _vetex_b_x;
            }
            if(_vetex_c_x < temp)
            {
                temp = _vetex_c_x;
            }
            min_x = temp;
            
            temp = _vetex_a_y;
            if(_vetex_b_y < temp)
            {
                temp = _vetex_b_y;
            }
            if(_vetex_c_y < temp)
            {
                temp = _vetex_c_y;
            }
            min_y = temp;
            break;
            
        case BOX_RECT:
            temp = _vetex_a_x;
            if(_vetex_b_x > temp)
            {
                temp = _vetex_b_x;
            }
            if(_vetex_c_x > temp)
            {
                temp = _vetex_c_x;
            }
            if(_vetex_d_x > temp)
            {
                temp = _vetex_d_x;
            }
            max_x = temp;
            
            temp = _vetex_a_y;
            if(_vetex_b_y > temp)
            {
                temp = _vetex_b_y;
            }
            if(_vetex_c_y > temp)
            {
                temp = _vetex_c_y;
            }
            if(_vetex_d_y > temp)
            {
                temp = _vetex_d_y;
            }
            max_y = temp;
            
            temp = _vetex_a_x;
            if(_vetex_b_x < temp)
            {
                temp = _vetex_b_x;
            }
            if(_vetex_c_x < temp)
            {
                temp = _vetex_c_x;
            }
            if(_vetex_d_x < temp)
            {
                temp = _vetex_d_x;
            }
            min_x = temp;
            
            temp = _vetex_a_y;
            if(_vetex_b_y < temp)
            {
                temp = _vetex_b_y;
            }
            if(_vetex_c_y < temp)
            {
                temp = _vetex_c_y;
            }
            if(_vetex_d_y < temp)
            {
                temp = _vetex_b_y;
            }
            min_y = temp;
            break;
    }
    _buffer_index_left = (int)((min_x + w/2) / grid_w) + 1;
    _buffer_index_right = (int)((max_x + w/2) / grid_w) + 1;
    _buffer_index_top = (int)((max_y + h/2)/ grid_h) + 1;
    _buffer_index_bot = (int)((min_y + h/2) / grid_w) + 1;
}

- (void)updateWithwidth:(float)w Height:(float)h
{
    if(abs(_vx) < THRESHOLD && abs(_vy) < THRESHOLD)
    {
        _freeze = YES;
    }
    _position_x += _vx;
    _position_y += _vy;
}


- (int)writeBufferWithWidth:(float) w WithHeight: (float) h
{
    int i,j;
    float temp;
    float max_x;
    float min_x;
    float max_y;
    float min_y;
    float grid_w = (w / COLLIDE_DETECTOR_BUFFER_WIDTH);
    float grid_h = (h / COLLIDE_DETECTOR_BUFFER_HEIGHT);
    switch(_shape)
    {
        case BOX_CIRCLE:
            min_x = _position_x - _r;
            max_x = _position_x + _r;
            min_y = _position_y - _r;
            max_y = _position_y + _r;
            break;
        case BOX_TRI:
            temp = _vetex_a_x;
            if(_vetex_b_x > temp)
            {
                temp = _vetex_b_x;
            }
            if(_vetex_c_x > temp)
            {
                temp = _vetex_c_x;
            }
            max_x = temp;
            
            temp = _vetex_a_y;
            if(_vetex_b_y > temp)
            {
                temp = _vetex_b_y;
            }
            if(_vetex_c_y > temp)
            {
                temp = _vetex_c_y;
            }
            max_y = temp;
            
            temp = _vetex_a_x;
            if(_vetex_b_x < temp)
            {
                temp = _vetex_b_x;
            }
            if(_vetex_c_x < temp)
            {
                temp = _vetex_c_x;
            }
            min_x = temp;
            
            temp = _vetex_a_y;
            if(_vetex_b_y < temp)
            {
                temp = _vetex_b_y;
            }
            if(_vetex_c_y < temp)
            {
                temp = _vetex_c_y;
            }
            min_y = temp;
            break;
            
        case BOX_RECT:
            temp = _vetex_a_x;
            if(_vetex_b_x > temp)
            {
                temp = _vetex_b_x;
            }
            if(_vetex_c_x > temp)
            {
                temp = _vetex_c_x;
            }
            if(_vetex_d_x > temp)
            {
                temp = _vetex_d_x;
            }
            max_x = temp;
            
            temp = _vetex_a_y;
            if(_vetex_b_y > temp)
            {
                temp = _vetex_b_y;
            }
            if(_vetex_c_y > temp)
            {
                temp = _vetex_c_y;
            }
            if(_vetex_d_y > temp)
            {
                temp = _vetex_d_y;
            }
            max_y = temp;
            
            temp = _vetex_a_x;
            if(_vetex_b_x < temp)
            {
                temp = _vetex_b_x;
            }
            if(_vetex_c_x < temp)
            {
                temp = _vetex_c_x;
            }
            if(_vetex_d_x < temp)
            {
                temp = _vetex_d_x;
            }
            min_x = temp;
            
            temp = _vetex_a_y;
            if(_vetex_b_y < temp)
            {
                temp = _vetex_b_y;
            }
            if(_vetex_c_y < temp)
            {
                temp = _vetex_c_y;
            }
            if(_vetex_d_y < temp)
            {
                temp = _vetex_b_y;
            }
            min_y = temp;
            break;
    }
    
    int cross_section_top;
    int cross_section_bot;
    int cross_section_left;
    int cross_section_right;
    int buffer_index_left = (int)((min_x + w/2) / grid_w) + 1;
    int buffer_index_right = (int)((max_x + w/2) / grid_w) + 1;
    int buffer_index_top = (int)((max_y + h/2)/ grid_h) + 1;
    int buffer_index_bot = (int)((min_y + h/2) / grid_w) + 1;
    
    //check bounds
    if(buffer_index_left < 0 || buffer_index_right >= COLLIDE_DETECTOR_BUFFER_WIDTH || buffer_index_bot < 0 || buffer_index_top >= COLLIDE_DETECTOR_BUFFER_HEIGHT)
        return -1;
    
    //calculate cross section
    cross_section_top = (buffer_index_top > _buffer_index_top)?_buffer_index_top:buffer_index_top;
    cross_section_bot = (buffer_index_bot < _buffer_index_bot)?_buffer_index_bot:buffer_index_bot;
    cross_section_left = (buffer_index_left < _buffer_index_left)?_buffer_index_left:buffer_index_left;
    cross_section_right = (buffer_index_right > _buffer_index_right)?_buffer_index_right:buffer_index_right;
    
    //update old buffer
    for(i = _buffer_index_left;i <= _buffer_index_right;i++)
    {
        for(j = cross_section_top + 1; j <= _buffer_index_top; j++)
        {
            NSMutableArray* entry;
            int index;
            entry = [TC_PhysicsBody searchBufferInfoAtX:i AtY:j];
            if(entry == nil)
                return -1;
            index = [TC_PhysicsBody searchBufferInfoIndexFrom:entry By:self];
            if(index != -1)
                [entry removeObjectAtIndex:index];
        }
    }
    for(i = _buffer_index_left;i < cross_section_left;i++)
    {
        for(j = cross_section_bot; j <= cross_section_top; j++)
        {
            NSMutableArray* entry;
            int index;
            entry = [TC_PhysicsBody searchBufferInfoAtX:i AtY:j];
            if(entry == nil)
                return -1;
            index = [TC_PhysicsBody searchBufferInfoIndexFrom:entry By:self];
            if(index != -1)
                [entry removeObjectAtIndex:index];
        }
    }
    for(i = cross_section_right + 1;i <= _buffer_index_right;i++)
    {
        for(j = cross_section_bot; j <= cross_section_top; j++)
        {
            NSMutableArray* entry;
            int index;
            entry = [TC_PhysicsBody searchBufferInfoAtX:i AtY:j];
            if(entry == nil)
                return -1;
            index = [TC_PhysicsBody searchBufferInfoIndexFrom:entry By:self];
            if(index != -1)
                [entry removeObjectAtIndex:index];
        }
    }
    for(i = _buffer_index_left;i <= _buffer_index_right;i++)
    {
        for(j = _buffer_index_bot; j < cross_section_bot - 1; j++)
        {
            NSMutableArray* entry;
            int index;
            entry = [TC_PhysicsBody searchBufferInfoAtX:i AtY:j];
            if(entry == nil)
                return -1;
            index = [TC_PhysicsBody searchBufferInfoIndexFrom:entry By:self];
            if(index != -1)
                [entry removeObjectAtIndex:index];
        }
    }
    
    //update new buffer
    for(i = buffer_index_left;i <= buffer_index_right;i++)
    {
        for(j = cross_section_top + 1; j <= buffer_index_top; j++)
        {
            NSMutableArray* entry;
            TC_BufferInfo* new;
            entry = [TC_PhysicsBody searchBufferInfoAtX:i AtY:j];
            if(entry == nil)
                return -1;
            new = [TC_BufferInfo alloc];
            new.target = self;
            [entry addObject:new];
        }
    }
    for(i = buffer_index_left;i < cross_section_left;i++)
    {
        for(j = cross_section_bot; j <= cross_section_top; j++)
        {NSMutableArray* entry;
            TC_BufferInfo* new;
            entry = [TC_PhysicsBody searchBufferInfoAtX:i AtY:j];
            if(entry == nil)
                return -1;
            new = [TC_BufferInfo alloc];
            new.target = self;
            [entry addObject:new];
        }
    }
    for(i = cross_section_right + 1;i <= buffer_index_right;i++)
    {
        for(j = cross_section_bot; j <= cross_section_top; j++)
        {
            NSMutableArray* entry;
            TC_BufferInfo* new;
            entry = [TC_PhysicsBody searchBufferInfoAtX:i AtY:j];
            if(entry == nil)
                return -1;
            new = [TC_BufferInfo alloc];
            new.target = self;
            [entry addObject:new];
        }
    }
    for(i = buffer_index_left;i <= buffer_index_right;i++)
    {
        for(j = buffer_index_bot; j < cross_section_bot - 1; j++)
        {
            NSMutableArray* entry;
            TC_BufferInfo* new;
            entry = [TC_PhysicsBody searchBufferInfoAtX:i AtY:j];
            if(entry == nil)
                return -1;
            new = [TC_BufferInfo alloc];
            new.target = self;
            [entry addObject:new];
        }
    }
    
    //update buffer infomation
    _buffer_index_bot = buffer_index_bot;
    _buffer_index_top = buffer_index_top;
    _buffer_index_right = buffer_index_right;
    _buffer_index_left = buffer_index_left;
    
    return 0;
}

+ (NSMutableArray*)searchBufferInfoAtX:(int)x AtY:(int)y
{
    int index = x * COLLIDE_DETECTOR_BUFFER_WIDTH + y;
    if(index >= COLLIDE_DETECTOR_BUFFER_WIDTH * COLLIDE_DETECTOR_BUFFER_HEIGHT)
        return nil;
    return collide_buffer[index];
}
+ (int)searchBufferInfoIndexFrom:(NSMutableArray*)entry By:(TC_PhysicsBody*) target
{
    int i;
    for(i = 0;i < [entry count]; i ++)
    {
        if(entry[i] == target)
        {
            return i;
        }
    }
    return -1;
}
@end
