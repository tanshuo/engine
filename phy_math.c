//
//  phy_math.c
//  try
//
//  Created by tanshuo on 7/30/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#include "phy_math.h"


void genNomalVector(VECTOR2D* result,float p1x,float p1y,float p2x,float p2y)
{
    result->x = p1y - p2y;
    result->y = p2x - p1x;
    float mol = result->x * result->x + result->y * result->y;
    mol = sqrtf(mol);
    result->x = result->x / mol;
    result->y = result->y / mol;
}

void genTangentVector(VECTOR2D* result, float p1x,float p1y,float p2x,float p2y)
{
    result->x = p2x - p1x;
    result->y = p2y - p1y;
    float mol = result->x * result->x + result->y * result->y;
    mol = sqrtf(mol);
    result->x = result->x / mol;
    result->y = result->y / mol;
}

float genDot(VECTOR2D* v1, VECTOR2D* v2)
{
    return v1->x * v2->x + v1->y * v2->y;
}

float genCross(VECTOR2D* v1, VECTOR2D* v2)
{
    return v1->x * v2->y + v1->y * v2->x;
}

void genVector2(VECTOR2D* v, float x, float y)
{
    v->x = x;
    v->y = y;
}
