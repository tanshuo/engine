//
//  TC_PhysicsBody.m
//  try
//
//  Created by tanshuo on 7/26/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import "TC_PhysicsBody.h"

@implementation TC_PhysicsBody
- (void) move
{

}

- (void) cleanBuffer
{

}

- (void) writeBuffer
{
    float temp;
    float max_x;
    float min_x;
    float max_y;
    float min_y;
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
}
@end
