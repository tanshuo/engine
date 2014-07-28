//
//  TC_PhysicsBody.m
//  try
//
//  Created by tanshuo on 7/26/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import "TC_PhysicsBody.h"

@implementation TC_PhysicsBody

- (void)initWithX:(float)x WithY:(float)y WithWidth:(float)w WithHeight:(float)h WithProperty:(BOOL)dynamic WithRotation:(float)rotation WithShape:(TC_SHAPE) shape  WithRadius:(float)r WithCoefficient:(float)e WithWorldWidth:(float)ww WithWorldHeight:(float)wh
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
    if(self.shape == BOX_RECT)
    {
        _vetex_a_x = x - w / 2.0;
        _vetex_a_y = y + h / 2.0;
        _vetex_b_x = x + w / 2.0;
        _vetex_b_y = y + h / 2.0;
        _vetex_c_x = x + w / 2.0;
        _vetex_c_y = y - h / 2.0;
        _vetex_d_x = x - w / 2.0;
        _vetex_d_y = y - h / 2.0;
        _r = sqrtf(w * w + h * h) / 2.0;
    }
    else if(self.shape == BOX_TRI)
    {
        _vetex_a_x = x;
        _vetex_a_y = y + r;
        _vetex_b_x = x + 3.0 * r / 2.0 / sqrtf(3.0);
        _vetex_b_y = y - r / 2.0;
        _vetex_c_x = x - 3.0 * r / 2.0 / sqrtf(3.0);
        _vetex_c_y = y - r / 2.0;
    }
    _contact_points = [NSMutableArray arrayWithCapacity:10];
    _hinges = [NSMutableArray arrayWithCapacity:10];
    
    float temp;
    float max_x;
    float min_x;
    float max_y;
    float min_y;
    float grid_w = (ww / COLLIDE_DETECTOR_BUFFER_WIDTH);
    float grid_h = (wh / COLLIDE_DETECTOR_BUFFER_HEIGHT);
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
    _buffer_index_left = (int)((min_x + ww/2) / grid_w) + 1;
    _buffer_index_right = (int)((max_x + ww/2) / grid_w) + 1;
    _buffer_index_top = (int)((max_y + wh/2)/ grid_h) + 1;
    _buffer_index_bot = (int)((min_y + wh/2) / grid_w) + 1;
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

- (TC_ContactInfo*)genCollide
{
    return nil;
}

- (void)collideDetectWith: (TC_PhysicsBody*) box
{
    
}

- (BOOL)isCollideWith: (TC_PhysicsBody*) box
{
    //First use a circle area to approxy collide
    float l = (self.position_x - box.position_x) * (self.position_x - box.position_x) + (self.position_y - box.position_y) * (self.position_y - box.position_y);
    if(l > (self.r + box.r) * (self.r + box.r))
    {
        return false;
    }
    
    //SAT Algorithm
    if(self.shape == BOX_RECT && box.shape == BOX_RECT)
    {
        float x1[4] = {self.vetex_a_x,self.vetex_b_x,self.vetex_c_x,self.vetex_d_x};
        float x2[4] = {box.vetex_a_x,box.vetex_b_x,box.vetex_c_x,box.vetex_d_x};
        float y1[4] = {self.vetex_a_y,self.vetex_b_y,self.vetex_c_y,self.vetex_d_y};
        float y2[4] = {box.vetex_a_y,box.vetex_b_y,box.vetex_c_y,box.vetex_d_y};
        int i;
        for(i = 0; i < 4;i ++)
        {
            
        }
    }
    else  if(self.shape == BOX_TRI && box.shape == BOX_RECT)
    {
    
    }
    else  if(self.shape == BOX_RECT && box.shape == BOX_TRI)
    {
        
    }
    
    //circle rectangle contact algorithm
    if(self.shape == BOX_RECT && box.shape == BOX_CIRCLE)
    {
    
    }
    else if(self.shape == BOX_CIRCLE && box.shape == BOX_RECT)
    {
    
    }
    
    //box triangle contact algorithm
    if(self.shape == BOX_TRI && box.shape == BOX_CIRCLE)
    {
        
    }
    else if(self.shape == BOX_CIRCLE && box.shape == BOX_TRI)
    {
        
    }
    return false;
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
