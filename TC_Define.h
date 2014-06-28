//
//  TC_Dictionary.h
//  try
//
//  Created by tanshuo on 6/27/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "types.h"
typedef enum{
    TC_GAMEOBJ,
    TC_FUNCTION,
    TC_FLOAT,
    TC_VECTOR2,
    TC_VECTOR3,
    TC_INT,
    TC_GLOBOL,
    TC_WHILE, //
    TC_IF,
    TC_THEN, // keyword
    TC_CAL,
    TC_KEYWORD_END,
    TC_OF, //of
    TC_MY, //my
    TC_AND, //and ,
    TC_OR, // or
    TC_AFTER, //after as soon as
    TC_AT, //at with on to by , using for function
    TC_BULILDIN_WORD, // I me parent child answer
    TC_BULILDIN_FUN, // move to...
} TC_Explain;
@interface TC_Define : NSObject
@property (strong,nonatomic)NSString* word;
@property TC_Explain explain;
@property TC_ID right_match;
@end
