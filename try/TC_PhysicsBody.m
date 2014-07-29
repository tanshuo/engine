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
    int i;
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
    
    _vetex_count = 4;
    _vetex_x = malloc(_vetex_count * sizeof(float));
    _vetex_y = malloc(_vetex_count * sizeof(float));
    if(self.shape == BOX_RECT)
    {
        _vetex_x[0] = x - w / 2.0;
        _vetex_y[0] = y + h / 2.0;
        _vetex_x[1] = x + w / 2.0;
        _vetex_y[1] = y + h / 2.0;
        _vetex_x[2] = x + w / 2.0;
        _vetex_y[2] = y - h / 2.0;
        _vetex_x[3] = x - w / 2.0;
        _vetex_y[3] = y - h / 2.0;
        _r = sqrtf(w * w + h * h) / 2.0;
    }
    else if(self.shape == BOX_TRI)
    {
        _vetex_x[0] = x;
        _vetex_y[0] = y + r;
        _vetex_x[1] = x + 3.0 * r / 2.0 / sqrtf(3.0);
        _vetex_y[1] = y - r / 2.0;
        _vetex_x[2] = x - 3.0 * r / 2.0 / sqrtf(3.0);
        _vetex_y[2] = y - r / 2.0;
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
            temp = _vetex_x[0];
            if(_vetex_x[1] > temp)
            {
                temp = _vetex_x[1];
            }
            if(_vetex_x[2] > temp)
            {
                temp = _vetex_x[2];
            }
            max_x = temp;
            
            temp = _vetex_y[0];
            if(_vetex_y[1] > temp)
            {
                temp = _vetex_y[1];
            }
            if(_vetex_y[2] > temp)
            {
                temp = _vetex_y[2];
            }
            max_y = temp;
            
            temp = _vetex_x[0];
            if(_vetex_x[1] < temp)
            {
                temp = _vetex_x[1];
            }
            if(_vetex_x[2] < temp)
            {
                temp = _vetex_x[2];
            }
            min_x = temp;
            
            temp = _vetex_y[0];
            if(_vetex_y[1] < temp)
            {
                temp = _vetex_y[1];
            }
            if(_vetex_y[2] < temp)
            {
                temp = _vetex_y[2];
            }
            min_y = temp;
            break;
            
        case BOX_RECT:
            temp = _vetex_x[0];
            for(i = 1; i < _vetex_count; i++)
            {
                if(_vetex_x[i] > temp)
                {
                    temp = _vetex_x[i];
                }
            }
            max_x = temp;
            
            temp = _vetex_y[0];
            for(i = 1; i < _vetex_count; i++)
            {
                if(_vetex_y[i] > temp)
                {
                    temp = _vetex_y[i];
                }
            }
            max_y = temp;
            
            temp = _vetex_x[0];
            for(i = 1; i < _vetex_count; i++)
            {
                if(_vetex_x[i] < temp)
                {
                    temp = _vetex_y[i];
                }
            }
            min_x = temp;
            
            temp = _vetex_y[0];
            for(i = 1; i < _vetex_count; i++)
            {
                if(_vetex_y[i] < temp)
                {
                    temp = _vetex_y[i];
                }
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
            temp = _vetex_x[0];
            if(_vetex_x[1] > temp)
            {
                temp = _vetex_x[1];
            }
            if(_vetex_x[2] > temp)
            {
                temp = _vetex_x[2];
            }
            max_x = temp;
            
            temp = _vetex_y[0];
            if(_vetex_y[1] > temp)
            {
                temp = _vetex_y[1];
            }
            if(_vetex_y[2] > temp)
            {
                temp = _vetex_y[2];
            }
            max_y = temp;
            
            temp = _vetex_x[0];
            if(_vetex_x[1] < temp)
            {
                temp = _vetex_x[1];
            }
            if(_vetex_x[2] < temp)
            {
                temp = _vetex_x[2];
            }
            min_x = temp;
            
            temp = _vetex_y[0];
            if(_vetex_y[1] < temp)
            {
                temp = _vetex_y[1];
            }
            if(_vetex_y[2] < temp)
            {
                temp = _vetex_y[2];
            }
            min_y = temp;
            break;
            
        case BOX_RECT:
            temp = _vetex_x[0];
            for(i = 1; i < _vetex_count; i++)
            {
                if(_vetex_x[i] > temp)
                {
                    temp = _vetex_x[i];
                }
            }
            max_x = temp;
            
            temp = _vetex_y[0];
            for(i = 1; i < _vetex_count; i++)
            {
                if(_vetex_y[i] > temp)
                {
                    temp = _vetex_y[i];
                }
            }
            max_y = temp;
            
            temp = _vetex_x[0];
            for(i = 1; i < _vetex_count; i++)
            {
                if(_vetex_x[i] < temp)
                {
                    temp = _vetex_y[i];
                }
            }
            min_x = temp;
            
            temp = _vetex_y[0];
            for(i = 1; i < _vetex_count; i++)
            {
                if(_vetex_y[i] < temp)
                {
                    temp = _vetex_y[i];
                }
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

- (float)seperationByEdgeNormal:(VECTOR2D*)normal ByEdge:(int)edge WithBox:(TC_PhysicsBody*)box1 WithBox:(TC_PhysicsBody*)box2 At:(int*) vetex
{
    int i;
    VECTOR2D v;
    genVector2(&v,box2.vetex_x[0] - box2.position_x,box2.vetex_y[0] - box2.position_y);
    float mindot = genDot(normal,&v);
    float temp;
    int ve = 0;
    for(i = 1; i < box2.vetex_count; i++)
    {
        genVector2(&v,box2.vetex_x[i] - box2.position_x,box2.vetex_y[i] - box2.position_y);
        temp = genDot(normal,&v);
        if(temp < mindot)
        {
            mindot = temp;
            ve = i;
        }
    }
    *vetex = ve;
    genVector2(&v,box2.vetex_x[ve] - box1.vetex_x[edge],box2.vetex_y[ve] - box1.vetex_y[edge]);
    return genDot(normal,&v);
}

- (float)maxSeperationDistanceBetween:(TC_PhysicsBody*)box1 And:(TC_PhysicsBody*)box2 From: (int*)edge To: (int*) vetex
{
    int i;
    int count = box1.vetex_count;
    VECTOR2D d;
    VECTOR2D normal1[box1.vetex_count];
    float dot_max;
    
    d.x = box2.position_x - box1.position_x;
    d.y = box2.position_y - box1.position_y;
    for(i = 0; i < count; i ++)
    {
        int index_end = (i + 1 < count)? i + 1 : 0;
        genNomalVector(&normal1[i],box1.vetex_x[i], box1.vetex_y[i],box1.vetex_x[index_end], box1.vetex_y[index_end]);
    }
    
    float temp;
    int e;
    dot_max = genDot(&d,&normal1[0]);
    e = 0;
    for(i = 1; i < count; i++)
    {
        temp = genDot(&d,&normal1[i]);
        if(temp > dot_max)
        {
            dot_max = temp;
            e = i;
        }
    }
    *edge = e;
    
    int vetex_current;
    int vetex_pre;
    int vetex_next;
    int e_pre;
    int e_next;
    float current_l = [self seperationByEdgeNormal:&normal1[e] ByEdge:e WithBox:box1 WithBox:box2 At:&vetex_current];
    e_pre = (e > 0)? e - 1 : count - 1;
    float pre_l = [self seperationByEdgeNormal:&normal1[e_pre] ByEdge:e_pre WithBox:box1 WithBox:box2 At:&vetex_pre];
    e_next = (e < count - 1)? e + 1 : 0;
    float next_l = [self seperationByEdgeNormal:&normal1[e_next] ByEdge:e_next WithBox:box1 WithBox:box2 At:&vetex_next];
    
    float result;
    int delta;
    if(current_l >= pre_l && current_l >= next_l)
    {
        result = current_l;
        *vetex = vetex_current;
        return result;
    }
    else if (pre_l >= current_l && pre_l >= next_l)
    {
        result = pre_l;
        *vetex = vetex_pre;
        delta = -1;
    }
    else
    {
        result = next_l;
        *vetex = vetex_next;
        delta = 1;
    }
    
    while(1)
    {
        if(delta > 0)
        {
            e_pre = (e_pre - 1 > 0)? e_pre - 1 : count - 1;
            float s = [self seperationByEdgeNormal:&normal1[e_pre] ByEdge:e_pre WithBox:box1 WithBox:box2 At:&vetex_pre];
            if(s > pre_l)
            {
                result = pre_l;
                *edge = e_pre;
                *vetex = vetex_pre;
            }
            else
                return result;
        }
        else if(delta < 0)
        {
            e_next = (e_next < count - 1)? e_next + 1 : 0;
            float s = [self seperationByEdgeNormal:&normal1[e_next] ByEdge:e_next WithBox:box1 WithBox:box2 At:&vetex_next];
            if(s > next_l)
            {
                result = next_l;
                *edge = e_next;
                *vetex = vetex_next;
            }
            else
                return result;
        }
        
    }
    return result;
}

- (TC_ContactInfo*)genCollide
{
    return nil;
}

- (void)collideDetectWith: (TC_PhysicsBody*) box
{
    if([self isPossibleCollideWith:box])
    {
        return;
    }
}

- (BOOL)isPossibleCollideWith: (TC_PhysicsBody*) box
{
    //use a circle area to approxy collide
    float l = (self.position_x - box.position_x) * (self.position_x - box.position_x) + (self.position_y - box.position_y) * (self.position_y - box.position_y);
    if(l > (self.r + box.r) * (self.r + box.r))
    {
        return NO;
    }
    return YES;
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

- (void)dealloc
{
    free(_vetex_x);
    free(_vetex_y);
}
@end
