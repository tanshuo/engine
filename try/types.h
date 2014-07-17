//
//  types.h
//  try
//
//  Created by tanshuo on 6/22/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#ifndef try_types_h
#define try_types_h

typedef enum{
    OBJDISPLAY,
    OBJSPRITE,
    OBJCAMARA,
    OBJLAYER,
} TC_OBJ_TYPE;

typedef enum{
    ins_jmp,
    ins_jmp_true,
    ins_jmp_false,
    ins_call,
    ins_push,
    ins_rtn,
    ins_jmp_last,
} TC_INS;


typedef enum{
    TC_INSTANCE,//<4 5 6>
    TC_FUNCTION,
    TC_VAR,
    TC_WHILE, //
    TC_IF,
    TC_BREAK,
    TC_IGNORE,//let should would on to
    TC_THEN, // keyword ,
    TC_CAL, //calculate
    TC_END, // ; only
    TC_OF, //of
    TC_MY, //my
    TC_ELSE,
    TC_AND, //and
    TC_OR, // or
    TC_AFTER, //after as soon as
    TC_DEFINE,
    TC_END_DEF,
    TC_PUSH,
    TC_RETURN,
    TC_DECLARE,
} TC_Explain;

typedef unsigned int TC_ID;
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_SAMPLE,
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

typedef struct position2d{
    float x;
    float y;
} TC_Position2d;

typedef struct signal{
    TC_ID signal_id;
    TC_ID do_what;
    int priority;
    float data1;
    float data2;
} TC_Signal;


#endif
