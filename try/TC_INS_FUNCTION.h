//
//  TC_INS_FUNCTION.h
//  try
//
//  Created by tanshuo on 7/9/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

//every vm will have a bind list and a difine list

typedef enum{
    FUN_BIND,
    FUN_DEFINE,
} TC_INS_FUNC_LOCATION;

@interface TC_INS_FUNCTION : NSObject
@property BOOL solved;
@property (strong,nonatomic) NSString* name; //function name
@property TC_INS_FUNC_LOCATION location;
@property SEL func;//if binded
@property int offset;//if defined
@property int right_match;
@end
