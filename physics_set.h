//
//  physics_set.h
//  try
//
//  Created by tanshuo on 7/26/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#ifndef try_physics_set_h
#define try_physics_set_h
#include "TC_ContactInfo.h"
#define COLLIDE_DETECTOR_BUFFER_HEIGHT 30
#define COLLIDE_DETECTOR_BUFFER_WIDTH 30

typedef enum shape{
    BOX_CIRCLE,
    BOX_RECT,
    BOX_TRI,
} TC_SHAPE;

typedef struct vector2d
{
    float x;
    float y;
} VECTOR2D;

NSMutableArray* collide_buffer;

#endif
