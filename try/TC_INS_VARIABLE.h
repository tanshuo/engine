//
//  TC_INS_VARIABLE.h
//  try
//
//  Created by tanshuo on 7/9/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "TC_WORD_LAYER.h"

typedef enum{
    VAR_GLOBOL,
    VAR_STACK,
    VAR_BIND,
    VAR_SELF,
} TC_INS_VAR_LOCATION;

typedef enum{
    VAR_UNKNOWN,
    VAR_FLOAT,
    VAR_VECTOR2,
    VAR_VECTOR3,
    VAR_INT,
    VAR_OBJECT,
    VAR_STRING,
    VAR_OFF_SET,
} TC_INS_VAR_TYPE;

@interface TC_INS_VARIABLE : NSObject
@property BOOL solved;
@property BOOL borrow;
@property int argoffset;
@property TC_INS_VAR_LOCATION location;
@property TC_INS_VAR_TYPE type;
@property (strong,nonatomic) TC_WORD_LAYER* var;
@property void* addr;
@property id obj;

- (void)dealloc;
@end
