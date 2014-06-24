//
//  types.h
//  try
//
//  Created by tanshuo on 6/22/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#ifndef try_types_h
#define try_types_h

typedef unsigned int TC_ID;
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};


// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

typedef struct position{
    float x;
    float y;
    float z;
} TC_Position;

typedef struct signal{
    TC_ID signal_id;
    TC_ID do_what;
    int priority;
    float data1;
    float data2;
} TC_Signal;

typedef struct insturction{
    TC_ID instruction_type;
    void* p1;
    void* p2;
    void* p3;
} TC_Instruction;
#endif
