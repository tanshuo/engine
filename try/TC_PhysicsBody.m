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
    _alive = YES;
    _position_x = x;
    _position_y = y;
    _ww = ww;
    _wh = wh;
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
    _normal = malloc(_vetex_count * sizeof(VECTOR2D));
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
    
    NSMutableArray* entry;
    int j;
    for(i = _buffer_index_left; i <= _buffer_index_right;i ++)
    {
        for(j = _buffer_index_bot; j <= _buffer_index_top; j++)
        {
            entry = [TC_PhysicsBody searchBufferInfoAtX:i AtY:j];
            if(entry != nil)
            {
                TC_BufferInfo* temp = [TC_BufferInfo alloc];
                temp.target = self;
                [entry addObject:temp];
            }
        }
    }
    [objects addObject:self];//register to list
}

- (void)updateWithwidth:(float)w Height:(float)h
{
    if(! _freeze)
    {
        [self writeBufferWithWidth:w WithHeight:h];
        [self genCollide];
    }
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
    VECTOR2D* normal1 = box1.normal;
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

- (void)genCollide
{
    int i,j,index;
    NSMutableArray* entry;
    TC_PhysicsBody* p;
    
    for(i = _buffer_index_left - 1; i <= _buffer_index_right + 1; i++)
    {
        for(j = _buffer_index_bot - 1; j <= _buffer_index_bot + 1; j++)
        {
            entry = [TC_PhysicsBody searchBufferInfoAtX:i AtY:j];
            if(entry == nil)
            {
                continue;
            }
            for(index = 0; index < [entry count]; index++)
            {
                p = [entry[index] target];
                if([p alive] == NO)
                {
                    [entry removeObjectAtIndex:index];
                    index --;
                    continue;
                }
                if(p == self)
                {
                    continue;
                }
                [self collideDetectWith:p];
            }
        }
    }
    
    for(i = _buffer_index_left; i <= _buffer_index_right; i++)
    {
        for(j = _buffer_index_top - 1; j <= _buffer_index_top + 1; j++)
        {
            entry = [TC_PhysicsBody searchBufferInfoAtX:i AtY:j];
            if(entry == nil)
            {
                continue;
            }
            for(index = 0; index < [entry count]; index++)
            {
                p = [entry[index] target];
                if([p alive] == NO)
                {
                    [entry removeObjectAtIndex:index];
                    index --;
                    continue;
                }
                if(p == self)
                {
                    continue;
                }
                [self collideDetectWith:p];
            }
        }
    }
    
    for(j = _buffer_index_bot + 1; j <= _buffer_index_top - 1; j++)
    {
        for(i = _buffer_index_left - 1; i <= _buffer_index_left + 1; i++)
        {
            entry = [TC_PhysicsBody searchBufferInfoAtX:i AtY:j];
            if(entry == nil)
            {
                continue;
            }
            for(index = 0; index < [entry count]; index++)
            {
                p = [entry[index] target];
                if([p alive] == NO)
                {
                    [entry removeObjectAtIndex:index];
                    index --;
                    continue;
                }
                if(p == self)
                {
                    continue;
                }
                [self collideDetectWith:p];
            }
        }
    }
    
    for(j = _buffer_index_bot + 1; j <= _buffer_index_top - 1; j++)
    {
        for(i = _buffer_index_right - 1; i <= _buffer_index_right + 1; i++)
        {
            entry = [TC_PhysicsBody searchBufferInfoAtX:i AtY:j];
            if(entry == nil)
            {
                continue;
            }
            for(index = 0; index < [entry count]; index++)
            {
                p = [entry[index] target];
                if([p alive] == NO)
                {
                    [entry removeObjectAtIndex:index];
                    index --;
                    continue;
                }
                if(p == self)
                {
                    continue;
                }
                [self collideDetectWith:p];
            }
        }
    }
}

- (BOOL) searchContactWith:(TC_PhysicsBody*)box In:(TC_PhysicsBody*)target
{
    int i;
    for(i = 0; i < [target.contact_points count]; i++)
    {
        if(target.contact_points[i] == box)
        {
            return YES;
        }
    }
    return NO;
}

- (void)collideDetectWith: (TC_PhysicsBody*) box
{
    if([self searchContactWith:box In:self])
    {
        return;
    }
    TC_ContactInfo* result = [TC_ContactInfo alloc];
    VECTOR2D v;
    if(![self isPossibleCollideWith:box])
    {
        return;
    }
    int edge_a,vetex_a,edge_b,vetex_b;
    float sa = [self maxSeperationDistanceBetween:self And:box From:&edge_a To:&vetex_a];
    float sb = [self maxSeperationDistanceBetween:box And:self From:&edge_b To:&vetex_b];
    if(sa > 0 || sb > 0)
    {
        return;
    }
    int a_in;
    int a_out;
    int b_in;
    int b_out;
    int re;
    re = [self findCrossEdges:&a_in :&a_out :&b_in :&b_out With:vetex_a With:vetex_b With:self With:box With:edge_a With:edge_b];
    if(re == -1)
    {
        result.break_in = YES;
        result.owner = box;
        [self.contact_points addObject:result];
        
        result = [TC_ContactInfo alloc];
        result.break_in = YES;
        result.owner = self;
        if([self searchContactWith:self In:box])
        {
            return;
        }
        [box.contact_points addObject:result];
        box.freeze = NO;
        return;
    }
    result.break_in = NO;
    
    int end;
    VECTOR2D vah;
    VECTOR2D vae;
    VECTOR2D vbh;
    VECTOR2D vbe;
    vah.x = box.vetex_x[a_in];
    vah.y = box.vetex_y[a_in];
    end = (a_in + 1 < box.vetex_count)? a_in + 1 : 0;
    vae.x = box.vetex_x[end];
    vae.y = box.vetex_y[end];
    
    vbh.x = self.vetex_x[b_out];
    vbh.y = self.vetex_y[b_out];
    end = (b_out + 1 < self.vetex_count)? b_out + 1 : 0;
    vbe.x = self.vetex_x[end];
    vbe.y = self.vetex_y[end];
    re = [self findIntersectionPoint:&v AtVectorA_Head:vah AtVectorA_End:vae AtVectorB_Head:vbh AtVectorB_End:vbe];
    if(re == -1)
    {
        return;
    }
    result.p1_x = v.x;
    result.p1_y = v.y;
    
    vah.x = box.vetex_x[a_out];
    vah.y = box.vetex_y[a_out];
    end = (a_out + 1 < box.vetex_count)? a_out + 1 : 0;
    vae.x = box.vetex_x[end];
    vae.y = box.vetex_y[end];
    
    vbh.x = self.vetex_x[b_in];
    vbh.y = self.vetex_y[b_in];
    end = (b_in + 1 < self.vetex_count)? b_in + 1 : 0;
    vbe.x = self.vetex_x[end];
    vbe.y = self.vetex_y[end];
    re = [self findIntersectionPoint:&v AtVectorA_Head:vah AtVectorA_End:vae AtVectorB_Head:vbh AtVectorB_End:vbe];
    if(re == -1)
    {
        return;
    }
    result.p2_x = v.x;
    result.p2_y = v.y;
    
    float d_self;
    float d_box;
    int self_start = b_in + 1 < self.vetex_count ? b_in + 1 : 0;
    int self_end = b_out;
    int box_start = a_in + 1 < box.vetex_count ? a_in + 1 : 0;;
    int box_end = a_out;
    
    d_self = [self calDepth:result Point:self_start Point:self_end Box:self];
    d_box = [self calDepth:result Point:box_start Point:box_end Box:box];
    genNomalVector(&v, result.p2_x, result.p2_y, result.p1_x, result.p1_y);
    
    float temp_p1_x = result.p1_x;
    float temp_p1_y = result.p1_y;
    float temp_p2_x = result.p2_x;
    float temp_p2_y = result.p2_y;
    
    result.normal_x = v.x;
    result.normal_y = v.y;
    result.depth = d_self;
    result.owner = box;
    result.folder = d_box + d_self;
    [self.contact_points addObject: result];
    
    result = [TC_ContactInfo alloc];
    result.normal_x = -v.x;
    result.normal_y = -v.y;
    result.depth = d_box;
    result.owner = self;
    result.p1_x = temp_p2_x;
    result.p1_y = temp_p2_y;
    result.p2_x = temp_p1_x;
    result.p2_y = temp_p1_y;
    result.folder = d_box + d_self;
    result.break_in = NO;
    if([self searchContactWith:self In:box])
    {
        return;
    }
    [box.contact_points addObject: result];
    box.freeze = NO;
}

-(float) calDepth:(TC_ContactInfo*)contact Point:(int)p_start Point:(int)p_end  Box:(TC_PhysicsBody*)box
{
    float result;
    int index;
    VECTOR2D v;
    VECTOR2D w;
    genTangentVector(&v, contact.p2_x, contact.p2_y, contact.p1_x, contact.p1_y);
    index = p_start;
    float max = -999999999.0;
    float temp;
    while(true)
    {
        index = index + 1 < box.vetex_count ? index + 1 : 0;
        if(index == p_end)
        {
            break;
        }
        genVector2(&w, box.vetex_x[index] - contact.p1_x, box.vetex_y[index] - contact.p1_y);
        temp = genCross(&v, &w);
    
        if(temp > max)
        {
            max = temp;
        }
    }
    result = max;
    return result;
}

- (int) findIntersectionPoint:(VECTOR2D*)v AtVectorA_Head:(VECTOR2D)vah AtVectorA_End:(VECTOR2D)vae AtVectorB_Head:(VECTOR2D)vbh AtVectorB_End:(VECTOR2D)vbe
{
    if((vae.y - vah.y) * (vbh.x - vbe.x) == (vae.x - vah.x) * (vbh.y - vbe.y))
    {
        return -1;
    }
    
    v->x = ((vae.x - vah.x) * (vbh.x - vbe.x) * (vbh.y - vah.y) - vbh.x * (vae.x - vah.x) * (vbh.y - vbe.y) + vah.x * (vae.y - vah.y) * (vbh.x - vbe.x)) / ((vae.y - vah.y) * (vbh.x - vbe.x) - (vae.x - vah.x) * (vbh.y - vbe.y));
    v->y = ((vae.y - vah.y) * (vbh.y - vbe.y) * (vbh.x - vah.x) - vbh.y * (vae.y - vah.y) * (vbh.x - vbe.x) + vah.y * (vae.x - vah.x) * (vbh.y - vbe.y)) / ((vae.x - vah.x) * (vbh.y - vbe.y) - (vae.y - vah.y) * (vbh.x - vbe.x));
    return 0;
}

- (BOOL) insideBox:(TC_PhysicsBody*)box Pivot:(VECTOR2D)p
{
    int i;
    VECTOR2D w;
    VECTOR2D v;
    w.x = p.x - box.position_x;
    w.y = p.y - box.position_y;
    for(i = 0; i < box.vetex_count; i ++)
    {
        genVector2(&v, box.vetex_x[i] - box.position_x, box.vetex_y[i] - box.position_y);
        if(genDot(&w, &box.normal[i]) > genDot(&v, &box.normal[i]))
        {
            return NO;
        }
    }
    
    return YES;
}

- (int)findCrossEdges:(int*)a_in : (int*)a_out : (int*)b_in : (int*)b_out With:(int)support_vetex_a With:(int)support_vetex_b With:(TC_PhysicsBody*)box_a With:(TC_PhysicsBody*)box_b With: (int)edge_a With:(int)edge_b
{
    int i;
    int count_left = 0;
    int count_right = 0;
    VECTOR2D v;
    int count1 = box_a.vetex_count;
    VECTOR2D* normal1 = box_a.normal;
    int count2 = box_b.vetex_count;
    VECTOR2D* normal2 = box_b.normal;
    for(i = 0; i < count1; i ++)
    {
        int index_end = (i + 1 < count1)? i + 1 : 0;
        genNomalVector(&normal1[i],box_a.vetex_x[i], box_a.vetex_y[i],box_a.vetex_x[index_end], box_a.vetex_y[index_end]);
    }
    for(i = 0; i < count2; i ++)
    {
        int index_end = (i + 1 < count1)? i + 1 : 0;
        genNomalVector(&normal2[i],box_b.vetex_x[i], box_b.vetex_y[i],box_b.vetex_x[index_end], box_b.vetex_y[index_end]);
    }
    
    int v_start,v_end;
    genVector2(&v, box_b.vetex_x[support_vetex_a], box_b.vetex_y[support_vetex_a]);
    if([self insideBox:box_a Pivot:v])
    {
        v_start = support_vetex_a;
        v_end = support_vetex_a;
        int index = support_vetex_a;
        while(true)
        {
            index = (index - 1 >= 0)? index - 1 : count2 - 1;
            genVector2(&v, box_b.vetex_x[index], box_b.vetex_y[index]);
            if([self insideBox:box_a Pivot:v])
            {
                count_left ++;
                if(index == support_vetex_a)
                {
                    return -1;
                }
                v_start = index;
            }
            else
                break;
        }
        index = support_vetex_a;
        while(true)
        {
            index = (index + 1 < count2)? index + 1 : 0;
            genVector2(&v, box_b.vetex_x[index], box_b.vetex_y[index]);
            if([self insideBox:box_a Pivot:v])
            {
                count_right ++;
                if(index == support_vetex_a)
                {
                    return -1;
                }
                v_end = index;
            }
            else
                break;
        }
        if(count_left + count_right >= count2 - 1)
        {
            return -1;
        }
        *a_in = v_start - 1 >= 0 ? v_start - 1 : count2 - 1;
        *a_out = v_end;
    }
    else
    {
        *a_in = edge_b;
        *a_out = edge_b;
    }
    ///
    count_left = 0;
    count_right = 0;
    genVector2(&v, box_a.vetex_x[support_vetex_b], box_a.vetex_y[support_vetex_b]);
    if([self insideBox:box_b Pivot:v])
    {
        v_start = support_vetex_b;
        v_end = support_vetex_b;
        int index = support_vetex_b;
        while(true)
        {
            index = (index - 1 >= 0)? index - 1 : count1 - 1;
            genVector2(&v, box_a.vetex_x[index], box_a.vetex_y[index]);
            if([self insideBox:box_b Pivot:v])
            {
                count_left ++;
                if(index == support_vetex_b)
                {
                    return -1;
                }
                v_start = index;
            }
            else
                break;
        }
        index = support_vetex_b;
        while(true)
        {
            index = (index + 1 < count1)? index + 1 : 0;
            genVector2(&v, box_a.vetex_x[index], box_a.vetex_y[index]);
            if([self insideBox:box_b Pivot:v])
            {
                count_right++;
                if(index == support_vetex_b)
                {
                    return -1;
                }
                v_end = index;
            }
            else
                break;
        }
        if(count_left + count_right >= count1 - 1)
        {
            return -1;
        }
        *b_in = v_start - 1 >= 0 ? v_start - 1 : count1 - 1;
        *b_out = v_end;
    }
    else
    {
        *b_in = edge_a;
        *b_out = edge_a;
    }
    return 0;
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
    if(x < 0 || y < 0 || x >= COLLIDE_DETECTOR_BUFFER_WIDTH || y >= COLLIDE_DETECTOR_BUFFER_HEIGHT)
    {
        return nil;
    }
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
    free(_normal);
}
@end
