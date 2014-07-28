//
//  phy_math.h
//  try
//
//  Created by tanshuo on 7/27/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#ifndef try_phy_math_h
#define try_phy_math_h
typedef struct vector2d
{
    float x;
    float y;
} VECTOR2D;


VECTOR2D* genNomalVector(float p1x,float p1y,float p2x,float p2y)
{
    VECTOR2D* result = malloc(sizeof(VECTOR2D));
    result->x = p1y - p2y;
    result->y = p2x - p1x;
    return result;
}

VECTOR2D* genTangentVector(float p1x,float p1y,float p2x,float p2y)
{
    VECTOR2D* result = malloc(sizeof(VECTOR2D));
    result->x = p2x - p1x;
    result->y = p2y - p1y;
    return result;
}

float genDot(VECTOR2D* tangent, VECTOR2D* normal)
{
    float temp1 = normal->x * normal->x + normal->y * normal->y;
    float temp2 = tangent->x * tangent->x + tangent->y * tangent->y;
    float dotx = temp2 * normal->x / temp1;
    float doty = temp2 * normal->y / temp1;
    return dotx * normal->x + doty * normal->y;
}

#endif
