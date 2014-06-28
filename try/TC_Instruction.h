//
//  TC_Instruction.h
//  try
//
//  Created by tanshuo on 6/27/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "types.h"

@interface TC_Instruction : NSObject
@property TC_ID instruction_id;
@property TC_ID para_count;
@property id para1;
@property id para2;
@property id para3;
@property id para4;
@property id para5;
@property id para6;
@property (strong,nonatomic) NSMutableArray* branchs;

@end
