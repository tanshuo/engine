//
//  TC_INS_VARIABLE.m
//  try
//
//  Created by tanshuo on 7/9/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import "TC_INS_VARIABLE.h"

@implementation TC_INS_VARIABLE

- (void)dealloc
{
    if(_borrow == NO)
        free(_addr);
}
@end
