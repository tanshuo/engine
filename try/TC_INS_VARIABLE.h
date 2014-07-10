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
} TC_INS_VAR_LOCATION;

typedef enum{
    VAR_FLOAT,
    VAR_VECTOR2,
    VAR_VECTOR3,
    VAR_INT,
} TC_INS_VAR_TYPE;

@interface TC_INS_VARIABLE : NSObject
@property BOOL solved;
@property TC_INS_VAR_LOCATION location;
@property TC_INS_VAR_TYPE type;
@property (strong,nonatomic) TC_WORD_LAYER* var;
@property void* addr;
@end
