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
    TC_KEYWORD, // calculate,done
    TC_OF, //of
    TC_MY, //my
    TC_UNKNOWN,
    TC_BULILDIN_WORD,
    TC_BULILDIN_FUN,
} TC_Explain;
@interface TC_Define : NSObject
@property (strong,nonatomic)NSString* word;
@property TC_Explain explain;
@property TC_ID left_match;
@property TC_ID right_match;
@end
