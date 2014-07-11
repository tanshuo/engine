//
//  TC_INS_OFFSET.h
//  try
//
//  Created by tanshuo on 7/9/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

typedef enum{
    MARK_LOGICAL_SOLVED,
    MARK_IF_END,
    MARK_WHILE_END,
    MARK_LOGICAL_END,
} TC_INS_MARK;

@interface TC_INS_OFFSET : NSObject
@property BOOL solved;
@property int offset;
@property int mark;
@property int extra;
@end
