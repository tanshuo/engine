//
//  phy_math.h
//  try
//
//  Created by tanshuo on 7/27/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#ifndef try_phy_math_h
#define try_phy_math_h
#import "math.h"

typedef struct vector2d
{
    float x;
    float y;
} VECTOR2D;

void genNomalVector(VECTOR2D* result,float p1x,float p1y,float p2x,float p2y);

void genTangentVector(VECTOR2D* result, float p1x,float p1y,float p2x,float p2y);

float genDot(VECTOR2D* v1, VECTOR2D* v2);

float genCross(VECTOR2D* v1, VECTOR2D* v2);

void genVector2(VECTOR2D* v, float x, float y);

#endif

